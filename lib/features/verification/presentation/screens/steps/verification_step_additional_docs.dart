import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_card.dart';
import 'verification_form_state.dart';
import 'verification_form_widgets.dart';

class VerificationAdditionalDocsStep extends StatelessWidget {
  final String usagePurpose;
  final String ownershipStatus;
  final VerificationFormControllers controllers;
  final String? businessDocName;
  final String? driverDocName;
  final String? companyDocName;
  final String? farmerDocName;
  final VoidCallback onBusinessCamera;
  final VoidCallback onBusinessPick;
  final VoidCallback onDriverCamera;
  final VoidCallback onDriverPick;
  final VoidCallback onCompanyCamera;
  final VoidCallback onCompanyPick;
  final VoidCallback onFarmerCamera;
  final VoidCallback onFarmerPick;

  const VerificationAdditionalDocsStep({
    super.key,
    required this.usagePurpose,
    required this.ownershipStatus,
    required this.controllers,
    required this.businessDocName,
    required this.driverDocName,
    required this.companyDocName,
    required this.farmerDocName,
    required this.onBusinessCamera,
    required this.onBusinessPick,
    required this.onDriverCamera,
    required this.onDriverPick,
    required this.onCompanyCamera,
    required this.onCompanyPick,
    required this.onFarmerCamera,
    required this.onFarmerPick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (usagePurpose == 'Operasional Usaha') ...[
          const SectionTitle('UMKM / Operasional Usaha'),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: [
                InputField(
                  label: 'Nomor Induk Berusaha (NIB) / SKU',
                  hintText: 'NIB-123456',
                  controller: controllers.nibNumber,
                ),
                UploadTile(
                  title: 'Dokumen NIB / SKU',
                  subtitle: 'Unggah dokumen usaha',
                  fileName: businessDocName,
                  onCamera: onBusinessCamera,
                  onPick: onBusinessPick,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (usagePurpose == 'Driver Ojol') ...[
          const SectionTitle('Driver Ojol'),
          const SizedBox(height: 12),
          UploadTile(
            title: 'Bukti driver aktif',
            subtitle: 'Unggah bukti driver aktif',
            fileName: driverDocName,
            onCamera: onDriverCamera,
            onPick: onDriverPick,
          ),
          const SizedBox(height: 16),
        ],
        if (ownershipStatus == 'Milik Perusahaan' ||
            usagePurpose == 'Logistik') ...[
          const SectionTitle('Komersial / Perusahaan'),
          const SizedBox(height: 12),
          UploadTile(
            title: 'Surat operasional perusahaan',
            subtitle: 'Unggah surat operasional',
            fileName: companyDocName,
            onCamera: onCompanyCamera,
            onPick: onCompanyPick,
          ),
          const SizedBox(height: 16),
        ],
        if (usagePurpose == 'Pertanian' || usagePurpose == 'Nelayan') ...[
          const SectionTitle('Petani / Nelayan'),
          const SizedBox(height: 12),
          UploadTile(
            title: 'Surat rekomendasi',
            subtitle: 'Unggah surat rekomendasi terkait',
            fileName: farmerDocName,
            onCamera: onFarmerCamera,
            onPick: onFarmerPick,
          ),
        ],
        if (usagePurpose != 'Operasional Usaha' &&
            usagePurpose != 'Driver Ojol' &&
            usagePurpose != 'Logistik' &&
            usagePurpose != 'Pertanian' &&
            usagePurpose != 'Nelayan' &&
            ownershipStatus != 'Milik Perusahaan')
          const InfoBanner(text: 'Tidak ada dokumen tambahan untuk kategori ini.'),
      ],
    );
  }
}
