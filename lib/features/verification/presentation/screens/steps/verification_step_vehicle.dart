import 'package:flutter/material.dart';
import '../../../../../shared/widgets/app_card.dart';
import 'verification_form_state.dart';
import 'verification_form_widgets.dart';

class VerificationVehicleStep extends StatelessWidget {
  final VerificationFormControllers controllers;
  final String? stnkFileName;
  final String? vehicleFileName;
  final VoidCallback onStnkCamera;
  final VoidCallback onVehicleCamera;

  const VerificationVehicleStep({
    super.key,
    required this.controllers,
    required this.stnkFileName,
    required this.vehicleFileName,
    required this.onStnkCamera,
    required this.onVehicleCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Dokumen Kendaraan'),
        const SizedBox(height: 12),
        UploadTile(
          title: 'Foto STNK',
          subtitle: 'Unggah foto STNK kendaraan',
          fileName: stnkFileName,
          onCamera: onStnkCamera,
        ),
        const SizedBox(height: 12),
        UploadTile(
          title: 'Foto Kendaraan',
          subtitle: 'Tampak depan, plat harus jelas',
          fileName: vehicleFileName,
          onCamera: onVehicleCamera,
        ),
        const SizedBox(height: 16),
        const SectionTitle('Informasi Kendaraan'),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: [
              InputField(
                label: 'Nomor STNK',
                hintText: 'STNK-001-234-567',
                controller: controllers.stnkNumber,
              ),
              const InfoBanner(
                text:
                    'Detail kendaraan (merk, tipe, tahun, warna, kapasitas, PKB) ditarik otomatis dari data Satlantas.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
