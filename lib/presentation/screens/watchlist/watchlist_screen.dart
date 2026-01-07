import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/movie.dart';
import '../../providers/movie_provider.dart';

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen> {
  Movie? _lastRemovedMovie;
  int? _lastRemovedIndex;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(watchlistProvider.notifier).loadWatchlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    final watchlistState = ref.watch(watchlistProvider);

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Watchlist',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: watchlistState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (error, stack) => Center(
          child: Text('Error: $error', style: TextStyle(color: AppTheme.textSecondary)),
        ),
        data: (movies) {
          if (movies.isEmpty) return _buildEmptyState();
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return _buildWatchlistItem(movie, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 64, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Your watchlist is empty',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding movies you want to watch',
            style: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistItem(Movie movie, int index) {
    return Dismissible(
      key: Key('${movie.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        _lastRemovedMovie = movie;
        _lastRemovedIndex = index; // Note: Index might vary if list changes, but ok for simple undo
        ref.read(watchlistProvider.notifier).removeFromWatchlist(movie.id);
        
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${movie.title} removed'),
            action: SnackBarAction(
              label: 'Undo',
              textColor: AppTheme.primary,
              onPressed: () {
                if (_lastRemovedMovie != null) {
                  ref.read(watchlistProvider.notifier).addToWatchlist(_lastRemovedMovie!);
                }
              },
            ),
            backgroundColor: AppTheme.surfaceContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => context.push('/movie/${movie.id}'),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Poster
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: 'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                  width: 60,
                  height: 90,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 60,
                    height: 90,
                    color: AppTheme.surfaceDark,
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 60,
                    height: 90,
                    color: AppTheme.surfaceDark,
                    child: const Icon(Icons.movie),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${movie.releaseDate.split('-').first} • ${movie.genres.isNotEmpty ? movie.genres.first : 'Movie'}',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          movie.voteAverage.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Favorite Icon
              Icon(Icons.favorite, color: AppTheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
