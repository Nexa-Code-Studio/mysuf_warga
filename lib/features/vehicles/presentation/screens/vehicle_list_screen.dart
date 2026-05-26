import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/vehicle.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../data/vehicle_providers.dart';
import 'pending_vehicle_submission_detail_screen.dart';

class VehicleListScreen extends ConsumerWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(buyerVehiclesProvider);
    final pendingVehicles = ref.watch(pendingVehicleRequestsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kendaraan'),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: FloatingActionButton(
          onPressed: () => context.go('/vehicles/add'),
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add, size: 26),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SectionHeader(
              title: 'Kendaraan Terdaftar',
            ),
            const SizedBox(height: 12),
            vehicles.when(
              data: (items) {
                final hasPending = pendingVehicles.maybeWhen(
                  data: (pendingItems) => pendingItems.isNotEmpty,
                  orElse: () => false,
                );
                if (items.isEmpty && !hasPending) {
                  return EmptyState(
                    title: 'Belum ada kendaraan',
                    message: 'Tambahkan kendaraan subsidi Anda sekarang.',
                    icon: Icons.directions_car_outlined,
                    actionLabel: 'Tambah Kendaraan',
                    onAction: () => context.go('/vehicles/add'),
                  );
                }
                if (items.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: items
                      .map((vehicle) => _VehicleTile(vehicle: vehicle))
                      .toList(),
                );
              },
              loading: () => const LoadingSkeleton(height: 120),
              error: (_, _) => ErrorState(
                title: 'Gagal memuat kendaraan',
                message: 'Tarik untuk mencoba lagi.',
                onRetry: () => ref.invalidate(buyerVehiclesProvider),
              ),
            ),
            const SizedBox(height: 24),
            AppCard(
              onTap: () => context.go('/vehicles/family'),
              child: Row(
                children: [
                  const Icon(Icons.group_outlined, color: AppColors.primaryRed),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Kelola akses kendaraan keluarga',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            const SizedBox(height: 16),
            pendingVehicles.when(
              data: (items) {
                if (items.isEmpty) {
                  return const SizedBox.shrink();
                }
                return AppCard(
                  padding: EdgeInsets.zero,
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    title: Text(
                      'Menunggu Verifikasi Admin',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${items.length} pengajuan kendaraan',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    children: items
                        .map((request) => _PendingVehicleTile(request: request))
                        .toList(),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleTile extends StatelessWidget {
  final Vehicle vehicle;

  const _VehicleTile({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () => context.go('/vehicles/detail', extra: vehicle),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.softGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.directions_car,
                color: AppColors.primaryRed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.plateNumber,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vehicle.typeLabel,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  if (_isCommercialUsage(vehicle.usageType)) ...[
                    const SizedBox(height: 6),
                    _UsageChip(usageType: vehicle.usageType),
                    if (vehicle.quotaLiters != null && vehicle.usedLiters != null && vehicle.remainingLiters != null) ...[
                      const SizedBox(height: 10),
                      _CommercialQuotaBar(vehicle: vehicle),
                    ],
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: vehicle.category == VehicleCategory.nonCommercial
                    ? const Color(0xFFE9F9EF)
                    : const Color(0xFFFFF5E5),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                vehicle.category == VehicleCategory.nonCommercial
                    ? 'Non-Kom'
                    : 'Komersial',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: vehicle.category == VehicleCategory.nonCommercial
                          ? AppColors.success
                          : AppColors.warning,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingVehicleTile extends StatelessWidget {
  final PendingVehicleRequest request;

  const _PendingVehicleTile({required this.request});

  @override
  Widget build(BuildContext context) {
    final color = request.usageType == 'COMMERCIAL_MOTORCYCLE' ? AppColors.warning : Colors.blue;
    final submittedLabel = '${request.submittedAt.day.toString().padLeft(2, '0')}-${request.submittedAt.month.toString().padLeft(2, '0')}-${request.submittedAt.year}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => PendingVehicleSubmissionDetailScreen(request: request),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.hourglass_top, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.plateNumber,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${request.registrationNumber} • ${request.status}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  _UsageChip(usageType: request.usageType),
                  const SizedBox(height: 6),
                  Text(
                    'Diajukan: $submittedLabel',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  if (request.reviewNote != null && request.reviewNote!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      request.reviewNote!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.warning),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommercialQuotaBar extends StatelessWidget {
  final Vehicle vehicle;

  const _CommercialQuotaBar({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final quota = vehicle.quotaLiters ?? 0;
    final used = vehicle.usedLiters ?? 0;
    final progress = quota <= 0 ? 0.0 : (used / quota).clamp(0.0, 1.0);
    final color = _usageColor(vehicle.usageType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Quota subsidi',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(
              '${used.toStringAsFixed(1)}L / ${quota.toStringAsFixed(1)}L',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.softGray,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _UsageChip extends StatelessWidget {
  final String usageType;

  const _UsageChip({required this.usageType});

  @override
  Widget build(BuildContext context) {
    final color = _usageColor(usageType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        usageType,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

bool _isCommercialUsage(String usageType) {
  return usageType == 'COMMERCIAL_MOTORCYCLE' ||
      usageType == 'COMMERCIAL_CAR' ||
      usageType == 'COMMERCIAL_TRUCK';
}

Color _usageColor(String usageType) {
  if (usageType == 'COMMERCIAL_MOTORCYCLE') {
    return AppColors.warning;
  }
  if (usageType == 'COMMERCIAL_CAR') {
    return Colors.blue;
  }
  if (usageType == 'COMMERCIAL_TRUCK') {
    return Colors.teal;
  }
  return AppColors.success;
}
