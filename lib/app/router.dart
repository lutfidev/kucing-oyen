import 'package:go_router/go_router.dart';

import '../gallery/gallery_board_screen.dart';
import '../gallery/gallery_oyen_screen.dart';
import '../gallery/gallery_screen.dart';
import '../screens/chapter/chapter_screen.dart';
import '../screens/closet/closet_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/level/level_screen.dart';
import 'routes.dart';

GoRouter createRouter({String initialLocation = AppRoutes.home}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
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
            ],
          ),
          GoRoute(
            path: 'kostum',
            builder: (context, state) => const ClosetScreen(),
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
