<div align="center">
  <img src="assets/branding/app_icon.png" alt="MotoVault" width="108" height="108" />
  <h1>MotoVault</h1>
  <p>Aplikasi pencatatan konsumsi BBM, riwayat servis, dan dokumen kendaraan berbasis Flutter & SQLite.</p>

  <p>
    <a href="https://github.com/sukr02k/motovault/actions/workflows/flutter_ci.yml"><img src="https://github.com/sukr02k/motovault/actions/workflows/flutter_ci.yml/badge.svg" alt="CI" /></a>
    <a href="https://github.com/sukr02k/motovault/releases/latest"><img src="https://img.shields.io/github/v/release/sukr02k/motovault?label=Release&color=2563EB" alt="Release" /></a>
    <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter" />
    <img src="https://img.shields.io/badge/SQLite-Local-0F172A?logo=sqlite&logoColor=white" alt="SQLite" />
  </p>
</div>

## Tentang Proyek

**MotoVault** adalah aplikasi mobile untuk mencatat biaya operasional dan perawatan kendaraan pribadi (sepeda motor maupun mobil). Seluruh data disimpan secara lokal di perangkat menggunakan database relasional SQLite, sehingga aplikasi dapat digunakan sepenuhnya tanpa koneksi internet maupun ketergantungan pada layanan cloud.

## Cakupan Fitur

### 1. Manajemen Garasi Multi-Kendaraan
- Pencatatan profil beberapa kendaraan sekaligus (kategori motor/mobil, nomor polisi, merk, model, tahun, dan foto kendaraan).
- Pemilih kendaraan cepat (*vehicle switcher*) di halaman Beranda, BBM, dan Servis.
- Sinkronisasi dan rekalkulasi otomatis nilai odometer kendaraan berdasarkan riwayat pengisian BBM dan servis terbaru.

### 2. Pencatatan & Analitik BBM
- Pencatatan transaksi pengisian bahan bakar (tanggal, jenis BBM, jumlah liter, harga per liter, total biaya, odometer, nama SPBU, dan lampiran foto struk).
- Perhitungan efisiensi konsumsi bahan bakar (`km/L`) antar pengisian.
- Grafik tren pengeluaran bulanan selama 6 bulan terakhir.
- Validasi odometer untuk mencegah kesalahan input nilai odometer yang lebih rendah dari catatan sebelumnya.

### 3. Riwayat & Jadwal Servis Berkala
- Pencatatan riwayat perbaikan dan servis berkala (jenis pekerjaan, rincian suku cadang, nama bengkel, biaya, odometer, dan foto nota).
- Pengaturan pengingat servis berikutnya berdasarkan target tanggal maupun batas kilometer odometer.

### 4. Dokumen & Pajak Kendaraan
- Penyimpanan informasi dokumen kendaraan (STNK, Pajak Tahunan/PKB, BPKB, SIM, dan Asuransi) beserta foto dokumen.
- Indikator status masa berlaku (*Aktif*, *Segera Habis*, *Kadaluarsa*) dengan notifikasi lokal terjadwal.
- Pintasan perpanjangan masa berlaku dokumen (`+1 Tahun` / `+5 Tahun`) secara langsung dari halaman dokumen.

### 5. Pemindaian Struk (On-Device OCR)
- Ekstraksi teks otomatis dari foto struk SPBU dan nota bengkel menggunakan Google ML Kit Text Recognition di perangkat.
- *Parser* heuristik untuk mengenali tanggal transaksi, volume liter, harga per liter, jenis BBM, serta total biaya dan mengisikannya langsung ke formulir pencatatan.

### 6. Laporan & Pencadangan Data
- Ekspor laporan riwayat kendaraan ke format **PDF (A4)** dan **CSV** untuk keperluan arsip atau cetak.
- Pencadangan (*backup*) dan pemulihan (*restore*) database SQLite lokal (`kendaraanku.db`), termasuk dukungan impor file `.db` dari penyimpanan perangkat melalui Android Storage Access Framework.
- Dukungan tema tampilan **Terang**, **Gelap**, dan **Ikuti Sistem**.

---

## Struktur Proyek

Proyek ini memisahkan lapisan presentasi UI, *state management* (`flutter_bloc`), dan akses data lokal (`sqflite`):

```text
lib/
├── core/
│   ├── components/       # Komponen UI reusable (BottomNav, Buttons, VehicleSwitcherBar, MotoVaultLogo)
│   ├── constants/        # Definisi warna adaptif (AppColors), tipografi, dan konstanta string
│   ├── services/         # Penjadwalan notifikasi lokal (NotificationService)
│   ├── utils/            # Formatter angka/tanggal, parser struk OCR, generator PDF/CSV, hashing SHA-256
│   ├── theme.dart        # Konfigurasi ThemeData terang dan gelap
│   └── theme_controller.dart
├── data/
│   ├── local/            # DatabaseHelper (SQLite), AuthLocalDatasource, DemoDataSeeder
│   ├── models/           # Model entitas (User, Vehicle, FuelLog, ServiceLog, VehicleDocument)
│   └── repositories/     # Repositori CRUD dan logika sinkronisasi odometer
├── presentation/
│   ├── auth/             # Splash, Onboarding, Login, dan Registrasi akun lokal
│   ├── blocs/            # BLoC untuk Vehicle, FuelLog, ServiceLog, Document, dan Dashboard
│   ├── docs/             # Daftar dokumen, form tambah/edit dokumen, dan perpanjangan masa berlaku
│   ├── fuel/             # Daftar log BBM, statistik 6 bulan, dan form tambah/edit BBM
│   ├── home/             # Navigasi utama 5-tab dan ringkasan kondisi kendaraan di Beranda
│   ├── notifications/    # Daftar pengingat servis dan masa berlaku dokumen
│   ├── profile/          # Pengaturan profil, keamanan akun, tema tampilan, dan backup/restore DB
│   ├── scan/             # Halaman pemindaian struk dengan kamera/galeri dan ML Kit OCR
│   ├── service/          # Daftar riwayat servis dan form tambah/edit servis
│   ├── settings/         # Ekspor laporan PDF A4 dan CSV
│   └── vehicle/          # Detail, tambah, dan edit data kendaraan
└── main.dart
```

---

## Spesifikasi Teknis

| Komponen | Pustaka | Keterangan |
| :--- | :--- | :--- |
| **SDK** | Flutter `3.x` / Dart `^3.7.0` | Kerangka kerja aplikasi lintas platform |
| **State Management** | `flutter_bloc`, `dartz` | Pengelolaan state berbasis event dan penanganan error fungsional |
| **Database Lokal** | `sqflite`, `shared_preferences` | Penyimpanan relasional SQLite & preferensi sesi/tema |
| **OCR** | `google_mlkit_text_recognition` | Pengenalan teks struk secara lokal di perangkat |
| **Grafik & Laporan** | `fl_chart`, `pdf`, `printing`, `csv` | Visualisasi grafik bulanan dan pembuatan dokumen PDF/CSV |
| **Utilitas Perangkat** | `flutter_local_notifications`, `share_plus`, `image_picker` | Notifikasi terjadwal, berbagi file ekspor, dan input gambar |

---

## Menjalankan Proyek Secara Lokal

### Prasyarat
- Flutter SDK `>= 3.7.0`
- JDK 17 (untuk kompilasi Android Gradle)
- Android SDK / Xcode

### Langkah Instalasi

1. **Clone repositori**
   ```bash
   git clone https://github.com/sukr02k/motovault.git
   cd motovault
   ```

2. **Unduh dependensi paket**
   ```bash
   flutter pub get
   ```

3. **Jalankan analisis kode & pengujian unit**
   ```bash
   flutter analyze
   flutter test
   ```

4. **Jalankan ke perangkat / emulator**
   ```bash
   flutter run
   ```

5. **Build APK Rilis**
   ```bash
   flutter build apk --release
   ```

> Untuk menguji fitur aplikasi tanpa memasukkan data dari awal, gunakan opsi **Muat Data Contoh** pada layar awal aplikasi. Data contoh dapat dihapus kapan saja melalui menu **Profil → Kosongkan Garasi**.

---

## Lisensi & Pengembang

Dikembangkan oleh **Abdan Syakuro** ([@sukr02k](https://github.com/sukr02k)).
