import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../features/auth/domain/models/ktp_data.dart';

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<KtpData> processImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    String nik = '';
    // Combine all extracted text blocks and remove all whitespace (handling spaces inside NIK)
    final String rawText = recognizedText.text;
    
    print('============================================================');
    print('   [DART OCR DEBUG] MEMULAI PROSES SCAN KTP');
    print('============================================================');
    print('1. TEKS MENTAH HASIL BACAAN GOOGLE ML KIT:');
    print(rawText);
    print('------------------------------------------------------------');

    final String cleanedText = rawText.replaceAll(RegExp(r'\s+'), '');
    print('2. TEKS SETELAH DIHAPUS SPASI & NEWLINE:');
    print(cleanedText);
    print('------------------------------------------------------------');

    // Normalize common OCR misread letters back to their correct digits
    // (e.g. 1 as I, L, l, i, |, !, /, \ or 0 as O, o, D)
    final String normalizedText = cleanedText
        .replaceAll(RegExp(r'[ILli!/\\\[\]]'), '1')
        .replaceAll(RegExp(r'[OoD]'), '0')
        .replaceAll(RegExp(r'[Ss]'), '5')
        .replaceAll(RegExp(r'[Bb]'), '8');
    
    print('3. TEKS SETELAH NORMALISASI ANGKAL (FAUL TOLERANT):');
    print(normalizedText);
    print('------------------------------------------------------------');

    // Search for 16 consecutive digits in the normalized text
    final RegExp nikRegex = RegExp(r'\d{16}');
    final match = nikRegex.firstMatch(normalizedText);
    if (match != null) {
      nik = match.group(0)!;
      print('4. HASIL EKSTRAKSI: BERHASIL MENEMUKAN NIK -> $nik');
    } else {
      print('4. HASIL EKSTRAKSI: GAGAL! Tidak ditemukan 16 digit angka berurutan.');
    }
    print('============================================================\n');

    // Simulasi ambil dari database berdasarkan NIK
    if (nik.isNotEmpty) {
      return KtpData(
        nik: nik,
        nama: '',
        tempatTanggalLahir: '',
        jenisKelamin: '',
        alamat: '',
        rtrw: '',
        kelDesa: '',
        kecamatan: '',
        agama: '',
        statusPerkawinan: '',
        pekerjaan: '',
        kewarganegaraan: '',
        berlakuHingga: '',
        ocrRawText: recognizedText.text,
      );
    } else {
      return KtpData.empty();
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
