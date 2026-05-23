import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../data/vehicle_api_repository.dart';
import '../../domain/vehicle_submission_result.dart';
import '../../../verification/presentation/screens/steps/verification_form_state.dart';
import '../../../verification/presentation/screens/steps/verification_form_widgets.dart';
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
  String _usageType = 'PERSONAL';
  bool _sharedVehicle = false;
  bool _agreeData = false;
  bool _agreeRisk = false;
  bool _agreeAi = false;

  final _controllers = VerificationFormControllers();
  final _picker = ImagePicker();
  final _vehicleRepository = VehicleApiRepository();

  String? _stnkPhotoPath;
  String? _vehiclePhotoPath;
  String? _productiveBusinessDocPath;
  bool _isSubmitting = false;

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
                        onPressed: _isSubmitting ? null : _handleContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(_isLastStep ? 'Submit' : 'Lanjut'),
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
        'Penggunaan & Dokumen Tambahan',
        'Kondisi Rumah Tangga',
        'Pakta Integritas',
      ];

  List<Widget> get _stepWidgets => [
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
        _HouseholdOnlyStep(
          sharedVehicle: _sharedVehicle,
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

  Future<void> _handleContinue() async {
    if (_isLastStep) {
      if (_validateBeforeSubmit()) {
        await _submitVehicle();
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
    } else if (_controllers.stnkNumber.text.trim().isEmpty) {
      message = 'Nomor STNK wajib diisi.';
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

  Future<void> _showPendingReviewDialog() async {
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
                  'Pengajuan sedang ditinjau',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Dokumen kendaraan usaha Anda berhasil dikirim dan sedang diperiksa admin. Kami akan mengaktifkan kendaraan setelah verifikasi selesai.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      context.go('/vehicles');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Kembali ke Kendaraan'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitVehicle() async {
    final stnkPhotoPath = _stnkPhotoPath;
    final vehiclePhotoPath = _vehiclePhotoPath;
    if (stnkPhotoPath == null || vehiclePhotoPath == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await _vehicleRepository.submitVehicle(
        registrationNumber: _controllers.stnkNumber.text.trim(),
        usageType: _usageType,
        stnkPhotoPath: stnkPhotoPath,
        vehiclePhotoPath: vehiclePhotoPath,
        productiveBusinessProofPath: _productiveBusinessDocPath,
      );

      if (!mounted) {
        return;
      }

      if (result.submissionType == VehicleSubmissionType.pendingReview) {
        await _showPendingReviewDialog();
      } else {
        await _showSuccessDialog();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
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
