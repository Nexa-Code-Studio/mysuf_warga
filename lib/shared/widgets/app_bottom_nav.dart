import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final String location;

  const AppBottomNav({super.key, required this.location});

  int _indexFromLocation() {
    if (location.startsWith('/vehicles')) return 1;
    if (location.startsWith('/wallet')) return 2;
    if (location.startsWith('/transactions')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/vehicles');
        break;
      case 2:
        context.go('/wallet');
        break;
      case 3:
        context.go('/transactions');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = _indexFromLocation();
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (value) => _onTap(context, value),
      backgroundColor: Colors.white,
      indicatorColor: AppColors.primaryRed.withOpacity(0.12),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Beranda',
        ),
        NavigationDestination(
          icon: Icon(Icons.directions_car_outlined),
          selectedIcon: Icon(Icons.directions_car),
          label: 'Kendaraan',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_balance_wallet_outlined),
          selectedIcon: Icon(Icons.account_balance_wallet),
          label: 'Dompet',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'Riwayat',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}
