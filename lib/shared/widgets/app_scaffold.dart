import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_bottom_nav.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    const mainTabs = {
      '/home',
      '/vehicles',
      '/wallet',
      '/transactions',
      '/profile',
    };
    final showBottomNav = mainTabs.contains(location);
    return Scaffold(
      body: child,
      bottomNavigationBar:
          showBottomNav ? AppBottomNav(location: location) : null,
    );
  }
}
