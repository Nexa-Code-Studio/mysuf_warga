import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/mock_providers.dart';
import '../../../../shared/widgets/app_card.dart';

class UpdateNfcScreen extends ConsumerStatefulWidget {
  const UpdateNfcScreen({super.key});

  @override
  ConsumerState<UpdateNfcScreen> createState() => _UpdateNfcScreenState();
}

class _UpdateNfcScreenState extends ConsumerState<UpdateNfcScreen> {
  bool _isScanning = false;
  bool _isSaving = false;
  String _statusText =
      'Tempelkan E-KTP ke bagian belakang perangkat untuk membaca NFC baru.';
  String? _scannedNfcId;

  String _maskNfcValue(String value) {
    if (value.length <= 4) {
      return value;
    }

    return '${'*' * (value.length - 4)}${value.substring(value.length - 4)}';
  }

  Future<void> _scanNfc() async {
    if (_isScanning || _isSaving) {
      return;
    }

    setState(() {
      _isScanning = true;
      _scannedNfcId = null;
      _statusText = 'Mendeteksi NFC E-KTP...';
    });

    try {
      final availability = await FlutterNfcKit.nfcAvailability;
      if (availability != NFCAvailability.available) {
        final message = availability == NFCAvailability.disabled
            ? 'NFC di perangkat ini sedang nonaktif. Aktifkan NFC di pengaturan lalu coba lagi.'
            : 'Perangkat ini tidak mendukung NFC. Gunakan ponsel fisik yang punya NFC.';
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        setState(() {
          _statusText = message;
        });
        return;
      }

      final dynamic tag = await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 20),
        androidCheckNDEF: false,
        androidPlatformSound: false,
        androidReaderModeFlags: 0x1F | 0x80 | 0x100,
        iosAlertMessage: 'Tempelkan E-KTP ke belakang perangkat',
      );

      final tagId = tag?.id?.toString().trim() ?? '';
      if (tagId.isEmpty) {
        throw Exception('Serial number NFC tidak ditemukan dari E-KTP.');
      }

      if (!mounted) {
        return;
      }

      final maskedTagId = _maskNfcValue(tagId);
      setState(() {
        _scannedNfcId = tagId;
        _statusText = 'NFC E-KTP terbaca: $maskedTagId';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('NFC E-KTP terdeteksi: $maskedTagId')),
      );
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }

      final message = error.message ?? 'Gagal membaca NFC E-KTP';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      setState(() {
        _statusText = 'NFC belum berhasil dibaca. Coba tempelkan kartu lagi.';
      });
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }

      final message = error.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      setState(() {
        _statusText = message;
      });
    } finally {
      try {
        await FlutterNfcKit.finish(iosAlertMessage: 'Sesi NFC selesai');
      } catch (_) {
        // Ignore if the session is already closed.
      }

      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _saveNfc() async {
    final scannedNfcId = _scannedNfcId;
    if (scannedNfcId == null || scannedNfcId.isEmpty || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(profileRepositoryProvider).updateNfc(scannedNfcId);
      ref.invalidate(profileProvider);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NFC E-KTP berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isScanning || _isSaving;
    final scannedNfcId = _scannedNfcId;
    final hasScannedNfc = scannedNfcId != null && scannedNfcId.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Update NFC'), elevation: 0),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.nfc_rounded,
                          color: AppColors.primaryRed,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Deteksi NFC E-KTP Baru',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _statusText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F3),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFD9DE)),
                      ),
                      child: const Icon(
                        Icons.contactless_rounded,
                        size: 52,
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ),
                  if (_isScanning) ...[
                    const SizedBox(height: 20),
                    const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryRed,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Konfirmasi Simpan',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasScannedNfc
                        ? 'NFC baru yang akan disimpan: ${_maskNfcValue(scannedNfcId)}'
                        : 'Scan NFC baru terlebih dahulu sebelum menyimpan perubahan.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isBusy ? null : _scanNfc,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  _isScanning
                      ? 'Membaca NFC...'
                      : hasScannedNfc
                      ? 'Scan Ulang NFC'
                      : 'Mulai Scan NFC',
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: hasScannedNfc && !_isScanning ? _saveNfc : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryRed,
                  side: const BorderSide(color: AppColors.primaryRed),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan NFC'),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Setelah disimpan, NFC ini akan dipakai untuk identitas transaksi Anda di aplikasi.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
