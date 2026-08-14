# SUBSIDIA Mobile (Warga Application)

Aplikasi mobile Warga untuk ekosistem **SUBSIDIA (Smart Subsidized Fuel Ecosystem)**. Aplikasi ini dibangun menggunakan Flutter dan terintegrasi secara dinamis dengan backend untuk mengelola pemantauan kuota subsidi BBM, riwayat transaksi finansial, transfer saldo dompet digital, pengaturan keamanan PIN, dan penerimaan Push Notification real-time.

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

### 3. Jalankan Aplikasi (Pilihan Environment API)

Aplikasi mobile dikonfigurasi untuk secara default terhubung ke server staging **https://sidia.nexacode.dev**. Anda bisa mengubah perilaku ini saat menjalankan perintah run.

*   **Mode Staging/Produksi (Default)**
    Cukup jalankan aplikasi secara normal untuk menghubungkan ke API server cloud:
    ```bash
    flutter run
    ```

*   **Mode Localhost (Development)**
    Gunakan flag `--dart-define=USE_LOCALHOST=true` untuk otomatis mengarahkan koneksi ke localhost backend (`http://localhost:8080/api/v1`):
    ```bash
    flutter run --dart-define=USE_LOCALHOST=true
    ```
    > [!TIP]
    > Pastikan Anda telah mengaktifkan ADB reverse (`adb reverse tcp:8080 tcp:8080`) jika menggunakan Emulator Android agar port `8080` lokal Anda dapat diakses oleh perangkat emulator.

*   **Custom API URL**
    Gunakan flag `--dart-define=SUBSIDIA_API_BASE_URL=<custom_url>` jika Anda ingin menggunakan custom IP atau port tertentu (misalnya emulator Android tanpa adb reverse):
    ```bash
    flutter run --dart-define=SUBSIDIA_API_BASE_URL=http://10.0.2.2:8080/api/v1
    ```

---

## 💎 Fitur Unggulan Terintegrasi

*   **Autentikasi & Penghapusan Sesi Aman**: Integrasi token JWT (Access/Refresh token) via Flutter Secure Storage. Sesi lokal dan seluruh cache data sensitif diatur ulang secara bersih menggunakan invalidasi Riverpod saat logout untuk mencegah kebocoran data antar-akun.
*   **Persistent & Push Notifications**: Sistem push notifikasi dinamis terintegrasi penuh dengan Firebase Cloud Messaging (FCM).
*   **State Management Modern (Riverpod 3.x)**: Menggunakan kelas notifier asinkron terpadu (`AsyncNotifier`) untuk rendering state UI yang bersih.
*   **Optimistic UI Updates**: Transaksi finansial atau status notifikasi dibaca memberikan umpan balik visual instan di antarmuka sebelum sinkronisasi backend selesai, memberikan pengalaman pengguna yang sangat responsif dan premium.
