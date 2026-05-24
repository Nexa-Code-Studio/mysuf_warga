import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/family_member.dart';
import '../../../../shared/models/vehicle.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../../vehicles/presentation/screens/vehicle_detail_screen.dart';
import '../../data/family_providers.dart';

class FamilyListScreen extends ConsumerWidget {
  const FamilyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final family = ref.watch(familyOverviewProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anggota Keluarga'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppCard(
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primaryRed),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Anggota keluarga otomatis terhubung lewat KK yang sama. Kendaraan cukup didaftarkan sekali per keluarga.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            family.when(
              data: (overview) {
                if (overview.members.isEmpty) {
                  return const EmptyState(
                    title: 'Belum ada anggota',
                    message: 'Tambahkan anggota keluarga untuk akses bersama.',
                    icon: Icons.group_outlined,
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...overview.members.map((member) => _FamilyTile(member: member)),
                    const SizedBox(height: 20),
                    Text(
                      'Kendaraan Semua Anggota Keluarga',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    if (overview.vehicles.isEmpty)
                      const EmptyState(
                        title: 'Belum ada kendaraan keluarga',
                        message: 'Kendaraan aktif keluarga akan muncul di sini.',
                        icon: Icons.directions_car_outlined,
                      )
                    else
                      ...overview.vehicles.map(
                        (vehicle) => _FamilyVehicleTile(vehicle: vehicle),
                      ),
                  ],
                );
              },
              loading: () => const LoadingSkeleton(height: 150),
              error: (_, _) => ErrorState(
                title: 'Gagal memuat keluarga',
                message: 'Tarik untuk memuat ulang daftar keluarga.',
                onRetry: () => ref.invalidate(familyOverviewProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FamilyTile extends StatelessWidget {
  final FamilyMember member;

  const _FamilyTile({required this.member});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFFFF1F3),
              child: Text(
                member.name.substring(0, 1),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryRed,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${member.role} - ${member.nikMasked}',
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
                color: member.isEligible
                    ? const Color(0xFFE9F9EF)
                    : const Color(0xFFFFF5E5),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                member.isEligible
                    ? 'KTP Terverifikasi'
                    : 'Belum Registrasi KTP',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: member.isEligible
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

class _FamilyVehicleTile extends StatelessWidget {
  final FamilyVehicle vehicle;

  const _FamilyVehicleTile({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => VehicleDetailScreen(
              vehicle: Vehicle(
                ownershipId: vehicle.ownershipId,
                vehicleId: vehicle.vehicleId,
                plateNumber: vehicle.plateNumber,
                typeLabel: vehicle.typeLabel,
                category: vehicle.category == 'commercial'
                    ? VehicleCategory.commercial
                    : VehicleCategory.nonCommercial,
                isActive: true,
                usageType: vehicle.usageType,
              ),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_car, color: AppColors.primaryRed),
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
                _UsageBadge(usageType: vehicle.usageType),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Dipegang oleh:',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...vehicle.holders.map(
              (holder) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${holder.name} (${holder.nikMasked})',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsageBadge extends StatelessWidget {
  final String usageType;

  const _UsageBadge({required this.usageType});

  @override
  Widget build(BuildContext context) {
    final isBusiness = usageType == 'OJOL' || usageType == 'UMKM';
    final color = usageType == 'OJOL'
        ? AppColors.warning
        : usageType == 'UMKM'
            ? Colors.blue
            : AppColors.success;
    final label = isBusiness ? usageType : 'PERSONAL';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
