import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/game/model/accessories.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/room.dart';
import 'package:kucing_oren/screens/chapter/chapter_screen.dart';
import 'package:kucing_oren/screens/room/room_geometry.dart';
import 'package:kucing_oren/screens/room/room_view.dart';
import 'package:kucing_oren/screens/settings/settings_screen.dart';
import 'package:kucing_oren/screens/shop/shop_screen.dart';
import 'package:kucing_oren/widgets/widgets.dart';

import '../test_helpers.dart';

/// Kamar di rute `/` seukuran desain 390×844.
Future<ProgressController> pumpRoom(
  WidgetTester tester, {
  ProgressController? progress,
  Size size = const Size(390, 844),
  Random Function()? random,
}) async {
  setScreenSize(tester, size);
  return pumpApp(
    tester,
    progress: progress ?? testProgressWith(),
    roomRandom: random,
  );
}

Finder itemView(RoomItemId id) =>
    find.byWidgetPredicate((w) => w is RoomItemView && w.id == id);

Finder kittyView(KittyId kitty) =>
    find.byWidgetPredicate((w) => w is KittyView && w.look.kitty == kitty);

/// Kotak kamar di layar dan geometrinya.
(Rect, RoomGeometry) roomOf(WidgetTester tester) {
  final rect = tester.getRect(find.byKey(const ValueKey('room-area')));
  return (rect, RoomGeometry(rect.size));
}

const allKitties = KittyId.values;

/// Semua barang ditaruh di posisi bawaannya.
Room fullRoom() {
  var room = Room();
  for (final item in shopItems) {
    room = room.buy(item.id);
  }
  return room;
}

void main() {
  group('titik merah', () {
    test('Toko: barang atau kucing yang belum dimiliki dan terjangkau', () {
      expect(shopHasAffordable(Home.initial, 0), isFalse);
      expect(shopHasAffordable(Home.initial, 49), isFalse);
      // Kardus Nyaman 50 koin.
      expect(shopHasAffordable(Home.initial, 50), isTrue);
      final full = Home(room: fullRoom(), kitties: allKitties);
      expect(shopHasAffordable(full, 99999), isFalse);
      expect(shopHasAffordable(Home(room: fullRoom()), 99999), isTrue);
    });

    test('Aksesoris: aksesoris yang belum dimiliki dan terjangkau', () {
      expect(accessoriesHaveAffordable(Home.initial, 49), isFalse);
      // Pita 50 koin.
      expect(accessoriesHaveAffordable(Home.initial, 50), isTrue);
      final all = Home(closet: AccessoryCloset(owned: AccessoryId.values));
      expect(accessoriesHaveAffordable(all, 99999), isFalse);
    });
  });

  group('posisi kucing', () {
    test('seed sama = posisi sama, seed lain = posisi lain', () {
      final a = kittySpots(allKitties, Random(1));
      expect(kittySpots(allKitties, Random(1)), a);
      expect(kittySpots(allKitties, Random(2)), isNot(a));
    });

    test('sembilan kucing di sembilan tempat berbeda', () {
      final spots = kittySpots(allKitties, Random(3));
      expect(spots.keys, unorderedEquals(allKitties));
      expect(spots.values.toSet(), hasLength(allKitties.length));
    });
  });

  group('kamar', () {
    testWidgets('kamar kosong: ajakan ke Toko dan dua bidang kosong', (
      tester,
    ) async {
      await pumpRoom(tester);
      expect(find.byType(RoomView), findsOneWidget);
      expect(find.text('Kamar masih sepi. Ke Toko, yuk!'), findsOneWidget);
      expect(find.text('Hiasan dinding?'), findsOneWidget);
      expect(find.text('Kasur, mungkin?'), findsOneWidget);
      await tester.tap(find.text('Kasur, mungkin?'));
      await settle(tester);
      expect(find.byType(ShopScreen), findsOneWidget);
    });

    testWidgets('kamar berisi: tanpa ajakan', (tester) async {
      await pumpRoom(
        tester,
        progress: testProgressWith(
          home: Home(room: Room().buy(RoomItemId.kasur)),
        ),
      );
      expect(find.text('Kamar masih sepi. Ke Toko, yuk!'), findsNothing);
      expect(find.text('Hiasan dinding?'), findsNothing);
    });

    testWidgets('header: chip koin, logo, dan total bintang', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpRoom(
        tester,
        progress: testProgressWith(best: {1: 3}, coins: 480),
      );
      expect(find.text('480'), findsOneWidget);
      expect(find.text('3/60', findRichText: true), findsOneWidget);
      expect(find.bySemanticsLabel('3 dari 60 bintang'), findsOneWidget);
      expect(find.bySemanticsLabel('Ginger Logic'), findsOneWidget);
      final chip = tester.getRect(find.byType(KoCoinChip));
      // Desain: header di top 50 = status bar 44 + 6; di test tanpa
      // status bar, 6 dari atas.
      expect(chip.left, closeTo(16, 0.5));
      expect(chip.top, closeTo(6, 4));
      semantics.dispose();
    });

    testWidgets('kamar mulai dari tepi atas sampai panel bawah', (
      tester,
    ) async {
      await pumpRoom(tester);
      final (room, geo) = roomOf(tester);
      expect(room.top, 0);
      expect(room.width, 390);
      // Panel bawah desain 192 (652–844), tanpa status bar bawah di test.
      expect(room.height, closeTo(652, 24));
      expect(geo.wall.height / room.height, closeTo(412 / 652, 1e-9));
    });

    testWidgets('barang yang ditaruh digambar di posisinya', (tester) async {
      final spot = Spot(0.2, 0.9);
      await pumpRoom(
        tester,
        progress: testProgressWith(
          home: Home(
            room: Room(owned: const [RoomItemId.kasur])
                .place(RoomItemId.kasur, spot),
          ),
        ),
      );
      final (room, geo) = roomOf(tester);
      final expected = geo
          .boxOf(roomItemOf(RoomItemId.kasur), spot)
          .shift(room.topLeft);
      final actual = tester.getRect(itemView(RoomItemId.kasur));
      expect(actual.topLeft, offsetMoreOrLessEquals(expected.topLeft));
      expect(actual.width, closeTo(expected.width, 0.01));
    });

    testWidgets('barang di Gudang tidak digambar', (tester) async {
      await pumpRoom(
        tester,
        progress: testProgressWith(
          home: Home(room: Room(owned: const [RoomItemId.bola])),
        ),
      );
      expect(itemView(RoomItemId.bola), findsNothing);
      expect(itemView(RoomItemId.mangkuk), findsOneWidget);
    });

    testWidgets('kucing yang dimiliki tampil dengan aksesorisnya', (
      tester,
    ) async {
      await pumpRoom(
        tester,
        progress: testProgressWith(
          home: Home(
            kitties: const [KittyId.salju],
            closet: AccessoryCloset(owned: const [AccessoryId.pita])
                .wear(KittyId.salju, AccessoryId.pita),
          ),
        ),
      );
      expect(kittyView(KittyId.oyen), findsOneWidget);
      expect(
        tester.widget<KittyView>(kittyView(KittyId.salju)).look.accessory,
        AccessoryId.pita,
      );
      expect(kittyView(KittyId.telon), findsNothing);
    });

    testWidgets(
      'sembilan kucing: semua di dalam area lantai, tidak satu titik',
      (tester) async {
        await pumpRoom(
          tester,
          progress: testProgressWith(home: Home(kitties: allKitties)),
        );
        final (room, geo) = roomOf(tester);
        final corners = <Offset>{};
        for (final kitty in allKitties) {
          final box = tester.getRect(kittyView(kitty)).shift(-room.topLeft);
          expect(box.left, greaterThanOrEqualTo(0), reason: '$kitty');
          expect(box.right, lessThanOrEqualTo(room.width), reason: '$kitty');
          expect(geo.feetOf(box), greaterThan(geo.floor.top), reason: '$kitty');
          expect(box.bottom, lessThanOrEqualTo(geo.floor.bottom + 0.01));
          corners.add(box.topLeft);
        }
        expect(corners, hasLength(allKitties.length));
      },
    );

    testWidgets('posisi kucing tetap selama kamar terbuka', (tester) async {
      await pumpRoom(
        tester,
        progress: testProgressWith(
          coins: 100,
          home: Home(kitties: const [KittyId.salju]),
        ),
      );
      final before = tester.getRect(kittyView(KittyId.salju));
      await tester.tap(find.text('Toko'));
      await settle(tester);
      await tester.binding.handlePopRoute();
      await settle(tester);
      expect(tester.getRect(kittyView(KittyId.salju)), before);
    });

    testWidgets('Main membuka peta babak', (tester) async {
      await pumpRoom(tester);
      await tester.tap(find.text('Main'));
      await settle(tester);
      expect(find.byType(ChapterView), findsOneWidget);
    });

    testWidgets('Toko, Aksesoris, dan Pengaturan', (tester) async {
      await pumpRoom(tester);
      await tester.tap(find.text('Toko'));
      await settle(tester);
      expect(
        tester.widget<ShopScreen>(find.byType(ShopScreen)).initialTab,
        ShopTab.items,
      );
      await tester.binding.handlePopRoute();
      await settle(tester);

      await tester.tap(find.text('Aksesoris'));
      await settle(tester);
      expect(
        tester.widget<ShopScreen>(find.byType(ShopScreen)).initialTab,
        ShopTab.accessories,
      );
      await tester.binding.handlePopRoute();
      await settle(tester);

      await tester.tap(find.text('Pengaturan'));
      await settle(tester);
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('tanpa titik merah kalau koin kurang', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpRoom(tester);
      expect(find.byKey(const ValueKey('room-dot-shop')), findsNothing);
      expect(find.byKey(const ValueKey('room-dot-accessories')), findsNothing);
      expect(find.bySemanticsLabel('Toko'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('titik merah hanya di tombol yang punya barang terjangkau', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpRoom(
        tester,
        progress: testProgressWith(
          coins: 99999,
          home: Home(closet: AccessoryCloset(owned: AccessoryId.values)),
        ),
      );
      expect(find.byKey(const ValueKey('room-dot-shop')), findsOneWidget);
      expect(find.byKey(const ValueKey('room-dot-accessories')), findsNothing);
      expect(
        find.bySemanticsLabel('Toko, ada yang baru terjangkau'),
        findsOneWidget,
      );
      semantics.dispose();
    });

    testWidgets('pembaca layar: kucing bisa diketuk', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpRoom(tester);
      expect(
        find.bySemanticsLabel('Oyen. Ketuk untuk lihat kartunya'),
        findsOneWidget,
      );
      semantics.dispose();
    });

    testWidgets('"Lihat di kamar" dari Toko menampilkan barang yang dibeli', (
      tester,
    ) async {
      setScreenSize(tester, const Size(390, 844));
      await pumpApp(
        tester,
        location: '/toko',
        progress: testProgressWith(coins: 100),
      );
      final card = find.byKey(const ValueKey('shop-item-kardus'));
      await tester.ensureVisible(card);
      await settle(tester);
      await tester.tap(card);
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('buy-confirm')));
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('buy-room')));
      await settle(tester);
      expect(find.byType(RoomView), findsOneWidget);
      final (room, geo) = roomOf(tester);
      final kardus = roomItemOf(RoomItemId.kardus);
      expect(
        tester.getRect(itemView(RoomItemId.kardus)).topLeft,
        offsetMoreOrLessEquals(
          geo.boxOf(kardus, kardus.defaultSpot).shift(room.topLeft).topLeft,
        ),
      );
    });
  });
}
