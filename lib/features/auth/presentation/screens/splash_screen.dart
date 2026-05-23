import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/auth_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1200), () async {
      if (mounted) {
        final attemptId = await _authRepository
            .loadPendingRegistrationAttemptId();
        if (!mounted) {
          return;
        }
        if (attemptId != null && attemptId.isNotEmpty) {
          context.go(
            '/register/processing?attempt_id=${Uri.encodeComponent(attemptId)}',
          );
          return;
        }
        final accessToken = await _authRepository.loadAccessToken();
        if (!mounted) {
          return;
        }
        if (accessToken != null && accessToken.isNotEmpty) {
          context.go('/home');
          return;
        }
        context.go('/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryRed,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_gas_station,
                color: AppColors.primaryRed,
                size: 42,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'MySuF',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Smart Subsidized Fuel Ecosystem',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
