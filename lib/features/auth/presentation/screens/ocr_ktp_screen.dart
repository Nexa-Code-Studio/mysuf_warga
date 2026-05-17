import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/camera_capture_screen.dart';
import '../../../../shared/widgets/step_indicator.dart';

class OcrKtpScreen extends StatefulWidget {
  const OcrKtpScreen({super.key});

  @override
  State<OcrKtpScreen> createState() => _OcrKtpScreenState();
}

class _OcrKtpScreenState extends State<OcrKtpScreen> {
  String? _ktpPhotoPath;

  Future<void> _captureKtpPhoto() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const CameraCaptureScreen(
          title: 'Ambil Foto KTP',
          actionLabel: 'Ambil Foto KTP',
          helperText: 'Posisikan KTP di dalam bingkai dan pastikan fokus.',
          lensDirection: CameraLensDirection.back,
          overlayType: CameraOverlayType.ktp,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _ktpPhotoPath = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OCR KTP')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepIndicator(
                steps: ['Data Diri', 'Upload KTP', 'Verifikasi'],
                currentStep: 2,
              ),
              const SizedBox(height: 20),
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
                      child: _ktpPhotoPath == null
                          ? const Icon(
                              Icons.document_scanner_outlined,
                              size: 48,
                              color: AppColors.primaryRed,
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                File(_ktpPhotoPath!),
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _captureKtpPhoto,
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
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFC7CF)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.primaryRed),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Foto akan diproses otomatis. Format JPG/PNG, maks. 5 MB. Pastikan KTP terlihat jelas dan tidak buram.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5E5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD8A8)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lock_outline, color: AppColors.warning),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Data identitas Anda dienkripsi dan hanya digunakan untuk proses verifikasi subsidi.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/register'),
                      child: const Text('Kembali'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.go('/auth/selfie'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Lanjut Selfie'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
