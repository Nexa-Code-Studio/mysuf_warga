import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/vehicle.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../data/vehicle_providers.dart';
import 'vehicle_document_preview_screen.dart';

class VehicleDetailScreen extends ConsumerWidget {
  final Vehicle vehicle;

  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(vehicleDetailProvider(vehicle.ownershipId));
    final statusLabel = vehicle.isActive ? 'Aktif' : 'Tidak Aktif';
    final statusColor = vehicle.isActive ? AppColors.success : AppColors.warning;
    final categoryLabel = vehicle.category == VehicleCategory.nonCommercial
        ? 'Non-Kom'
        : 'Komersial';

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Kendaraan')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.plateNumber,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vehicle.typeLabel,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoPill(label: statusLabel, color: statusColor),
                      _InfoPill(
                        label: categoryLabel,
                        color: vehicle.category == VehicleCategory.nonCommercial
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            detailAsync.when(
              data: (detail) => Column(
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Kendaraan',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(label: 'Nomor STNK', value: detail.registrationNumber),
                        const SizedBox(height: 8),
                        _DetailRow(label: 'Merk', value: detail.brand),
                        const SizedBox(height: 8),
                        _DetailRow(label: 'Tipe', value: detail.vehicleType),
                        const SizedBox(height: 8),
                        _DetailRow(label: 'Tahun', value: '${detail.manufactureYear}'),
                        const SizedBox(height: 8),
                        _DetailRow(label: 'Warna', value: detail.color),
                        const SizedBox(height: 8),
                        _DetailRow(label: 'Kapasitas Mesin', value: '${detail.engineCapacityCc} cc'),
                        const SizedBox(height: 8),
                        _DetailRow(label: 'PKB Tahunan', value: 'Rp ${detail.pkb}'),
                        const SizedBox(height: 8),
                        _DetailRow(label: 'NJKB', value: 'Rp ${detail.njkb}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kepemilikan',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(label: 'Pemilik STNK', value: detail.ownerName ?? '-'),
                        const SizedBox(height: 8),
                        _DetailRow(label: 'Status Kepemilikan', value: detail.ownershipStatus),
                        const SizedBox(height: 8),
                        _DetailRow(label: 'Tujuan Penggunaan', value: detail.usageType),
                        if (_isCommercialUsage(detail.usageType)) ...[
                          const SizedBox(height: 8),
                          _DetailRow(
                            label: 'Mode Kuota',
                            value: detail.quotaMode == 'OWNER_PERSONAL_QUOTA'
                                ? 'Kuota Pribadi'
                                : detail.quotaMode == 'DEDICATED_VEHICLE_QUOTA'
                                    ? 'Kuota Kendaraan'
                                    : detail.quotaMode,
                          ),
                          if (detail.quotaLiters != null &&
                              detail.usedLiters != null &&
                              detail.remainingLiters != null) ...[
                            const SizedBox(height: 16),
                            _QuotaSummaryBar(detail: detail),
                          ],
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dipegang Anggota Keluarga',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        if (detail.holdersInFamily.isEmpty)
                          Text(
                            'Belum ada anggota keluarga lain yang memegang kendaraan ini.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          )
                        else
                          ...detail.holdersInFamily.map(
                            (holder) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _DetailRow(
                                label: holder.name,
                                value: holder.nikMasked,
                              ),
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
                          'Dokumen & Foto',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        if (detail.documents.isEmpty)
                          Text(
                            'Belum ada dokumen kendaraan.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          )
                        else
                          ...detail.documents.map(
                            (document) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _DocTile(
                                title: _documentTitle(document.documentType),
                                subtitle: document.originalFilename ?? document.storageKey,
                                onTap: () => _openDocument(context, ref, vehicle.ownershipId, document),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              loading: () => const LoadingSkeleton(height: 320),
              error: (_, _) => ErrorState(
                title: 'Gagal memuat detail kendaraan',
                message: 'Tarik atau buka ulang halaman untuk mencoba lagi.',
                onRetry: () => ref.invalidate(vehicleDetailProvider(vehicle.ownershipId)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _documentTitle(String documentType) {
    switch (documentType) {
      case 'STNK_PHOTO':
        return 'Foto STNK';
      case 'VEHICLE_PHOTO':
        return 'Foto Kendaraan';
      case 'PRODUCTIVE_BUSINESS_PROOF':
        return 'Bukti Usaha Produktif';
      default:
        return documentType;
    }
  }

  Future<void> _openDocument(
    BuildContext context,
    WidgetRef ref,
    String ownershipId,
    VehicleDocument document,
  ) async {
    final dialogRoute = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    Navigator.of(context).push(dialogRoute);

    try {
      final previewData = await ref.read(vehicleApiRepositoryProvider).fetchVehicleDocument(
            ownershipId: ownershipId,
            document: document,
          );
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).removeRoute(dialogRoute);
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => VehicleDocumentPreviewScreen(
            title: document.originalFilename ?? _documentTitle(document.documentType),
            mimeType: previewData.mimeType,
            bytes: previewData.bytes,
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).removeRoute(dialogRoute);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
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

class _QuotaSummaryBar extends StatelessWidget {
  final VehicleDetail detail;

  const _QuotaSummaryBar({required this.detail});

  @override
  Widget build(BuildContext context) {
    final quota = detail.quotaLiters ?? 0;
    final used = detail.usedLiters ?? 0;
    final progress = quota <= 0 ? 0.0 : (used / quota).clamp(0.0, 1.0);
    final color = _usageColor(detail.usageType);

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

class _InfoPill extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
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

class _DocTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DocTile({required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.softGray,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.image_outlined, color: AppColors.primaryRed),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
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
      ),
    );
  }
}
