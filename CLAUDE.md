# MotoVault — Smart Vehicle & Garage Ledger (Full Offline Flutter App)

## Project Overview
**MotoVault** (`com.abdan.motovault`) adalah aplikasi pencatatan kendaraan & garasi pribadi 100% offline berbasis Flutter:
- Garasi multi-kendaraan (Motor & Mobil) dengan sinkronisasi odometer otomatis
- Pencatatan BBM & grafik tren konsumsi 6 bulan (`fl_chart`)
- Riwayat servis berkala & pengingat otomatis
- Brankas dokumen kendaraan (STNK, Pajak Tahunan PKB, SIM, BPKB, Asuransi)
- Scan nota SPBU & servis otomatis dengan Google ML Kit On-Device OCR
- Laporan PDF A4 (pratinjau cetak & bagikan) dan ekspor CSV
- Mode Demo Instan 1-Tap (`DemoDataSeeder`) untuk eksplorasi cepat

## Current Status
- UI & Navigation (5-Tab BottomNav): **COMPLETE**
- Data Layer (SQLite v2 + SharedPreferences + DemoDataSeeder): **COMPLETE**
- BLoC State Management (`VehicleBloc`, `FuelLogBloc`, `ServiceLogBloc`, `DocumentBloc`, `DashboardBloc`): **COMPLETE**
- On-Device OCR (`ReceiptParser` + `google_mlkit_text_recognition`): **COMPLETE**
- PDF/CSV Export & Print Preview (`ExportHelper` + `printing` + `share_plus`): **COMPLETE**

## Design System
- Brand Palette: **Deep Cobalt & Electric Cyan**
  - Primary: `#2563EB`, Primary Strong: `#0F172A`, Accent: `#06B6D4`
  - Hero Gradient: `#0F172A` → `#1D4ED8` → `#06B6D4`
- Typography: Plus Jakarta Sans (`google_fonts`), tabular figures for numeric metrics
- Theme: Reactive Light, Dark, & System mode via `ThemeController`
