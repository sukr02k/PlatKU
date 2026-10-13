import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class PasswordHasher {
  PasswordHasher._();

  static const String _prefix = 'sha256\$';

  static bool isHashed(String value) => value.startsWith(_prefix);

  /// Hashes a plain-text password using salted SHA-256 (`sha256$<salt>$<digest>`).
  /// If [password] is already hashed, returns it unchanged.
  static String hash(String password, {String? customSalt}) {
    if (isHashed(password)) return password;
    final salt = customSalt ?? _generateSalt(16);
    final digest = _computeDigest(salt, password);
    return '$_prefix$salt\$$digest';
  }

  /// Verifies [plainPassword] against [storedPassword].
  /// Supports both salted `sha256$<salt>$<digest>` hashes and legacy plain text.
  static bool verify(String plainPassword, String storedPassword) {
    if (isHashed(storedPassword)) {
      final parts = storedPassword.split('\$');
      if (parts.length != 3) return false;
      final salt = parts[1];
      final expectedDigest = parts[2];
      final actualDigest = _computeDigest(salt, plainPassword);
      return _constantTimeEquals(actualDigest, expectedDigest);
    }
    return plainPassword == storedPassword;
  }

  static String _computeDigest(String salt, String password) {
    final bytes = utf8.encode('motovault_v1:$salt:$password');
    return sha256.convert(bytes).toString();
  }

  static String _generateSalt(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
