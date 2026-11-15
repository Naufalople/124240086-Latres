import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';

/// DatabaseHelper mengimplementasikan Local Database menggunakan Hive
/// sesuai dengan materi Modul 6: Local Storage (Shared Preferences & Hive).
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static const String boxName = 'users';

  DatabaseHelper._init();

  static Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  Box get _box => Hive.box(boxName);

  // Mendaftarkan user ke local database Hive
  Future<void> registerUser(User user) async {
    if (_box.containsKey(user.username)) {
      throw Exception('Username sudah digunakan! Silakan gunakan username lain.');
    }
    // Simpan data user ke Hive box berdasarkan key username
    await _box.put(user.username, user.toMap());
  }

  // Cek login username dan password dari local database Hive
  Future<User?> loginUser(String username, String password) async {
    final rawData = _box.get(username);
    if (rawData != null) {
      final map = Map<String, dynamic>.from(rawData as Map);
      if (map['password'] == password) {
        return User.fromMap(map);
      }
    }
    return null;
  }

  // Cek apakah username sudah terdaftar
  Future<bool> isUsernameExists(String username) async {
    return _box.containsKey(username);
  }
}
