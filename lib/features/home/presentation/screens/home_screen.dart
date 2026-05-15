import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/quota.dart';
import '../../../../shared/providers/mock_providers.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_pill.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final quota = ref.watch(quotaProvider);

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
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryRed,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
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
                          ?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 12),
                    StatusPill(
                      label: data.isEligible ? 'Eligible' : 'Review',
                      color: data.isEligible
                          ? AppColors.success
                          : AppColors.warning,
                      backgroundColor: Colors.white.withOpacity(0.15),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.notifications_none, color: Colors.white),
              ),
            ],
          ),
        );
      },
      loading: () => const LoadingSkeleton(height: 120),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _QuotaCard extends StatelessWidget {
  final Quota quota;

  const _QuotaCard({required this.quota});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      onTap: () => context.go('/home/quota'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Sisa Kuota Bulanan',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              Text(
                quota.periodLabel,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                quota.remainingQuota.toString(),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(width: 6),
              Text(
                '/ ${formatLiters(quota.monthlyQuota)}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: quota.progress,
              minHeight: 8,
              backgroundColor: AppColors.softGray,
              color: AppColors.primaryRed,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: quota.fuelTypes
                .map(
                  (fuel) => Chip(
                    avatar: const Icon(
                      Icons.local_gas_station,
                      color: AppColors.primaryRed,
                      size: 16,
                    ),
                    label: Text(fuel),
                  ),
                )
                .toList(),
          ),
        ],
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
