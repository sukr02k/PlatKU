import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platku/core/constants/colors.dart';
import 'package:platku/core/constants/app_styles.dart';
import 'package:platku/core/utils/formatters.dart';
import 'package:platku/core/utils/image_helper.dart';
import 'package:platku/data/models/vehicle_model.dart';
import 'package:platku/presentation/blocs/vehicle/vehicle_bloc.dart';
import 'package:platku/presentation/blocs/vehicle/vehicle_event.dart';
import 'package:platku/presentation/vehicle/pages/edit_vehicle_page.dart';
import 'package:platku/presentation/service/pages/service_page.dart';
import 'package:platku/data/repositories/service_log_repository.dart';
import 'package:platku/data/repositories/fuel_log_repository.dart';
import 'package:platku/data/repositories/vehicle_document_repository.dart';
import 'package:platku/data/repositories/vehicle_repository.dart';
import 'package:platku/data/models/service_log_model.dart';
import 'package:platku/data/models/fuel_log_model.dart';
import 'package:platku/data/models/vehicle_document_model.dart';


class DetailVehiclePage extends StatefulWidget {
  final VehicleModel vehicle;
  const DetailVehiclePage({super.key, required this.vehicle});

  @override
  State<DetailVehiclePage> createState() => _DetailVehiclePageState();
}

class _DetailVehiclePageState extends State<DetailVehiclePage> {
  late VehicleModel _vehicle;
  bool _wasEdited = false;
  int _activeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _vehicle = widget.vehicle;
  }

  void _onBack() {
    Navigator.pop(context, _wasEdited);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _onBack();
        },
        child: Scaffold(
          backgroundColor: AppColors.bg,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _HeroHeader(
                  vehicle: _vehicle,
                  onBack: _onBack,
                  onEdit: _navigateToEdit,
                  onDelete: _confirmDelete,
                ),
                const SizedBox(height: 18),
                _StatsGrid(vehicle: _vehicle),
                const SizedBox(height: 20),
                _TabBar(
                  activeIndex: _activeTabIndex,
                  onTap: (index) => setState(() => _activeTabIndex = index),
                ),
                const SizedBox(height: 16),
                if (_activeTabIndex == 0)
                  _SpesifikasiCard(vehicle: _vehicle)
                else if (_activeTabIndex == 1)
                  _ServisTab(vehicle: _vehicle)
                else
                  _DokumenTab(vehicle: _vehicle),
                const SizedBox(height: 16),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToEdit() async {
    final vehicleBloc = context.read<VehicleBloc>();
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: vehicleBloc,
          child: EditVehiclePage(vehicle: _vehicle),
        ),
      ),
    );
    if (result == true && mounted) {
      _wasEdited = true;
      vehicleBloc.add(LoadVehicles(_vehicle.userId));
      if (_vehicle.id != null) {
        final res = await VehicleRepository().getById(_vehicle.id!);
        res.fold((_) => null, (updated) {
          if (mounted) {
            setState(() => _vehicle = updated);
          }
        });
      }
    }
  }

  Future<void> _confirmDelete() async {
    final v = widget.vehicle;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Hapus Kendaraan?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        content: Text(
          'Kendaraan "${v.brand} ${v.model} (${v.plateNumber})" beserta seluruh riwayat BBM, servis, dan dokumennya akan dihapus permanen.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textMuted,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSoft,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Ya, Hapus',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted && v.id != null) {
      context.read<VehicleBloc>().add(ArchiveVehicle(v.id!));
      Navigator.pop(context, true);
    }
  }
}

// ─── Hero Header ───────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final VehicleModel vehicle;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HeroHeader({
    required this.vehicle,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _vehicleIcon() {
    switch (vehicle.type) {
      case 'motor':
        return Icons.two_wheeler_rounded;
      case 'mobil':
        return Icons.directions_car_rounded;
      default:
        return Icons.local_shipping_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradientVertical,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 4),
            // Top bar
            Row(
              children: [
                // Back button
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Detail Kendaraan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Edit button
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.edit_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Delete button
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 19,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Vehicle photo or icon
            if (vehicle.imagePath != null &&
                vehicle.imagePath!.isNotEmpty &&
                File(vehicle.imagePath!).existsSync())
              GestureDetector(
                onTap: () => ImageHelper.showFullScreenImage(
                  context,
                  file: File(vehicle.imagePath!),
                  title: '${vehicle.brand} ${vehicle.model} (${vehicle.plateNumber})',
                ),
                child: Container(
                  width: 220,
                  height: 145,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.45),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17.5),
                    child: Image.file(
                      File(vehicle.imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        _vehicleIcon(),
                        size: 110,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ),
              )
            else
              Icon(
                _vehicleIcon(),
                size: 150,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            const SizedBox(height: 12),
            // Plate badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                vehicle.plateNumber,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Vehicle name
            Text(
              '${vehicle.brand} ${vehicle.model}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${vehicle.color} · ${vehicle.year}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stats Grid ────────────────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final VehicleModel vehicle;

  const _StatsGrid({required this.vehicle});

  Future<(String, String)> _loadMeta() async {
    String lastService = '-';
    String nextTax = '-';
    if (vehicle.id == null) return (lastService, nextTax);

    final serviceRes = await ServiceLogRepository().getByVehicle(vehicle.id!);
    final services = serviceRes.fold((_) => <ServiceLogModel>[], (r) => r);
    if (services.isNotEmpty) {
      services.sort((a, b) => b.date.compareTo(a.date));
      lastService = Formatters.date(services.first.date);
    }

    final docRes = await VehicleDocumentRepository().getByVehicle(vehicle.id!);
    final docs = docRes.fold((_) => <VehicleDocumentModel>[], (r) => r);
    final vehicleDocs = docs
        .where((d) =>
            d.expiryDate != null &&
            (d.documentType.toLowerCase().contains('pajak') ||
                d.documentType.toUpperCase() == 'STNK'))
        .toList();
    if (vehicleDocs.isNotEmpty) {
      vehicleDocs.sort((a, b) => a.expiryDate!.compareTo(b.expiryDate!));
      nextTax = Formatters.date(vehicleDocs.first.expiryDate!);
    }

    return (lastService, nextTax);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FutureBuilder<(String, String)>(
        future: _loadMeta(),
        builder: (context, snapshot) {
          final lastService = snapshot.data?.$1 ?? '-';
          final nextTax = snapshot.data?.$2 ?? '-';

          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MiniStatCard(
                      iconBg: AppColors.tintGraphiteBg,
                      icon: Icons.speed_rounded,
                      iconColor: AppColors.tintGraphiteFg,
                      label: 'ODOMETER',
                      value: Formatters.odometer(vehicle.initialOdometer),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniStatCard(
                      iconBg: AppColors.tintPeachBg,
                      icon: Icons.local_gas_station_rounded,
                      iconColor: AppColors.tintPeachFg,
                      label: 'TIPE BBM',
                      value: vehicle.fuelType,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _MiniStatCard(
                      iconBg: AppColors.tintMintBg,
                      icon: Icons.build_rounded,
                      iconColor: AppColors.tintMintFg,
                      label: 'SERVIS TERAKHIR',
                      value: lastService,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniStatCard(
                      iconBg: AppColors.tintAmberBg,
                      icon: Icons.receipt_long_rounded,
                      iconColor: AppColors.tintAmberFg,
                      label: 'PAJAK BERIKUT',
                      value: nextTax,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _MiniStatCard({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppStyles.rLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon, size: 18, color: iconColor),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: AppColors.textSoft,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab Bar ───────────────────────────────────────────────────────────────────
class _TabBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTap;

  const _TabBar({required this.activeIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tabs = ['Spesifikasi', 'Servis', 'Dokumen'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isActive = index == activeIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      tabs[index],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─── Spesifikasi Card ──────────────────────────────────────────────────────────
class _SpesifikasiCard extends StatelessWidget {
  final VehicleModel vehicle;

  const _SpesifikasiCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final specs = [
      ('Nama', vehicle.name),
      ('Merk & Tipe', '${vehicle.brand} ${vehicle.model}'),
      ('Tahun', vehicle.year.toString()),
      ('Warna', vehicle.color),
      ('Plat Nomor', vehicle.plateNumber),
      ('Jenis', vehicle.type[0].toUpperCase() + vehicle.type.substring(1)),
      ('Bahan Bakar', vehicle.fuelType),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppStyles.rLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: List.generate(specs.length, (index) {
            final spec = specs[index];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        spec.$1,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        spec.$2,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < specs.length - 1)
                  Divider(color: AppColors.divider, height: 1),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ─── Servis Tab ───────────────────────────────────────────────────────────────
class _ServisTab extends StatelessWidget {
  final VehicleModel vehicle;

  const _ServisTab({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ServiceLogRepository().getByVehicle(vehicle.id!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final logs = snapshot.data?.fold(
          (l) => <ServiceLogModel>[],
          (r) => r,
        ) ?? <ServiceLogModel>[];

        if (logs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.tintMintBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.build_rounded,
                      color: AppColors.tintMintFg,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada catatan servis',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final displayLogs = logs.take(5).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              ...displayLogs.map((log) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppStyles.rLg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.tintMintBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.build_rounded,
                          size: 20,
                          color: AppColors.tintMintFg,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.description,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              log.workshopName ?? '-',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.currency(log.cost),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.date(log.date),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
              if (logs.length > 5)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: GestureDetector(
                    onTap: () {
                      final vehicleBloc = context.read<VehicleBloc>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: vehicleBloc,
                            child: const ServicePage(),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(AppStyles.r),
                      ),
                      child: Center(
                        child: Text(
                          'Lihat Semua Servis',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Dokumen Tab ──────────────────────────────────────────────────────────────
class _DokumenTab extends StatelessWidget {
  final VehicleModel vehicle;

  const _DokumenTab({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        FuelLogRepository().getByVehicle(vehicle.id!),
        ServiceLogRepository().getByVehicle(vehicle.id!),
        VehicleDocumentRepository().getByVehicle(vehicle.id!),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final results = snapshot.data;
        final fuelLogs = (results?[0] as dynamic)?.fold(
          (l) => <FuelLogModel>[],
          (r) => r,
        ) as List<FuelLogModel>? ?? <FuelLogModel>[];
        final serviceLogs = (results?[1] as dynamic)?.fold(
          (l) => <ServiceLogModel>[],
          (r) => r,
        ) as List<ServiceLogModel>? ?? <ServiceLogModel>[];
        final vehicleDocs = (results?[2] as dynamic)?.fold(
          (l) => <VehicleDocumentModel>[],
          (r) => r,
        ) as List<VehicleDocumentModel>? ?? <VehicleDocumentModel>[];

        final fuelWithPhotos = fuelLogs
            .where((l) => l.receiptImagePath != null)
            .toList();
        final serviceWithPhotos = serviceLogs
            .where((l) => l.receiptImagePath != null)
            .toList();
        final totalItems = vehicleDocs.length +
            fuelWithPhotos.length +
            serviceWithPhotos.length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Info count
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppStyles.rLg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.tintSlateBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.folder_rounded,
                        size: 20,
                        color: AppColors.tintSlateFg,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${vehicleDocs.length} dokumen resmi  ·  ${fuelLogs.length} BBM  ·  ${serviceLogs.length} servis',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (totalItems == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.badge_rounded,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada dokumen & nota',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Dokumen STNK, Pajak, BPKB, atau foto nota BBM/servis akan muncul di sini',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                ...vehicleDocs.map((doc) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _DocPhotoCard(
                    iconBg: AppColors.tintGraphiteBg,
                    icon: Icons.badge_rounded,
                    iconColor: AppColors.tintGraphiteFg,
                    title: doc.documentNumber != null &&
                            doc.documentNumber!.isNotEmpty
                        ? '${doc.documentType} · ${doc.documentNumber}'
                        : doc.documentType,
                    subtitle: doc.expiryDate != null
                        ? 'Berlaku s/d ${Formatters.date(doc.expiryDate!)}'
                        : (doc.notes ?? 'Dokumen Permanen'),
                    amount: doc.daysUntilExpiry != null
                        ? '${doc.daysUntilExpiry} hr'
                        : 'Aktif',
                    hasPhoto: doc.imagePath != null && doc.imagePath!.isNotEmpty,
                    onTap: () => _showAttachmentPreview(
                      context,
                      title: doc.documentNumber != null &&
                              doc.documentNumber!.isNotEmpty
                          ? '${doc.documentType} · ${doc.documentNumber}'
                          : doc.documentType,
                      subtitle: doc.expiryDate != null
                          ? 'Berlaku s/d ${Formatters.date(doc.expiryDate!)}'
                          : 'Dokumen Permanen',
                      badge: doc.daysUntilExpiry != null
                          ? '${doc.daysUntilExpiry} hari lagi'
                          : 'Aktif',
                      notes: doc.notes,
                      imagePath: doc.imagePath,
                    ),
                  ),
                )),
                ...fuelWithPhotos.map((log) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _DocPhotoCard(
                    iconBg: AppColors.tintPeachBg,
                    icon: Icons.local_gas_station_rounded,
                    iconColor: AppColors.tintPeachFg,
                    title: 'Nota BBM - ${log.fuelType}',
                    subtitle: Formatters.date(log.date),
                    amount: Formatters.currency(log.totalCost),
                    hasPhoto: log.receiptImagePath != null &&
                        log.receiptImagePath!.isNotEmpty,
                    onTap: () => _showAttachmentPreview(
                      context,
                      title: 'Nota BBM · ${log.fuelType}',
                      subtitle:
                          '${Formatters.date(log.date)} · ${log.liters.toStringAsFixed(2)} L · ${Formatters.odometer(log.odometer)}',
                      badge: Formatters.currency(log.totalCost),
                      notes: log.notes,
                      imagePath: log.receiptImagePath,
                    ),
                  ),
                )),
                ...serviceWithPhotos.map((log) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _DocPhotoCard(
                    iconBg: AppColors.tintMintBg,
                    icon: Icons.build_rounded,
                    iconColor: AppColors.tintMintFg,
                    title: 'Nota Servis - ${log.description}',
                    subtitle: Formatters.date(log.date),
                    amount: Formatters.currency(log.cost),
                    hasPhoto: log.receiptImagePath != null &&
                        log.receiptImagePath!.isNotEmpty,
                    onTap: () => _showAttachmentPreview(
                      context,
                      title: 'Nota Servis · ${log.serviceType}',
                      subtitle:
                          '${Formatters.date(log.date)} · ${log.workshopName ?? '-'}',
                      badge: Formatters.currency(log.cost),
                      notes: log.description,
                      imagePath: log.receiptImagePath,
                    ),
                  ),
                )),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showAttachmentPreview(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String badge,
    String? notes,
    String? imagePath,
  }) {
    final hasFile =
        imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      badge,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              if (notes != null && notes.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    notes,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: AppColors.text,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              if (hasFile)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(ctx).size.height * 0.5,
                    ),
                    child: InteractiveViewer(
                      child: Image.file(
                        File(imagePath),
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.image_not_supported_outlined,
                        size: 28,
                        color: AppColors.textSoft,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Belum ada foto lampiran untuk dokumen ini',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocPhotoCard extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String amount;
  final bool hasPhoto;
  final VoidCallback? onTap;

  const _DocPhotoCard({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.hasPhoto = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppStyles.rLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  amount,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  hasPhoto ? Icons.camera_alt : Icons.chevron_right_rounded,
                  size: hasPhoto ? 14 : 18,
                  color: hasPhoto ? AppColors.tintGraphiteFg : AppColors.textSoft,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
