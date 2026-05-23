import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/auth_repository.dart';
import '../../domain/registration_attempt.dart';

class RegistrationProcessingScreen extends StatefulWidget {
  final String? attemptId;

  const RegistrationProcessingScreen({super.key, this.attemptId});

  @override
  State<RegistrationProcessingScreen> createState() =>
      _RegistrationProcessingScreenState();
}

class _RegistrationProcessingScreenState
    extends State<RegistrationProcessingScreen> {
  final _authRepository = AuthRepository();
  Timer? _pollTimer;
  RegistrationAttempt? _attempt;
  String? _attemptId;
  String? _errorMessage;
  bool _isRefreshing = false;
  DateTime? _lastRefreshAt;

  @override
  void initState() {
    super.initState();
    _restoreAndStart();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _restoreAndStart() async {
    final restoredAttemptId =
        widget.attemptId ??
        await _authRepository.loadPendingRegistrationAttemptId();

    if (!mounted) {
      return;
    }

    if (restoredAttemptId == null || restoredAttemptId.isEmpty) {
      setState(() {
        _errorMessage = 'Data proses pendaftaran tidak ditemukan.';
      });
      return;
    }

    setState(() {
      _attemptId = restoredAttemptId;
    });

    await _refreshStatus(force: true);
    _startPollingIfNeeded();
  }

  Future<void> _refreshStatus({bool force = false}) async {
    if (_attemptId == null || _attemptId!.isEmpty || _isRefreshing) {
      return;
    }

    final now = DateTime.now();
    if (!force &&
        _lastRefreshAt != null &&
        now.difference(_lastRefreshAt!) <
            AppConstants.registrationRefreshDebounce) {
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    try {
      final attempt = await _authRepository.getRegistrationAttemptStatus(
        _attemptId!,
      );
      if (!mounted) {
        return;
      }
      _lastRefreshAt = DateTime.now();
      setState(() {
        _attempt = attempt;
        _errorMessage = null;
      });

      if (attempt.isTerminal) {
        _pollTimer?.cancel();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void _startPollingIfNeeded() {
    _pollTimer?.cancel();
    if (_attempt != null && !_attempt!.isProcessing) {
      return;
    }

    _pollTimer = Timer.periodic(AppConstants.registrationPollInterval, (_) {
      _refreshStatus();
    });
  }

  Future<void> _finishSuccessFlow() async {
    await _authRepository.clearPendingRegistrationAttemptId();
    if (!mounted) {
      return;
    }
    context.go('/login');
  }

  Future<void> _backToRegistration() async {
    await _authRepository.clearPendingRegistrationAttemptId();
    if (!mounted) {
      return;
    }
    context.go('/register');
  }

  String _statusTitle() {
    final status = _attempt?.status;
    switch (status) {
      case RegistrationAttemptStatus.completed:
        return 'Verifikasi Berhasil';
      case RegistrationAttemptStatus.failed:
        return 'Verifikasi Gagal';
      case RegistrationAttemptStatus.processing:
      case RegistrationAttemptStatus.pending:
      case RegistrationAttemptStatus.reviewRequired:
      case RegistrationAttemptStatus.verified:
        return 'Verifikasi Sedang Diproses';
      default:
        return 'Proses Pendaftaran';
    }
  }

  String _statusDescription() {
    if (_errorMessage != null && _attempt == null) {
      return _errorMessage!;
    }

    final attempt = _attempt;
    if (attempt == null) {
      return 'Mohon tunggu, kami sedang mengambil status pendaftaran Anda.';
    }

    switch (attempt.status) {
      case RegistrationAttemptStatus.completed:
        return 'Akun Anda berhasil dibuat. Silakan lanjutkan ke halaman login untuk masuk ke aplikasi.';
      case RegistrationAttemptStatus.failed:
        return _failureMessage(attempt.failureReason, attempt.failureDetail);
      case RegistrationAttemptStatus.processing:
      case RegistrationAttemptStatus.pending:
      case RegistrationAttemptStatus.reviewRequired:
      case RegistrationAttemptStatus.verified:
        return 'Kami sedang memverifikasi foto KTP dan selfie Anda. Anda boleh menutup aplikasi dan kembali ke halaman ini nanti.';
      case RegistrationAttemptStatus.unknown:
        return 'Status pendaftaran belum dapat dikenali. Silakan segarkan halaman ini.';
    }
  }

  String _failureMessage(String? reason, String? detail) {
    switch (reason) {
      case 'NIK_OCR_MISMATCH':
        return 'NIK pada foto KTP tidak cocok dengan NIK yang Anda masukkan.';
      case 'NIK_NOT_FOUND':
        return 'NIK tidak ditemukan pada data registri warga.';
      case 'NIK_OCR_NOT_FOUND':
      case 'NIK_OCR_INVALID':
        return 'Sistem tidak berhasil membaca NIK dari foto KTP. Silakan ambil ulang foto KTP dengan lebih jelas.';
      case 'FACE_MISMATCH':
        return 'Wajah pada selfie tidak cocok dengan foto pada KTP.';
      case 'FACE_NOT_FOUND_IN_SELFIE':
        return 'Wajah tidak terdeteksi pada selfie. Pastikan wajah terlihat jelas di dalam oval.';
      case 'MULTIPLE_FACES_IN_SELFIE':
        return 'Terdapat lebih dari satu wajah pada selfie. Pastikan hanya Anda yang terlihat di frame.';
      case 'IMAGE_TOO_BLURRY':
        return 'Foto terlalu buram. Silakan ambil ulang dengan posisi lebih stabil.';
      case 'IMAGE_TOO_DARK':
        return 'Foto terlalu gelap. Gunakan pencahayaan yang lebih baik.';
      case 'IMAGE_TOO_BRIGHT':
        return 'Foto terlalu terang. Hindari pantulan cahaya langsung.';
      case 'IMAGE_TOO_SMALL':
        return 'Resolusi foto terlalu kecil untuk diverifikasi. Ambil ulang dengan kualitas yang lebih baik.';
      case 'KTP_CARD_NOT_CLEAR':
        return 'Kartu KTP tidak terlihat jelas. Pastikan seluruh kartu terlihat dan tidak silau.';
      default:
        return detail ?? 'Verifikasi tidak berhasil. Silakan coba lagi.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_attempt == null || _attempt!.isProcessing) ...[
                  const CircularProgressIndicator(color: AppColors.primaryRed),
                ] else if (_attempt!.status ==
                    RegistrationAttemptStatus.completed) ...[
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 56,
                  ),
                ] else ...[
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.warning,
                    size: 56,
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  _statusTitle(),
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  _statusDescription(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (_attemptId != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'ID proses: $_attemptId',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isRefreshing ? null : () => _refreshStatus(),
                    icon: const Icon(Icons.refresh),
                    label: Text(_isRefreshing ? 'Memuat...' : 'Refresh'),
                  ),
                ),
                if (_attempt != null &&
                    _attempt!.status ==
                        RegistrationAttemptStatus.completed) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _finishSuccessFlow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Masuk ke Akun'),
                    ),
                  ),
                ],
                if (_attempt != null &&
                    _attempt!.status == RegistrationAttemptStatus.failed) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _backToRegistration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Kembali ke Pendaftaran'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
