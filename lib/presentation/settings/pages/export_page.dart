import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import 'package:flutter_kendaraanku_app/core/constants/colors.dart';
import 'package:flutter_kendaraanku_app/core/utils/export_helper.dart';
import 'package:flutter_kendaraanku_app/data/repositories/fuel_log_repository.dart';
import 'package:flutter_kendaraanku_app/data/repositories/service_log_repository.dart';
import 'package:flutter_kendaraanku_app/data/repositories/vehicle_document_repository.dart';

class ExportPage extends StatefulWidget {
  final int vehicleId;
  final String vehicleName;
  final String plateNumber;

  const ExportPage({
    super.key,
    required this.vehicleId,
    required this.vehicleName,
    required this.plateNumber,
  });

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  bool _isLoading = false;
  String? _loadingLabel;
  String? _lastExportedPath;

  Future<void> _exportFuelCsv() async {
    setState(() {
      _isLoading = true;
      _loadingLabel = 'Export BBM (CSV)';
    });
    try {
      final result =
          await FuelLogRepository().getByVehicle(widget.vehicleId);
      result.fold(
        (error) => _showSnackBar(error, isError: true),
        (logs) async {
          if (logs.isEmpty) {
            _showSnackBar('Belum ada data BBM untuk diekspor',
                isError: true);
            return;
          }
          final path = await ExportHelper.exportFuelLogsCsv(
            logs,
            widget.vehicleName,
          );
          if (mounted) setState(() => _lastExportedPath = path);
          await Share.shareXFiles(
            [XFile(path)],
            text: 'Data BBM ${widget.vehicleName} (${widget.plateNumber}) - MotoVault',
          );
        },
      );
    } catch (e) {
      _showSnackBar('Gagal export: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingLabel = null;
        });
      }
    }
  }

  Future<void> _exportServiceCsv() async {
    setState(() {
      _isLoading = true;
      _loadingLabel = 'Export Servis (CSV)';
    });
    try {
      final result =
          await ServiceLogRepository().getByVehicle(widget.vehicleId);
      result.fold(
        (error) => _showSnackBar(error, isError: true),
        (logs) async {
          if (logs.isEmpty) {
            _showSnackBar('Belum ada data servis untuk diekspor',
                isError: true);
            return;
          }
          final path = await ExportHelper.exportServiceLogsCsv(
            logs,
            widget.vehicleName,
          );
          if (mounted) setState(() => _lastExportedPath = path);
          await Share.shareXFiles(
            [XFile(path)],
            text: 'Data Servis ${widget.vehicleName} (${widget.plateNumber}) - MotoVault',
          );
        },
      );
    } catch (e) {
      _showSnackBar('Gagal export: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingLabel = null;
        });
      }
    }
  }

  Future<void> _exportPdfReport({bool preview = false}) async {
    setState(() {
      _isLoading = true;
      _loadingLabel = preview
          ? 'Preview & Cetak Laporan (PDF)'
          : 'Laporan Lengkap (PDF)';
    });
    try {
      final fuelResult =
          await FuelLogRepository().getByVehicle(widget.vehicleId);
      final serviceResult =
          await ServiceLogRepository().getByVehicle(widget.vehicleId);
      final docResult =
          await VehicleDocumentRepository().getByVehicle(widget.vehicleId);

      final fuelLogs = fuelResult.getOrElse(() => []);
      final serviceLogs = serviceResult.getOrElse(() => []);
      final docs = docResult.getOrElse(() => []);

      if (fuelLogs.isEmpty && serviceLogs.isEmpty && docs.isEmpty) {
        _showSnackBar('Belum ada data untuk diekspor', isError: true);
        return;
      }

      final path = await ExportHelper.exportVehicleReportPdf(
        vehicleName: widget.vehicleName,
        plateNumber: widget.plateNumber,
        fuelLogs: fuelLogs,
        serviceLogs: serviceLogs,
        documents: docs,
      );
      if (mounted) setState(() => _lastExportedPath = path);

      if (preview) {
        final bytes = await File(path).readAsBytes();
        await Printing.layoutPdf(
          onLayout: (_) async => bytes,
          name: 'Laporan_${widget.vehicleName.replaceAll(' ', '_')}.pdf',
        );
      } else {
        await Share.shareXFiles(
          [XFile(path)],
          text: 'Laporan Kendaraan ${widget.vehicleName} (${widget.plateNumber}) - MotoVault',
        );
      }
    } catch (e) {
      _showSnackBar('Gagal export: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingLabel = null;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontSize: 12),
        ),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Column(
          children: [
            _buildHeroHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  children: [
                    _buildVehicleCard(),
                    const SizedBox(height: 24),
                    _buildExportButton(
                      icon: Icons.print_rounded,
                      label: 'Preview & Cetak Laporan (PDF)',
                      subtitle:
                          'Tampilkan pratinjau dokumen PDF A4 siap cetak langsung di layar',
                      tintBg: AppColors.tintBlueBg,
                      tintFg: AppColors.tintBlueFg,
                      onTap: () => _exportPdfReport(preview: true),
                    ),
                    const SizedBox(height: 12),
                    _buildExportButton(
                      icon: Icons.description_outlined,
                      label: 'Laporan Lengkap (PDF)',
                      subtitle:
                          'Buat & bagikan laporan ringkasan + riwayat BBM & servis (PDF)',
                      tintBg: AppColors.tintLavenderBg,
                      tintFg: AppColors.tintLavenderFg,
                      onTap: () => _exportPdfReport(preview: false),
                    ),
                    const SizedBox(height: 12),
                    _buildExportButton(
                      icon: Icons.local_gas_station_outlined,
                      label: 'Export BBM (CSV)',
                      subtitle:
                          'Ekspor & bagikan semua catatan pengisian BBM ke file CSV',
                      tintBg: AppColors.tintPeachBg,
                      tintFg: AppColors.tintPeachFg,
                      onTap: _exportFuelCsv,
                    ),
                    const SizedBox(height: 12),
                    _buildExportButton(
                      icon: Icons.build_outlined,
                      label: 'Export Servis (CSV)',
                      subtitle:
                          'Ekspor & bagikan semua catatan servis ke file CSV',
                      tintBg: AppColors.tintMintBg,
                      tintFg: AppColors.tintMintFg,
                      onTap: _exportServiceCsv,
                    ),
                    if (_lastExportedPath != null) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.tintMintBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                size: 18, color: AppColors.tintMintFg),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tersimpan di: $_lastExportedPath',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.tintMintFg,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradientVertical,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            right: -60,
            top: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Export Data',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.tintBlueBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.directions_car_outlined,
              size: 22,
              color: AppColors.tintBlueFg,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.vehicleName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.plateNumber,
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
    );
  }

  Widget _buildExportButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color tintBg,
    required Color tintFg,
    required VoidCallback onTap,
  }) {
    final isCurrentlyLoading = _isLoading && _loadingLabel == label;

    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isLoading && !isCurrentlyLoading ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tintBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isCurrentlyLoading
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: tintFg,
                        ),
                      )
                    : Icon(icon, size: 20, color: tintFg),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.file_download_outlined,
                size: 20,
                color: AppColors.textSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
