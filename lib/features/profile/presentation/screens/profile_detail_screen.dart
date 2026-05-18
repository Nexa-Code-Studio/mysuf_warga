import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/mock_providers.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/loading_skeleton.dart';

class ProfileDetailScreen extends ConsumerWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Profil')),
      body: SafeArea(
        child: profile.when(
          data: (data) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              AppCard(
                padding: const EdgeInsets.all(20),
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
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Akun',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(label: 'Nama Lengkap', value: data.name),
                    const SizedBox(height: 8),
                    _DetailRow(label: 'NIK', value: data.nikMasked),
                    const SizedBox(height: 8),
                    _DetailRow(
                      label: 'Nomor KK',
                      value: data.familyCardNumber,
                    ),
                    const SizedBox(height: 8),
                    _DetailRow(
                      label: 'Status Verifikasi',
                      value: data.isVerified ? 'Terverifikasi' : 'Belum',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan Kepesertaan',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Status Subsidi',
                      value: data.isEligible ? 'Eligible' : 'Belum Eligible',
                    ),
                    const SizedBox(height: 8),
                    _DetailRow(
                      label: 'Jumlah Kendaraan',
                      value: '${data.vehiclesCount} unit',
                    ),
                    const SizedBox(height: 8),
                    _DetailRow(
                      label: 'Kuota Tersisa',
                      value: '${data.quotaRemaining} L',
                    ),
                  ],
                ),
              ),
            ],
          ),
          loading: () => const LoadingSkeleton(height: 160),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 12),
        Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
