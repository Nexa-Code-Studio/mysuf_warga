import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/vehicle.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../data/vehicle_providers.dart';
import 'vehicle_document_preview_screen.dart';

class PendingVehicleSubmissionDetailScreen extends ConsumerWidget {
  final PendingVehicleRequest request;

  const PendingVehicleSubmissionDetailScreen({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(pendingVehicleRequestDetailProvider(request.requestId));

    return Scaffold(
      appBar: AppBar(title: const Text('Pengajuan Kendaraan')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppCard(
              child: Row(
                children: [
                  const Icon(Icons.hourglass_top, color: AppColors.primaryRed),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.plateNumber,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${request.registrationNumber} • ${request.status}',
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status Pengajuan',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(label: 'Status', value: detail.status),
                        const SizedBox(height: 8),
                        _DetailRow(label: 'Tujuan Penggunaan', value: detail.usageType),
                        const SizedBox(height: 8),
                        _DetailRow(label: 'Mode Kuota', value: detail.quotaMode),
                        if (detail.reviewNote != null && detail.reviewNote!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _DetailRow(label: 'Catatan Admin', value: detail.reviewNote!),
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
                          'Dokumen Pengajuan',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        if (detail.documents.isEmpty)
                          Text(
                            'Belum ada dokumen pengajuan.',
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
                                onTap: () => _openPendingDocument(
                                  context,
                                  ref,
                                  request.requestId,
                                  document,
                                ),
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
                title: 'Gagal memuat detail pengajuan',
                message: 'Silakan coba lagi beberapa saat lagi.',
                onRetry: () => ref.invalidate(pendingVehicleRequestDetailProvider(request.requestId)),
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

  Future<void> _openPendingDocument(
    BuildContext context,
    WidgetRef ref,
    String requestId,
    VehicleDocument document,
  ) async {
    final dialogRoute = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    Navigator.of(context).push(dialogRoute);

    try {
      final previewData = await ref.read(vehicleApiRepositoryProvider).fetchPendingVehicleDocument(
            requestId: requestId,
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
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
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

  const _DocTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

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
            const Icon(Icons.description_outlined, color: AppColors.primaryRed),
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
