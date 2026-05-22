import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../features/auth/domain/models/ktp_data.dart';

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<KtpData> processImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    String nik = '';

    final RegExp nikRegex = RegExp(r'\b\d{16}\b');

    List<String> lines = [];
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        lines.add(line.text.trim());
      }
    }

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];

      if (nik.isEmpty) {
        final match = nikRegex.firstMatch(line.replaceAll(RegExp(r'\s+'), ''));
        if (match != null) {
          nik = match.group(0)!;
          break; // Stop parsing once NIK is found
        }
      }
    }

    // Simulasi ambil dari database berdasarkan NIK
    if (nik.isNotEmpty) {
      return KtpData(
        nik: nik,
        nama: 'JOHN DOE', // Simulasi dari database
        tempatTanggalLahir: 'JAKARTA, 01-01-1990',
        jenisKelamin: 'LAKI-LAKI',
        alamat: 'JL. MERDEKA NO 1',
        rtrw: '001/002',
        kelDesa: 'GAMBIR',
        kecamatan: 'GAMBIR',
        agama: 'ISLAM',
        statusPerkawinan: 'BELUM KAWIN',
        pekerjaan: 'KARYAWAN SWASTA',
        kewarganegaraan: 'WNI',
        berlakuHingga: 'SEUMUR HIDUP',
      );
    } else {
      return KtpData.empty();
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
