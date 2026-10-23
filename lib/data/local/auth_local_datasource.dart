import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDatasource {
  Future<void> saveSession({
    required int userId,
    required String userName,
    required String userEmail,
    String? userImagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setInt('user_id', userId);
    await prefs.setString('user_name', userName);
    await prefs.setString('user_email', userEmail);
    if (userImagePath != null && userImagePath.isNotEmpty) {
      await prefs.setString('user_image_path', userImagePath);
    } else {
      await prefs.remove('user_image_path');
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  Future<String?> getUserImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_image_path');
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_image_path');
  }

  Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_first_time') ?? true;
  }

  Future<void> setFirstTimeDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_time', false);
  }

  Future<DateTime?> getNotificationsLastSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt('notifications_last_seen');
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> markNotificationsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'notifications_last_seen',
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
