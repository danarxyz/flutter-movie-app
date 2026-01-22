import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/movie.dart';
import '../../providers/movie_provider.dart';
import '../../widgets/responsive/responsive_layout.dart';

class ContentListScreen extends ConsumerStatefulWidget {
  final String title;
  final String category;

  const ContentListScreen({
    super.key,
    required this.title,
    required this.category,
  });

  @override
  ConsumerState<ContentListScreen> createState() => _ContentListScreenState();
}

class _ContentListScreenState extends ConsumerState<ContentListScreen> {
  @override
  void initState() {
    super.initState();
    // Ideally we might want to trigger a refresh or load more here
    // But since providers are global, data might already be there
  }

  MovieState _getProviderState() {
    switch (widget.category) {
      case 'trending_movie':
        return ref.watch(trendingMoviesProvider);
      case 'popular_movie':
        return ref.watch(popularMoviesProvider);
      case 'top_rated_movie':
        return ref.watch(topRatedMoviesProvider);
      case 'trending_tv':
        return ref.watch(trendingTVProvider);
      case 'popular_tv':
        return ref.watch(popularTVProvider);
      case 'anime':
        return ref.watch(animeProvider);
      default:
        return MovieInitial();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _getProviderState();

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(MovieState state) {
    if (state is MovieLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    if (state is MovieError) {
      return Center(child: Text(state.message, style: TextStyle(color: AppTheme.textSecondary)));
    }

    if (state is MovieLoaded) {
      return ResponsiveLayout(
        mobileBody: _buildGrid(state.movies, 2),  // 2 columns on mobile
        tabletBody: _buildGrid(state.movies, 4),  // 4 columns on tablet
        desktopBody: _buildGrid(state.movies, 6), // 6 columns on desktop
      );
    }

    return const Center(child: Text('No content available', style: TextStyle(color: Colors.white)));
  }

  Widget _buildGrid(List<Movie> movies, int crossAxisCount) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return GestureDetector(
          onTap: () => context.push('/movie/${movie.id}?type=${movie.mediaType}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: 'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Container(color: AppTheme.surfaceContainer),
                    errorWidget: (context, url, err) => Container(
                      color: AppTheme.surfaceContainer,
                      child: const Icon(Icons.movie),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                movie.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    movie.voteAverage.toStringAsFixed(1),
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
