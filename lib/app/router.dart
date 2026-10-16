import 'package:go_router/go_router.dart';

import '../gallery/gallery_screen.dart';
import '../screens/home/home_screen.dart';
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
          ),
        ],
      ),
    ],
  );
}
