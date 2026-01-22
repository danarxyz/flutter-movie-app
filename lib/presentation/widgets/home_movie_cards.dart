import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services for HapticFeedback
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/movie.dart';
import 'shimmer_loading.dart';

/// Widget for the large Trending Carousel Item
class TrendingCard extends StatelessWidget {
  final Movie movie;

  const TrendingCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact(); // UX Detail: Haptic feedback
        context.push('/movie/${movie.id}?type=${movie.mediaType}');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image - OPTIMIZED
              Hero(
                tag: 'movie_poster_${movie.id}',
                child: CachedNetworkImage(
                  imageUrl: '${AppConstants.imageBaseUrl}${movie.posterPath}',
                  fit: BoxFit.cover,
                  // Optimization: Resize image in memory
                  memCacheWidth: 600, 
                  placeholder: (context, url) => Container(
                    color: AppTheme.surfaceContainer,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppTheme.surfaceContainer,
                    child: const Icon(Icons.movie, size: 50),
                  ),
                ),
              ),
              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
              // Content
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _RatingBadge(rating: movie.voteAverage),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget for Horizontal Lists
class CompactMovieCard extends StatelessWidget {
  final Movie movie;
  final bool showRating;

  const CompactMovieCard({
    super.key, 
    required this.movie, 
    this.showRating = false
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact(); // UX Detail: Haptic feedback
        context.push('/movie/${movie.id}?type=${movie.mediaType}');
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: 'movie_poster_compact_${movie.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: '${AppConstants.imageLowResUrl}${movie.posterPath}',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        memCacheWidth: 350,
                        placeholder: (context, url) => const ShimmerLoading(width: double.infinity, height: double.infinity),
                        errorWidget: (context, url, error) => Container(
                          color: AppTheme.surfaceContainer,
                          child: const Icon(Icons.movie),
                        ),
                      ),
                    ),
                  ),
                  if (showRating)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: _RatingBadge(rating: movie.voteAverage, fontSize: 10, iconSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              movie.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for Grid View
class GridMovieCard extends StatelessWidget {
  final Movie movie;

  const GridMovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick(); // UX Detail: Different haptic for grid
        context.push('/movie/${movie.id}?type=${movie.mediaType}');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: 'movie_poster_grid_${movie.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: '${AppConstants.imageLowResUrl}${movie.posterPath}',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    memCacheWidth: 350,
                    placeholder: (context, url) => const ShimmerLoading(width: double.infinity, height: double.infinity),
                    errorWidget: (context, url, error) => Container(
                      color: AppTheme.surfaceContainer,
                      child: const Icon(Icons.movie),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 12),
                const SizedBox(width: 4),
                Text(
                  movie.voteAverage.toStringAsFixed(1),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  final double fontSize;
  final double iconSize;

  const _RatingBadge({required this.rating, this.fontSize = 14, this.iconSize = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, color: Colors.amber, size: iconSize),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
