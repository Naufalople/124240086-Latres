import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/character.dart';
import '../../services/api_service.dart';
import '../../services/favorite_service.dart';
import '../../utils/app_theme.dart';
import 'character_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  String _selectedStatus = 'all'; // 'all', 'alive', 'dead', 'unknown'
  String _searchQuery = '';

  List<Character> _characters = [];
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _statusFilters = ['all', 'alive', 'dead', 'unknown'];

  @override
  void initState() {
    super.initState();
    _fetchCharacters();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _searchQuery = query.trim();
        });
        _fetchCharacters();
      }
    });
  }

  Future<void> _fetchCharacters() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await ApiService.getCharacters(
        status: _selectedStatus == 'all' ? null : _selectedStatus,
        name: _searchQuery.isEmpty ? null : _searchQuery,
      );

      if (!mounted) return;
      setState(() {
        _characters = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _toggleFavorite(Character character) async {
    final added = await FavoriteService.instance.toggleFavorite(character);
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? '${character.name} ditambahkan ke favorit!'
              : '${character.name} dihapus dari favorit!',
        ),
        backgroundColor: added ? AppTheme.portalGreenDark : AppTheme.statusDead,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search & Filter Header Section
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            color: AppTheme.spaceDark,
            child: Column(
              children: [
                // Search Bar (Bonus 1)
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Cari karakter Rick & Morty...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.portalGreen),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppTheme.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppTheme.cardDark,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Status Filter Chips (Alive, Dead, Unknown, All)
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _statusFilters.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final status = _statusFilters[index];
                      final isSelected = _selectedStatus == status;
                      final filterLabel = status == 'all'
                          ? 'Semua'
                          : status[0].toUpperCase() + status.substring(1);

                      Color activeColor = AppTheme.portalGreen;
                      if (status == 'alive') activeColor = AppTheme.statusAlive;
                      if (status == 'dead') activeColor = AppTheme.statusDead;
                      if (status == 'unknown') activeColor = AppTheme.statusUnknown;

                      return ChoiceChip(
                        label: Text(filterLabel),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedStatus = status;
                            });
                            _fetchCharacters();
                          }
                        },
                        selectedColor: activeColor.withValues(alpha: 0.25),
                        backgroundColor: AppTheme.cardDark,
                        labelStyle: TextStyle(
                          color: isSelected ? activeColor : AppTheme.textMuted,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                        side: BorderSide(
                          color: isSelected ? activeColor : AppTheme.cardDarkLight,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        showCheckmark: false,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Body: Content / Loading / Error / Empty
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.portalGreen),
            SizedBox(height: 16),
            Text(
              'Memuat karakter dari semesta Rick & Morty...',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 64,
                color: AppTheme.statusDead,
              ),
              const SizedBox(height: 16),
              const Text(
                'Gagal Mengambil Data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchCharacters,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.portalGreen,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_characters.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.search_off_rounded,
                size: 64,
                color: AppTheme.textMuted,
              ),
              const SizedBox(height: 16),
              const Text(
                'Tidak Ada Karakter Ditemukan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isNotEmpty
                    ? 'Tidak ada karakter dengan nama "$_searchQuery"'
                    : 'Tidak ada karakter pada status ini.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textMuted),
              ),
              if (_searchQuery.isNotEmpty || _selectedStatus != 'all') ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _selectedStatus = 'all';
                    });
                    _fetchCharacters();
                  },
                  icon: const Icon(Icons.restart_alt_rounded, color: AppTheme.rickCyan),
                  label: const Text(
                    'Reset Filter & Pencarian',
                    style: TextStyle(color: AppTheme.rickCyan),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.portalGreen,
      backgroundColor: AppTheme.cardDark,
      onRefresh: _fetchCharacters,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _characters.length,
        itemBuilder: (context, index) {
          final character = _characters[index];
          final statusColor = AppTheme.getStatusColor(character.status);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CharacterDetailScreen(character: character),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Character Avatar
                    Hero(
                      tag: 'character-avatar-${character.id}',
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            character.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppTheme.cardDarkLight,
                              child: const Icon(
                                Icons.person_rounded,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Character Name and Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            character.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),

                          // Status Badge
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${character.status} - ${character.species}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Location hint
                          Text(
                            '📍 ${character.locationName}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Favorite Button (ListenableBuilder ensures real-time sync with FavoriteScreen and DetailScreen)
                    ListenableBuilder(
                      listenable: FavoriteService.instance,
                      builder: (context, _) {
                        final isFav = FavoriteService.instance.isFavorite(character.id);
                        return IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav ? AppTheme.statusDead : AppTheme.textMuted,
                            size: 26,
                          ),
                          tooltip: isFav ? 'Hapus favorit' : 'Tambah favorit',
                          onPressed: () => _toggleFavorite(character),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
