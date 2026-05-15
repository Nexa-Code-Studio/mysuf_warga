import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/vehicle.dart';
import '../../../../shared/providers/mock_providers.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../../shared/widgets/section_header.dart';

class VehicleListScreen extends ConsumerWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kendaraan'),
        actions: [
          IconButton(
            onPressed: () => context.go('/vehicles/add'),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SectionHeader(
              title: 'Kendaraan Terdaftar',
              actionLabel: 'Tambah',
            ),
            const SizedBox(height: 12),
            vehicles.when(
              data: (items) {
                if (items.isEmpty) {
                  return EmptyState(
                    title: 'Belum ada kendaraan',
                    message: 'Tambahkan kendaraan subsidi Anda sekarang.',
                    icon: Icons.directions_car_outlined,
                    actionLabel: 'Tambah Kendaraan',
                    onAction: () => context.go('/vehicles/add'),
                  );
                }
                return Column(
                  children: items
                      .map((vehicle) => _VehicleTile(vehicle: vehicle))
                      .toList(),
                );
              },
              loading: () => const LoadingSkeleton(height: 120),
              error: (_, __) => ErrorState(
                title: 'Gagal memuat kendaraan',
                message: 'Tarik untuk mencoba lagi.',
                onRetry: () => ref.invalidate(vehiclesProvider),
              ),
            ),
            const SizedBox(height: 24),
            AppCard(
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
                  IconButton(
                    onPressed: () => context.go('/vehicles/family'),
                    icon: const Icon(Icons.chevron_right),
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

class _VehicleTile extends StatelessWidget {
  final Vehicle vehicle;

  const _VehicleTile({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
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
