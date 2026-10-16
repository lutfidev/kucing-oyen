import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/theme.dart';
import 'progress_scope.dart';
import 'router.dart';
import 'routes.dart';

class KucingOrenApp extends StatefulWidget {
  const KucingOrenApp({
    super.key,
    required this.progress,
    this.initialLocation = AppRoutes.home,
  });

  /// Data level dan progres pemain, dibagikan ke semua layar.
  final ProgressController progress;
  final String initialLocation;

  @override
  State<KucingOrenApp> createState() => _KucingOrenAppState();
}

class _KucingOrenAppState extends State<KucingOrenApp> {
  late final GoRouter _router = createRouter(
    initialLocation: widget.initialLocation,
  );
  final ThemeData _theme = KoTheme.light();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProgressScope(
      progress: widget.progress,
      child: MaterialApp.router(
        title: 'Kucing Oren',
        debugShowCheckedModeBanner: false,
        theme: _theme,
        routerConfig: _router,
      ),
    );
  }
}
