import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../shared/widgets/app_scaffold.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/restricted_screen.dart';
import '../features/auth/presentation/screens/logout_processing_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/registration_processing_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/home/presentation/screens/spbu_nearby_screen.dart';
import '../features/verification/presentation/screens/subsidy_verification_screen.dart';
import '../features/vehicles/presentation/screens/add_vehicle_screen.dart';
import '../features/vehicles/presentation/screens/vehicle_detail_screen.dart';
import '../features/vehicles/presentation/screens/vehicle_list_screen.dart';
import '../features/family/presentation/screens/family_list_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/quota/presentation/screens/quota_screen.dart';
import '../features/wallet/presentation/screens/topup_screen.dart';
import '../features/wallet/presentation/screens/topup_status_screen.dart';
import '../features/wallet/presentation/screens/wallet_screen.dart';
import '../features/wallet/presentation/screens/qris_screen.dart';
import '../features/wallet/presentation/screens/transfer_screen.dart';
import '../features/transactions/presentation/screens/transaction_history_screen.dart';
import '../features/transactions/presentation/screens/transaction_detail_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/profile_detail_screen.dart';
import '../features/profile/presentation/screens/notification_settings_screen.dart';
import '../features/profile/presentation/screens/help_center_screen.dart';
import '../features/profile/presentation/screens/security_pin_screen.dart';
import '../features/profile/presentation/screens/update_nfc_screen.dart';
import '../features/risk/presentation/screens/risk_screen.dart';
import '../shared/models/vehicle.dart';

import '../features/auth/presentation/screens/ktp_capture_screen.dart';
import '../features/auth/presentation/screens/ocr_confirmation_screen.dart';
import '../features/auth/presentation/screens/selfie_capture_screen.dart';
import '../features/auth/presentation/screens/verification_result_screen.dart';
import '../features/auth/domain/models/ktp_data.dart';
import '../features/auth/domain/models/verification_result.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => _fadePage(state, const SplashScreen()),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) =>
            _fadePage(state, const OnboardingScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _fadePage(state, const LoginScreen()),
      ),
      GoRoute(
        path: '/restricted',
        pageBuilder: (context, state) => _fadePage(
          state,
          RestrictedScreen(
            reason: state.extra as String? ?? 'Akses Anda dibatasi oleh sistem.',
          ),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => _fadePage(
          state,
          RegisterScreen(
            initialStep:
                int.tryParse(state.uri.queryParameters['step'] ?? '1') ?? 1,
          ),
        ),
      ),
      GoRoute(
        path: '/register/processing',
        pageBuilder: (context, state) => _fadePage(
          state,
          RegistrationProcessingScreen(
            attemptId: state.uri.queryParameters['attempt_id'],
          ),
        ),
      ),
      GoRoute(
        path: '/logout-processing',
        pageBuilder: (context, state) =>
            _fadePage(state, const LogoutProcessingScreen()),
      ),
      GoRoute(
        path: '/verification',
        pageBuilder: (context, state) =>
            _fadePage(state, const SubsidyVerificationScreen()),
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) =>
            _fadePage(state, const NotificationsScreen()),
      ),
      GoRoute(
        path: '/auth/ktp-capture',
        pageBuilder: (context, state) =>
            _fadePage(state, const KtpCaptureScreen()),
      ),
      GoRoute(
        path: '/auth/ocr-confirm',
        pageBuilder: (context, state) => _fadePage(
          state,
          OcrConfirmationScreen(initialData: state.extra! as KtpData),
        ),
      ),
      GoRoute(
        path: '/auth/selfie-capture',
        pageBuilder: (context, state) =>
            _fadePage(state, const SelfieCaptureScreen()),
      ),
      GoRoute(
        path: '/auth/verification-result',
        pageBuilder: (context, state) => _fadePage(
          state,
          VerificationResultScreen(result: state.extra! as VerificationResult),
        ),
      ),
      GoRoute(path: '/auth/nik-kk', redirect: (_, __) => '/register?step=3'),
      GoRoute(path: '/auth/ocr-ktp', redirect: (_, _) => '/register?step=2'),
      GoRoute(path: '/auth/selfie', redirect: (_, _) => '/register?step=3'),
      GoRoute(path: '/auth/nik-kk', redirect: (_, _) => '/register?step=3'),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => _fadePage(
              state,
              HomeScreen(
                showVerifyNotice: state.uri.queryParameters['verify'] == '1',
              ),
            ),
            routes: [
              GoRoute(
                path: 'spbu',
                pageBuilder: (context, state) =>
                    _fadePage(state, const SpbuNearbyScreen()),
              ),
              GoRoute(
                path: 'quota',
                pageBuilder: (context, state) =>
                    _fadePage(state, const QuotaScreen()),
              ),
              GoRoute(
                path: 'risk',
                pageBuilder: (context, state) =>
                    _fadePage(state, const RiskScreen()),
              ),
            ],
          ),
          GoRoute(
            path: '/vehicles',
            pageBuilder: (context, state) =>
                _fadePage(state, const VehicleListScreen()),
            routes: [
              GoRoute(
                path: 'detail',
                pageBuilder: (context, state) => _fadePage(
                  state,
                  VehicleDetailScreen(vehicle: state.extra! as Vehicle),
                ),
              ),
              GoRoute(
                path: 'add',
                pageBuilder: (context, state) =>
                    _fadePage(state, const AddVehicleScreen()),
              ),
              GoRoute(
                path: 'family',
                pageBuilder: (context, state) =>
                    _fadePage(state, const FamilyListScreen()),
              ),
            ],
          ),
          GoRoute(
            path: '/wallet',
            pageBuilder: (context, state) =>
                _fadePage(state, const WalletScreen()),
            routes: [
              GoRoute(
                path: 'topup',
                pageBuilder: (context, state) =>
                    _fadePage(state, const TopUpScreen()),
                routes: [
                  GoRoute(
                    path: 'status',
                    pageBuilder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>;
                      return _fadePage(
                        state,
                        TopUpStatusScreen(
                          topupId: extra['id'] as String,
                          paymentLinkUrl: extra['payment_link_url'] as String,
                          amount: extra['amount'] as int,
                        ),
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'qris',
                pageBuilder: (context, state) =>
                    _fadePage(state, const QrisScreen()),
              ),
              GoRoute(
                path: 'transfer',
                pageBuilder: (context, state) =>
                    _fadePage(state, const TransferScreen()),
              ),
            ],
          ),
          GoRoute(
            path: '/transactions',
            pageBuilder: (context, state) =>
                _fadePage(state, const TransactionHistoryScreen()),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return _fadePage(state, TransactionDetailScreen(id: id));
                },
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                _fadePage(state, const ProfileScreen()),
            routes: [
              GoRoute(
                path: 'detail',
                pageBuilder: (context, state) =>
                    _fadePage(state, const ProfileDetailScreen()),
              ),
              GoRoute(
                path: 'notifications',
                pageBuilder: (context, state) =>
                    _fadePage(state, const NotificationSettingsScreen()),
              ),
              GoRoute(
                path: 'help',
                pageBuilder: (context, state) =>
                    _fadePage(state, const HelpCenterScreen()),
              ),
              GoRoute(
                path: 'pin',
                pageBuilder: (context, state) =>
                    _fadePage(state, const SecurityPinScreen()),
              ),
              GoRoute(
                path: 'update-nfc',
                pageBuilder: (context, state) =>
                    _fadePage(state, const UpdateNfcScreen()),
              ),
            ],
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
    transitionsBuilder: (_, animation, _, child) {
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
