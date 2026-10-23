import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:platku/core/constants/strings.dart';
import 'package:platku/core/theme_controller.dart';
import 'package:platku/core/utils/formatters.dart';
import 'package:platku/core/utils/password_hasher.dart';
import 'package:platku/core/utils/receipt_parser.dart';
import 'package:platku/data/models/user_model.dart';
import 'package:platku/data/models/vehicle_document_model.dart';
import 'package:platku/data/models/vehicle_model.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('id_ID', null);
  });

  group('PlatKU Brand & ThemeController', () {
    test('AppStrings exposes PlatKU brand identity and v1.2.0 version', () {
      expect(AppStrings.appName, 'PlatKU');
      expect(AppStrings.appTagline, 'Catatan Kendaraan Pribadi di Genggaman');
      expect(AppStrings.appVersion, 'v1.2.0');
      expect(AppStrings.appBuild, 'Build 3');
    });

    test('ThemeController switches between light, dark, and system modes',
        () async {
      await ThemeController.instance.load();
      expect(ThemeController.instance.value, ThemeMode.light);

      await ThemeController.instance.setThemeById('dark');
      expect(ThemeController.instance.value, ThemeMode.dark);
      expect(ThemeController.instance.currentId, 'dark');

      await ThemeController.instance.setThemeById('system');
      expect(ThemeController.instance.value, ThemeMode.system);
      expect(ThemeController.instance.currentId, 'system');
    });
  });

  group('PasswordHasher Security Utilities', () {
    test('Hashes plain password with salted SHA-256 and verifies accurately', () {
      final hashed = PasswordHasher.hash('rahasia123');
      expect(PasswordHasher.isHashed(hashed), isTrue);
      expect(hashed, isNot('rahasia123'));
      expect(PasswordHasher.verify('rahasia123', hashed), isTrue);
      expect(PasswordHasher.verify('salah123', hashed), isFalse);
      // Idempotent if called again on already-hashed string
      expect(PasswordHasher.hash(hashed), equals(hashed));
      // Backward compatible with legacy plain text
      expect(PasswordHasher.verify('legacyPass', 'legacyPass'), isTrue);
    });
  });

  group('Formatters Indonesian Locale Utilities', () {
    test('Formats currency, odometer, and fuel consumption accurately', () {
      expect(Formatters.currency(450000), contains('450.000'));
      expect(Formatters.odometer(14850), '14.850 km');
      expect(Formatters.consumption(42.5), '42,5 km/L');
      expect(Formatters.parseFormattedNumber('Rp 1.250.000'), 1250000.0);
    });
  });

  group('ReceiptParser Offline OCR Heuristics', () {
    test('Parses Indonesian Pertamina SPBU fuel receipt accurately', () {
      const sampleReceipt = '''
PERTAMINA SPBU 34.129.02
JL. JEND SUDIRMAN JAKARTA
TANGGAL: 14/08/2026
PRODUK: PERTAMAX
HARGA/LITER: Rp 13.700
VOLUME: 4,20 L
TOTAL HARGA: Rp 57.540
''';

      final parsed = ReceiptParser.parse(sampleReceipt);
      expect(parsed.kind, ReceiptKind.fuel);
      expect(parsed.fuelType, 'Pertamax');
      expect(parsed.liters, closeTo(4.2, 0.01));
      expect(parsed.pricePerLiter, 13700);
      expect(parsed.totalAmount, 57540);
      expect(parsed.date, DateTime(2026, 8, 14));
    });

    test('Detects and parses workshop service receipt accurately', () {
      const serviceReceipt = '''
AHASS HONDA ASTRA MOTOR
SERVIS BERKALA & GANTI OLI
10-09-2026
TOTAL BAYAR: Rp 245.000
''';

      final parsed = ReceiptParser.parse(serviceReceipt);
      expect(parsed.kind, ReceiptKind.service);
      expect(parsed.totalAmount, 245000);
      expect(parsed.date, DateTime(2026, 9, 10));
    });
  });

  group('VehicleDocumentModel Expiry Calculations', () {
    test('Correctly identifies expiring soon and expired documents', () {
      final now = DateTime.now();
      final expiringDoc = VehicleDocumentModel(
        vehicleId: 1,
        documentType: 'Pajak Tahunan',
        documentNumber: 'PKB-2026',
        expiryDate: now.add(const Duration(days: 12)),
        createdAt: now,
        updatedAt: now,
      );
      expect(expiringDoc.isExpired, isFalse);
      expect(expiringDoc.isExpiringSoon, isTrue);

      final expiredDoc = VehicleDocumentModel(
        vehicleId: 1,
        documentType: 'SIM',
        documentNumber: 'SIM-C-001',
        expiryDate: now.subtract(const Duration(days: 5)),
        createdAt: now,
        updatedAt: now,
      );
      expect(expiredDoc.isExpired, isTrue);
      expect(expiredDoc.isExpiringSoon, isFalse);
    });
  });

  group('UserModel Profile & Avatar Serialization', () {
    test('Correctly serializes, deserializes, and copies user imagePath', () {
      final now = DateTime.now();
      final user = UserModel(
        id: 1,
        name: 'Abdan Syakuro',
        email: 'abdan@platku.id',
        password: 'hashedpassword',
        imagePath: '/data/user/avatar.jpg',
        createdAt: now,
        updatedAt: now,
      );

      final map = user.toMap();
      expect(map['image_path'], '/data/user/avatar.jpg');
      expect(map['name'], 'Abdan Syakuro');
      expect(map['email'], 'abdan@platku.id');

      final deserialized = UserModel.fromMap(map);
      expect(deserialized.imagePath, '/data/user/avatar.jpg');
      expect(deserialized.name, 'Abdan Syakuro');

      final updated = user.copyWith(imagePath: '/data/user/new_avatar.jpg');
      expect(updated.imagePath, '/data/user/new_avatar.jpg');
      expect(updated.name, 'Abdan Syakuro');
    });
  });

  group('VehicleModel Garage Entity & Photo Serialization', () {
    test('Correctly serializes, deserializes, and copies vehicle model with imagePath', () {
      final now = DateTime.now();
      final vehicle = VehicleModel(
        id: 42,
        userId: 1,
        name: 'Vario Kesayangan',
        type: 'motor',
        brand: 'Honda',
        model: 'Vario 160',
        year: 2024,
        plateNumber: 'B 1234 XYZ',
        color: 'Matte Black',
        imagePath: '/data/user/0/app/app_flutter/vario.jpg',
        initialOdometer: 12500.0,
        fuelType: 'Pertamax',
        tankCapacity: 5.5,
        isActive: true,
        notes: 'Motor harian kantor',
        createdAt: now,
        updatedAt: now,
      );

      final map = vehicle.toMap();
      expect(map['id'], 42);
      expect(map['user_id'], 1);
      expect(map['name'], 'Vario Kesayangan');
      expect(map['brand'], 'Honda');
      expect(map['plate_number'], 'B 1234 XYZ');
      expect(map['image_path'], '/data/user/0/app/app_flutter/vario.jpg');
      expect(map['tank_capacity'], 5.5);
      expect(map['initial_odometer'], 12500.0);
      expect(map['is_active'], 1);

      final fromMap = VehicleModel.fromMap(map);
      expect(fromMap.id, 42);
      expect(fromMap.imagePath, '/data/user/0/app/app_flutter/vario.jpg');
      expect(fromMap.tankCapacity, 5.5);
      expect(fromMap.initialOdometer, 12500.0);
      expect(fromMap.isActive, isTrue);

      final updated = vehicle.copyWith(
        imagePath: '/data/user/0/app/app_flutter/vario_updated.jpg',
        isActive: false,
      );
      expect(updated.imagePath, '/data/user/0/app/app_flutter/vario_updated.jpg');
      expect(updated.isActive, isFalse);
      expect(updated.brand, 'Honda');
      expect(updated.toMap()['is_active'], 0);
    });
  });
}

