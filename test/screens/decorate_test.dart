import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/room.dart';
import 'package:kucing_oren/screens/room/decorate.dart';
import 'package:kucing_oren/screens/room/kitty_card.dart';
import 'package:kucing_oren/screens/room/room_view.dart';

import '../test_helpers.dart';
import 'room_fixtures.dart';

/// Kamar dengan kasur, lukisan, dan bola di posisi bawaan, plus jam di
/// Gudang.
Home decoratedHome() {
  var room = Room();
  for (final id in [RoomItemId.kasur, RoomItemId.lukisan, RoomItemId.bola]) {
    room = room.buy(id);
  }
  room = room.buy(RoomItemId.jam).store(RoomItemId.jam);
  return Home(room: room, kitties: const [KittyId.salju]);
}

Future<ProgressController> pumpDecorating(
  WidgetTester tester, {
  ProgressController? progress,
  Size size = const Size(390, 844),
}) async {
  final p = await pumpRoom(
    tester,
    size: size,
    progress: progress ?? withNeeds(const {}, home: decoratedHome()),
  );
  await tester.tap(find.text('Hias'));
  await tester.pumpAndSettle();
  return p;
}

/// Menyeret [target] sejauh [offset] dalam beberapa langkah dengan satu
/// bingkai di antaranya, seperti jari sungguhan (barang yang terangkat
/// dibangun ulang di tengah seretan).
Future<void> dragFramed(
  WidgetTester tester,
  Finder target,
  Offset offset,
) async {
  final gesture = await tester.startGesture(tester.getCenter(target));
  const steps = 8;
  for (var i = 0; i < steps; i++) {
    await gesture.moveBy(offset / steps.toDouble());
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
}

/// Kotak barang [id] di koordinat kamar.
Rect boxIn(WidgetTester tester, RoomItemId id) {
  final (room, _) = roomOf(tester);
  return tester.getRect(itemView(id)).shift(-room.topLeft);
}

void main() {
  testWidgets('tombol Hias hanya kalau ada barang selain mangkuk', (
    tester,
  ) async {
    await pumpRoom(tester);
    expect(find.text('Hias'), findsNothing);
    await pumpRoom(
      tester,
      progress: testProgressWith(
        home: Home(room: Room(owned: const [RoomItemId.bola])),
      ),
    );
    // Barang di Gudang tetap bisa diambil lewat Hias.
    expect(find.text('Hias'), findsOneWidget);
    expect(find.text('Kamar masih sepi. Ke Toko, yuk!'), findsNothing);
  });

  testWidgets('Hias: garis putus-putus, baki Gudang, dan Selesai', (
    tester,
  ) async {
    await pumpDecorating(tester);
    expect(find.text('Seret barang ke tempat baru'), findsOneWidget);
    expect(find.text('Gudang'), findsOneWidget);
    expect(find.text('1 barang'), findsOneWidget);
    expect(find.text('Selesai'), findsOneWidget);
    expect(find.text('Area lantai'), findsOneWidget);
    expect(find.text('Area dinding'), findsOneWidget);
    expect(find.text('Main'), findsNothing);
    expect(find.text('Hias'), findsNothing);
    await tester.tap(kittyView(KittyId.oyen), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(KittyCard), findsNothing);
  });

  testWidgets('kamar tidak berubah ukuran saat masuk mode hias', (
    tester,
  ) async {
    await pumpRoom(
      tester,
      progress: withNeeds(const {}, home: decoratedHome()),
    );
    final before = roomOf(tester).$1;
    final kasur = tester.getRect(itemView(RoomItemId.kasur));
    await tester.tap(find.text('Hias'));
    await tester.pumpAndSettle();
    expect(roomOf(tester).$1, before);
    expect(tester.getRect(itemView(RoomItemId.kasur)), kasur);
  });

  testWidgets('seret barang lantai mengubah posisinya dan menyimpannya', (
    tester,
  ) async {
    final progress = await pumpDecorating(tester);
    final (_, geo) = roomOf(tester);
    final start = boxIn(tester, RoomItemId.kasur);
    await dragFramed(tester, itemView(RoomItemId.kasur), const Offset(-40, 30));
    await tester.pumpAndSettle();
    final expected = geo.spotFor(
      roomItemOf(RoomItemId.kasur),
      start.topLeft + const Offset(-40, 30),
    );
    final spot = progress.home.room.spotOf(RoomItemId.kasur)!;
    expect(spot.x, closeTo(expected.x, 0.001));
    expect(spot.y, closeTo(expected.y, 0.001));
    expect(
      boxIn(tester, RoomItemId.kasur).topLeft,
      offsetMoreOrLessEquals(start.topLeft + const Offset(-40, 30)),
    );
  });

  testWidgets('seret tidak bisa keluar zonanya', (tester) async {
    final progress = await pumpDecorating(tester);
    final (_, geo) = roomOf(tester);
    await dragFramed(
      tester,
      itemView(RoomItemId.lukisan),
      const Offset(0, 400),
    );
    await tester.pumpAndSettle();
    expect(progress.home.room.spotOf(RoomItemId.lukisan)!.y, 1);
    expect(
      boxIn(tester, RoomItemId.lukisan).bottom,
      lessThanOrEqualTo(geo.wall.bottom),
    );
  });

  testWidgets('lepas di atas baki memasukkan barang ke Gudang', (tester) async {
    final progress = await pumpDecorating(tester);
    final tray = tester.getRect(find.byType(StorageTray));
    final ball = tester.getCenter(itemView(RoomItemId.bola));
    await dragFramed(tester, itemView(RoomItemId.bola), tray.center - ball);
    await tester.pumpAndSettle();
    expect(progress.home.room.isPlaced(RoomItemId.bola), isFalse);
    expect(progress.home.room.owns(RoomItemId.bola), isTrue);
    expect(find.text('2 barang'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(StorageTray),
        matching: find.text('Bola Benang'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('mangkuk tidak bisa masuk Gudang', (tester) async {
    final progress = await pumpDecorating(tester);
    final tray = tester.getRect(find.byType(StorageTray));
    final bowl = tester.getCenter(itemView(RoomItemId.mangkuk));
    await dragFramed(tester, itemView(RoomItemId.mangkuk), tray.center - bowl);
    await tester.pumpAndSettle();
    expect(progress.home.room.isPlaced(RoomItemId.mangkuk), isTrue);
  });

  testWidgets('ketuk barang di Gudang menaruhnya di posisi bawaan', (
    tester,
  ) async {
    final progress = await pumpDecorating(tester);
    await tester.tap(find.text('Jam Kucing'));
    await tester.pumpAndSettle();
    expect(
      progress.home.room.spotOf(RoomItemId.jam),
      roomItemOf(RoomItemId.jam).defaultSpot,
    );
    expect(itemView(RoomItemId.jam), findsOneWidget);
    expect(
      find.text('Gudangnya kosong. Semua barang sudah dipajang, Oyen bangga.'),
      findsOneWidget,
    );
  });

  testWidgets('Selesai: pujian dan +5 Senang untuk semua kucing', (
    tester,
  ) async {
    final progress = await pumpDecorating(
      tester,
      progress: withNeeds({
        KittyId.oyen: (80, 50),
        KittyId.salju: (80, 40),
      }, home: decoratedHome()),
    );
    await tester.tap(find.text('Selesai'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Kamar makin cakep!'), findsOneWidget);
    expect(find.text('+5 Senang untuk semua kucing'), findsOneWidget);
    expect(progress.catNeeds(KittyId.oyen).joy, 55);
    expect(progress.catNeeds(KittyId.salju).joy, 45);
    expect(find.text('Main'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Kamar makin cakep!'), findsNothing);
  });

  testWidgets('kurangi gerak: pujian tampil diam selama waktunya', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpDecorating(tester);
    await tester.tap(find.text('Selesai'));
    for (var i = 0; i < 22; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Kamar makin cakep!'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Kamar makin cakep!'), findsNothing);
  });

  testWidgets('menghias lagi dalam sejam: pujian tanpa bonus', (tester) async {
    final progress = await pumpDecorating(
      tester,
      progress: withNeeds({KittyId.oyen: (80, 50)}, home: decoratedHome()),
    );
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hias'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Selesai'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Kamar makin cakep!'), findsOneWidget);
    expect(find.text('+5 Senang untuk semua kucing'), findsNothing);
    expect(progress.catNeeds(KittyId.oyen).joy, 55);
    await tester.pumpAndSettle();
  });

  testWidgets('ketukan ganda Selesai hanya memberi satu bonus', (tester) async {
    final progress = await pumpDecorating(
      tester,
      progress: withNeeds({KittyId.oyen: (80, 50)}, home: decoratedHome()),
    );
    final done = find.text('Selesai');
    await tester.tap(done);
    await tester.tap(done, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(progress.catNeeds(KittyId.oyen).joy, 55);
  });

  testWidgets('tombol kembali sistem saat menghias = Selesai', (tester) async {
    final progress = await pumpDecorating(
      tester,
      progress: withNeeds({KittyId.oyen: (80, 50)}, home: decoratedHome()),
    );
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(RoomView), findsOneWidget);
    expect(find.text('Kamar makin cakep!'), findsOneWidget);
    expect(find.text('Main'), findsOneWidget);
    expect(progress.catNeeds(KittyId.oyen).joy, 55);
    await tester.pumpAndSettle();
  });

  testWidgets('Hias menutup kartu kucing yang terbuka', (tester) async {
    await pumpRoom(
      tester,
      progress: withNeeds(const {}, home: decoratedHome()),
    );
    await tester.tap(kittyView(KittyId.salju));
    await tester.pumpAndSettle();
    expect(find.byType(KittyCard), findsOneWidget);
    // Kartu menutupi tombol Hias: tutup lewat latar, lalu masuk mode hias.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hias'));
    await tester.pumpAndSettle();
    expect(find.byType(KittyCard), findsNothing);
  });

  testWidgets('tata letak tersimpan sesudah aplikasi dibuka ulang', (
    tester,
  ) async {
    final progress = await pumpDecorating(tester);
    await dragFramed(tester, itemView(RoomItemId.kasur), const Offset(-40, 30));
    await tester.pumpAndSettle();
    final spot = progress.home.room.spotOf(RoomItemId.kasur);
    final reloaded = await ProgressController.load(
      levels: testLevels,
      store: progress.store,
    );
    expect(reloaded.home.room.spotOf(RoomItemId.kasur), spot);
  });

  testWidgets('pembaca layar: barang punya aksi Simpan ke Gudang', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final progress = await pumpDecorating(tester);
    tester.semantics.customAction(
      find.semantics.byLabel('Bola Benang'),
      const CustomSemanticsAction(label: 'Simpan ke Gudang'),
    );
    await tester.pumpAndSettle();
    expect(progress.home.room.isPlaced(RoomItemId.bola), isFalse);
    expect(find.bySemanticsLabel('Taruh Bola Benang di kamar'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('mode hias di 360×640 teks 130% tanpa overflow', (tester) async {
    setTextScale(tester, 1.3);
    await pumpDecorating(tester, size: const Size(360, 640));
    expect(tester.takeException(), isNull);
    expect(find.text('Gudang'), findsOneWidget);
  });
}
