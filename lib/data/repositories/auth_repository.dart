import 'package:dartz/dartz.dart';
import 'package:platku/core/utils/password_hasher.dart';
import 'package:platku/data/database_helper.dart';
import 'package:platku/data/models/user_model.dart';

class AuthRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.getInstance();

  Future<Either<String, UserModel>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final db = await _dbHelper.database;

      final existing = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      if (existing.isNotEmpty) {
        return const Left('Email sudah terdaftar');
      }

      final now = DateTime.now();
      final hashedPassword = PasswordHasher.hash(password);
      final id = await db.insert('users', {
        'name': name,
        'email': email,
        'password': hashedPassword,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      final user = UserModel(
        id: id,
        name: name,
        email: email,
        password: hashedPassword,
        createdAt: now,
        updatedAt: now,
      );
      return Right(user);
    } catch (e) {
      return Left('Gagal mendaftar: $e');
    }
  }

  Future<Either<String, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (results.isEmpty) {
        return const Left('Email atau kata sandi salah');
      }

      final user = UserModel.fromMap(results.first);
      if (!PasswordHasher.verify(password, user.password)) {
        return const Left('Email atau kata sandi salah');
      }

      // Auto-upgrade legacy plain-text password to salted SHA-256 hash
      if (!PasswordHasher.isHashed(user.password) && user.id != null) {
        final upgraded = user.copyWith(
          password: PasswordHasher.hash(password),
          updatedAt: DateTime.now(),
        );
        await db.update(
          'users',
          upgraded.toMap(),
          where: 'id = ?',
          whereArgs: [user.id],
        );
        return Right(upgraded);
      }

      return Right(user);
    } catch (e) {
      return Left('Gagal masuk: $e');
    }
  }

  Future<Either<String, UserModel>> getUserById(int id) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query('users', where: 'id = ?', whereArgs: [id]);
      if (results.isEmpty) return const Left('User tidak ditemukan');
      return Right(UserModel.fromMap(results.first));
    } catch (e) {
      return Left('Error: $e');
    }
  }

  Future<Either<String, bool>> updateUser(UserModel user) async {
    try {
      final db = await _dbHelper.database;
      // Check if email is already taken by another user
      if (user.id != null) {
        final existingEmail = await db.query(
          'users',
          where: 'email = ? AND id != ?',
          whereArgs: [user.email, user.id],
        );
        if (existingEmail.isNotEmpty) {
          return const Left('Email sudah digunakan oleh akun lain');
        }
      }

      final securedUser = user.copyWith(
        password: PasswordHasher.hash(user.password),
        updatedAt: DateTime.now(),
      );
      await db.update(
        'users',
        securedUser.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
      return const Right(true);
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        return const Left('Email sudah digunakan oleh akun lain');
      }
      return Left('Gagal update: $e');
    }
  }
}
