# PlatKU — Catatan Kendaraan Pribadi di Genggaman (Full Offline Flutter App)

## Project Overview
**PlatKU** (`id.platku.app`) adalah aplikasi pencatatan kendaraan & garasi pribadi 100% offline berbasis Flutter:
- Garasi multi-kendaraan (Motor & Mobil) dengan sinkronisasi odometer otomatis
- Pencatatan BBM & grafik tren konsumsi 6 bulan (`fl_chart`)
- Riwayat servis berkala & pengingat otomatis
- Brankas dokumen kendaraan (STNK, Pajak Tahunan PKB, SIM, BPKB, Asuransi)
- Scan nota SPBU & servis otomatis dengan Google ML Kit On-Device OCR
- Laporan PDF A4 (pratinjau cetak & bagikan) dan ekspor CSV

## Current Status
- UI & Navigation (5-Tab BottomNav): **COMPLETE**
- Data Layer (SQLite v2 + SharedPreferences): **COMPLETE**
- BLoC State Management (`VehicleBloc`, `FuelLogBloc`, `ServiceLogBloc`, `DocumentBloc`, `DashboardBloc`): **COMPLETE**
- On-Device OCR (`ReceiptParser` + `google_mlkit_text_recognition`): **COMPLETE**
- PDF/CSV Export & Print Preview (`ExportHelper` + `printing` + `share_plus`): **COMPLETE**

## Design System
- Brand Palette: **Graphite + Red Racing**
  - Primary: `#DC2626`, Primary Strong: `#B91C1C`, Accent: `#F97316`
  - Hero Gradient: `#14171B` → `#B91C1C` → `#DC2626`
- Typography: Plus Jakarta Sans (`google_fonts`), tabular figures for numeric metrics
- Theme: Reactive Light, Dark, & System mode via `ThemeController`
- Logo: Plat nomor kendaraan motif (plat hitam + "KU" monogram + aksen red racing)