import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../shared/widgets/app_scaffold.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/nik_kk_validation_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/ocr_ktp_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/selfie_verification_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/vehicles/presentation/screens/add_vehicle_screen.dart';
import '../features/vehicles/presentation/screens/vehicle_list_screen.dart';
import '../features/family/presentation/screens/family_list_screen.dart';
import '../features/quota/presentation/screens/quota_screen.dart';
import '../features/wallet/presentation/screens/topup_screen.dart';
import '../features/wallet/presentation/screens/wallet_screen.dart';
import '../features/transactions/presentation/screens/transaction_history_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/risk/presentation/screens/risk_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => _fadePage(
          state,
          const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _fadePage(
          state,
          const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _fadePage(
          state,
          const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => _fadePage(
          state,
          const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: '/auth/ocr-ktp',
        pageBuilder: (context, state) => _fadePage(
          state,
          const OcrKtpScreen(),
        ),
      ),
      GoRoute(
        path: '/auth/selfie',
        pageBuilder: (context, state) => _fadePage(
          state,
          const SelfieVerificationScreen(),
        ),
      ),
      GoRoute(
        path: '/auth/nik-kk',
        pageBuilder: (context, state) => _fadePage(
          state,
          const NikKkValidationScreen(),
        ),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => _fadePage(
              state,
              const HomeScreen(),
            ),
            routes: [
              GoRoute(
                path: 'quota',
                pageBuilder: (context, state) => _fadePage(
                  state,
                  const QuotaScreen(),
                ),
              ),
              GoRoute(
                path: 'risk',
                pageBuilder: (context, state) => _fadePage(
                  state,
                  const RiskScreen(),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/vehicles',
            pageBuilder: (context, state) => _fadePage(
              state,
              const VehicleListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'add',
                pageBuilder: (context, state) => _fadePage(
                  state,
                  const AddVehicleScreen(),
                ),
              ),
              GoRoute(
                path: 'family',
                pageBuilder: (context, state) => _fadePage(
                  state,
                  const FamilyListScreen(),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/wallet',
            pageBuilder: (context, state) => _fadePage(
              state,
              const WalletScreen(),
            ),
            routes: [
              GoRoute(
                path: 'topup',
                pageBuilder: (context, state) => _fadePage(
                  state,
                  const TopUpScreen(),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/transactions',
            pageBuilder: (context, state) => _fadePage(
              state,
              const TransactionHistoryScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => _fadePage(
              state,
              const ProfileScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});

CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
