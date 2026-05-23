import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import 'steps/verification_form_state.dart';
import 'steps/verification_step_household.dart';
import 'steps/verification_step_identity.dart';
import 'steps/verification_step_review.dart';
import 'steps/verification_step_usage.dart';
import 'steps/verification_step_vehicle.dart';

class SubsidyVerificationScreen extends StatefulWidget {
  const SubsidyVerificationScreen({super.key});

  @override
  State<SubsidyVerificationScreen> createState() =>
      _SubsidyVerificationScreenState();
}

class _SubsidyVerificationScreenState extends State<SubsidyVerificationScreen> {
  int _currentStep = 0;
  String _gender = 'Laki-laki';
  String _usageType = 'PERSONAL';
  String _occupation = 'UMKM';
  String _householdVehicles = '1-2 Kendaraan';
  bool _sharedVehicle = false;
  String _resultStatus = 'Pending Review';
  bool _agreeData = false;
  bool _agreeRisk = false;
  bool _agreeAi = false;

  final _controllers = VerificationFormControllers();
  final _picker = ImagePicker();

  String? _stnkPhotoPath;
  String? _vehiclePhotoPath;
  String? _productiveBusinessDocPath;

  final List<FamilyMember> _members = const [
    FamilyMember('Siti Rahma', 'Istri', true),
    FamilyMember('Ardi Saputra', 'Anak', false),
    FamilyMember('Yusuf Ahmad', 'Ayah', true),
  ];

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verifikasi Subsidi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
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
        'Verifikasi Identitas',
        'Linking Kendaraan',
        'Penggunaan & Dokumen Tambahan',
        'Kondisi Rumah Tangga',
        'Review & Pakta Integritas',
      ];

  List<Widget> get _stepWidgets => [
        VerificationIdentityStep(
          controllers: _controllers,
          gender: _gender,
          onGenderChanged: (value) {
            if (value == null) {
              return;
            }
            setState(() {
              _gender = value;
            });
          },
          occupation: _occupation,
          onOccupationChanged: (value) {
            if (value == null) {
              return;
            }
            setState(() {
              _occupation = value;
            });
          },
          onPickDob: _pickDob,
        ),
        VerificationVehicleStep(
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
        ),
        VerificationUsageStep(
          usageType: _usageType,
          onUsageTypeChanged: (value) {
            if (value == null) {
              return;
            }
            setState(() {
              _usageType = value;
            });
          },
          productiveBusinessDocName: _fileLabel(_productiveBusinessDocPath),
          onProductiveBusinessCamera: () => _pickImage(
            ImageSource.camera,
            (path) => _productiveBusinessDocPath = path,
          ),
          onProductiveBusinessPick: () => _pickFile(
            (path) => _productiveBusinessDocPath = path,
          ),
        ),
        VerificationHouseholdStep(
          householdVehicles: _householdVehicles,
          onHouseholdChanged: (value) {
            if (value == null) {
              return;
            }
            setState(() {
              _householdVehicles = value;
            });
          },
          sharedVehicle: _sharedVehicle,
          members: _members,
          controllers: _controllers,
          onSharedChanged: (value) {
            setState(() {
              _sharedVehicle = value;
            });
          },
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

  void _handleContinue() {
    if (_isLastStep) {
      if (_validateBeforeSubmit()) {
        _showSubmitConfirmation();
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

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(now.year - 80),
      lastDate: now,
    );
    if (picked == null) {
      return;
    }
    final value =
        '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    setState(() {
      _controllers.dob.text = value;
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

  Future<void> _showSubmitConfirmation() async {
    final shouldSubmit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Periksa kembali data Anda',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pastikan semua data sudah benar sebelum dikirim.',
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
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(false),
                        child: const Text('Cek Lagi'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Submit'),
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

    if (shouldSubmit != true || !mounted) {
      return;
    }

    await _showResultDialog();
  }

  bool _validateBeforeSubmit() {
    String? message;

    if (_controllers.dob.text.trim().isEmpty) {
      message = 'Tanggal lahir wajib diisi.';
    } else if (_controllers.phone.text.trim().isEmpty) {
      message = 'Nomor HP wajib diisi.';
    } else if (_controllers.address.text.trim().isEmpty) {
      message = 'Alamat domisili wajib diisi.';
    } else if (_controllers.province.text.trim().isEmpty) {
      message = 'Provinsi wajib diisi.';
    } else if (_controllers.city.text.trim().isEmpty) {
      message = 'Kota/Kabupaten wajib diisi.';
    } else if (_controllers.district.text.trim().isEmpty) {
      message = 'Kecamatan wajib diisi.';
    } else if (_controllers.subdistrict.text.trim().isEmpty) {
      message = 'Kelurahan wajib diisi.';
    } else if (_controllers.postalCode.text.trim().isEmpty) {
      message = 'Kode pos wajib diisi.';
    } else if (_occupation.trim().isEmpty) {
      message = 'Status pekerjaan wajib dipilih.';
    } else if (_stnkPhotoPath == null) {
      message = 'Foto STNK wajib diambil.';
    } else if (_vehiclePhotoPath == null) {
      message = 'Foto kendaraan wajib diambil.';
    } else if (_controllers.stnkNumber.text.trim().isEmpty) {
      message = 'Nomor STNK wajib diisi.';
    } else if (_controllers.householdActiveCount.text.trim().isEmpty) {
      message = 'Jumlah anggota aktif berkendara wajib diisi.';
    } else if (_sharedVehicle && _controllers.sharedName.text.trim().isEmpty) {
      message = 'Nama anggota bersama wajib diisi.';
    } else if (_sharedVehicle && _controllers.sharedNik.text.trim().isEmpty) {
      message = 'NIK anggota bersama wajib diisi.';
    } else if (_sharedVehicle &&
        _controllers.sharedRelation.text.trim().isEmpty) {
      message = 'Relasi keluarga wajib diisi.';
    } else if ((_usageType == 'OJOL' || _usageType == 'UMKM') &&
        _productiveBusinessDocPath == null) {
      message = 'Bukti Usaha Produktif wajib dilampirkan.';
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

  Future<void> _showResultDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verifikasi berhasil dikirim',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Berikut hasil verifikasi sementara Anda:',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                _ResultRow(label: 'Status', value: _resultStatus),
                const _ResultRow(label: 'Kuota Subsidi', value: '120 L'),
                const _ResultRow(label: 'Jenis BBM Aktif', value: 'Pertalite'),
                const _ResultRow(label: 'Risk Score Fraud', value: '42'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      context.go('/home');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Kembali ke Dashboard'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
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
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
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
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.primaryRed),
            ),
          ),
        ],
      ),
    );
  }
}
