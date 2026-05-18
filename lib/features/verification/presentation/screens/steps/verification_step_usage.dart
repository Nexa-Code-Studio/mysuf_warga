import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import '../../../../../shared/widgets/app_card.dart';
import 'verification_form_state.dart';
import 'verification_form_widgets.dart';

class VerificationUsageStep extends StatelessWidget {
  final String ownershipStatus;
  final ValueChanged<String?> onOwnershipChanged;
  final String usagePurpose;
  final ValueChanged<String?> onPurposeChanged;
  final String businessCategory;
  final ValueChanged<String?> onBusinessChanged;
  final String usageIntensity;
  final ValueChanged<String?> onIntensityChanged;
  final VerificationFormControllers controllers;
  final List<String> purposeOptions;

  const VerificationUsageStep({
    super.key,
    required this.ownershipStatus,
    required this.onOwnershipChanged,
    required this.usagePurpose,
    required this.onPurposeChanged,
    required this.businessCategory,
    required this.onBusinessChanged,
    required this.usageIntensity,
    required this.onIntensityChanged,
    required this.controllers,
    required this.purposeOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Status Kepemilikan'),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: [
              DropdownField(
                label: 'Kepemilikan',
                value: ownershipStatus,
                items: const [
                  'Milik Pribadi',
                  'Milik Keluarga',
                  'Milik Perusahaan',
                ],
                onChanged: onOwnershipChanged,
              ),
              if (ownershipStatus == 'Milik Perusahaan') ...[
                const SizedBox(height: 12),
                InputField(
                  label: 'Nama Perusahaan',
                  hintText: 'PT Contoh Sejahtera',
                  controller: controllers.companyName,
                ),
                InputField(
                  label: 'ID Perusahaan',
                  hintText: 'ID-001-234',
                  controller: controllers.companyId,
                ),
                const InfoBanner(text: 'Menunggu approval admin perusahaan.'),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionTitle('Tujuan Penggunaan'),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: [
              DropdownField(
                label: 'Tujuan Penggunaan',
                value: usagePurpose,
                items: purposeOptions,
                onChanged: onPurposeChanged,
              ),
              const SizedBox(height: 12),
              if (usagePurpose == 'Operasional Usaha') ...[
                DropdownField(
                  label: 'Kategori Usaha',
                  value: businessCategory,
                  items: const [
                    'Non-komersial',
                    'UMKM',
                    'Logistik kecil',
                    'Industri besar',
                  ],
                  onChanged: onBusinessChanged,
                ),
                const SizedBox(height: 12),
                InputField(
                  label: 'Nama usaha (optional)',
                  hintText: 'Toko Sembako Berkah',
                  controller: controllers.businessName,
                ),
              ],
              if (usagePurpose != 'Pribadi (Non-Komersial)') ...[
                InputField(
                  label: 'Lokasi kerja/usaha',
                  hintText: 'Jl. Melati 5',
                  controller: controllers.workLocation,
                ),
                InputField(
                  label: 'Estimasi jarak rumah → kerja (km)',
                  hintText: '12',
                  controller: controllers.distance,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 12),
              ],
              DropdownField(
                label: 'Intensitas Penggunaan',
                value: usageIntensity,
                items: const ['Jarang', 'Normal', 'Tinggi'],
                onChanged: onIntensityChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
