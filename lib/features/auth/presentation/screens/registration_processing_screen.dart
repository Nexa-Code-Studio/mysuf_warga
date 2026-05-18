import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

class RegistrationProcessingScreen extends StatefulWidget {
  const RegistrationProcessingScreen({super.key});

  @override
  State<RegistrationProcessingScreen> createState() =>
      _RegistrationProcessingScreenState();
}

class _RegistrationProcessingScreenState
    extends State<RegistrationProcessingScreen> {
  static const _dotCycle = 4;
  static const _tickDuration = Duration(milliseconds: 450);
  static const _dialogDelay = Duration(milliseconds: 2200);

  Timer? _dotsTimer;
  Timer? _dialogTimer;
  int _dotCount = 0;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _dotsTimer = Timer.periodic(_tickDuration, (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _dotCount = (_dotCount + 1) % _dotCycle;
      });
    });
    _dialogTimer = Timer(_dialogDelay, () {
      if (mounted) {
        _showSuccessDialog();
      }
    });
  }

  @override
  void dispose() {
    _dotsTimer?.cancel();
    _dialogTimer?.cancel();
    super.dispose();
  }

  void _showSuccessDialog() {
    if (_dialogShown) {
      return;
    }
    _dialogShown = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Registrasi berhasil',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Akun Anda berhasil dibuat. Lanjutkan verifikasi untuk melihat kuota subsidi.',
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
                      context.go('/verification');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Verifikasi Sekarang'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      context.go('/home');
                    },
                    child: const Text('Nanti Saja'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * _dotCount;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: AppColors.primaryRed,
                ),
                const SizedBox(height: 16),
                Text(
                  'Sistem sedang memproses pendaftaran$dots',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mohon tunggu sebentar, kami sedang memverifikasi data Anda.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
