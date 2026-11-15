import 'package:flutter/material.dart';
import '../../models/character.dart';
import '../../services/favorite_service.dart';
import '../../utils/app_theme.dart';

class CharacterDetailScreen extends StatelessWidget {
  final Character character;

  const CharacterDetailScreen({
    super.key,
    required this.character,
  });

  void _handleToggleFavorite(BuildContext context) async {
    final added = await FavoriteService.instance.toggleFavorite(character);
    if (!context.mounted) return;

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
    final statusColor = AppTheme.getStatusColor(character.status);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          character.name,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Favorite button in AppBar (ListenableBuilder for instant reactive icon update)
          ListenableBuilder(
            listenable: FavoriteService.instance,
            builder: (context, _) {
              final isFav = FavoriteService.instance.isFavorite(character.id);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFav ? AppTheme.statusDead : AppTheme.textLight,
                  size: 28,
                ),
                tooltip: isFav ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                onPressed: () => _handleToggleFavorite(context),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Image with Glow & Status Badge
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.cardDark,
                    AppTheme.spaceDark,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    // Character Avatar
                    Hero(
                      tag: 'character-avatar-${character.id}',
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: statusColor,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withValues(alpha: 0.35),
                              blurRadius: 28,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            character.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppTheme.cardDarkLight,
                              child: const Icon(
                                Icons.person,
                                size: 80,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: AppTheme.cardDarkLight,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppTheme.portalGreen,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Character Name
                    Text(
                      character.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textLight,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Status pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            character.status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Karakter',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.portalGreen,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Detail Cards
                  _buildInfoTile(
                    icon: Icons.category_rounded,
                    label: 'Spesies',
                    value: character.species,
                    accentColor: AppTheme.rickCyan,
                  ),
                  const SizedBox(height: 12),

                  _buildInfoTile(
                    icon: Icons.transgender_rounded,
                    label: 'Gender',
                    value: character.gender,
                    accentColor: Colors.amberAccent,
                  ),
                  const SizedBox(height: 12),

                  _buildInfoTile(
                    icon: Icons.public_rounded,
                    label: 'Origin (Asal)',
                    value: character.originName,
                    accentColor: AppTheme.portalGreen,
                  ),
                  const SizedBox(height: 12),

                  _buildInfoTile(
                    icon: Icons.location_on_rounded,
                    label: 'Location (Lokasi Saat Ini)',
                    value: character.locationName,
                    accentColor: Colors.pinkAccent,
                  ),

                  if (character.type.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoTile(
                      icon: Icons.fingerprint_rounded,
                      label: 'Tipe / Sub-species',
                      value: character.type,
                      accentColor: Colors.purpleAccent,
                    ),
                  ],

                  if (character.episode.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoTile(
                      icon: Icons.movie_outlined,
                      label: 'Jumlah Kemunculan Episode',
                      value: '${character.episode.length} Episode',
                      accentColor: Colors.orangeAccent,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Big Favorite Action Button
                  ListenableBuilder(
                    listenable: FavoriteService.instance,
                    builder: (context, _) {
                      final isFav = FavoriteService.instance.isFavorite(character.id);
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFav ? AppTheme.statusDead : AppTheme.portalGreen,
                            foregroundColor: isFav ? Colors.white : Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          ),
                          label: Text(
                            isFav ? 'HAPUS DARI FAVORIT' : 'TAMBAH KE FAVORIT',
                          ),
                          onPressed: () => _handleToggleFavorite(context),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.cardDarkLight,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'Unknown' : value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
