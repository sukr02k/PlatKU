import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_kendaraanku_app/data/models/fuel_log_model.dart';
import 'package:flutter_kendaraanku_app/data/models/service_log_model.dart';
import 'package:flutter_kendaraanku_app/data/models/vehicle_document_model.dart';
import 'package:flutter_kendaraanku_app/data/repositories/fuel_log_repository.dart';
import 'package:flutter_kendaraanku_app/data/repositories/service_log_repository.dart';
import 'package:flutter_kendaraanku_app/data/repositories/vehicle_document_repository.dart';
import 'package:flutter_kendaraanku_app/core/utils/formatters.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final FuelLogRepository _fuelLogRepository;
  final ServiceLogRepository _serviceLogRepository;
  final VehicleDocumentRepository _documentRepository;

  DashboardBloc(
    this._fuelLogRepository,
    this._serviceLogRepository, {
    VehicleDocumentRepository? documentRepository,
  })  : _documentRepository =
            documentRepository ?? VehicleDocumentRepository(),
        super(DashboardInitial()) {
    on<LoadDashboard>(_onLoad);
  }

  Future<void> _onLoad(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    final fuelResult = await _fuelLogRepository.getByVehicle(event.vehicleId);
    final serviceResult =
        await _serviceLogRepository.getByVehicle(event.vehicleId);
    final docResult =
        await _documentRepository.getByVehicle(event.vehicleId);

    // Handle errors
    if (fuelResult.isLeft()) {
      final error = fuelResult.fold((l) => l, (r) => '');
      emit(DashboardError(error));
      return;
    }
    if (serviceResult.isLeft()) {
      final error = serviceResult.fold((l) => l, (r) => '');
      emit(DashboardError(error));
      return;
    }

    final fuelLogs = fuelResult.getOrElse(() => []);
    final serviceLogs = serviceResult.getOrElse(() => []);
    final docs = docResult.getOrElse(() => []);

    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);

    // This month's fuel stats
    final fuelThisMonth =
        fuelLogs.where((l) => !l.date.isBefore(thisMonth)).toList();
    final totalFuelCostThisMonth =
        fuelThisMonth.fold(0.0, (sum, l) => sum + l.totalCost);
    final fuelCountThisMonth = fuelThisMonth.length;

    // This month's service stats
    final serviceThisMonth =
        serviceLogs.where((l) => !l.date.isBefore(thisMonth)).toList();
    final totalServiceCostThisMonth =
        serviceThisMonth.fold(0.0, (sum, l) => sum + l.cost);
    final serviceCountThisMonth = serviceThisMonth.length;

    final totalExpenseThisMonth =
        totalFuelCostThisMonth + totalServiceCostThisMonth;

    // Average consumption (full-tank-to-full-tank method)
    final avgConsumption = _calculateAvgConsumption(fuelLogs);

    // Recent activities (combine fuel + service, sort desc, take 5)
    final recentActivities = _buildRecentActivities(fuelLogs, serviceLogs);

    // Reminders from service logs + expiring vehicle documents
    final reminders = _buildReminders(serviceLogs, docs, now);

    emit(DashboardLoaded(DashboardData(
      totalExpenseThisMonth: totalExpenseThisMonth,
      totalFuelCostThisMonth: totalFuelCostThisMonth,
      totalServiceCostThisMonth: totalServiceCostThisMonth,
      avgConsumption: avgConsumption,
      fuelCountThisMonth: fuelCountThisMonth,
      serviceCountThisMonth: serviceCountThisMonth,
      recentActivities: recentActivities,
      reminders: reminders,
    )));
  }

  double _calculateAvgConsumption(List<FuelLogModel> logs) {
    final fullTankLogs = logs.where((l) => l.isFullTank).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (fullTankLogs.length < 2) return 0;

    double totalKm = 0;
    double totalLiters = 0;
    for (int i = 1; i < fullTankLogs.length; i++) {
      final km = fullTankLogs[i].odometer - fullTankLogs[i - 1].odometer;
      if (km > 0) {
        totalKm += km;
        totalLiters += fullTankLogs[i].liters;
      }
    }
    return totalLiters > 0 ? totalKm / totalLiters : 0;
  }

  List<ActivityItem> _buildRecentActivities(
    List<FuelLogModel> fuelLogs,
    List<ServiceLogModel> serviceLogs,
  ) {
    final activities = <ActivityItem>[];

    for (final log in fuelLogs) {
      final stationText = log.stationName ?? '';
      final dateText = Formatters.dateShort(log.date);
      activities.add(ActivityItem(
        type: 'fuel',
        title: 'Isi BBM ${log.fuelType}',
        subtitle:
            stationText.isNotEmpty ? '$stationText · $dateText' : dateText,
        amount: log.totalCost,
        date: log.date,
      ));
    }

    for (final log in serviceLogs) {
      final workshopText = log.workshopName ?? '';
      final dateText = Formatters.dateShort(log.date);
      activities.add(ActivityItem(
        type: 'service',
        title: log.description,
        subtitle: workshopText.isNotEmpty
            ? '$workshopText · $dateText'
            : dateText,
        amount: log.cost,
        date: log.date,
      ));
    }

    activities.sort((a, b) => b.date.compareTo(a.date));
    return activities.take(5).toList();
  }

  List<ReminderItem> _buildReminders(
    List<ServiceLogModel> serviceLogs,
    List<VehicleDocumentModel> docs,
    DateTime now,
  ) {
    final reminders = <ReminderItem>[];
    final today = DateTime(now.year, now.month, now.day);

    // Track seen service types so we only show the latest active reminder per service type
    final seenServiceTypes = <String>{};
    final sortedServices = List<ServiceLogModel>.from(serviceLogs)
      ..sort((a, b) => b.date.compareTo(a.date));

    for (final log in sortedServices) {
      if (log.nextServiceDate == null && log.nextServiceOdometer == null) {
        continue;
      }
      if (seenServiceTypes.contains(log.serviceType)) continue;

      final effectiveDueDate =
          log.nextServiceDate ?? log.date.add(const Duration(days: 90));
      final dueDay = DateTime(
        effectiveDueDate.year,
        effectiveDueDate.month,
        effectiveDueDate.day,
      );
      final daysUntil = dueDay.difference(today).inDays;

      // Show if upcoming or overdue within last 30 days
      if (daysUntil >= -30) {
        seenServiceTypes.add(log.serviceType);
        final odoText = log.nextServiceOdometer != null
            ? ' · Target ${Formatters.thousands(log.nextServiceOdometer!.round())} km'
            : '';
        reminders.add(ReminderItem(
          kind: 'service',
          title: log.description,
          subtitle: '${log.serviceType}$odoText',
          dueDate: effectiveDueDate,
          daysUntil: daysUntil,
          nextOdometer: log.nextServiceOdometer,
        ));
      }
    }

    for (final d in docs) {
      if (d.expiryDate == null) continue;
      final expDay = DateTime(
        d.expiryDate!.year,
        d.expiryDate!.month,
        d.expiryDate!.day,
      );
      final daysUntil = expDay.difference(today).inDays;
      if (daysUntil >= -30 && daysUntil <= 60) {
        reminders.add(ReminderItem(
          kind: 'document',
          title: 'Perpanjang ${d.documentType}',
          subtitle: d.documentNumber ?? 'Dokumen Kendaraan',
          dueDate: d.expiryDate!,
          daysUntil: daysUntil,
        ));
      }
    }

    reminders.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return reminders;
  }
}
