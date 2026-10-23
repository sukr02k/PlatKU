# PlatKU — Offline-First Vehicle & Garage Management

<p align="center">
  <img src="assets/branding/app_icon.png" alt="PlatKU Logo" width="140"/>
</p>

<p align="center">
  <strong>Aplikasi Manajemen Kendaraan, Konsumsi BBM, Servis Berkala & Dokumen Berbasis Offline-First (Flutter + SQLite + BLoC)</strong>
</p>

<p align="center">
  <a href="https://github.com/sukr02k/platku/actions/workflows/flutter_ci.yml">
    <img src="https://github.com/sukr02k/platku/actions/workflows/flutter_ci.yml/badge.svg" alt="PlatKU Flutter CI & Release APK"/>
  </a>
  <a href="https://github.com/sukr02k/platku/releases/latest">
    <img src="https://img.shields.io/badge/Release-v1.2.0-DC2626?logo=github&logoColor=white" alt="Latest Release v1.2.0"/>
  </a>
  <img src="https://img.shields.io/badge/Tests-9%20passed-10B981?logo=checkmarx&logoColor=white" alt="Tests 9 passed"/>
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/SQLite-v3%20Offline-14171B?logo=sqlite&logoColor=white" alt="SQLite v3"/>
  <img src="https://img.shields.io/badge/State-BLoC-DC2626" alt="BLoC"/>
  <img src="https://img.shields.io/badge/OCR-Google%20ML%20Kit-10B981" alt="Google ML Kit"/>
</p>

---

## Unduh Aplikasi (Release APK)

| Versi | Format | Arsitektur Target | Ukuran File | Tautan Unduh |
| :--- | :--- | :--- | :--- | :--- |
| **v1.2.0** | `.apk` (Release) | `arm64-v8a` (Android modern 64-bit) | **33 MB** | [Download PlatKU.v1.2.0.apk](https://github.com/sukr02k/platku/releases/download/v1.2.0/PlatKU.v1.2.0.apk) |
| **v1.2.0** | Arsip Asset Lengkap | Semua ABI (`arm64`, `armeabi-v7a`, `x86_64`) | ~27 - 35 MB | [Lihat Semua Asset di GitHub Releases](https://github.com/sukr02k/platku/releases/tag/v1.2.0) |

---

## Ringkasan Project (Overview)

**PlatKU** adalah aplikasi pencatatan operasional dan perawatan kendaraan pribadi (sepeda motor maupun mobil) yang dirancang dengan pendekatan **100% Offline-First**. Seluruh pencatatan konsumsi bahan bakar (`km/L`), riwayat servis berkala, pemantauan masa berlaku dokumen kendaraan (STNK, Pajak Tahunan/PKB, BPKB, SIM, Asuransi), hingga pemindaian struk SPBU/bengkel berbasis *on-device OCR* berjalan langsung di perangkat menggunakan **SQLite** tanpa ketergantungan koneksi internet.

Untuk menjaga keamanan data pada skenario *offline*, aplikasi ini dilengkapi dengan sistem **Backup & Restore Database (`.db`)** bervalidasi header SQLite (termasuk impor langsung dari penyimpanan perangkat via Android Storage Access Framework) serta ekspor laporan kendaraan ke format **PDF (A4)** dan **CSV**.

---

## Fitur Utama

### 1. Manajemen Garasi Multi-Kendaraan
- **Multi-Profil Kendaraan**: Pencatatan sepeda motor dan mobil lengkap dengan nomor polisi, merk, model, tahun, kapasitas tangki, jenis BBM utama, dan foto fisik kendaraan.
- **Vehicle & Profile Photo Picker**: Pemilihan foto kendaraan dan foto profil avatar pengguna secara fleksibel langsung dari **Kamera** perangkat maupun **Galeri**, dilengkapi opsi ganti dan hapus foto.
- **Vehicle Switcher Cepat**: Pemilih kendaraan aktif langsung di halaman *Beranda*, *BBM*, dan *Servis* tanpa perlu berpindah tab.
- **Sinkronisasi & Rekalkulasi Odometer Otomatis**: Memperbarui dan menghitung ulang nilai odometer tertinggi kendaraan secara otomatis setiap kali catatan BBM atau servis ditambah, diedit, maupun dihapus.
- **Alur Edit Kendaraan Mulus**: Penyuntingan spesifikasi kendaraan di halaman detail mempertahankan konteks halaman dengan pembaruan data lokal instan tanpa melempar pengguna keluar.

### 2. Pencatatan & Analitik BBM
- **CRUD Transaksi BBM Lengkap**: Pencatatan dan pengeditan riwayat pengisian BBM (tanggal, jenis BBM, volume liter, harga per liter, total biaya, odometer, nama SPBU, status *full tank*, dan foto struk).
- **Kalkulasi Efisiensi Bahan Bakar (`km/L`)**: Menghitung konsumsi bahan bakar rata-rata dan biaya per pengisian secara akurat menggunakan metode *full-tank-to-full-tank*.
- **Proteksi Validasi Odometer**: Mencegah kesalahan input odometer yang lebih rendah dari catatan sebelumnya pada pengisian baru.
- **Visualisasi Grafik 6 Bulan**: Grafik batang pengeluaran bulanan interaktif menggunakan `fl_chart`.
- **Pull-to-Refresh & Full-screen Struk Zoom**: Gestur tarik-ke-bawah untuk sinkronisasi data seketika serta penampil struk kasir layar penuh dengan pinch-to-zoom (`InteractiveViewer`).

### 3. Riwayat Servis & Brankas Dokumen
- **CRUD Riwayat Servis Berkala**: Pencatatan dan pembaruan rincian perbaikan/servis berkala beserta pengingat jadwal servis berikutnya berdasarkan target tanggal maupun batas kilometer odometer.
- **Pemantauan Masa Berlaku Dokumen & Overdue Reminder**: Penyimpanan data STNK, Pajak Tahunan (PKB), BPKB, SIM, dan Asuransi dengan status visual (*Aktif*, *Segera Habis*, *Kadaluarsa*) serta sistem notifikasi dokumen lewat jatuh tempo hingga 30 hari ke belakang.
- **Perpanjangan Cepat Dokumen**: Pintasan perpanjangan masa berlaku dokumen (`+1 Tahun` dan `+5 Tahun`) langsung dari kartu dokumen maupun halaman formulir.
- **Interactive Document Zoom Viewer**: Pembesaran foto dokumen legal (STNK, SIM, BPKB) layar penuh dengan gestur zoom untuk memudahkan pembacaan nomor rangka, nomor mesin, dan masa berlaku.

### 4. On-Device OCR, Laporan & Keamanan Data
- **Scan Nota SPBU & Bengkel (On-Device OCR)**: Ekstraksi otomatis tanggal transaksi, liter BBM, harga per liter, jenis BBM, dan total biaya dari foto struk menggunakan **Google ML Kit Text Recognition**.
- **Ekspor Laporan PDF (A4) & CSV**: Pembuatan laporan riwayat kendaraan siap cetak (dilengkapi pratinjau cetak via `printing`) serta ekspor spreadsheet `.csv` via `share_plus`.
- **Backup & Restore Database Lokal (`.db`)**: Pencadangan dan pemulihan database SQLite `platku.db` dengan validasi *magic bytes* header `SQLite format 3` serta transisi bersih *state re-initialization* ke halaman awal.
- **Keamanan Akun & Tema Adaptif**: Penyimpanan password akun lokal menggunakan *Salted SHA-256*, validasi unik email akun, serta dukungan tema **Terang**, **Gelap**, dan **Ikuti Sistem** secara *real-time*.

---


## Arsitektur Aplikasi

Aplikasi ini mengimplementasikan pemisahan lapisan yang tegas antara **Presentation Layer (UI)**, **Business Logic Layer (BLoC)**, **Core On-Device Services**, dan **Data Layer (Repositories & SQLite)**:

```mermaid
flowchart TD
    subgraph Presentation["Presentation Layer (UI)"]
        Screens["Screens (Home, Fuel, Service, Docs, Scan, Vehicle, Profile, Export)"]
        Widgets["Reusable Widgets (VehicleSwitcherBar, Adaptive Theme, Pull-to-Refresh & Zoom Preview)"]
    end

    subgraph Logic["Business Logic Layer (BLoC)"]
        Blocs["VehicleBloc | FuelLogBloc | ServiceLogBloc | DocumentBloc | DashboardBloc | AuthBloc"]
    end

    subgraph CoreServices["Core On-Device & External Services"]
        ImgHelper["ImageHelper (Permanent File Storage & Interactive Fullscreen Zoom Viewer)"]
        OCR["ReceiptParser & Google ML Kit OCR (On-Device Text Recognition)"]
        Export["ExportHelper (PDF A4 Generator, Print Preview & CSV Export)"]
        Notif["NotificationService (Scheduled Service & Document Expiry Alerts)"]
        SAF["Backup MethodChannel (Android SAF .db Import & SQLite Header Check)"]
    end

    subgraph Data["Data Layer"]
        Repos["Repositories (Vehicle, FuelLog, ServiceLog, Document, Auth)"]
        Local["Local Sources (AuthLocalDatasource)"]
        DB[("DatabaseHelper (SQLite v3)")]
        Prefs[("SharedPreferences (Session & ThemeMode)")]
    end

    Screens --> Blocs
    Blocs --> Repos
    Screens --> CoreServices
    Repos --> DB
    Repos --> Local
    Local --> DB
    Local --> Prefs
    SAF --> DB
```

### Struktur Direktori

```text
lib/
├── core/
│   ├── components/       # Komponen UI reusable (BottomNav, Buttons, VehicleSwitcherBar, PlatkuLogo)
│   ├── constants/        # Sistem warna adaptif Light/Dark (AppColors), tipografi, dan konstanta string
│   ├── services/         # Penjadwalan notifikasi lokal (NotificationService)
│   ├── utils/            # Formatters (id_ID), ReceiptParser (OCR), ExportHelper (PDF/CSV), ImageHelper, PasswordHasher
│   ├── theme.dart        # Konfigurasi ThemeData terang dan gelap
│   └── theme_controller.dart
├── data/
│   ├── local/            # AuthLocalDatasource
│   ├── models/           # Model entitas (User, Vehicle, FuelLog, ServiceLog, VehicleDocument)
│   ├── repositories/     # Abstraksi query CRUD, filter relasional & rekalkulasi odometer otomatis
│   └── database_helper.dart # Konfigurasi skema SQLite v3, indexing B-Tree & migrasi tabel
├── presentation/
│   ├── auth/             # SplashPage, OnboardingPage, LoginPage, RegisterPage
│   ├── blocs/            # State management berbasis BLoC (Vehicle, FuelLog, ServiceLog, Document, Dashboard, Auth)
│   ├── docs/             # Halaman daftar dokumen, tambah/edit dokumen, & perpanjangan masa berlaku
│   ├── fuel/             # Halaman log BBM, statistik 6 bulan (fl_chart), & form tambah/edit BBM
│   ├── home/             # MainNavigationPage (5 tab) & HomePage
│   ├── notifications/    # Halaman daftar pengingat servis & masa berlaku dokumen
│   ├── profile/          # Halaman Profil, Keamanan, Tema, & Backup/Restore Database (.db)
│   ├── scan/             # Halaman pemindaian struk kamera/galeri dengan Google ML Kit OCR
│   ├── service/          # Halaman riwayat servis & form tambah/edit servis
│   ├── settings/         # Halaman ekspor laporan PDF A4 & CSV
│   └── vehicle/          # Halaman detail, tambah, dan edit kendaraan
└── main.dart             # Entry point aplikasi
```

---

## Skema Database (ERD)

Database lokal SQLite (`DatabaseHelper`, versi 3) terdiri dari **6 tabel** yang dilengkapi *Foreign Key Constraints (`ON DELETE CASCADE`)* dan *B-Tree Indexes* pada kolom pencarian utama (`user_id`, `vehicle_id`, `date`, `expiry_date`):

```mermaid
erDiagram
    USERS ||--o{ VEHICLES : "owns"
    VEHICLES ||--o{ FUEL_LOGS : "records"
    VEHICLES ||--o{ SERVICE_LOGS : "maintains"
    VEHICLES ||--o{ VEHICLE_DOCUMENTS : "holds"
    EXPENSE_CATEGORIES ||--o{ SERVICE_LOGS : "categorizes"

    USERS {
        int id PK
        string name
        string email UK
        string password
        string image_path
        string created_at
        string updated_at
    }
    VEHICLES {
        int id PK
        int user_id FK
        string name
        string type
        string brand
        string model
        int year
        string plate_number
        string color
        string image_path
        real initial_odometer
        string fuel_type
        real tank_capacity
        int is_active
        string notes
        string created_at
        string updated_at
    }
    FUEL_LOGS {
        int id PK
        int vehicle_id FK
        string date
        real odometer
        real liters
        real price_per_liter
        real total_cost
        string fuel_type
        string station_name
        int is_full_tank
        string receipt_image_path
        string notes
        string created_at
    }
    SERVICE_LOGS {
        int id PK
        int vehicle_id FK
        string date
        real odometer
        string service_type
        string description
        real cost
        string workshop_name
        string receipt_image_path
        real next_service_odometer
        string next_service_date
        string notes
        string created_at
    }
    VEHICLE_DOCUMENTS {
        int id PK
        int vehicle_id FK
        string document_type
        string document_number
        string issue_date
        string expiry_date
        string image_path
        string notes
        string created_at
        string updated_at
    }
    EXPENSE_CATEGORIES {
        int id PK
        string name
        string icon
        int is_default
    }
```

---

## Tech Stack

| Kategori | Paket / Teknologi | Kegunaan |
| :--- | :--- | :--- |
| **Framework & Bahasa** | Flutter & Dart (`^3.7.0`) | Cross-platform UI & aplikasi mobile Android |
| **State Management** | `flutter_bloc` (`^9.0.0`) & `dartz` | Event-driven BLoC state management & functional error handling |
| **Local Database** | `sqflite` (`^2.4.2`) & `shared_preferences` | Penyimpanan relasional offline (SQLite v3, foreign keys cascade & B-Tree index) |
| **Media & Storage** | `image_picker` & `path_provider` | Pengambilan foto dari kamera/galeri & persistensi dokumen permanen via `ImageHelper` |
| **On-Device OCR** | `google_mlkit_text_recognition` (`^0.15.1`) | Ekstraksi teks struk SPBU & nota servis secara lokal di perangkat |
| **Data Visualization** | `fl_chart` (`^0.70.2`) | Grafik analisis pengeluaran BBM & servis 6 bulan terakhir |
| **Report & Export** | `pdf` (`^3.12.0`), `printing` & `csv` | Pembuatan laporan PDF A4, pratinjau cetak, dan ekspor CSV |
| **Keamanan & Notifikasi** | `crypto`, `flutter_local_notifications` | Salted SHA-256 password hashing & pengingat lokal terjadwal |

---

## Cara Menjalankan Project

### 1. Prasyarat
- Flutter SDK `>= 3.7.0`
- Android Studio / VS Code
- Java 17 (untuk build Android)

### 2. Instalasi & Menjalankan Aplikasi

```bash
# Unduh dependencies
flutter pub get

# Jalankan analisis kode & unit test
flutter analyze
flutter test

# Jalankan aplikasi di perangkat / emulator
flutter run
```

### 3. Mulai Mencatat
Setelah masuk, tambahkan kendaraan pertama Anda lewat tombol **Tambah Kendaraan** di Beranda, lalu catat BBM, servis, dan dokumen secara offline.

---

## Riwayat Versi (Changelog)

### v1.2.0
- **Vehicle & Profile Photo Pickers**: Pemilihan foto kendaraan dan avatar profil dari kamera maupun galeri dengan persistensi berkas permanen di direktori dokumen aplikasi (`getApplicationDocumentsDirectory`).
- **Interactive Image Viewer**: Penampil foto layar penuh dengan pinch-to-zoom (`InteractiveViewer`) pada avatar profil, kendaraan, struk BBM, struk servis, dan dokumen resmi (STNK/SIM/BPKB).
- **Gestur Pull-to-Refresh**: RefreshIndicator terpasang di seluruh halaman utama (`HomePage`, `FuelPage`, `ServicePage`, `DocsPage`).
- **Detail Vehicle Edit Flow**: Penyuntingan kendaraan mempertahankan konteks halaman detail dengan sinkronisasi state lokal instan.
- **Database Restore Sync**: Sinkronisasi state sesi dan navigasi bersih ke SplashPage setelah pemulihan database SQLite.
- **Validasi Akun**: Penanganan validasi email unik pada SQLite profil lokal.
- **CI/CD & Testing**: Pembaruan GitHub Actions ke `actions/checkout@v4` dan ekspansi 9/9 unit & widget tests passing.

### v1.1.0
- **Perpanjangan Dokumen Cepat**: Pintasan perpanjang masa berlaku dokumen (`+1 Tahun` dan `+5 Tahun`).
- **Kalkulasi Efisiensi BBM**: Perhitungan `km/L` akurat antar pengisian *full tank*.
- **Pembersihan Logika & UI**: Perbaikan konsistensi warna tema adaptif dan validasi odometer.

### v1.0.0
- **Rilis Awal**: Garasi multi-kendaraan, CRUD transaksi BBM & servis berkala, brankas dokumen legal, OCR struk nota belanja dengan Google ML Kit, ekspor PDF/CSV, dan cadangan database SQLite lokal.