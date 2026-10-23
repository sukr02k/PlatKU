import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:platku/core/utils/formatters.dart';
import 'package:platku/data/models/fuel_log_model.dart';
import 'package:platku/data/models/service_log_model.dart';
import 'package:platku/data/models/vehicle_document_model.dart';

class ExportHelper {
  /// Export fuel logs to CSV file, returns the file path
  static Future<String> exportFuelLogsCsv(
    List<FuelLogModel> logs,
    String vehicleName,
  ) async {
    final headers = [
      'Tanggal',
      'Odometer (km)',
      'Liter',
      'Harga/Liter',
      'Total',
      'Jenis BBM',
      'SPBU',
      'Full Tank',
      'Catatan',
    ];
    final rows = logs
        .map((l) => [
              l.date.toIso8601String().substring(0, 10),
              l.odometer.toString(),
              l.liters.toString(),
              l.pricePerLiter.toString(),
              l.totalCost.toString(),
              l.fuelType,
              l.stationName ?? '',
              l.isFullTank ? 'Ya' : 'Tidak',
              l.notes ?? '',
            ])
        .toList();

    final csvData = const ListToCsvConverter().convert([headers, ...rows]);
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final safeName = vehicleName.replaceAll(' ', '_');
    final file = File('${dir.path}/bbm_${safeName}_$timestamp.csv');
    await file.writeAsString(csvData);
    return file.path;
  }

  /// Export service logs to CSV file, returns the file path
  static Future<String> exportServiceLogsCsv(
    List<ServiceLogModel> logs,
    String vehicleName,
  ) async {
    final headers = [
      'Tanggal',
      'Odometer (km)',
      'Jenis Servis',
      'Deskripsi',
      'Biaya',
      'Bengkel',
      'Catatan',
    ];
    final rows = logs
        .map((l) => [
              l.date.toIso8601String().substring(0, 10),
              l.odometer?.toString() ?? '',
              l.serviceType,
              l.description,
              l.cost.toString(),
              l.workshopName ?? '',
              l.notes ?? '',
            ])
        .toList();

    final csvData = const ListToCsvConverter().convert([headers, ...rows]);
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final safeName = vehicleName.replaceAll(' ', '_');
    final file = File('${dir.path}/servis_${safeName}_$timestamp.csv');
    await file.writeAsString(csvData);
    return file.path;
  }

  /// Export full vehicle report as PDF, returns the file path
  static Future<String> exportVehicleReportPdf({
    required String vehicleName,
    required String plateNumber,
    required List<FuelLogModel> fuelLogs,
    required List<ServiceLogModel> serviceLogs,
    List<VehicleDocumentModel> documents = const [],
  }) async {
    final pdf = pw.Document();

    final totalFuelCost =
        fuelLogs.fold(0.0, (sum, l) => sum + l.totalCost);
    final totalServiceCost =
        serviceLogs.fold(0.0, (sum, l) => sum + l.cost);
    final totalLiters =
        fuelLogs.fold(0.0, (sum, l) => sum + l.liters);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            text: 'Laporan Kendaraan PlatKU - $vehicleName',
          ),
          pw.Paragraph(text: 'Plat Nomor: $plateNumber'),
          pw.Paragraph(
            text: 'Tanggal Cetak: ${Formatters.date(DateTime.now())}',
          ),
          pw.SizedBox(height: 16),

          // Summary
          pw.Header(level: 1, text: 'Ringkasan Operasional'),
          pw.Bullet(
            text:
                'Total BBM: ${fuelLogs.length}x pengisian (${Formatters.liters(totalLiters)})',
          ),
          pw.Bullet(
            text: 'Total Biaya BBM: ${Formatters.currency(totalFuelCost)}',
          ),
          pw.Bullet(
            text: 'Total Servis: ${serviceLogs.length} kali',
          ),
          pw.Bullet(
            text:
                'Total Biaya Servis: ${Formatters.currency(totalServiceCost)}',
          ),
          pw.Bullet(
            text:
                'Total Pengeluaran: ${Formatters.currency(totalFuelCost + totalServiceCost)}',
          ),
          if (documents.isNotEmpty)
            pw.Bullet(
              text: 'Dokumen Tercatat: ${documents.length} dokumen',
            ),
          pw.SizedBox(height: 20),

          // Documents table
          if (documents.isNotEmpty) ...[
            pw.Header(level: 1, text: 'Daftar Dokumen Kendaraan'),
            pw.TableHelper.fromTextArray(
              headers: [
                'Jenis Dokumen',
                'Nomor Dokumen',
                'Masa Berlaku',
                'Status',
              ],
              data: documents.map((d) {
                final days = d.daysUntilExpiry;
                final status = days == null
                    ? 'Tercatat'
                    : days < 0
                        ? 'Kedaluwarsa (${-days} hr lalu)'
                        : days <= 30
                            ? 'Segera Habis ($days hr lagi)'
                            : 'Aktif ($days hr lagi)';
                return [
                  d.documentType,
                  d.documentNumber ?? '-',
                  d.expiryDate != null ? Formatters.date(d.expiryDate!) : '-',
                  status,
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 20),
          ],

          // Fuel logs table
          if (fuelLogs.isNotEmpty) ...[
            pw.Header(level: 1, text: 'Riwayat Pengisian BBM'),
            pw.TableHelper.fromTextArray(
              headers: [
                'Tanggal',
                'Jenis BBM',
                'Tipe',
                'Odometer',
                'Liter',
                'Total',
              ],
              data: fuelLogs
                  .map((l) => [
                        Formatters.date(l.date),
                        l.fuelType,
                        l.isFullTank ? 'Full' : 'Parsial',
                        Formatters.odometer(l.odometer),
                        Formatters.liters(l.liters),
                        Formatters.currency(l.totalCost),
                      ])
                  .toList(),
            ),
            pw.SizedBox(height: 20),
          ],

          // Service logs table
          if (serviceLogs.isNotEmpty) ...[
            pw.Header(level: 1, text: 'Riwayat Servis & Perawatan'),
            pw.TableHelper.fromTextArray(
              headers: [
                'Tanggal',
                'Kategori',
                'Deskripsi',
                'Bengkel',
                'Biaya',
              ],
              data: serviceLogs
                  .map((l) => [
                        Formatters.date(l.date),
                        l.serviceType,
                        l.description,
                        l.workshopName ?? '-',
                        Formatters.currency(l.cost),
                      ])
                  .toList(),
            ),
          ],
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final safeName = vehicleName.replaceAll(' ', '_');
    final file =
        File('${dir.path}/laporan_${safeName}_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }
}
