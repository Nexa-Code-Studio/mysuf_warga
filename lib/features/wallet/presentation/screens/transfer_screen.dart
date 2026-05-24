import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/providers/mock_providers.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../data/wallet_providers.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  final List<int> _presetAmounts = [10000, 50000, 100000, 200000];

  bool _isSearching = false;
  bool _isLoading = false;
  Map<String, dynamic>? _recipientData;
  String? _searchError;

  @override
  void dispose() {
    _nikController.dispose();
    _amountController.dispose();
    _pinController.dispose();
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
    setState(() {});
  }

  int _parseAmount() {
    final text = _amountController.text.replaceAll('.', '').trim();
    return int.tryParse(text) ?? 0;
  }

  Future<void> _handleSearchRecipient() async {
    final nik = _nikController.text.trim();
    if (nik.length < 12) {
      setState(() {
        _searchError = 'Format NIK tidak valid (minimal 12 digit)';
        _recipientData = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
      _recipientData = null;
    });

    try {
      final repository = ref.read(walletApiRepositoryProvider);
      final result = await repository.searchRecipient(nik);
      setState(() {
        _recipientData = result;
      });
    } catch (e) {
      setState(() {
        _searchError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _showPinVerificationSheet(bool isPinActive, double amount, String recipientName) async {
    _pinController.clear();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Verifikasi PIN',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Masukkan 6 digit PIN transaksi Anda untuk menyetujui transfer sebesar ${formatCurrencyIdr(amount.toInt())} ke $recipientName.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, letterSpacing: 16, fontWeight: FontWeight.w700),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (val) {
                    if (val == null || val.length != 6) {
                      return 'Masukkan 6 digit PIN';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: '******',
                    hintStyle: TextStyle(fontSize: 22, letterSpacing: 16),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.pop(context, _pinController.text);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Konfirmasi Transfer'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((enteredPin) {
      if (enteredPin != null && enteredPin is String) {
        _executeTransfer(enteredPin);
      }
    });
  }

  Future<void> _executeTransfer(String? pin) async {
    final amount = _parseAmount().toDouble();
    final recipientNik = _nikController.text.trim();
    final recipientName = _recipientData?['name'] ?? '';

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(walletApiRepositoryProvider);
      await repository.transfer(
        recipientNik: recipientNik,
        amount: amount,
        pin: pin,
      );

      // Invalidate balance and transaction history
      ref.invalidate(profileProvider);

      if (mounted) {
        _showSuccessDialog(amount, recipientName);
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog(double amount, String recipientName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Transfer Berhasil!',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  'Anda telah berhasil mengirimkan saldo ke penerima.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.softGray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Penerima', style: TextStyle(color: AppColors.textSecondary)),
                          Text(recipientName, style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Jumlah', style: TextStyle(color: AppColors.textSecondary)),
                          Text(formatCurrencyIdr(amount.toInt()), style: const TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Pop Transfer Screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Kembali ke Wallet'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleTransferInitiation(bool isPinActive, double balance) {
    final amount = _parseAmount();
    if (_recipientData == null) return;

    if (amount < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal nominal transfer adalah Rp 10.000'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
      return;
    }

    if (amount > balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo Anda tidak mencukupi'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
      return;
    }

    final recipientName = _recipientData?['name'] ?? '';

    if (isPinActive) {
      _showPinVerificationSheet(isPinActive, amount.toDouble(), recipientName);
    } else {
      _executeTransfer(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsyncValue = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transfer Saldo'),
        elevation: 0,
      ),
      body: profileAsyncValue.when(
        data: (profile) {
          final isVerified = profile.isVerified;
          final balance = profile.walletBalance.toDouble();
          final isPinActive = profile.isPinActive;

          if (!isVerified) {
            return const SafeArea(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: 64,
                        color: AppColors.primaryRed,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Akun Belum Terverifikasi',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Untuk alasan keamanan, fitur transfer dompet hanya tersedia untuk pengguna yang telah melakukan verifikasi identitas (KTP). Silakan verifikasi akun Anda terlebih dahulu.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CARD 1: Search Recipient
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cari Penerima',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _nikController,
                                keyboardType: TextInputType.number,
                                maxLength: 16,
                                enabled: !_isLoading && !_isSearching,
                                decoration: const InputDecoration(
                                  hintText: 'Masukkan NIK Penerima',
                                  counterText: '',
                                  prefixIcon: Icon(Icons.search),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _isLoading || _isSearching
                                  ? null
                                  : _handleSearchRecipient,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryRed,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isSearching
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text('Cari'),
                            ),
                          ],
                        ),
                        if (_searchError != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _searchError!,
                            style: const TextStyle(color: AppColors.primaryRed, fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // CARD 1.5: Recipient Found Detail (Clean Green Verified look)
                  if (_recipientData != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.shade300, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Penerima Ditemukan',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.green.shade800,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _recipientData!['name'],
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'NIK: ${_recipientData!['nik_masked']}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // CARD 2: Amount Input
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nominal Transfer',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Saldo Anda: ${formatCurrencyIdr(balance.toInt())}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
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
                                  (amt) => InkWell(
                                    onTap: _isLoading
                                        ? () {}
                                        : () => _applyPreset(amt),
                                    borderRadius: BorderRadius.circular(999),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: _amountController.text == _formatAmount(amt)
                                            ? AppColors.primaryRed
                                            : AppColors.softGray,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        'Rp ${_formatAmount(amt)}',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: _amountController.text == _formatAmount(amt)
                                                  ? Colors.white
                                                  : AppColors.textPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // BUTTON: Initiate
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () => _handleTransferInitiation(isPinActive, balance),
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
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Kirim Saldo'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
          ),
        ),
        error: (error, _) => Center(
          child: Text(
            'Gagal memuat saldo: $error',
            style: const TextStyle(color: AppColors.primaryRed),
          ),
        ),
      ),
    );
  }
}
