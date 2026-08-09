import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_bottom_nav.dart';

class BottomNavNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void setVisible(bool visible) {
    state = visible;
  }
}

final bottomNavVisibleProvider = NotifierProvider<BottomNavNotifier, bool>(BottomNavNotifier.new);

class AppScaffold extends ConsumerWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    const mainTabs = {
      '/home',
      '/wallet',
      '/transactions',
      '/profile',
    };
    final showBottomNav = mainTabs.contains(location);
    final isVisible = ref.watch(bottomNavVisibleProvider);

    return Scaffold(
      body: Stack(
        children: [
          child,
          if (showBottomNav)
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedSlide(
                offset: isVisible ? Offset.zero : const Offset(0, 1),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: AppBottomNav(location: location),
              ),
            ),
        ],
      ),
    );
  }
}
