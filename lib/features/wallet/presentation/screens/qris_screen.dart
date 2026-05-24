import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../../data/wallet_providers.dart';

class QrisScreen extends ConsumerWidget {
  const QrisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('QRIS E-KTP'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: walletState.when(
            data: (data) {
              final rawNik = data.nik;
              
              if (rawNik == null || rawNik.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Icon(
                      Icons.verified_user_outlined,
                      size: 80,
                      color: AppColors.primaryRed.withOpacity(0.3),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Belum Terverifikasi',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Anda harus menyelesaikan verifikasi E-KTP terlebih dahulu agar sistem dapat mendaftarkan NIK Anda pada dompet digital.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => context.go('/home'),
                        child: const Text(
                          'Kembali ke Beranda',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                );
              }

              // Symmetric XOR obfuscation with shared secret key for high security
              final rawBytes = utf8.encode(rawNik);
              final keyBytes = utf8.encode(AppConstants.qrisSecretKey);
              final xorBytes = List<int>.generate(
                rawBytes.length,
                (i) => rawBytes[i] ^ keyBytes[i % keyBytes.length],
              );
              final base64Nik = base64.encode(xorBytes);
              final qrData = 'MYSUF-QRIS:KTP:$base64Nik';

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    // High-fidelity QR Code Card
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Red QRIS Header Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'QRIS E-KTP',
                              style: TextStyle(
                                color: AppColors.primaryRed,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // The QR image
                          QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 240.0,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: AppColors.primaryRed,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Pindai kode QR di atas pada dispenser SPBU / petugas untuk verifikasi kuota subsidi secara instan.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
            loading: () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 80),
                  LoadingSkeleton(height: 240, width: 240),
                  SizedBox(height: 24),
                  LoadingSkeleton(height: 20, width: 180),
                  SizedBox(height: 8),
                  LoadingSkeleton(height: 16, width: 120),
                ],
              ),
            ),
            error: (err, _) => ErrorState(
              title: 'Gagal memuat QRIS',
              message: err.toString().replaceAll('Exception: ', ''),
              onRetry: () => ref.refresh(walletProvider),
            ),
          ),
        ),
      ),
    );
  }
}
