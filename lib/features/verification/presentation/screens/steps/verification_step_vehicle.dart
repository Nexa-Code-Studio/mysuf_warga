import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../shared/widgets/app_card.dart';
import 'verification_form_state.dart';
import 'verification_form_widgets.dart';

class VerificationVehicleStep extends StatelessWidget {
  final String vehicleCategory;
  final ValueChanged<String?> onCategoryChanged;
  final VerificationFormControllers controllers;
  final String? stnkFileName;
  final String? vehicleFileName;
  final VoidCallback onStnkCamera;
  final VoidCallback onVehicleCamera;
  final VoidCallback onPickVehicleYear;

  const VerificationVehicleStep({
    super.key,
    required this.vehicleCategory,
    required this.onCategoryChanged,
    required this.controllers,
    required this.stnkFileName,
    required this.vehicleFileName,
    required this.onStnkCamera,
    required this.onVehicleCamera,
    required this.onPickVehicleYear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Kategori Kendaraan'),
        const SizedBox(height: 12),
        AppCard(
          child: DropdownField(
            label: 'Moda Transportasi',
            value: vehicleCategory,
            items: const [
              'Sepeda Motor',
              'Mobil Pribadi',
              'Mobil Komersial',
              'Pickup / Truk UMKM',
            ],
            onChanged: onCategoryChanged,
          ),
        ),
        const SizedBox(height: 16),
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
                label: 'Nomor Polisi',
                hintText: 'B 1234 ABC',
                controller: controllers.plateNumber,
              ),
              InputField(
                label: 'Nomor STNK',
                hintText: 'STNK-001-234-567',
                controller: controllers.stnkNumber,
              ),
              InputField(
                label: 'Merk Kendaraan',
                hintText: 'Honda',
                controller: controllers.brand,
              ),
              InputField(
                label: 'Tipe Kendaraan',
                hintText: 'Vario 125',
                controller: controllers.vehicleType,
              ),
              InputField(
                label: 'Tahun Kendaraan',
                hintText: '2019',
                controller: controllers.vehicleYear,
                readOnly: true,
                onTap: onPickVehicleYear,
              ),
              InputField(
                label: 'Warna Kendaraan',
                hintText: 'Hitam',
                controller: controllers.vehicleColor,
              ),
              InputField(
                label: 'Kapasitas Mesin (CC)',
                hintText: '125',
                controller: controllers.vehicleCc,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionTitle('Data Pajak & Ekonomi'),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: [
              InputField(
                label: 'Nilai Pajak Tahunan (PKB)',
                hintText: '450000',
                controller: controllers.taxValue,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
