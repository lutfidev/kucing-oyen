import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kucing_oren/app/progress_scope.dart';
import 'package:kucing_oren/app/routes.dart';
import 'package:kucing_oren/game/model/home.dart';
import 'package:kucing_oren/game/model/home_items.dart';
import 'package:kucing_oren/game/model/kitties.dart';
import 'package:kucing_oren/game/model/room.dart';
import 'package:kucing_oren/game/model/snacks.dart';
import 'package:kucing_oren/screens/home/home_screen.dart';
import 'package:kucing_oren/screens/shop/shop_screen.dart';

import '../test_helpers.dart';

/// Toko dengan saldo [coins] dan isi rumah [home].
Future<ProgressController> pumpShop(
  WidgetTester tester, {
  int coins = 0,
  Home? home,
  ShopTab tab = ShopTab.items,
}) async {
  setScreenSize(tester, const Size(390, 844));
  final progress = await pumpApp(
    tester,
    location: AppRoutes.shop(tab: tab),
    progress: testProgressWith(coins: coins, home: home),
  );
  await settle(tester);
  return progress;
}

/// Menggulir kartu [key] ke layar lalu mengetuknya.
Future<void> tapCard(WidgetTester tester, String key) async {
  final card = find.byKey(ValueKey(key));
  await tester.ensureVisible(card);
  await settle(tester);
  await tester.tap(card);
  await settle(tester);
}

void main() {
  group('tab Barang', () {
    testWidgets('kartu menampilkan harga, Punyamu, dan koin kurang', (
      tester,
    ) async {
      await pumpShop(
        tester,
        coins: 100,
        home: Home(room: Room(owned: const [RoomItemId.karpet])),
      );
      expect(find.text('Kardus Nyaman'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);
      expect(find.text('Punyamu'), findsOneWidget);
      expect(find.text('Koin kurang'), findsWidgets);
    });

    testWidgets('beli barang lewat sheet konfirmasi', (tester) async {
      final progress = await pumpShop(tester, coins: 100);
      await tapCard(tester, 'shop-item-kardus');
      expect(find.text('Kardus Nyaman'), findsWidgets);
      expect(
        find.text('Yang dipilih kardusnya, bukan isinya.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Beli · 50 koin'));
      await settle(tester);
      expect(find.text('Kardus Nyaman jadi punyamu!'), findsOneWidget);
      expect(progress.coins, 50);
      expect(progress.home.room.owns(RoomItemId.kardus), isTrue);

      await tester.tap(find.text('Lihat di kamar'));
      await settle(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('koin pas cukup tetap bisa beli', (tester) async {
      final progress = await pumpShop(tester, coins: 50);
      await tapCard(tester, 'shop-item-kardus');
      await tester.tap(find.text('Beli · 50 koin'));
      await settle(tester);
      expect(progress.coins, 0);
      expect(progress.home.room.owns(RoomItemId.kardus), isTrue);
    });

    testWidgets('koin kurang: sheet tanpa tombol beli', (tester) async {
      final progress = await pumpShop(tester, coins: 10);
      await tapCard(tester, 'shop-item-kardus');
      expect(find.text('Koin kurang · 40'), findsOneWidget);
      expect(find.text('Beli · 50 koin'), findsNothing);
      expect(progress.coins, 10);

      await tester.tap(find.text('Nanti dulu'));
      await settle(tester);
      expect(find.text('Koin kurang · 40'), findsNothing);
    });

    testWidgets('dua ketukan beli hanya memotong sekali', (tester) async {
      final progress = await pumpShop(tester, coins: 100);
      await tapCard(tester, 'shop-item-kardus');
      final buy = find.text('Beli · 50 koin');
      await tester.tap(buy);
      await tester.tap(buy, warnIfMissed: false);
      await settle(tester);
      expect(progress.coins, 50);
    });

    testWidgets('barang yang dimiliki tidak membuka sheet', (tester) async {
      await pumpShop(
        tester,
        coins: 100,
        home: Home(room: Room(owned: const [RoomItemId.kardus])),
      );
      await tapCard(tester, 'shop-item-kardus');
      expect(find.text('Nanti dulu'), findsNothing);
    });

    testWidgets('sheet ditutup oleh tombol kembali sistem', (tester) async {
      await pumpShop(tester, coins: 100);
      await tapCard(tester, 'shop-item-kardus');
      expect(find.text('Nanti dulu'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await settle(tester);
      expect(find.text('Nanti dulu'), findsNothing);
      expect(find.byType(ShopScreen), findsOneWidget);
    });

    testWidgets('pembaca layar: label kartu per keadaan', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpShop(
        tester,
        coins: 100,
        home: Home(room: Room(owned: const [RoomItemId.karpet])),
      );
      expect(find.bySemanticsLabel('Kardus Nyaman, 50 koin'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Karpet Bulat, sudah punyamu'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Akuarium, 600 koin, koin kurang'),
        findsOneWidget,
      );
      semantics.dispose();
    });
  });

  group('tab Kucing', () {
    testWidgets('tab berganti isi', (tester) async {
      await pumpShop(tester, coins: 500);
      expect(find.text('Kardus Nyaman'), findsOneWidget);

      await tester.tap(find.text('Kucing'));
      await settle(tester);
      expect(find.text('Kardus Nyaman'), findsNothing);
      expect(find.text('Salju'), findsOneWidget);
      expect(
        find.text(
          'Semua kucing tinggal sekamar dengan Oyen. Oyen setuju. '
          'Kayaknya.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Makanan'));
      await settle(tester);
      expect(find.text('Salju'), findsNothing);
      expect(find.text('Susu'), findsOneWidget);
    });

    testWidgets('adopsi kucing lewat sheet', (tester) async {
      final progress = await pumpShop(tester, coins: 400, tab: ShopTab.kitties);
      // Salju dan Kopi Susu sama-sama 300 koin.
      expect(find.text('Adopsi · 300'), findsNWidgets(2));
      await tapCard(tester, 'shop-kitty-salju');
      expect(
        find.text('Putih bersih. Bertahan bersih sampai ketemu kardus.'),
        findsWidgets,
      );

      await tester.tap(find.text('Beli · 300 koin'));
      await settle(tester);
      expect(find.text('Salju pindah ke kamar!'), findsOneWidget);
      expect(progress.coins, 100);
      expect(progress.home.ownsKitty(KittyId.salju), isTrue);

      await tester.tap(find.byKey(const ValueKey('buy-close')));
      await settle(tester);
      expect(find.text('Tinggal di kamar'), findsOneWidget);
    });

    testWidgets('koin kurang menampilkan selisih', (tester) async {
      await pumpShop(tester, coins: 100, tab: ShopTab.kitties);
      // Salju dan Kopi Susu sama-sama 300 koin.
      expect(find.text('Kurang 200 koin'), findsNWidgets(2));
      expect(find.text('Adopsi · 300'), findsNothing);
    });

    testWidgets('pembaca layar: kartu kucing per keadaan', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpShop(
        tester,
        coins: 300,
        home: Home(kitties: const [KittyId.arang]),
        tab: ShopTab.kitties,
      );
      expect(find.bySemanticsLabel('Salju, 300 koin'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Arang, sudah tinggal di kamar'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Kembang, 700 koin, koin kurang'),
        findsOneWidget,
      );
      semantics.dispose();
    });
  });

  group('tab Makanan', () {
    testWidgets('beli camilan langsung menambah stok', (tester) async {
      final progress = await pumpShop(tester, coins: 100, tab: ShopTab.snacks);
      expect(find.text('Stok: 0'), findsWidgets);
      await tester.tap(find.byKey(const ValueKey('shop-snack-susu')));
      await settle(tester);
      expect(progress.coins, 85);
      expect(progress.home.pantry.countOf(SnackId.susu), 1);
      expect(find.text('Stok: 1'), findsOneWidget);
    });

    testWidgets('camilan bisa dibeli berulang, sekali potong per ketukan', (
      tester,
    ) async {
      final progress = await pumpShop(tester, coins: 100, tab: ShopTab.snacks);
      final buy = find.byKey(const ValueKey('shop-snack-susu'));
      await tester.tap(buy);
      await tester.tap(buy);
      await settle(tester);
      expect(progress.coins, 70);
      expect(progress.home.pantry.countOf(SnackId.susu), 2);
      expect(find.text('Stok: 2'), findsOneWidget);
    });

    testWidgets('stok penuh tidak menambah dan tidak memotong koin', (
      tester,
    ) async {
      final progress = await pumpShop(
        tester,
        coins: 100,
        home: Home(pantry: Pantry(const {SnackId.susu: maxSnackStock})),
        tab: ShopTab.snacks,
      );
      await tester.tap(find.byKey(const ValueKey('shop-snack-susu')));
      await settle(tester);
      expect(progress.coins, 100);
      expect(progress.home.pantry.countOf(SnackId.susu), maxSnackStock);
    });

    testWidgets('koin kurang: tombol camilan mati', (tester) async {
      final semantics = tester.ensureSemantics();
      final progress = await pumpShop(tester, coins: 5, tab: ShopTab.snacks);
      expect(
        find.bySemanticsLabel('Beli Susu seharga 15 koin, koin kurang'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('shop-snack-susu')));
      await settle(tester);
      expect(progress.coins, 5);
      expect(progress.home.pantry.countOf(SnackId.susu), 0);
      semantics.dispose();
    });
  });
}
