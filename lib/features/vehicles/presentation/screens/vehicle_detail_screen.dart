import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/vehicle.dart';
import '../../../../shared/widgets/app_card.dart';

class VehicleDetailScreen extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
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
                  const _DetailRow(label: 'Nomor STNK', value: 'STNK-0002341'),
                  const SizedBox(height: 8),
                  const _DetailRow(label: 'Merk', value: 'Toyota'),
                  const SizedBox(height: 8),
                  const _DetailRow(label: 'Tipe', value: 'Avanza 1.5 G'),
                  const SizedBox(height: 8),
                  const _DetailRow(label: 'Tahun', value: '2020'),
                  const SizedBox(height: 8),
                  const _DetailRow(label: 'Warna', value: 'Hitam'),
                  const SizedBox(height: 8),
                  const _DetailRow(label: 'Kapasitas Mesin', value: '1496 cc'),
                  const SizedBox(height: 8),
                  const _DetailRow(label: 'PKB Tahunan', value: 'Rp 450.000'),
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
                  const _DetailRow(label: 'Pemilik', value: 'Budi Santoso'),
                  const SizedBox(height: 8),
                  const _DetailRow(
                    label: 'Status Kepemilikan',
                    value: 'Pribadi',
                  ),
                  const SizedBox(height: 8),
                  const _DetailRow(label: 'Alamat Domisili', value: 'Jakarta'),
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
                  const _DocTile(
                    title: 'Foto STNK',
                    subtitle: 'STNK-0002341.jpg',
                  ),
                  const SizedBox(height: 10),
                  const _DocTile(
                    title: 'Foto Plat Kendaraan',
                    subtitle: 'plat_b1234abc.jpg',
                  ),
                  const SizedBox(height: 10),
                  const _DocTile(
                    title: 'Dokumen Tambahan',
                    subtitle: 'surat_pernyataan.pdf',
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

class _InfoPill extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
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

  const _DocTile({required this.title, required this.subtitle});

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
    );
  }
}
