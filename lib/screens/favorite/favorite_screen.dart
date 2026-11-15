import 'package:flutter/material.dart';
import '../../services/favorite_service.dart';
import '../../utils/app_theme.dart';
import '../home/character_detail_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: FavoriteService.instance,
        builder: (context, _) {
          final favorites = FavoriteService.instance.favorites;

          if (favorites.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppTheme.cardDark,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.cardDarkLight, width: 2),
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        size: 48,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Daftar Favorit Masih Kosong',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Anda belum menambahkan karakter ke daftar favorit. Buka menu Characters dan ketuk ikon hati untuk menyimpannya di sini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hint Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppTheme.cardDarkLight.withValues(alpha: 0.4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.swipe_left_rounded,
                      size: 20,
                      color: AppTheme.rickCyan,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Geser (swipe) item untuk menghapus dari favorit',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLight.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.portalGreen.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${favorites.length} Karakter',
                        style: const TextStyle(
                          color: AppTheme.portalGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Favorites List with Dismissible
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final character = favorites[index];
                    final statusColor = AppTheme.getStatusColor(character.status);

                    return Dismissible(
                      key: Key('fav-${character.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: AppTheme.statusDead,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Hapus',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.delete_forever_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                      onDismissed: (direction) async {
                        final removedCharacter = character;
                        final removedIndex = index;

                        await FavoriteService.instance.removeFavorite(character.id);

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${character.name} berhasil dihapus dari favorit.'),
                            backgroundColor: AppTheme.statusDead,
                            action: SnackBarAction(
                              label: 'URUNGKAN',
                              textColor: Colors.white,
                              onPressed: () {
                                FavoriteService.instance.insertFavorite(
                                  removedIndex,
                                  removedCharacter,
                                );
                              },
                            ),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                      child: Card(
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
                                // Character Image
                                Container(
                                  width: 68,
                                  height: 68,
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
                                const SizedBox(width: 14),

                                // Character Info
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
                                      const SizedBox(height: 4),
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
                                            '${character.status} • ${character.species}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: AppTheme.textMuted,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
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

                                // Red favorite heart indicator
                                const Icon(
                                  Icons.favorite_rounded,
                                  color: AppTheme.statusDead,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
