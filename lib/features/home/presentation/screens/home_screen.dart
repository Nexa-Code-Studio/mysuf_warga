import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_pill.dart';
import '../../../../shared/providers/mock_providers.dart';
import '../../domain/buyer_home.dart';
import '../providers/home_providers.dart';
import '../../../../shared/models/wallet_transaction.dart';

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
    final homeData = ref.watch(homeDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(profileProvider);
            ref.invalidate(homeDashboardProvider);
          },
          child: homeData.when(
            data: (home) => ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                _Header(profile: profile, home: home),
                const SizedBox(height: 16),
                if (home.vehicleVerification.showVerifyVehicleCta) ...[
                  _VerifyInlineCard(
                    ctaRoute: home.vehicleVerification.ctaRoute,
                  ),
                  const SizedBox(height: 16),
                ],
                _QuotaCard(quota: home.personalQuota, verificationStatus: home.riskStatus.verificationStatus),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Aksi Cepat'),
                const SizedBox(height: 12),
                const _QuickActions(),
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'SPBU Terdekat',
                  actionLabel: 'Lihat Semua',
                  onAction: () => context.go('/home/spbu'),
                ),
                const SizedBox(height: 12),
                if (!home.nearbyGasStations.locationAvailable)
                  AppCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.softGray,
                            child: const Icon(Icons.location_off, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              home.nearbyGasStations.message ??
                                  'Lokasi Anda tidak ditemukan, tolong nyalakan GPS.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (home.nearbyGasStations.items.isEmpty)
                  AppCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'Tidak ada SPBU terdekat yang ditemukan.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  )
                else
                  ...home.nearbyGasStations.items.map((station) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _StationCard(
                          name: station.name,
                          distance: '${station.distanceKm.toStringAsFixed(1)} km dari lokasi Anda',
                        ),
                      )),
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Transaksi Terkini',
                  actionLabel: 'Semua',
                  onAction: () => context.go('/transactions'),
                ),
                const SizedBox(height: 12),
                if (home.recentTransactions.isEmpty)
                  AppCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'Belum ada transaksi.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  )
                else
                  ...home.recentTransactions.map((tx) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _RecentTransactionCard(
                          title: tx.title,
                          subtitle: tx.subtitle,
                          amount: tx.transactionFlow == TransactionFlow.inflow
                              ? '+ Rp ${_formatAmount(tx.amount)}'
                              : '- Rp ${_formatAmount(tx.amount)}',
                          amountColor: tx.transactionFlow == TransactionFlow.inflow
                              ? AppColors.success
                              : AppColors.primaryRed,
                        ),
                      )),
                const SizedBox(height: 24),
                const SectionHeader(
                  title: 'Status Risiko',
                ),
                const SizedBox(height: 12),
                _RiskCard(risk: home.riskStatus),
              ]
                  .animate(interval: 70.ms)
                  .fadeIn(duration: 300.ms)
                  .moveY(begin: 8, end: 0),
            ),
            loading: () => ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: const [
                LoadingSkeleton(height: 120),
                SizedBox(height: 16),
                LoadingSkeleton(height: 170),
                SizedBox(height: 24),
                SectionHeader(title: 'Aksi Cepat'),
                SizedBox(height: 12),
                LoadingSkeleton(height: 96),
                SizedBox(height: 24),
                SectionHeader(title: 'SPBU Terdekat'),
                SizedBox(height: 12),
                LoadingSkeleton(height: 80),
                SizedBox(height: 10),
                LoadingSkeleton(height: 80),
              ],
            ),
            error: (err, _) => ErrorState(
              title: 'Gagal memuat dashboard',
              message: err.toString(),
              onRetry: () => ref.invalidate(homeDashboardProvider),
            ),
          ),
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    return amount.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}

class _Header extends StatelessWidget {
  final AsyncValue profile;
  final BuyerHome home;

  const _Header({required this.profile, required this.home});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 0 && hour < 11) {
      return 'Selamat Pagi';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  String _getTwoWords(String fullName) {
    if (fullName.isEmpty) return '';
    final words = fullName.trim().split(RegExp(r'\s+'));
    if (words.length <= 2) {
      return fullName;
    }
    return '${words[0]} ${words[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return profile.when(
      data: (data) {
        final verificationStatus = home.riskStatus.verificationStatus.toUpperCase();
        
        String statusLabel = 'Perlu Verifikasi';
        Color statusColor = AppColors.warning;
        
        if (verificationStatus == 'VERIFIED') {
          statusLabel = 'Terverifikasi';
          statusColor = AppColors.success;
        } else if (verificationStatus == 'REJECTED') {
          statusLabel = 'Ditolak';
          statusColor = AppColors.danger;
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _getTwoWords(data.name),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  StatusPill(
                    label: statusLabel,
                    color: statusColor,
                    backgroundColor: AppColors.softGray,
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => context.push('/notifications'),
              borderRadius: BorderRadius.circular(20),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.softGray,
                child: const Icon(Icons.notifications_none,
                    color: AppColors.textPrimary),
              ),
            ),
          ],
        );
      },
      loading: () => const LoadingSkeleton(height: 120),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _VerifyInlineCard extends StatelessWidget {
  final String ctaRoute;

  const _VerifyInlineCard({required this.ctaRoute});

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
              onPressed: () => context.go(ctaRoute),
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
                    context.go('/verification');
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
  final PersonalQuotaHome quota;
  final String verificationStatus;

  const _QuotaCard({required this.quota, required this.verificationStatus});

  @override
  Widget build(BuildContext context) {
    final isVerified = verificationStatus.toUpperCase() == 'VERIFIED';

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
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            Positioned(
              left: 140,
              bottom: -60,
              child: _PatternCircle(
                size: 160,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            Positioned(
              left: -40,
              bottom: 40,
              child: _PatternCircle(
                size: 90,
                color: Colors.white.withValues(alpha: 0.1),
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
                      Icon(
                        isVerified ? Icons.chevron_right : Icons.lock_outline,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isVerified ? '${quota.remainingLiters.toStringAsFixed(0)} L' : '--',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isVerified
                        ? 'Sisa kuota dari total ${quota.quotaLiters.toStringAsFixed(0)} Liter bulan ini.'
                        : 'Lengkapi verifikasi untuk melihat kuota subsidi Anda.',
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
  final RiskStatusHome risk;

  const _RiskCard({required this.risk});

  @override
  Widget build(BuildContext context) {
    final verificationStatus = risk.verificationStatus.toUpperCase();
    final isVerified = verificationStatus == 'VERIFIED';
    
    final statusColor = !isVerified
        ? AppColors.warning
        : risk.riskScore >= 75
            ? AppColors.danger
            : risk.riskScore >= 50
                ? AppColors.warning
                : AppColors.success;

    return AppCard(
      onTap: () => context.go('/home/risk'),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: statusColor.withValues(alpha: 0.12),
            child: Icon(Icons.shield_outlined, color: statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isVerified
                      ? 'Skor Risiko ${risk.riskScore.toStringAsFixed(0)}'
                      : 'Skor Risiko --',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  !isVerified
                      ? 'Lengkapi verifikasi untuk melihat tingkat risiko akun Anda.'
                      : risk.riskScore >= 75
                          ? 'Akun dalam pemantauan ketat untuk transaksi subsidi.'
                          : risk.riskScore >= 50
                              ? 'Status sedang di-review, kuota dikurangi proporsional.'
                              : 'Status aman, kuota subsidi berjalan normal.',
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
