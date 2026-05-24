import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/mock_providers.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../data/auth_repository.dart';

class LogoutProcessingScreen extends ConsumerStatefulWidget {
  const LogoutProcessingScreen({super.key});

  @override
  ConsumerState<LogoutProcessingScreen> createState() => _LogoutProcessingScreenState();
}

class _LogoutProcessingScreenState extends ConsumerState<LogoutProcessingScreen> {
  static const _delay = Duration(milliseconds: 1400);
  Timer? _timer;
  final _authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    _performLogout();
  }

  Future<void> _performLogout() async {
    try {
      // 1. Clear secure tokens and session cookies from secure storage
      await _authRepository.clearSession();

      // 2. Invalidate all sensitive global Riverpod caches to prevent state leaks across accounts
      ref.invalidate(profileProvider);
      ref.invalidate(quotaProvider);
      ref.invalidate(vehiclesProvider);
      ref.invalidate(familyProvider);
      ref.invalidate(transactionsProvider);
      ref.invalidate(riskProvider);
      ref.invalidate(notificationsProvider);
    } catch (_) {
      // Ignore errors during cleanup
    }
    
    _timer = Timer(_delay, () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: AppColors.primaryRed,
                ),
                const SizedBox(height: 16),
                Text(
                  'Keluar akun...',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mohon tunggu sebentar.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
