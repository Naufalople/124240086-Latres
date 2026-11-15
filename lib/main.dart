import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/database_helper.dart';
import 'services/favorite_service.dart';
import 'services/session_service.dart';
import 'utils/app_theme.dart';

void main() async {
  // Memastikan binding widget terinisialisasi sebelum menjalankan operasi async
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive (Local Database sesuai Modul 6: Local Storage)
  await Hive.initFlutter();
  await DatabaseHelper.init();

  // Inisialisasi daftar favorit dari SharedPreferences (Sesuai Modul 6)
  await FavoriteService.instance.init();

  // Cek status sesi login dari SharedPreferences (Modul 6)
  final bool loggedIn = await SessionService.isLoggedIn();

  runApp(RickAndMortyApp(isLoggedIn: loggedIn));
}

class RickAndMortyApp extends StatelessWidget {
  final bool isLoggedIn;

  const RickAndMortyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rick & Morty Explorer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: isLoggedIn ? const MainScreen() : const LoginScreen(),
    );
  }
}
