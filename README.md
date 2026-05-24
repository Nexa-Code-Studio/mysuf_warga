# MySuF Mobile (Warga Application)

Aplikasi mobile Warga untuk ekosistem **MySuF (Smart Subsidized Fuel Ecosystem)**. Aplikasi ini dibangun menggunakan Flutter dan terintegrasi secara dinamis dengan backend untuk mengelola pemantauan kuota subsidi BBM, riwayat transaksi finansial, transfer saldo dompet digital, pengaturan keamanan PIN, dan penerimaan Push Notification real-time.

---

## 🛠️ Langkah Menjalankan Aplikasi

Ikuti panduan berikut untuk menghubungkan dan menjalankan aplikasi pada perangkat fisik atau emulator Android Anda.

### 1. Sinkronisasi Port Android (ADB Reverse)
Sebelum menjalankan aplikasi, pastikan port lokal mesin pengembang terhubung ke perangkat/emulator Anda agar koneksi localhost API berjalan lancar:
```bash
adb reverse tcp:8080 tcp:8080
```

### 2. Dapatkan Dependensi Flutter
Pasang pustaka dan dependensi proyek:
```bash
flutter pub get
```

### 3. Jalankan Aplikasi dengan Base URL API
Jalankan aplikasi Flutter menggunakan konstanta `--dart-define` untuk mengarahkan request HTTP ke server lokal backend Anda (biasanya port `8080`):
```bash
flutter run --dart-define=MYSUF_API_BASE_URL=http://10.0.2.2:8080/api/v1
```

> [!TIP]
> IP `10.0.2.2` adalah rute default Android Emulator untuk mengakses port localhost pada mesin induk Anda. Jika menggunakan perangkat fisik, Anda bisa mencocokkannya dengan IP lokal komputer Anda atau menggunakan `http://localhost:8080/api/v1` jika port forwarding `adb reverse` aktif.

---

## 💎 Fitur Unggulan Terintegrasi

*   **Autentikasi & Penghapusan Sesi Aman**: Integrasi token JWT (Access/Refresh token) via Flutter Secure Storage. Sesi lokal dan seluruh cache data sensitif diatur ulang secara bersih menggunakan invalidasi Riverpod saat logout untuk mencegah kebocoran data antar-akun.
*   **Persistent & Push Notifications**: Sistem push notifikasi dinamis terintegrasi penuh dengan Firebase Cloud Messaging (FCM).
*   **State Management Modern (Riverpod 3.x)**: Menggunakan kelas notifier asinkron terpadu (`AsyncNotifier`) untuk rendering state UI yang bersih.
*   **Optimistic UI Updates**: Transaksi finansial atau status notifikasi dibaca memberikan umpan balik visual instan di antarmuka sebelum sinkronisasi backend selesai, memberikan pengalaman pengguna yang sangat responsif dan premium.
