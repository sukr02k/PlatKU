import 'package:flutter_kendaraanku_app/core/utils/password_hasher.dart';
import 'package:flutter_kendaraanku_app/data/database_helper.dart';
import 'package:flutter_kendaraanku_app/data/local/auth_local_datasource.dart';

class DemoDataSeeder {
  static const String demoEmail = 'abdan@motovault.id';
  static const String demoName = 'Abdan Syakuro';
  static const String demoPassword = 'motovault123';

  /// Deletes all vehicles, fuel logs, service logs, and documents for [userId].
  static Future<void> clearUserGarage(int userId) async {
    final db = await DatabaseHelper.getInstance().database;
    final existingVehicles = await db.query(
      'vehicles',
      columns: ['id'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    for (final v in existingVehicles) {
      final vId = v['id'] as int;
      await db.delete('fuel_logs', where: 'vehicle_id = ?', whereArgs: [vId]);
      await db.delete('service_logs', where: 'vehicle_id = ?', whereArgs: [vId]);
      await db.delete(
        'vehicle_documents',
        where: 'vehicle_id = ?',
        whereArgs: [vId],
      );
    }
    await db.delete('vehicles', where: 'user_id = ?', whereArgs: [userId]);
  }

  /// Seeds demo user + vehicles + fuel logs + service logs + documents,
  /// logs the user in, and returns the userId.
  static Future<int> seedAndLogin({int? targetUserId}) async {
    final db = await DatabaseHelper.getInstance().database;
    final now = DateTime.now();
    final nowIso = now.toIso8601String();
    final hashedDemoPassword = PasswordHasher.hash(demoPassword);

    int userId;
    String userName = demoName;
    String userEmail = demoEmail;

    if (targetUserId != null) {
      userId = targetUserId;
      final uRows = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );
      if (uRows.isNotEmpty) {
        userName = uRows.first['name'] as String;
        userEmail = uRows.first['email'] as String;
      }
    } else {
      final existing = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [demoEmail],
      );
      if (existing.isNotEmpty) {
        userId = existing.first['id'] as int;
        userName = existing.first['name'] as String;
        final storedPwd = existing.first['password'] as String? ?? '';
        if (!PasswordHasher.isHashed(storedPwd)) {
          await db.update(
            'users',
            {'password': hashedDemoPassword, 'updated_at': nowIso},
            where: 'id = ?',
            whereArgs: [userId],
          );
        }
      } else {
        userId = await db.insert('users', {
          'name': demoName,
          'email': demoEmail,
          'password': hashedDemoPassword,
          'created_at': nowIso,
          'updated_at': nowIso,
        });
      }
    }

    // Remove existing data for this user to ensure clean, idempotent demo seeding
    await clearUserGarage(userId);

    // 1. Insert Vehicle 1: Honda Vario 160 ABS
    final varioId = await db.insert('vehicles', {
      'user_id': userId,
      'name': 'Vario 160 Daily',
      'type': 'motor',
      'brand': 'Honda',
      'model': 'Vario 160 ABS',
      'year': 2024,
      'plate_number': 'B 4821 KZR',
      'color': 'Matte Cobalt Blue',
      'initial_odometer': 14850.0,
      'fuel_type': 'Pertamax',
      'tank_capacity': 5.5,
      'is_active': 1,
      'notes': 'Kendaraan harian komuter Jakarta Selatan',
      'created_at': nowIso,
      'updated_at': nowIso,
    });

    // 2. Insert Vehicle 2: Toyota Kijang Innova Zenix Hybrid
    final zenixId = await db.insert('vehicles', {
      'user_id': userId,
      'name': 'Innova Zenix Hybrid',
      'type': 'mobil',
      'brand': 'Toyota',
      'model': 'Kijang Innova Zenix Q HV',
      'year': 2025,
      'plate_number': 'B 1024 SUK',
      'color': 'Platinum White Pearl',
      'initial_odometer': 22400.0,
      'fuel_type': 'Pertamax',
      'tank_capacity': 52.0,
      'is_active': 1,
      'notes': 'Mobil keluarga & perjalanan luar kota',
      'created_at': nowIso,
      'updated_at': nowIso,
    });

    // 3. Seed 6 months of Fuel Logs for Vario 160
    final varioFuelEntries = [
      (daysAgo: 150, odo: 12100.0, liters: 4.2, price: 12950.0, station: 'SPBU Pertamina MT Haryono', notes: 'Full tank awal bulan'),
      (daysAgo: 125, odo: 12490.0, liters: 4.3, price: 12950.0, station: 'SPBU Pertamina Tebet', notes: 'Tarikan mesin enteng'),
      (daysAgo: 98, odo: 12880.0, liters: 4.1, price: 13200.0, station: 'Shell Kuningan', notes: 'Shell Super RON 92'),
      (daysAgo: 72, odo: 13290.0, liters: 4.4, price: 13200.0, station: 'SPBU Pertamina Pancoran', notes: 'Rutin komuter'),
      (daysAgo: 48, odo: 13710.0, liters: 4.3, price: 13500.0, station: 'SPBU Pertamina Kalibata', notes: 'Isi penuh pagi hari'),
      (daysAgo: 28, odo: 14120.0, liters: 4.2, price: 13500.0, station: 'Shell Gatot Subroto', notes: 'Perjalanan dalam kota'),
      (daysAgo: 14, odo: 14490.0, liters: 4.1, price: 13700.0, station: 'SPBU Pertamina Mampang', notes: 'Kondisi lalu lintas padat'),
      (daysAgo: 3, odo: 14850.0, liters: 4.0, price: 13700.0, station: 'SPBU Pertamina Kemang', notes: 'Pengisian terakhir minggu ini'),
    ];

    for (final f in varioFuelEntries) {
      final d = now.subtract(Duration(days: f.daysAgo));
      await db.insert('fuel_logs', {
        'vehicle_id': varioId,
        'date': d.toIso8601String(),
        'odometer': f.odo,
        'liters': f.liters,
        'price_per_liter': f.price,
        'total_cost': f.liters * f.price,
        'fuel_type': 'Pertamax',
        'station_name': f.station,
        'is_full_tank': 1,
        'notes': f.notes,
        'created_at': d.toIso8601String(),
      });
    }

    // 4. Seed 6 months of Fuel Logs for Innova Zenix Hybrid
    final zenixFuelEntries = [
      (daysAgo: 140, odo: 17600.0, liters: 36.0, price: 12950.0, station: 'SPBU Pertamina COCO Fatmawati', notes: 'Isi penuh sebelum tol Trans Jawa'),
      (daysAgo: 110, odo: 18420.0, liters: 38.5, price: 13200.0, station: 'Rest Area KM 57 Cikampek', notes: 'Perjalanan dinas Bandung'),
      (daysAgo: 80, odo: 19250.0, liters: 37.0, price: 13200.0, station: 'Shell Antasari', notes: 'Efisiensi hybrid sangat irit'),
      (daysAgo: 52, odo: 20100.0, liters: 39.0, price: 13500.0, station: 'SPBU Pertamina Pondok Indah', notes: 'Pemakaian kombinasi tol & kota'),
      (daysAgo: 25, odo: 21250.0, liters: 41.0, price: 13700.0, station: 'SPBU Pertamina Senayan', notes: 'Isi penuh akhir pekan'),
      (daysAgo: 5, odo: 22400.0, liters: 40.5, price: 13700.0, station: 'Shell TB Simatupang', notes: 'Konsumsi stabil 18.8 km/L'),
    ];

    for (final f in zenixFuelEntries) {
      final d = now.subtract(Duration(days: f.daysAgo));
      await db.insert('fuel_logs', {
        'vehicle_id': zenixId,
        'date': d.toIso8601String(),
        'odometer': f.odo,
        'liters': f.liters,
        'price_per_liter': f.price,
        'total_cost': f.liters * f.price,
        'fuel_type': 'Pertamax',
        'station_name': f.station,
        'is_full_tank': 1,
        'notes': f.notes,
        'created_at': d.toIso8601String(),
      });
    }

    // 5. Seed Service Logs for Vario 160
    await db.insert('service_logs', {
      'vehicle_id': varioId,
      'date': now.subtract(const Duration(days: 18)).toIso8601String(),
      'odometer': 14500.0,
      'service_type': 'Ganti Oli Mesin',
      'description': 'Ganti Oli Mesin SPX2 & Oli Gardan AHM',
      'cost': 95000.0,
      'workshop_name': 'AHASS Wahana Tebet',
      'next_service_odometer': 16500.0,
      'next_service_date': now.add(const Duration(days: 5)).toIso8601String(),
      'notes': 'Oli Mesin AHM SPX2 0.8L, Oli Gardan, cek tekanan ban nitrogen',
      'created_at': nowIso,
    });

    await db.insert('service_logs', {
      'vehicle_id': varioId,
      'date': now.subtract(const Duration(days: 65)).toIso8601String(),
      'odometer': 13200.0,
      'service_type': 'Ganti Kampas Rem',
      'description': 'Ganti Kampas Rem Depan ABS & Belakang',
      'cost': 165000.0,
      'workshop_name': 'AHASS Kuningan Motor',
      'next_service_odometer': 20000.0,
      'notes': 'Kampas rem original Honda Genuine Parts + minyak rem DOT 4',
      'created_at': nowIso,
    });

    await db.insert('service_logs', {
      'vehicle_id': varioId,
      'date': now.subtract(const Duration(days: 115)).toIso8601String(),
      'odometer': 12000.0,
      'service_type': 'Tune Up / Servis Rutin',
      'description': 'Servis CVT Lengkap & Injeksi Cleaner',
      'cost': 185000.0,
      'workshop_name': 'AHASS Wahana Tebet',
      'next_service_odometer': 16000.0,
      'notes': 'Pembersihan rumah CVT, grease ulang pulley, cek roller & V-Belt',
      'created_at': nowIso,
    });

    // 6. Seed Service Logs for Innova Zenix Hybrid
    await db.insert('service_logs', {
      'vehicle_id': zenixId,
      'date': now.subtract(const Duration(days: 35)).toIso8601String(),
      'odometer': 20100.0,
      'service_type': 'Tune Up / Servis Rutin',
      'description': 'Servis Berkala 20.000 KM & Health Check Hybrid',
      'cost': 1450000.0,
      'workshop_name': 'Auto2000 Sudirman',
      'next_service_odometer': 30000.0,
      'next_service_date': now.add(const Duration(days: 18)).toIso8601String(),
      'notes': 'Oli TMO 0W-20 Full Synthetic 4L, Filter Oli, Filter Baterai HV, Balancing 4 Roda',
      'created_at': nowIso,
    });

    await db.insert('service_logs', {
      'vehicle_id': zenixId,
      'date': now.subtract(const Duration(days: 85)).toIso8601String(),
      'odometer': 18500.0,
      'service_type': 'Servis AC',
      'description': 'Flushing AC & Ganti Cabin Filter Karbon Aktif',
      'cost': 650000.0,
      'workshop_name': 'Rotary Bintaro',
      'notes': 'Suhu kabin kembali dingin maksimal 18°C',
      'created_at': nowIso,
    });

    // 7. Seed Vehicle Documents
    await db.insert('vehicle_documents', {
      'vehicle_id': varioId,
      'document_type': 'STNK',
      'document_number': 'STNK-B4821KZR-2024',
      'issue_date': DateTime(now.year - 1, now.month, now.day).toIso8601String(),
      'expiry_date': now.add(const Duration(days: 12)).toIso8601String(),
      'notes': 'Perpanjangan pajak tahunan via aplikasi SIGNAL Samsat Digital',
      'created_at': nowIso,
      'updated_at': nowIso,
    });

    await db.insert('vehicle_documents', {
      'vehicle_id': varioId,
      'document_type': 'SIM',
      'document_number': 'SIM-C-317499080012',
      'issue_date': DateTime(now.year - 2, 5, 10).toIso8601String(),
      'expiry_date': DateTime(now.year + 3, 5, 10).toIso8601String(),
      'notes': 'SIM C Metro Jaya a.n. Abdan Syakuro',
      'created_at': nowIso,
      'updated_at': nowIso,
    });

    await db.insert('vehicle_documents', {
      'vehicle_id': zenixId,
      'document_type': 'Pajak',
      'document_number': 'PKB-B1024SUK-2026',
      'issue_date': DateTime(now.year - 1, now.month, now.day).toIso8601String(),
      'expiry_date': now.add(const Duration(days: 26)).toIso8601String(),
      'notes': 'PKB Tahunan Kijang Innova Zenix Hybrid',
      'created_at': nowIso,
      'updated_at': nowIso,
    });

    await db.insert('vehicle_documents', {
      'vehicle_id': zenixId,
      'document_type': 'Asuransi',
      'document_number': 'GARDA-OTO-9928174',
      'issue_date': DateTime(now.year, 1, 15).toIso8601String(),
      'expiry_date': DateTime(now.year + 1, 1, 15).toIso8601String(),
      'notes': 'Asuransi Comprehensive All-Risk + Perluasan Banjir & TJH',
      'created_at': nowIso,
      'updated_at': nowIso,
    });

    await db.insert('vehicle_documents', {
      'vehicle_id': zenixId,
      'document_type': 'BPKB',
      'document_number': 'BPKB-M-09823411',
      'issue_date': DateTime(2025, 2, 1).toIso8601String(),
      'expiry_date': null,
      'notes': 'Tersimpan di brankas rumah',
      'created_at': nowIso,
      'updated_at': nowIso,
    });

    // Save session
    final authLocal = AuthLocalDatasource();
    await authLocal.setFirstTimeDone();
    await authLocal.saveSession(
      userId: userId,
      userName: userName,
      userEmail: userEmail,
    );

    return userId;
  }
}
