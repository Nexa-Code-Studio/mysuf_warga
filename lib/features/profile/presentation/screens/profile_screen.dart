import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/providers/mock_providers.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/section_header.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            profile.when(
              data: (data) => AppCard(
                onTap: () => context.go('/profile/detail'),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFFFFF1F3),
                      child: Text(
                        data.name.substring(0, 2),
                        style: const TextStyle(
                          color: AppColors.primaryRed,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'NIK: ${data.nikMasked}',
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
              ),
              loading: () => const LoadingSkeleton(height: 90),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            profile.when(
              data: (data) => AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _MetricCard(
                      label: 'Saldo',
                      value: formatCurrencyIdr(data.walletBalance),
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    const SizedBox(width: 12),
                    _MetricCard(
                      label: 'Kuota Sisa',
                      value: '${data.quotaRemaining} L',
                      icon: Icons.local_gas_station_outlined,
                    ),
                    const SizedBox(width: 12),
                    _MetricCard(
                      label: 'Kendaraan',
                      value: '${data.vehiclesCount} Unit',
                      icon: Icons.directions_car_outlined,
                    ),
                  ],
                ),
              ),
              loading: () => const LoadingSkeleton(height: 90),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Akun & Identitas'),
            const SizedBox(height: 12),
            _MenuTile(
              title: 'Verifikasi Identitas',
              subtitle: 'Lengkapi KTP & selfie untuk verifikasi',
              icon: Icons.verified_user_outlined,
              onTap: () => context.go('/verification'),
            ),
            const SizedBox(height: 10),
            _MenuTile(
              title: 'Anggota Keluarga',
              subtitle: 'Otomatis dari KK yang sama',
              icon: Icons.group_outlined,
              onTap: () => context.go('/vehicles/family'),
            ),
            const SizedBox(height: 10),
            _MenuTile(
              title: 'Kendaraan Saya',
              subtitle: 'Input kendaraan cukup sekali per KK',
              icon: Icons.directions_car_outlined,
              onTap: () => context.go('/vehicles'),
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Keamanan'),
            const SizedBox(height: 12),
            _MenuTile(
              title: 'Status Risiko AI',
              subtitle: 'Skor 72 - Dalam Review',
              icon: Icons.shield_outlined,
              onTap: () => context.go('/home/risk'),
            ),
            const SizedBox(height: 10),
            _MenuTile(
              title: 'Pengaturan Notifikasi',
              subtitle: 'Pengingat kuota dan transaksi',
              icon: Icons.notifications_none,
              onTap: () => context.go('/profile/notifications'),
            ),
            const SizedBox(height: 10),
            _MenuTile(
              title: 'Pusat Panduan',
              subtitle: 'FAQ, panduan, dan bantuan aplikasi',
              icon: Icons.help_outline,
              onTap: () => context.go('/profile/help'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.go('/logout-processing'),
                icon: const Icon(Icons.logout),
                label: const Text('Keluar Akun'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryRed, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.softGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryRed),
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
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
