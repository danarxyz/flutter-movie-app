import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_utils.dart'; // Import utility
import '../../../domain/entities/movie.dart';
import '../../providers/movie_provider.dart';
import '../../widgets/error_screen.dart';

import 'package:equatable/equatable.dart';

// Movie Detail Provider - calls actual API
class MovieDetailParams extends Equatable {
  final int id;
  final String type;
  const MovieDetailParams(this.id, this.type);
  @override
  List<Object> get props => [id, type];
}

final movieDetailProvider = FutureProvider.family<Movie?, MovieDetailParams>((ref, params) async {
  final repository = ref.watch(movieRepositoryProvider);
  try {
    return await repository.getContentDetail(params.id, type: params.type);
  } catch (e) {
    return null;
  }
});

class MovieDetailScreen extends ConsumerStatefulWidget {
  final int movieId;
  final String mediaType;
  
  const MovieDetailScreen({
    super.key, 
    required this.movieId,
    this.mediaType = 'movie', // Default to movie
  });

  @override
  ConsumerState<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends ConsumerState<MovieDetailScreen> {

  @override
  Widget build(BuildContext context) {
    final movieAsync = ref.watch(movieDetailProvider(
      MovieDetailParams(widget.movieId, widget.mediaType),
    ));

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      body: movieAsync.when(
        data: (movie) {
          if (movie == null) {
            return ErrorScreen.generalError(
              message: 'Movie not found',
              onRetry: () => ref.invalidate(movieDetailProvider(
                MovieDetailParams(widget.movieId, widget.mediaType),
              )),
            );
          }
          return _buildContent(context, ref, movie);
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (error, stack) {
          if (isNetworkError(error)) {
            return ErrorScreen.noInternet(
              onRetry: () => ref.invalidate(movieDetailProvider(
                MovieDetailParams(widget.movieId, widget.mediaType),
              )),
            );
          }
          return ErrorScreen.generalError(
            message: error.toString(),
            onRetry: () => ref.invalidate(movieDetailProvider(
              MovieDetailParams(widget.movieId, widget.mediaType),
            )),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Movie movie) {
    return CustomScrollView(
      slivers: [
        // Backdrop with Gradient
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: AppTheme.surfaceDark,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.share, color: Colors.white),
              ),
              onPressed: () {},
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: 'https://image.tmdb.org/t/p/w780${movie.backdropPath.isNotEmpty ? movie.backdropPath : movie.posterPath}',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: AppTheme.surfaceContainer),
                  errorWidget: (context, url, error) => Container(color: AppTheme.surfaceContainer),
                ),
                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppTheme.surfaceDark.withValues(alpha: 0.5),
                        AppTheme.surfaceDark,
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Year
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Poster
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: 'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                        width: 100,
                        height: 150,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 100,
                          height: 150,
                          color: AppTheme.surfaceContainer,
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 100,
                          height: 150,
                          color: AppTheme.surfaceContainer,
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
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${movie.releaseDate.split('-').first} • 2h 30m',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Rating
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                movie.voteAverage.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '/10',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Genres
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: movie.genres.take(3).map((genre) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  genre,
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, child) {
                          final watchlistState = ref.watch(watchlistProvider);
                          final isInWatchlist = watchlistState.maybeWhen(
                            data: (movies) => movies.any((m) => m.id == movie.id),
                            orElse: () => false,
                          );

                          return ElevatedButton.icon(
                            onPressed: () {
                              if (isInWatchlist) {
                                ref.read(watchlistActionsProvider.notifier).removeFromWatchlist(movie.id);
                                SnackBarUtils.showInfo(context, 'Removed from watchlist');
                              } else {
                                ref.read(watchlistActionsProvider.notifier).addToWatchlist(movie);
                                SnackBarUtils.showWithAction(
                                  context,
                                  'Added to watchlist',
                                  actionLabel: 'VIEW',
                                  onPressed: () => context.go('/?tab=2'),
                                );
                              }
                            },
                            icon: Icon(isInWatchlist ? Icons.bookmark_remove : Icons.bookmark_add),
                            label: Text(isInWatchlist ? 'Remove from Watchlist' : 'Add to Watchlist'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isInWatchlist ? AppTheme.surfaceContainer : AppTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.star_border, color: Colors.white),
                        tooltip: 'Rate',
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Overview
                const Text(
                  'Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  movie.overview.isNotEmpty ? movie.overview : 'No overview available.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Cast Section
                if (movie.cast.isNotEmpty) ...[
                  const Text(
                    'Top Cast',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 130,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: movie.cast.length,
                      itemBuilder: (context, index) {
                        final actor = movie.cast[index];
                        return Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.surfaceContainer,
                                  image: actor.profilePath != null 
                                    ? DecorationImage(
                                        image: CachedNetworkImageProvider('https://image.tmdb.org/t/p/w200${actor.profilePath}'),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                ),
                                child: actor.profilePath == null 
                                  ? Icon(Icons.person, color: AppTheme.textSecondary) 
                                  : null,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                actor.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                actor.character,
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Movie Info
                if (movie.director != null) _buildInfoRow('Director', movie.director!),
                // Writers usually come from crew too, but simplifying to director for now 
                if (movie.runtime != null) _buildInfoRow('Runtime', '${movie.runtime} min'),
                _buildInfoRow('Release Date', movie.releaseDate),
                
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
