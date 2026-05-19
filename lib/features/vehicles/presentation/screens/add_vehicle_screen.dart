import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../verification/presentation/screens/steps/verification_form_state.dart';
import '../../../verification/presentation/screens/steps/verification_form_widgets.dart';
import '../../../verification/presentation/screens/steps/verification_step_additional_docs.dart';
import '../../../verification/presentation/screens/steps/verification_step_review.dart';
import '../../../verification/presentation/screens/steps/verification_step_usage.dart';
import '../../../verification/presentation/screens/steps/verification_step_vehicle.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  int _currentStep = 0;
  String _vehicleCategory = 'Sepeda Motor';
  String _ownershipStatus = 'Milik Pribadi';
  String _usagePurpose = 'Pribadi (Non-Komersial)';
  String _businessCategory = 'Non-komersial';
  String _usageIntensity = 'Normal';
  bool _sharedVehicle = false;
  bool _agreeData = false;
  bool _agreeRisk = false;
  bool _agreeAi = false;

  final _controllers = VerificationFormControllers();
  final _picker = ImagePicker();

  String? _stnkPhotoPath;
  String? _vehiclePhotoPath;
  String? _businessDocPath;
  String? _driverDocPath;
  String? _companyDocPath;
  String? _farmerDocPath;

  @override
  void dispose() {
    _controllers.dispose();
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

  bool get _isLastStep => _currentStep == _stepWidgets.length - 1;

  List<String> get _stepTitles => const [
        'Linking Kendaraan',
        'Kepemilikan & Penggunaan',
        'Kondisi Rumah Tangga',
        'Dokumen Tambahan',
        'Pakta Integritas',
      ];

  List<Widget> get _stepWidgets => [
        VerificationVehicleStep(
          vehicleCategory: _vehicleCategory,
          controllers: _controllers,
          stnkFileName: _fileLabel(_stnkPhotoPath),
          vehicleFileName: _fileLabel(_vehiclePhotoPath),
          onStnkCamera: () => _pickImage(
            ImageSource.camera,
            (path) => _stnkPhotoPath = path,
          ),
          onVehicleCamera: () => _pickImage(
            ImageSource.camera,
            (path) => _vehiclePhotoPath = path,
          ),
          onCategoryChanged: (value) {
            if (value == null) {
              return;
            }
            setState(() {
              _vehicleCategory = value;
            });
          },
        ),
        VerificationUsageStep(
          ownershipStatus: _ownershipStatus,
          usagePurpose: _usagePurpose,
          businessCategory: _businessCategory,
          usageIntensity: _usageIntensity,
          controllers: _controllers,
          purposeOptions: _purposeOptions,
          onOwnershipChanged: (value) {
            if (value == null) {
              return;
            }
            setState(() {
              _ownershipStatus = value;
              if (value == 'Milik Perusahaan' &&
                  _usagePurpose == 'Pribadi (Non-Komersial)') {
                _usagePurpose = 'Operasional Usaha';
              }
            });
          },
          onPurposeChanged: (value) {
            if (value == null) {
              return;
            }
            setState(() {
              _usagePurpose = value;
            });
          },
          onBusinessChanged: (value) {
            if (value == null) {
              return;
            }
            setState(() {
              _businessCategory = value;
            });
          },
          onIntensityChanged: (value) {
            if (value == null) {
              return;
            }
            setState(() {
              _usageIntensity = value;
            });
          },
        ),
        _HouseholdOnlyStep(
          sharedVehicle: _sharedVehicle,
          onSharedChanged: (value) {
            setState(() {
              _sharedVehicle = value;
            });
          },
        ),
        VerificationAdditionalDocsStep(
          usagePurpose: _usagePurpose,
          ownershipStatus: _ownershipStatus,
          controllers: _controllers,
          businessDocName: _fileLabel(_businessDocPath),
          driverDocName: _fileLabel(_driverDocPath),
          companyDocName: _fileLabel(_companyDocPath),
          farmerDocName: _fileLabel(_farmerDocPath),
          onBusinessCamera: () => _pickImage(
            ImageSource.camera,
            (path) => _businessDocPath = path,
          ),
          onBusinessPick: () => _pickFile(
            (path) => _businessDocPath = path,
          ),
          onDriverCamera: () => _pickImage(
            ImageSource.camera,
            (path) => _driverDocPath = path,
          ),
          onDriverPick: () => _pickFile(
            (path) => _driverDocPath = path,
          ),
          onCompanyCamera: () => _pickImage(
            ImageSource.camera,
            (path) => _companyDocPath = path,
          ),
          onCompanyPick: () => _pickFile(
            (path) => _companyDocPath = path,
          ),
          onFarmerCamera: () => _pickImage(
            ImageSource.camera,
            (path) => _farmerDocPath = path,
          ),
          onFarmerPick: () => _pickFile(
            (path) => _farmerDocPath = path,
          ),
        ),
        VerificationReviewStep(
          agreeData: _agreeData,
          agreeRisk: _agreeRisk,
          agreeAi: _agreeAi,
          onAgreeData: (value) {
            setState(() {
              _agreeData = value ?? false;
            });
          },
          onAgreeRisk: (value) {
            setState(() {
              _agreeRisk = value ?? false;
            });
          },
          onAgreeAi: (value) {
            setState(() {
              _agreeAi = value ?? false;
            });
          },
        ),
      ];

  List<String> get _purposeOptions {
    if (_ownershipStatus == 'Milik Perusahaan') {
      return const [
        'Operasional Usaha',
        'Logistik',
        'Driver Ojol',
        'Pertanian',
        'Nelayan',
      ];
    }
    return const [
      'Pribadi (Non-Komersial)',
      'Operasional Usaha',
      'Logistik',
      'Driver Ojol',
      'Pertanian',
      'Nelayan',
    ];
  }

  void _handleContinue() {
    if (_isLastStep) {
      if (_validateBeforeSubmit()) {
        _showSuccessDialog();
      }
      return;
    }
    setState(() {
      _currentStep += 1;
    });
  }

  void _handleBack() {
    if (_currentStep == 0) {
      return;
    }
    setState(() {
      _currentStep -= 1;
    });
  }

  Future<void> _pickImage(
    ImageSource source,
    ValueChanged<String> onSelected,
  ) async {
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file == null) {
      return;
    }
    setState(() {
      onSelected(file.path);
    });
  }

  Future<void> _pickFile(ValueChanged<String> onSelected) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    final path = result?.files.single.path;
    if (path == null) {
      return;
    }
    setState(() {
      onSelected(path);
    });
  }

  String? _fileLabel(String? path) {
    if (path == null || path.isEmpty) {
      return null;
    }
    final parts = path.split(RegExp(r'[\\/]'));
    return parts.isNotEmpty ? parts.last : path;
  }

  bool _validateBeforeSubmit() {
    String? message;

    if (_stnkPhotoPath == null) {
      message = 'Foto STNK wajib diambil.';
    } else if (_vehiclePhotoPath == null) {
      message = 'Foto kendaraan wajib diambil.';
    } else if (_controllers.plateNumber.text.trim().isEmpty) {
      message = 'Nomor polisi wajib diisi.';
    } else if (_controllers.stnkNumber.text.trim().isEmpty) {
      message = 'Nomor STNK wajib diisi.';
    } else if (_ownershipStatus == 'Milik Perusahaan' &&
        _controllers.companyName.text.trim().isEmpty) {
      message = 'Nama perusahaan wajib diisi.';
    } else if (_ownershipStatus == 'Milik Perusahaan' &&
        _controllers.companyId.text.trim().isEmpty) {
      message = 'ID perusahaan wajib diisi.';
    } else if (_usagePurpose == 'Operasional Usaha' &&
        _controllers.businessName.text.trim().isEmpty) {
      message = 'Nama usaha wajib diisi.';
    } else if (_usagePurpose != 'Pribadi (Non-Komersial)' &&
        _controllers.workLocation.text.trim().isEmpty) {
      message = 'Lokasi kerja/usaha wajib diisi.';
    } else if (_usagePurpose != 'Pribadi (Non-Komersial)' &&
        _controllers.distance.text.trim().isEmpty) {
      message = 'Estimasi jarak wajib diisi.';
    } else if (_usagePurpose == 'Operasional Usaha' &&
        _controllers.nibNumber.text.trim().isEmpty) {
      message = 'Nomor NIB/SKU wajib diisi.';
    } else if (_usagePurpose == 'Operasional Usaha' &&
        _businessDocPath == null) {
      message = 'Dokumen NIB/SKU wajib dilampirkan.';
    } else if (_usagePurpose == 'Driver Ojol' && _driverDocPath == null) {
      message = 'Bukti driver aktif wajib dilampirkan.';
    } else if ((_ownershipStatus == 'Milik Perusahaan' ||
            _usagePurpose == 'Logistik') &&
        _companyDocPath == null) {
      message = 'Surat operasional wajib dilampirkan.';
    } else if ((_usagePurpose == 'Pertanian' || _usagePurpose == 'Nelayan') &&
        _farmerDocPath == null) {
      message = 'Surat rekomendasi wajib dilampirkan.';
    } else if (!_agreeData || !_agreeRisk || !_agreeAi) {
      message = 'Semua persetujuan wajib dicentang.';
    }

    if (message == null) {
      return true;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    return false;
  }

  Future<void> _showSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kendaraan berhasil ditambahkan',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan cek kuota subsidi kendaraan Anda.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          context.go('/vehicles');
                        },
                        child: const Text('Nanti'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          context.go('/home/quota');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Cek Kuota'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
    final progress = currentStep / totalSteps;
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
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.softGray,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryRed),
            ),
          ),
        ],
      ),
    );
  }
}

class _HouseholdOnlyStep extends StatelessWidget {
  final bool sharedVehicle;
  final ValueChanged<bool> onSharedChanged;

  const _HouseholdOnlyStep({
    required this.sharedVehicle,
    required this.onSharedChanged,
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
            title: const Text('Kendaraan digunakan bersama?'),
            value: sharedVehicle,
            onChanged: onSharedChanged,
          ),
        ),
      ],
    );
  }
}
