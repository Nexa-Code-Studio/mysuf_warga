import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/mock_providers.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../data/profile_repository.dart';

class SecurityPinScreen extends ConsumerStatefulWidget {
  const SecurityPinScreen({super.key});

  @override
  ConsumerState<SecurityPinScreen> createState() => _SecurityPinScreenState();
}

class _SecurityPinScreenState extends ConsumerState<SecurityPinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  String? _validatePin(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN tidak boleh kosong';
    }
    if (value.length != 6 || int.tryParse(value) == null) {
      return 'PIN harus berupa 6 digit angka';
    }
    return null;
  }

  Future<void> _handleSubmit(bool isPinActive) async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPinController.text != _confirmPinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi PIN baru tidak cocok'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(profileRepositoryProvider);
      await repository.updatePin(
        pin: _newPinController.text,
        oldPin: isPinActive ? _oldPinController.text : null,
      );

      // Invalidate profile state to refresh active indicator in settings
      ref.invalidate(profileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN keamanan transaksi berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    final profileAsyncValue = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('PIN Transaksi'),
        elevation: 0,
      ),
      body: profileAsyncValue.when(
        data: (profile) {
          final isPinActive = profile.isPinActive;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.security_outlined,
                                color: AppColors.primaryRed,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                isPinActive ? 'Ubah PIN Transaksi' : 'Buat PIN Transaksi',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isPinActive
                                ? 'Masukkan PIN lama Anda sebelum menentukan PIN baru.'
                                : 'PIN digunakan untuk mengamankan transaksi pengiriman saldo Anda.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (isPinActive) ...[
                      Text(
                        'PIN Lama',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _oldPinController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: _validatePin,
                        enabled: !_isLoading,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan 6 digit PIN lama',
                          counterText: '',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    Text(
                      isPinActive ? 'PIN Baru' : 'Buat PIN Baru',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _newPinController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: _validatePin,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        hintText: isPinActive
                            ? 'Masukkan 6 digit PIN baru'
                            : 'Buat 6 digit PIN baru',
                        counterText: '',
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Konfirmasi PIN Baru',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPinController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: _validatePin,
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        hintText: 'Ulangi 6 digit PIN baru',
                        counterText: '',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _handleSubmit(isPinActive),
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
                            : const Text('Simpan PIN'),
                      ),
                    ),
                  ],
                ),
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
            'Gagal memuat profil: $error',
            style: const TextStyle(color: AppColors.primaryRed),
          ),
        ),
      ),
    );
  }
}
