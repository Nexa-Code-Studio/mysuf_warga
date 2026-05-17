import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/quota.dart';
import '../../../../shared/providers/mock_providers.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_pill.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final bool showVerifyNotice;

  const HomeScreen({super.key, this.showVerifyNotice = false});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late bool _showVerifyNotice;
  bool _didShowVerifyPopup = false;

  @override
  void initState() {
    super.initState();
    _showVerifyNotice = widget.showVerifyNotice;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_showVerifyNotice && !_didShowVerifyPopup) {
      _didShowVerifyPopup = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showVerifyPopup(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final quota = ref.watch(quotaProvider);
    final isVerified = false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(profileProvider);
            ref.invalidate(quotaProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              _Header(profile: profile),
              const SizedBox(height: 16),
              if (!isVerified) ...[
                _VerifyInlineCard(
                  onVerify: () => context.go('/register?step=2'),
                ),
                const SizedBox(height: 16),
              ],
              quota.when(
                data: (data) => _QuotaCard(quota: data),
                loading: () => const LoadingSkeleton(height: 170),
                error: (_, __) => ErrorState(
                  title: 'Gagal memuat kuota',
                  message: 'Tarik untuk memuat ulang data kuota.',
                  onRetry: () => ref.invalidate(quotaProvider),
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Aksi Cepat'),
              const SizedBox(height: 12),
              _QuickActions(),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'SPBU Terdekat',
                actionLabel: 'Lihat Semua',
                onAction: () {},
              ),
              const SizedBox(height: 12),
              const _StationCard(
                name: 'SPBU 31.001 Sudirman',
                distance: '0.8 km dari lokasi Anda',
              ),
              const SizedBox(height: 10),
              const _StationCard(
                name: 'SPBU 31.002 Gatot Subroto',
                distance: '1.4 km dari lokasi Anda',
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Transaksi Terkini',
                actionLabel: 'Semua',
                onAction: () => context.go('/transactions'),
              ),
              const SizedBox(height: 12),
              const _RecentTransactionCard(
                title: 'Pertalite - SPBU 31.001',
                subtitle: 'Hari ini, 08:24',
                amount: '- Rp 150.000',
                amountColor: AppColors.primaryRed,
              ),
              const SizedBox(height: 10),
              const _RecentTransactionCard(
                title: 'Pertamax - SPBU 31.002',
                subtitle: 'Kemarin, 19:05',
                amount: '- Rp 280.000',
                amountColor: AppColors.primaryRed,
              ),
              const SizedBox(height: 10),
              const _RecentTransactionCard(
                title: 'Top Up Dompet',
                subtitle: 'Kemarin, 12:45',
                amount: '+ Rp 500.000',
                amountColor: AppColors.success,
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Status Risiko',
                actionLabel: 'Detail',
                onAction: () => context.go('/home/risk'),
              ),
              const SizedBox(height: 12),
              const _RiskCard(),
            ]
                .animate(interval: 70.ms)
                .fadeIn(duration: 300.ms)
                .moveY(begin: 8, end: 0),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AsyncValue profile;

  const _Header({required this.profile});

  @override
  Widget build(BuildContext context) {
    return profile.when(
      data: (data) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Pagi',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  const StatusPill(
                    label: 'Perlu Verifikasi',
                    color: AppColors.warning,
                    backgroundColor: AppColors.softGray,
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.softGray,
              child:
                  const Icon(Icons.notifications_none, color: AppColors.textPrimary),
            ),
          ],
        );
      },
      loading: () => const LoadingSkeleton(height: 120),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _VerifyInlineCard extends StatelessWidget {
  final VoidCallback onVerify;

  const _VerifyInlineCard({required this.onVerify});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.warning),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lengkapi data kendaraan, pajak, dan verifikasi agar kuota subsidi aktif.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onVerify,
              child: const Text('Verifikasi Sekarang'),
            ),
          ),
        ],
      ),
    );
  }
}

void _showVerifyPopup(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Registrasi berhasil',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close),
                    splashRadius: 18,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Akun Anda berhasil dibuat dan tervalidasi oleh sistem. Lanjutkan verifikasi untuk melihat kuota subsidi.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.go('/register?step=2');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Verifikasi Sekarang'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _QuotaCard extends StatelessWidget {
  final Quota quota;

  const _QuotaCard({required this.quota});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      color: AppColors.primaryRed,
      borderRadius: BorderRadius.circular(24),
      onTap: () => context.go('/home/quota'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -40,
              child: _PatternCircle(
                size: 140,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            Positioned(
              left: 140,
              bottom: -60,
              child: _PatternCircle(
                size: 160,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
            Positioned(
              left: -40,
              bottom: 40,
              child: _PatternCircle(
                size: 90,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Sisa Kuota Bulanan',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: Colors.white),
                      ),
                      const Spacer(),
                      const Icon(Icons.lock_outline, color: Colors.white70),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '--',
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lengkapi verifikasi untuk melihat kuota subsidi Anda.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final List<_QuickAction> actions = const [
    _QuickAction('Bayar SPBU', Icons.credit_card, '/wallet'),
    _QuickAction('Top Up', Icons.north_east, '/wallet/topup'),
    _QuickAction('Riwayat', Icons.schedule, '/transactions'),
    _QuickAction('Keluarga', Icons.group_outlined, '/vehicles/family'),
  ];

  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: actions
          .map(
            (action) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: InkWell(
                    onTap: () => context.go(action.route),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.softGray,
                          child: Icon(action.icon, color: AppColors.primaryRed),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          action.label,
                          style: Theme.of(context).textTheme.labelMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final String route;

  const _QuickAction(this.label, this.icon, this.route);
}

class _StationCard extends StatelessWidget {
  final String name;
  final String distance;

  const _StationCard({required this.name, required this.distance});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.softGray,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.location_on_outlined,
                color: AppColors.primaryRed),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  distance,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F9EF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Buka',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskCard extends StatelessWidget {
  const _RiskCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.go('/home/risk'),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFFFFF5E5),
            child: Icon(Icons.shield_outlined, color: AppColors.warning),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Skor Risiko 72',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Status dalam review, lengkapi verifikasi.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class _RecentTransactionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;

  const _RecentTransactionCard({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.softGray,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.receipt_long,
                color: AppColors.primaryRed),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _PatternCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _PatternCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        color: Colors.transparent,
      ),
    );
  }
}
