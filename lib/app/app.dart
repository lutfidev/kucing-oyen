import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/theme.dart';
import 'router.dart';
import 'routes.dart';

class KucingOrenApp extends StatefulWidget {
  const KucingOrenApp({super.key, this.initialLocation = AppRoutes.home});

  final String initialLocation;

  @override
  State<KucingOrenApp> createState() => _KucingOrenAppState();
}

class _KucingOrenAppState extends State<KucingOrenApp> {
  late final GoRouter _router = createRouter(
    initialLocation: widget.initialLocation,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kucing Oren',
      debugShowCheckedModeBanner: false,
      theme: KoTheme.light(),
      routerConfig: _router,
    );
  }
}
