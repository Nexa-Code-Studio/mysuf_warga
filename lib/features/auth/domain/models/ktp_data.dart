class KtpData {
  final String nik;
  final String nama;
  final String tempatTanggalLahir;
  final String jenisKelamin;
  final String alamat;
  final String rtrw;
  final String kelDesa;
  final String kecamatan;
  final String agama;
  final String statusPerkawinan;
  final String pekerjaan;
  final String kewarganegaraan;
  final String berlakuHingga;

  KtpData({
    required this.nik,
    required this.nama,
    this.tempatTanggalLahir = '',
    this.jenisKelamin = '',
    this.alamat = '',
    this.rtrw = '',
    this.kelDesa = '',
    this.kecamatan = '',
    this.agama = '',
    this.statusPerkawinan = '',
    this.pekerjaan = '',
    this.kewarganegaraan = '',
    this.berlakuHingga = '',
  });

  factory KtpData.empty() {
    return KtpData(
      nik: '',
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
    );
  }

  bool get isValid => nik.isNotEmpty && nama.isNotEmpty;

  KtpData copyWith({
    String? nik,
    String? nama,
    String? tempatTanggalLahir,
    String? jenisKelamin,
    String? alamat,
    String? rtrw,
    String? kelDesa,
    String? kecamatan,
    String? agama,
    String? statusPerkawinan,
    String? pekerjaan,
    String? kewarganegaraan,
    String? berlakuHingga,
  }) {
    return KtpData(
      nik: nik ?? this.nik,
      nama: nama ?? this.nama,
      tempatTanggalLahir: tempatTanggalLahir ?? this.tempatTanggalLahir,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      alamat: alamat ?? this.alamat,
      rtrw: rtrw ?? this.rtrw,
      kelDesa: kelDesa ?? this.kelDesa,
      kecamatan: kecamatan ?? this.kecamatan,
      agama: agama ?? this.agama,
      statusPerkawinan: statusPerkawinan ?? this.statusPerkawinan,
      pekerjaan: pekerjaan ?? this.pekerjaan,
      kewarganegaraan: kewarganegaraan ?? this.kewarganegaraan,
      berlakuHingga: berlakuHingga ?? this.berlakuHingga,
    );
  }
}
