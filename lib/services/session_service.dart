import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk mengelola sesi login pengguna menggunakan SharedPreferences
/// sesuai dengan materi Modul 6 (Contoh program 6.4, 6.5, 6.12, 6.13, 6.18)
class SessionService {
  // Sesuai penamaan key pada Modul 6: 'loginData'
  static const String keyLoginData = 'loginData';
  static const String keyUsername = 'username';
  static const String keyFullName = 'nama';

  static Future<void> saveLoginSession({
    required String username,
    required String fullName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyLoginData, true);
    await prefs.setString(keyUsername, username);
    await prefs.setString(keyFullName, fullName);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyLoginData) ?? false;
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUsername);
  }

  static Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyFullName);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyLoginData, false);
    await prefs.remove(keyUsername);
    await prefs.remove(keyFullName);
  }
}
