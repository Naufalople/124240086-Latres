import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import '../services/session_service.dart';
import '../utils/app_theme.dart';
import 'auth/login_screen.dart';
import 'episode/episode_screen.dart';
import 'favorite/favorite_screen.dart';
import 'home/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String _username = '';
  String _fullName = '';

  final List<Widget> _screens = const [
    HomeScreen(),
    FavoriteScreen(),
    EpisodeScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    FavoriteService.instance.init();
  }

  Future<void> _loadUserInfo() async {
    final user = await SessionService.getUsername();
    final name = await SessionService.getFullName();
    if (mounted) {
      setState(() {
        _username = user ?? '';
        _fullName = name ?? '';
      });
    }
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Rick & Morty';
      case 1:
        return 'Favorites';
      case 2:
        return 'Episodes View';
      default:
        return 'Rick & Morty Explorer';
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppTheme.statusDead),
            SizedBox(width: 10),
            Text(
              'Konfirmasi Keluar',
              style: TextStyle(color: AppTheme.textLight, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Halo ${_fullName.isNotEmpty ? _fullName : _username}, apakah Anda yakin ingin keluar dari aplikasi?',
          style: const TextStyle(color: AppTheme.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusDead,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () async {
              final nav = Navigator.of(this.context);
              Navigator.pop(context); // close dialog
              await SessionService.logout();

              nav.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getTitle(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            if (_username.isNotEmpty)
              Text(
                'Halo, ${_fullName.isNotEmpty ? _fullName : _username}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.portalGreen,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.statusDead),
            tooltip: 'Logout',
            onPressed: _showLogoutDialog,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.groups_rounded),
            activeIcon: Icon(Icons.groups_rounded, color: AppTheme.portalGreen),
            label: 'Characters',
          ),
          BottomNavigationBarItem(
            icon: ListenableBuilder(
              listenable: FavoriteService.instance,
              builder: (context, _) {
                final count = FavoriteService.instance.favorites.length;
                return Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  backgroundColor: AppTheme.statusDead,
                  child: const Icon(Icons.favorite_rounded),
                );
              },
            ),
            activeIcon: ListenableBuilder(
              listenable: FavoriteService.instance,
              builder: (context, _) {
                final count = FavoriteService.instance.favorites.length;
                return Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  backgroundColor: AppTheme.statusDead,
                  child: const Icon(Icons.favorite_rounded, color: AppTheme.portalGreen),
                );
              },
            ),
            label: 'Favorites',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.movie_filter_outlined),
            activeIcon: Icon(Icons.movie_filter_rounded, color: AppTheme.portalGreen),
            label: 'Episodes',
          ),
        ],
      ),
    );
  }
}
