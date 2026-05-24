import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../data/wallet_providers.dart';

class TopUpStatusScreen extends ConsumerStatefulWidget {
  final String topupId;
  final String paymentLinkUrl;
  final int amount;

  const TopUpStatusScreen({
    super.key,
    required this.topupId,
    required this.paymentLinkUrl,
    required this.amount,
  });

  @override
  ConsumerState<TopUpStatusScreen> createState() => _TopUpStatusScreenState();
}

class _TopUpStatusScreenState extends ConsumerState<TopUpStatusScreen> {
  Timer? _timer;
  String _status = 'PENDING'; // PENDING, PAID, FAILED, EXPIRED
  bool _isChecking = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    if (_isChecking) return;

    setState(() => _isChecking = true);

    try {
      final repo = ref.read(walletApiRepositoryProvider);
      final tx = await repo.pollTopUpStatus(widget.topupId);
      final newStatus = (tx['status'] as String? ?? 'PENDING').toUpperCase();

      if (mounted) {
        setState(() {
          _status = newStatus;
          _errorMessage = null;
        });

        if (newStatus == 'PAID') {
          _timer?.cancel();
          ref.invalidate(walletProvider);
        } else if (newStatus == 'FAILED' || newStatus == 'EXPIRED') {
          _timer?.cancel();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _relaunchPaymentUrl() async {
    final uri = Uri.parse(widget.paymentLinkUrl);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        throw Exception('Gagal membuka halaman pembayaran.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    }
  }

  Widget _buildPendingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 100,
          width: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryRed.withAlpha((0.15 * 255).round()),
                ),
                strokeWidth: 8,
                value: 1.0,
              ),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
                strokeWidth: 8,
              ),
              const Icon(
                Icons.hourglass_empty_rounded,
                color: AppColors.primaryRed,
                size: 36,
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .rotate(duration: 2000.ms, curve: Curves.easeInOut),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Menunggu Pembayaran',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0.0),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Silakan selesaikan pembayaran Anda di halaman Xendit yang telah dibuka.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
          ),
        ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: AppCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nominal Top Up',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    Text(
                      formatCurrencyIdr(widget.amount),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Metode',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    Text(
                      'Xendit Payment Link',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryRed.withAlpha((0.85 * 255).round()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _relaunchPaymentUrl,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Buka Kembali Halaman Pembayaran'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isChecking ? null : _checkStatus,
                      icon: _isChecking
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryRed),
                              ),
                            )
                          : const Icon(Icons.sync_rounded),
                      label: const Text('Cek Status'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryRed,
                        side: const BorderSide(color: AppColors.primaryRed),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: () => context.pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Kembali'),
                    ),
                  ),
                ],
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.primaryRed, fontSize: 13),
                ),
              ]
            ],
          ),
        ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 110,
          width: 110,
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4ADE80).withAlpha((0.3 * 255).round()),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ],
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 64,
          ),
        )
            .animate()
            .scale(
              duration: 500.ms,
              curve: Curves.elasticOut,
              begin: const Offset(0.3, 0.3),
            )
            .fadeIn(duration: 300.ms),
        const SizedBox(height: 32),
        Text(
          'Top Up Berhasil!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.success,
              ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0.0),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Saldo E-KTP Anda telah berhasil dikreditkan. Uang Anda sekarang sudah dikelola secara aman di dalam aplikasi.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
          ),
        ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: AppCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nominal Dikreditkan',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    Text(
                      formatCurrencyIdr(widget.amount),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.success,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status Transaksi',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    Text(
                      'SUKSES / PAID',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Kembali ke E-Wallet'),
            ),
          ),
        ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
      ],
    );
  }

  Widget _buildFailedState(String title, Color accentColor, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 110,
          width: 110,
          decoration: BoxDecoration(
            color: accentColor.withAlpha((0.15 * 255).round()),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: accentColor,
            size: 64,
          ),
        ).animate().scale(duration: 400.ms).fadeIn(),
        const SizedBox(height: 32),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: accentColor,
              ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0.0),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Halaman pembayaran ini sudah kedaluwarsa atau transaksi dibatalkan. Silakan coba lagi jika diperlukan.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
          ),
        ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Kembali ke E-Wallet'),
            ),
          ),
        ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (_status) {
      case 'PAID':
        content = _buildSuccessState();
        break;
      case 'FAILED':
        content = _buildFailedState(
          'Top Up Gagal',
          AppColors.primaryRed,
          Icons.error_outline_rounded,
        );
        break;
      case 'EXPIRED':
        content = _buildFailedState(
          'Pembayaran Kedaluwarsa',
          Colors.orange,
          Icons.alarm_off_rounded,
        );
        break;
      default:
        content = _buildPendingState();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: content,
          ),
        ),
      ),
    );
  }
}
