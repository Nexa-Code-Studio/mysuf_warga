import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../data/wallet_providers.dart';

class TopUpScreen extends ConsumerStatefulWidget {
  const TopUpScreen({super.key});

  @override
  ConsumerState<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends ConsumerState<TopUpScreen> {
  final TextEditingController _amountController = TextEditingController();
  final List<int> _presetAmounts = [50000, 100000, 200000, 500000];
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _formatAmount(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
  }

  void _applyPreset(int amount) {
    _amountController.text = _formatAmount(amount);
  }

  int _parseAmount() {
    final text = _amountController.text.replaceAll('.', '').trim();
    return int.tryParse(text) ?? 0;
  }

  Future<void> _handlePayment() async {
    final amount = _parseAmount();
    if (amount < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal nominal top up adalah Rp 10.000'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ref
          .read(walletApiRepositoryProvider)
          .createTopUpSession(amount.toDouble());

      final paymentLinkUrl = result['payment_link_url'] as String?;
      final topupId = result['id'] as String?;

      if (paymentLinkUrl == null || topupId == null) {
        throw Exception('Response top up dari server tidak valid.');
      }

      final uri = Uri.parse(paymentLinkUrl);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        throw Exception('Gagal membuka halaman pembayaran.');
      }

      if (mounted) {
        context.pushReplacement(
          '/wallet/topup/status',
          extra: {
            'id': topupId,
            'payment_link_url': paymentLinkUrl,
            'amount': amount,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal membuat session pembayaran: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      appBar: AppBar(title: const Text('Top Up Saldo')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nominal Top Up',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        hintText: 'Masukkan nominal',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Rp',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _presetAmounts
                          .map(
                            (amount) => _AmountChip(
                              label: _formatAmount(amount),
                              isSelected:
                                  _amountController.text == _formatAmount(amount),
                              onTap: _isLoading
                                  ? () {}
                                  : () => setState(() => _applyPreset(amount)),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Metode Pembayaran',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    _MethodTile(
                      title: 'Xendit Payment Session',
                      subtitle: 'Dukungan QRIS, VA, E-Wallet & Retail',
                      isSelected: true,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Lanjutkan Pembayaran'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AmountChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryRed : AppColors.softGray,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          'Rp $label',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodTile({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryRed,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet_outlined,
                color: AppColors.primaryRed),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.radio_button_checked,
              color: AppColors.primaryRed,
            ),
          ],
        ),
      ),
    );
  }
}
