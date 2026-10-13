import 'package:dartz/dartz.dart';
import 'package:flutter_kendaraanku_app/data/database_helper.dart';
import 'package:flutter_kendaraanku_app/data/models/vehicle_model.dart';

class VehicleRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.getInstance();

  Future<Either<String, List<VehicleModel>>> getByUser(int userId) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'vehicles',
        where: 'user_id = ? AND is_active = 1',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );
      return Right(results.map((m) => VehicleModel.fromMap(m)).toList());
    } catch (e) {
      return Left('Gagal memuat kendaraan: $e');
    }
  }

  Future<Either<String, VehicleModel>> getById(int id) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query('vehicles', where: 'id = ?', whereArgs: [id]);
      if (results.isEmpty) return const Left('Kendaraan tidak ditemukan');
      return Right(VehicleModel.fromMap(results.first));
    } catch (e) {
      return Left('Error: $e');
    }
  }

  Future<Either<String, int>> add(VehicleModel vehicle) async {
    try {
      final db = await _dbHelper.database;
      final id = await db.insert('vehicles', vehicle.toMap());
      return Right(id);
    } catch (e) {
      return Left('Gagal menambah kendaraan: $e');
    }
  }

  Future<Either<String, bool>> update(VehicleModel vehicle) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'vehicles',
        vehicle.copyWith(updatedAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [vehicle.id],
      );
      return const Right(true);
    } catch (e) {
      return Left('Gagal update kendaraan: $e');
    }
  }

  Future<Either<String, bool>> archive(int id) async {
    try {
      final db = await _dbHelper.database;
      await db.transaction((txn) async {
        await txn.delete(
          'fuel_logs',
          where: 'vehicle_id = ?',
          whereArgs: [id],
        );
        await txn.delete(
          'service_logs',
          where: 'vehicle_id = ?',
          whereArgs: [id],
        );
        await txn.delete(
          'vehicle_documents',
          where: 'vehicle_id = ?',
          whereArgs: [id],
        );
        await txn.delete(
          'vehicles',
          where: 'id = ?',
          whereArgs: [id],
        );
      });
      return const Right(true);
    } catch (e) {
      return Left('Gagal menghapus kendaraan: $e');
    }
  }

  Future<void> syncOdometerIfHigher(int vehicleId, double? odometer) async {
    if (odometer == null || odometer <= 0) return;
    try {
      final db = await _dbHelper.database;
      final rows = await db.query(
        'vehicles',
        columns: ['initial_odometer'],
        where: 'id = ?',
        whereArgs: [vehicleId],
      );
      if (rows.isEmpty) return;
      final currentOdo =
          (rows.first['initial_odometer'] as num?)?.toDouble() ?? 0.0;
      if (odometer > currentOdo) {
        await db.update(
          'vehicles',
          {
            'initial_odometer': odometer,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [vehicleId],
        );
      }
    } catch (_) {
      // Ignore odometer sync errors silently
    }
  }

  /// Recalculates the vehicle's odometer from the highest remaining fuel or
  /// service log entry when a log is updated or deleted.
  Future<void> recalculateOdometer(int vehicleId) async {
    try {
      final db = await _dbHelper.database;
      final fuelMaxRows = await db.rawQuery(
        'SELECT MAX(odometer) AS max_odo FROM fuel_logs WHERE vehicle_id = ?',
        [vehicleId],
      );
      final serviceMaxRows = await db.rawQuery(
        'SELECT MAX(odometer) AS max_odo FROM service_logs WHERE vehicle_id = ? AND odometer IS NOT NULL',
        [vehicleId],
      );

      final fuelMax =
          (fuelMaxRows.firstOrNull?['max_odo'] as num?)?.toDouble() ?? 0.0;
      final serviceMax =
          (serviceMaxRows.firstOrNull?['max_odo'] as num?)?.toDouble() ?? 0.0;
      final highestLogged = fuelMax > serviceMax ? fuelMax : serviceMax;

      if (highestLogged > 0) {
        await db.update(
          'vehicles',
          {
            'initial_odometer': highestLogged,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [vehicleId],
        );
      }
    } catch (_) {
      // Ignore odometer recalculation errors silently
    }
  }
}
