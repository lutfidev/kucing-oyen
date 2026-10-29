import 'dart:math';

import 'package:go_router/go_router.dart';

import '../gallery/gallery_board_screen.dart';
import '../gallery/gallery_kitty_screen.dart';
import '../gallery/gallery_oyen_screen.dart';
import '../gallery/gallery_screen.dart';
import '../gallery/gallery_sound_screen.dart';
import '../screens/chapter/chapter_screen.dart';
import '../screens/closet/closet_screen.dart';
import '../screens/level/level_screen.dart';
import '../screens/room/room_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/shop/shop_screen.dart';
import 'routes.dart';

/// [roomRandom] membuat pengacak posisi kucing tiap kamar dibuka; null =
/// acak sungguhan (test memberi seed supaya gambarnya selalu sama).
GoRouter createRouter({
  String initialLocation = AppRoutes.home,
  Random Function()? roomRandom,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => RoomScreen(random: roomRandom?.call()),
        routes: [
          GoRoute(
            path: 'galeri',
            builder: (context, state) => const GalleryScreen(),
            routes: [
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
                path: 'suara',
                builder: (context, state) => const GallerySoundScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'kostum',
            builder: (context, state) => const ClosetScreen(),
          ),
          GoRoute(
            path: 'toko',
            builder: (context, state) => ShopScreen(
              initialTab: ShopTab.parse(state.uri.queryParameters['tab']),
            ),
          ),
          GoRoute(
            path: 'pengaturan',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'babak/:chapter',
            builder: (context, state) =>
                ChapterScreen(chapter: _number(state, 'chapter')),
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
