import '../gallery/gallery_ui_v2_screen.dart';

import 'dart:math';

import 'package:flutter/widgets.dart';

import 'package:go_router/go_router.dart';

import '../gallery/gallery_board_screen.dart';
import '../gallery/gallery_kitty_screen.dart';
import '../gallery/gallery_oyen_screen.dart';
import '../gallery/gallery_screen.dart';
import '../gallery/gallery_sound_screen.dart';
import '../gallery/gallery_v2_screen.dart';
import '../screens/chapter/chapter_screen.dart';
import '../screens/level/level_screen.dart';
import '../screens/room/room_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/shop/shop_screen.dart';
import '../game/render/v2/art_pack.dart';
import 'routes.dart';

/// [roomRandom] membuat pengacak posisi kucing tiap kamar dibuka; null =
/// acak sungguhan (test memberi seed supaya gambarnya selalu sama).
/// [roomLife] = kucing kamar bergerak sendiri.
GoRouter createRouter({
  String initialLocation = AppRoutes.home,
  Random Function()? roomRandom,
  bool roomLife = true,
  WidgetBuilder? homeBuilder,
  Future<ArtPack> Function()? loadShopArt,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    // Rute yang tidak ada (mis. `/kostum` Lemari Kostum lama) membuka kamar.
    onException: (context, state, router) => router.go(AppRoutes.home),
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) =>
            homeBuilder?.call(context) ??
            RoomScreen(random: roomRandom?.call(), life: roomLife),
        routes: [
          GoRoute(
            path: 'galeri',
            builder: (context, state) => const GalleryScreen(),
            routes: [
              GoRoute(
                path: 'ui-v2',
                builder: (context, state) => const GalleryUiV2Screen(),
              ),
              GoRoute(
                path: 'aset-v2',
                builder: (context, state) => const GalleryV2Screen(),
              ),
              GoRoute(
                path: 'papan',
                builder: (context, state) => const GalleryBoardScreen(),
              ),
              GoRoute(
                path: 'oyen',
                builder: (context, state) => const GalleryOyenScreen(),
              ),
              GoRoute(
                path: 'kucing',
                builder: (context, state) => const GalleryKittyScreen(),
              ),
              GoRoute(
                path: 'gerak',
                builder: (context, state) => const GalleryMotionScreen(),
              ),
              GoRoute(
                path: 'suara',
                builder: (context, state) => const GallerySoundScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'toko',
            builder: (context, state) => ShopScreen(
              loadArt: loadShopArt,
              initialTab: ShopTab.parse(state.uri.queryParameters['tab']),
            ),
          ),
          GoRoute(
            path: 'pengaturan',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'babak/:chapter',
            builder: (context, state) => ChapterScreen(
              chapter: _number(state, 'chapter'),
              walkFrom: int.tryParse(state.uri.queryParameters['dari'] ?? ''),
              intro: state.uri.queryParameters['baru'] == '1',
            ),
            routes: [
              GoRoute(
                path: 'level/:id',
                builder: (context, state) => LevelScreen(
                  chapter: _number(state, 'chapter'),
                  levelId: _number(state, 'id'),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Angka di path, atau null kalau bukan angka.
int? _number(GoRouterState state, String name) =>
    int.tryParse(state.pathParameters[name] ?? '');
