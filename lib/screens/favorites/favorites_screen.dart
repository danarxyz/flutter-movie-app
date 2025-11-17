import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/media_card.dart';
import '../../models/movie.dart';
import '../../models/tv_show.dart';
import '../movies/movie_detail_screen.dart';
import '../tv_shows/tv_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Load favorites when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favProvider, child) {
        // Loading state
        if (favProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Empty state
        if (favProvider.favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No favorites yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add movies and TV shows to your favorites',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Favorites list
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary and clear button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${favProvider.favoritesCount} favorites',
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(color: Colors.grey[600]),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      _showClearDialog(context, favProvider);
                    },
                    tooltip: 'Clear all favorites',
                  ),
                ],
              ),
            ),
            // Grid of favorites
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: favProvider.favorites.length,
                itemBuilder: (context, index) {
                  final item = favProvider.favorites[index];
                  return MediaCard(
                    item: item,
                    onTap: () {
                      if (item is Movie) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MovieDetailScreen(movieId: item.id),
                          ),
                        );
                      } else if (item is TVShow) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TVDetailScreen(tvShowId: item.id),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showClearDialog(BuildContext context, FavoritesProvider favProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all favorites?'),
        content: const Text(
          'This will remove all items from your favorites. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              favProvider.clearFavorites();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All favorites cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
