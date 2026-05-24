import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../providers/quota_providers.dart';

class QuotaScreen extends ConsumerWidget {
  const QuotaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotaState = ref.watch(quotaDetailProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Kuota')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(quotaDetailProvider.future),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: quotaState.when(
              data: (data) {
                final personal = data.personalQuota;

                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    AppCard(
                      color: const Color(0xFFFFF4F5),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: AppColors.primaryRed),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Kuota dan status eligible tampil setelah verifikasi. Perhitungan dilakukan oleh sistem dan tidak ditampilkan di aplikasi.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Kuota Bulanan',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDECEC),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'Aktif',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: AppColors.primaryRed,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                formatLiters(personal.remainingLiters),
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'tersisa dari ${formatLiters(personal.quotaLiters)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppColors.textSecondary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: personal.progress,
                              minHeight: 8,
                              backgroundColor: AppColors.softGray,
                              color: AppColors.primaryRed,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Periode ${personal.periodLabel}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jenis BBM yang diizinkan',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          if (data.subsidizedFuels.isEmpty)
                            Text(
                              'Tidak ada jenis BBM bersubsidi yang terdaftar.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: data.subsidizedFuels
                                  .map(
                                    (fuel) => Chip(
                                      avatar: const Icon(
                                        Icons.local_gas_station,
                                        size: 16,
                                        color: AppColors.primaryRed,
                                      ),
                                      label: Text(
                                        fuel.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      backgroundColor: AppColors.softGray,
                                    ),
                                  )
                                  .toList(),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kuota per Kendaraan',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          if (data.vehicles.isEmpty)
                            Text(
                              'Belum ada kendaraan terdaftar.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: data.vehicles.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final vehicle = data.vehicles[index];
                                return _VehicleQuotaTile(
                                  plateNumber: vehicle.plateNumber,
                                  brand: vehicle.brand,
                                  totalLitersPurchased: vehicle.totalLitersPurchased,
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      LoadingSkeleton(height: 80),
                      SizedBox(height: 16),
                      LoadingSkeleton(height: 180),
                      SizedBox(height: 16),
                      LoadingSkeleton(height: 120),
                    ],
                  ),
                ),
              ),
              error: (err, stack) => ErrorState(
                title: 'Gagal memuat kuota',
                message: err.toString().replaceAll('Exception: ', ''),
                onRetry: () => ref.refresh(quotaDetailProvider),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VehicleQuotaTile extends StatelessWidget {
  final String plateNumber;
  final String brand;
  final double totalLitersPurchased;

  const _VehicleQuotaTile({
    required this.plateNumber,
    required this.brand,
    required this.totalLitersPurchased,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.softGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.directions_car, color: AppColors.primaryRed),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plateNumber,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  brand,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatLiters(totalLitersPurchased),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Total Pembelian',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
