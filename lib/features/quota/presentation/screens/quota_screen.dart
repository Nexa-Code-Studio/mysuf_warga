import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/providers/mock_providers.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';

class QuotaScreen extends ConsumerWidget {
  const QuotaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quota = ref.watch(quotaProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Kuota')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: quota.when(
            data: (data) {
              return Column(
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kuota Bulanan',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              formatLiters(data.remainingQuota),
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'dari ${formatLiters(data.monthlyQuota)}',
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
                            value: data.progress,
                            minHeight: 8,
                            backgroundColor: AppColors.softGray,
                            color: AppColors.primaryRed,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Periode ${data.periodLabel}',
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
                        Wrap(
                          spacing: 8,
                          children: data.fuelTypes
                              .map(
                                (fuel) => Chip(
                                  avatar: const Icon(
                                    Icons.local_gas_station,
                                    size: 16,
                                    color: AppColors.primaryRed,
                                  ),
                                  label: Text(fuel),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const LoadingSkeleton(height: 180),
            error: (_, __) => ErrorState(
              title: 'Gagal memuat kuota',
              message: 'Tarik untuk mencoba kembali.',
              onRetry: () => ref.invalidate(quotaProvider),
            ),
          ),
        ),
      ),
    );
  }
}
