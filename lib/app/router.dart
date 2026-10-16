import 'package:go_router/go_router.dart';

import '../gallery/gallery_board_screen.dart';
import '../gallery/gallery_oyen_screen.dart';
import '../gallery/gallery_screen.dart';
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
            path: 'level/:id',
            builder: (context, state) => LevelScreen(
              levelId: int.tryParse(state.pathParameters['id'] ?? ''),
            ),
          ),
        ],
      ),
    ],
  );
}
