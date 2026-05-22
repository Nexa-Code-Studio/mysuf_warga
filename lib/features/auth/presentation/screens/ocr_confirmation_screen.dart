import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/ktp_data.dart';

class OcrConfirmationScreen extends StatefulWidget {
  final KtpData initialData;

  const OcrConfirmationScreen({
    super.key,
    required this.initialData,
  });

  @override
  State<OcrConfirmationScreen> createState() => _OcrConfirmationScreenState();
}

class _OcrConfirmationScreenState extends State<OcrConfirmationScreen> {
  late TextEditingController _nikController;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nikController = TextEditingController(text: widget.initialData.nik);
    _nameController = TextEditingController(text: widget.initialData.nama);
  }

  @override
  void dispose() {
    _nikController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Data KTP'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Periksa kembali data diri Anda',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pastikan NIK dan Nama sesuai dengan KTP Anda. Anda dapat mengedit jika ada kesalahan pembacaan (OCR).',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nikController,
              decoration: const InputDecoration(
                labelText: 'NIK',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                // In a real app, we might save this data locally or in state management
                // before moving to the next step
                context.push('/auth/selfie-capture');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE31837), // Pertamina Red
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Lanjut Verifikasi Wajah',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
