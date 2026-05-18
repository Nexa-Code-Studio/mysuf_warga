import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../verification/presentation/screens/steps/verification_form_widgets.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  int _currentStep = 0;
  bool _sharedVehicle = false;
  bool _agreeData = false;
  bool _agreeUsage = false;
  bool _agreeRules = false;
  bool _showAgreementError = false;

  String _linkingSource = 'KTP';
  String _ownership = 'Pribadi';
  String _vehicleType = 'Roda 2';

  String? _stnkPhoto;
  String? _platePhoto;
  String? _extraDoc;

  final _plateController = TextEditingController();
  final _stnkController = TextEditingController();
  final _brandController = TextEditingController();
  final _typeController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _engineController = TextEditingController();
  final _companyController = TextEditingController();

  @override
  void dispose() {
    _plateController.dispose();
    _stnkController.dispose();
    _brandController.dispose();
    _typeController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _engineController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tambah Kendaraan')),
      body: SafeArea(
        child: Column(
          children: [
            _StepHeader(
              currentStep: _currentStep + 1,
              totalSteps: _stepTitles.length,
              title: _stepTitles[_currentStep],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: _stepWidgets[_currentStep],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  if (_currentStep > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _handleBack,
                        child: const Text('Kembali'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(_isLastStep ? 'Submit' : 'Lanjut'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> get _stepTitles => const [
        'Linking Kendaraan',
        'Kepemilikan',
        'Kondisi Rumah Tangga',
        'Dokumen Tambahan',
        'Pakta Integritas',
      ];

  List<Widget> get _stepWidgets => [
        _LinkingStep(
          linkingSource: _linkingSource,
          vehicleType: _vehicleType,
          plateController: _plateController,
          stnkController: _stnkController,
          brandController: _brandController,
          typeController: _typeController,
          yearController: _yearController,
          colorController: _colorController,
          engineController: _engineController,
          onLinkingChanged: (value) => setState(() => _linkingSource = value),
          onVehicleTypeChanged: (value) => setState(() => _vehicleType = value),
        ),
        _OwnershipStep(
          ownership: _ownership,
          companyController: _companyController,
          onOwnershipChanged: (value) => setState(() => _ownership = value),
        ),
        _HouseholdStep(
          sharedVehicle: _sharedVehicle,
          onChanged: (value) => setState(() => _sharedVehicle = value),
        ),
        _AdditionalDocsStep(
          stnkFileName: _stnkPhoto,
          plateFileName: _platePhoto,
          extraDocName: _extraDoc,
          onStnkCamera: () => _markDoc('Foto STNK diambil', (value) {
            _stnkPhoto = value;
          }),
          onStnkPick: () => _markDoc('Foto STNK terpilih', (value) {
            _stnkPhoto = value;
          }),
          onPlateCamera: () => _markDoc('Foto plat diambil', (value) {
            _platePhoto = value;
          }),
          onPlatePick: () => _markDoc('Foto plat terpilih', (value) {
            _platePhoto = value;
          }),
          onExtraPick: () => _markDoc('Dokumen tambahan terpilih', (value) {
            _extraDoc = value;
          }),
        ),
        _AgreementStep(
          agreeData: _agreeData,
          agreeUsage: _agreeUsage,
          agreeRules: _agreeRules,
          showError: _showAgreementError,
          onAgreeData: (value) => setState(() => _agreeData = value ?? false),
          onAgreeUsage: (value) => setState(() => _agreeUsage = value ?? false),
          onAgreeRules: (value) => setState(() => _agreeRules = value ?? false),
        ),
      ];

  bool get _isLastStep => _currentStep == _stepWidgets.length - 1;

  void _handleBack() {
    if (_currentStep == 0) {
      return;
    }
    setState(() => _currentStep -= 1);
  }

  void _handleContinue() {
    if (_isLastStep) {
      final allAgreed = _agreeData && _agreeUsage && _agreeRules;
      setState(() => _showAgreementError = !allAgreed);
      if (!allAgreed) {
        return;
      }
      context.go('/vehicles');
      return;
    }

    setState(() => _currentStep += 1);
  }

  void _markDoc(String label, ValueChanged<String> onSet) {
    setState(() => onSet(label));
  }
}

class _StepHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String title;

  const _StepHeader({
    required this.currentStep,
    required this.totalSteps,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step $currentStep dari $totalSteps',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _LinkingStep extends StatelessWidget {
  final String linkingSource;
  final String vehicleType;
  final TextEditingController plateController;
  final TextEditingController stnkController;
  final TextEditingController brandController;
  final TextEditingController typeController;
  final TextEditingController yearController;
  final TextEditingController colorController;
  final TextEditingController engineController;
  final ValueChanged<String> onLinkingChanged;
  final ValueChanged<String> onVehicleTypeChanged;

  const _LinkingStep({
    required this.linkingSource,
    required this.vehicleType,
    required this.plateController,
    required this.stnkController,
    required this.brandController,
    required this.typeController,
    required this.yearController,
    required this.colorController,
    required this.engineController,
    required this.onLinkingChanged,
    required this.onVehicleTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Sumber Data Kendaraan'),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: [
              DropdownField(
                label: 'Sumber Data',
                value: linkingSource,
                items: const ['KTP', 'KK', 'Dokumen Lain'],
                onChanged: (value) {
                  if (value == null) return;
                  onLinkingChanged(value);
                },
              ),
              InputField(
                label: 'Nomor Plat Kendaraan',
                hintText: 'B 1234 ABC',
                controller: plateController,
              ),
              InputField(
                label: 'Nomor STNK',
                hintText: 'STNK-0002341',
                controller: stnkController,
              ),
              DropdownField(
                label: 'Jenis Kendaraan',
                value: vehicleType,
                items: const ['Roda 2', 'Roda 4', 'Roda 6'],
                onChanged: (value) {
                  if (value == null) return;
                  onVehicleTypeChanged(value);
                },
              ),
              InputField(
                label: 'Merk',
                hintText: 'Toyota',
                controller: brandController,
              ),
              InputField(
                label: 'Tipe',
                hintText: 'Avanza 1.5 G',
                controller: typeController,
              ),
              InputField(
                label: 'Tahun',
                hintText: '2020',
                controller: yearController,
                keyboardType: TextInputType.number,
              ),
              InputField(
                label: 'Warna',
                hintText: 'Hitam',
                controller: colorController,
              ),
              InputField(
                label: 'Kapasitas Mesin (cc)',
                hintText: '1496',
                controller: engineController,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OwnershipStep extends StatelessWidget {
  final String ownership;
  final TextEditingController companyController;
  final ValueChanged<String> onOwnershipChanged;

  const _OwnershipStep({
    required this.ownership,
    required this.companyController,
    required this.onOwnershipChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Kepemilikan'),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: [
              DropdownField(
                label: 'Status Kepemilikan',
                value: ownership,
                items: const ['Pribadi', 'Perusahaan'],
                onChanged: (value) {
                  if (value == null) return;
                  onOwnershipChanged(value);
                },
              ),
              if (ownership == 'Perusahaan')
                InputField(
                  label: 'Nama Perusahaan',
                  hintText: 'PT Contoh Sejahtera',
                  controller: companyController,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HouseholdStep extends StatelessWidget {
  final bool sharedVehicle;
  final ValueChanged<bool> onChanged;

  const _HouseholdStep({
    required this.sharedVehicle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Kondisi Rumah Tangga'),
        const SizedBox(height: 12),
        AppCard(
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: sharedVehicle,
            onChanged: onChanged,
            title: const Text('Kendaraan digunakan bersama keluarga'),
            subtitle: Text(
              sharedVehicle
                  ? 'Kendaraan bisa digunakan oleh anggota keluarga.'
                  : 'Kendaraan hanya digunakan pemilik terdaftar.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}

class _AdditionalDocsStep extends StatelessWidget {
  final String? stnkFileName;
  final String? plateFileName;
  final String? extraDocName;
  final VoidCallback onStnkCamera;
  final VoidCallback onStnkPick;
  final VoidCallback onPlateCamera;
  final VoidCallback onPlatePick;
  final VoidCallback onExtraPick;

  const _AdditionalDocsStep({
    required this.stnkFileName,
    required this.plateFileName,
    required this.extraDocName,
    required this.onStnkCamera,
    required this.onStnkPick,
    required this.onPlateCamera,
    required this.onPlatePick,
    required this.onExtraPick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Dokumen Tambahan'),
        const SizedBox(height: 12),
        UploadTile(
          title: 'Foto STNK',
          subtitle: 'Ambil atau pilih foto STNK',
          fileName: stnkFileName,
          onCamera: onStnkCamera,
          onPick: onStnkPick,
        ),
        const SizedBox(height: 12),
        UploadTile(
          title: 'Foto Plat Kendaraan',
          subtitle: 'Ambil atau pilih foto plat',
          fileName: plateFileName,
          onCamera: onPlateCamera,
          onPick: onPlatePick,
        ),
        const SizedBox(height: 12),
        UploadTile(
          title: 'Dokumen Tambahan',
          subtitle: 'Unggah dokumen pendukung',
          fileName: extraDocName,
          onPick: onExtraPick,
        ),
      ],
    );
  }
}

class _AgreementStep extends StatelessWidget {
  final bool agreeData;
  final bool agreeUsage;
  final bool agreeRules;
  final bool showError;
  final ValueChanged<bool?> onAgreeData;
  final ValueChanged<bool?> onAgreeUsage;
  final ValueChanged<bool?> onAgreeRules;

  const _AgreementStep({
    required this.agreeData,
    required this.agreeUsage,
    required this.agreeRules,
    required this.showError,
    required this.onAgreeData,
    required this.onAgreeUsage,
    required this.onAgreeRules,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Pakta Integritas'),
        const SizedBox(height: 8),
        AgreementTile(
          value: agreeData,
          label: 'Data kendaraan yang saya isi adalah benar.',
          onChanged: onAgreeData,
        ),
        AgreementTile(
          value: agreeUsage,
          label: 'Kendaraan digunakan sesuai ketentuan subsidi.',
          onChanged: onAgreeUsage,
        ),
        AgreementTile(
          value: agreeRules,
          label: 'Saya siap mengikuti proses verifikasi tambahan.',
          onChanged: onAgreeRules,
        ),
        if (showError) ...[
          const SizedBox(height: 8),
          Text(
            'Semua persetujuan wajib dicentang.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.danger),
          ),
        ],
      ],
    );
  }
}
