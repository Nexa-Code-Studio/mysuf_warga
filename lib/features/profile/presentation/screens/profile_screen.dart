import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/providers/mock_providers.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/error_state.dart';
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
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
              loading: () => const LoadingSkeleton(height: 90),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            profile.when(
              data: (data) => Row(
                children: [
                  _MetricCard(
                    label: 'Saldo',
                    value: formatCurrencyIdr(data.walletBalance),
                    accentColor: AppColors.primaryRed,
                  ),
                  const SizedBox(width: 12),
                  _MetricCard(
                    label: 'Kuota Sisa',
                    value: '${data.quotaRemaining} L',
                    accentColor: AppColors.primaryRed,
                  ),
                  const SizedBox(width: 12),
                  _MetricCard(
                    label: 'Kendaraan',
                    value: '${data.vehiclesCount} Unit',
                    accentColor: AppColors.primaryRed,
                  ),
                ],
              ),
              loading: () => const LoadingSkeleton(height: 90),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Akun & Identitas'),
            const SizedBox(height: 12),
            const _MenuTile(
              title: 'Verifikasi Identitas',
              subtitle: 'KTP & Selfie diverifikasi',
              trailing: 'Aktif',
              icon: Icons.verified_user_outlined,
            ),
            const SizedBox(height: 10),
            const _MenuTile(
              title: 'Anggota Keluarga',
              subtitle: '3 anggota - KK terdaftar',
              trailing: 'Kelola',
              icon: Icons.group_outlined,
            ),
            const SizedBox(height: 10),
            const _MenuTile(
              title: 'Kendaraan Saya',
              subtitle: '2 kendaraan terdaftar',
              trailing: 'Detail',
              icon: Icons.directions_car_outlined,
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Keamanan'),
            const SizedBox(height: 12),
            const _MenuTile(
              title: 'Status Risiko AI',
              subtitle: 'Skor 72 - Dalam Review',
              trailing: 'Review',
              icon: Icons.shield_outlined,
            ),
            const SizedBox(height: 10),
            const _MenuTile(
              title: 'Pengaturan Notifikasi',
              subtitle: 'Pengingat kuota dan transaksi',
              trailing: 'Atur',
              icon: Icons.notifications_none,
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
  final Color accentColor;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;
  final IconData icon;

  const _MenuTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.icon,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F3),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              trailing,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
