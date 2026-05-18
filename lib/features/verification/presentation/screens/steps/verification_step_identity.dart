import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/app_card.dart';
import 'verification_form_state.dart';
import 'verification_form_widgets.dart';

class VerificationIdentityStep extends StatelessWidget {
  final VerificationFormControllers controllers;
  final String gender;
  final ValueChanged<String?> onGenderChanged;
  final String occupation;
  final ValueChanged<String?> onOccupationChanged;
  final VoidCallback onPickDob;

  const VerificationIdentityStep({
    super.key,
    required this.controllers,
    required this.gender,
    required this.onGenderChanged,
    required this.occupation,
    required this.onOccupationChanged,
    required this.onPickDob,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Data Pribadi'),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: [
              const ReadOnlyField(
                label: 'Nama Lengkap',
                value: 'Ahmad Pratama',
              ),
              const ReadOnlyField(label: 'NIK', value: '3201123456789012'),
              const ReadOnlyField(
                label: 'Nomor KK',
                value: '3201123456789012',
              ),
              InputField(
                label: 'Tanggal Lahir',
                hintText: '12/05/1995',
                controller: controllers.dob,
                readOnly: true,
                onTap: onPickDob,
              ),
              DropdownField(
                label: 'Jenis Kelamin',
                value: gender,
                items: const ['Laki-laki', 'Perempuan'],
                onChanged: onGenderChanged,
              ),
              InputField(
                label: 'Nomor HP',
                hintText: '0812 3456 7890',
                controller: controllers.phone,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              DropdownField(
                label: 'Status Pekerjaan',
                value: occupation,
                items: const [
                  'Pelajar/Mahasiswa',
                  'Pegawai',
                  'Guru',
                  'UMKM',
                  'Driver Ojol',
                  'Logistik',
                  'Petani',
                  'Nelayan',
                  'Lainnya',
                ],
                onChanged: onOccupationChanged,
              ),
              const ReadOnlyField(
                label: 'Email',
                value: 'ahmad@email.com',
              ),
              InputField(
                label: 'Alamat Domisili',
                hintText: 'Jl. Merdeka 12',
                controller: controllers.address,
              ),
              InputField(
                label: 'Provinsi',
                hintText: 'DKI Jakarta',
                controller: controllers.province,
              ),
              InputField(
                label: 'Kota/Kabupaten',
                hintText: 'Jakarta Selatan',
                controller: controllers.city,
              ),
              InputField(
                label: 'Kecamatan',
                hintText: 'Tebet',
                controller: controllers.district,
              ),
              InputField(
                label: 'Kelurahan',
                hintText: 'Tebet Barat',
                controller: controllers.subdistrict,
              ),
              InputField(
                label: 'Kode Pos',
                hintText: '12810',
                controller: controllers.postalCode,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionTitle('Upload Dokumen'),
        const SizedBox(height: 12),
        AppCard(
          child: Row(
            children: const [
              Expanded(
                child: DocumentTile(
                  icon: Icons.credit_card,
                  title: 'Foto KTP',
                  subtitle: 'Tersimpan dari registrasi',
                  statusLabel: 'Terkirim',
                  statusColor: AppColors.success,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: DocumentTile(
                  icon: Icons.face_retouching_natural,
                  title: 'Selfie Verification',
                  subtitle: 'Tersimpan dari registrasi',
                  statusLabel: 'Terkirim',
                  statusColor: AppColors.success,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
