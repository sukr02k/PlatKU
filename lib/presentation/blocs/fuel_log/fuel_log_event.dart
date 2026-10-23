import 'package:platku/data/models/fuel_log_model.dart';

abstract class FuelLogEvent {}

class LoadFuelLogs extends FuelLogEvent {
  final int vehicleId;
  LoadFuelLogs(this.vehicleId);
}

class AddFuelLog extends FuelLogEvent {
  final FuelLogModel fuelLog;
  AddFuelLog(this.fuelLog);
}

class UpdateFuelLog extends FuelLogEvent {
  final FuelLogModel fuelLog;
  UpdateFuelLog(this.fuelLog);
}

class DeleteFuelLog extends FuelLogEvent {
  final int id;
  final int vehicleId;
  DeleteFuelLog(this.id, this.vehicleId);
}
