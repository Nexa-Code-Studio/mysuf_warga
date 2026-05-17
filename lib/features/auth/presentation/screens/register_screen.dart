import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/step_indicator.dart';

class RegisterScreen extends StatefulWidget {
  final int initialStep;

  const RegisterScreen({super.key, this.initialStep = 1});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late int _currentStep;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _dataFormKey = GlobalKey<FormState>();
  bool _autoValidateData = false;
  final _nameController = TextEditingController();
  final _nikController = TextEditingController();
  final _kkController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep.clamp(1, 3);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _kkController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step.clamp(1, 3);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daftar Akun'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StepIndicator(
                      steps: const ['Data Diri', 'Upload KTP', 'Verifikasi'],
                      currentStep: _currentStep,
                    ),
                    const SizedBox(height: 20),
                    _buildStepContent(context),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _currentStep == 1
                          ? SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  final isValid =
                                      _dataFormKey.currentState?.validate() ??
                                          false;
                                  if (!isValid) {
                                    setState(() {
                                      _autoValidateData = true;
                                    });
                                    return;
                                  }
                                  _goToStep(_currentStep + 1);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryRed,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text('Lanjut'),
                              ),
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      _goToStep(_currentStep - 1);
                                    },
                                    child: const Text('Kembali'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_currentStep == 3) {
                                        context.go('/home?verify=1');
                                      } else {
                                        _goToStep(_currentStep + 1);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryRed,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child:
                                        Text(_currentStep == 3 ? 'Selesai' : 'Lanjut'),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah Punya Akun? ',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Masuk'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    switch (_currentStep) {
      case 1:
        return _buildDataDiriStep(context);
      case 2:
        return _buildUploadKtpStep(context);
      case 3:
      default:
        return _buildVerificationStep(context);
    }
  }

  Widget _buildDataDiriStep(BuildContext context) {
    return Form(
      key: _dataFormKey,
      autovalidateMode: _autoValidateData
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Column(
        key: const ValueKey('step-1'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lengkapi data awal',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pastikan data sesuai KTP dan KK.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nama Lengkap',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Form wajib diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nikController,
            decoration: const InputDecoration(
              labelText: 'NIK',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) {
                return 'Form wajib diisi';
              }
              if (!RegExp(r'^\d{16}$').hasMatch(trimmed)) {
                return 'NIK harus 16 angka';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _kkController,
            decoration: const InputDecoration(
              labelText: 'Nomor Kartu Keluarga',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) {
                return 'Form wajib diisi';
              }
              if (!RegExp(r'^\d{16}$').hasMatch(trimmed)) {
                return 'Nomor KK harus 16 angka';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) {
                return 'Form wajib diisi';
              }
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                  .hasMatch(trimmed)) {
                return 'Email tidak valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Kata Sandi',
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) {
                return 'Form wajib diisi';
              }
              if (trimmed.length < 6) {
                return 'Kata sandi minimal 6 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Konfirmasi Kata Sandi',
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
              ),
            ),
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) {
                return 'Form wajib diisi';
              }
              if (trimmed != _passwordController.text.trim()) {
                return 'Konfirmasi kata sandi tidak sama';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUploadKtpStep(BuildContext context) {
    return Column(
      key: const ValueKey('step-2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unggah foto KTP',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pastikan foto jelas dan tidak terpotong.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 24),
        AppCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.softGray,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.document_scanner_outlined,
                  size: 48,
                  color: AppColors.primaryRed,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Ambil Foto KTP'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InfoCard(
          icon: Icons.info_outline,
          iconColor: AppColors.primaryRed,
          backgroundColor: const Color(0xFFFFF1F3),
          borderColor: const Color(0xFFFFC7CF),
          message:
              'Foto diproses otomatis dengan OCR. Format JPG/PNG, maks. 5 MB. Pastikan KTP terlihat jelas dan tidak buram.',
        ),
        const SizedBox(height: 12),
        _InfoCard(
          icon: Icons.lock_outline,
          iconColor: AppColors.warning,
          backgroundColor: const Color(0xFFFFF5E5),
          borderColor: const Color(0xFFFFD8A8),
          message:
              'Data identitas Anda dienkripsi dan hanya digunakan untuk proses verifikasi subsidi.',
        ),
      ],
    );
  }

  Widget _buildVerificationStep(BuildContext context) {
    return Column(
      key: const ValueKey('step-3'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verifikasi identitas',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selfie digunakan untuk mencocokkan data KTP.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 24),
        AppCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.softGray,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.face_retouching_natural,
                  size: 52,
                  color: AppColors.primaryRed,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Ambil Selfie'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InfoCard(
          icon: Icons.info_outline,
          iconColor: AppColors.primaryRed,
          backgroundColor: const Color(0xFFFFF1F3),
          borderColor: const Color(0xFFFFC7CF),
          message:
              'Pastikan wajah terlihat jelas dan tidak tertutup. Gunakan pencahayaan yang baik.',
        ),
        const SizedBox(height: 12),
        _InfoCard(
          icon: Icons.lock_outline,
          iconColor: AppColors.warning,
          backgroundColor: const Color(0xFFFFF5E5),
          borderColor: const Color(0xFFFFD8A8),
          message:
              'Foto selfie disimpan aman dan hanya digunakan untuk proses verifikasi identitas.',
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final String message;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
