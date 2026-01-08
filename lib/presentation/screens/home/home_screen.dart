import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/screen_utils.dart';
import '../../../domain/entities/movie.dart';
import '../../providers/movie_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['Movies', 'TV Shows', 'Anime'];

  @override
  void initState() {
    super.initState();
    // Load initial data
    Future.microtask(() {
      _loadDataForFilter(0);
    });
  }

  void _loadDataForFilter(int index) {
    if (index == 0) {
      // Movies
      ref.read(trendingMoviesProvider.notifier).loadTrendingMovies();
      ref.read(popularMoviesProvider.notifier).loadPopularMovies();
      ref.read(topRatedMoviesProvider.notifier).loadTopRatedMovies();
    } else if (index == 1) {
      // TV Shows
      ref.read(trendingTVProvider.notifier).loadTrendingTVShows();
      ref.read(popularTVProvider.notifier).loadPopularTVShows();
      // For Top Rated we can reuse or add another provider, for now just reuse popular for grid
    } else if (index == 2) {
      // Anime
      ref.read(trendingTVProvider.notifier).loadTrendingTVShows();
      ref.read(animeProvider.notifier).loadAnime();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Trending: Switch based on filter
    final trendingState = (_selectedFilter == 1 || _selectedFilter == 2)
        ? ref.watch(trendingTVProvider)
        : ref.watch(trendingMoviesProvider);
    
    // Switch state based on filter
    final popularState = _selectedFilter == 1 
        ? ref.watch(popularTVProvider) 
        : _selectedFilter == 2 
            ? ref.watch(animeProvider)
            : ref.watch(popularMoviesProvider);
    
    final topRatedState = ref.watch(topRatedMoviesProvider); // Keep for movies
    
    // For "For You" grid, we use the selected category content
    final gridState = _selectedFilter == 0 ? topRatedState : popularState;

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header (App Bar)
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            
            // Filter Chips
            SliverToBoxAdapter(
              child: _buildFilterChips(),
            ),
            
            // Trending Now Section
            SliverToBoxAdapter(
              child: _buildSectionTitle('Trending Now', onSeeAll: () {
                String category = 'trending_movie';
                if (_selectedFilter == 1) category = 'trending_tv';
                if (_selectedFilter == 2) category = 'trending_tv'; // Reuse for anime if needed, or implement trending_anime
                
                context.push(Uri(path: '/list', queryParameters: {
                  'title': 'Trending Now',
                  'category': category
                }).toString());
              }),
            ),
            SliverToBoxAdapter(
              child: _buildTrendingCarousel(trendingState),
            ),
            
            // Popular Section (Dynamic Title)
            SliverToBoxAdapter(
              child: _buildSectionTitle(
                _selectedFilter == 1 ? 'Popular TV Shows' : _selectedFilter == 2 ? 'Popular Anime' : 'Popular Movies', 
                onSeeAll: () {
                  String category = 'popular_movie';
                  String title = 'Popular Movies';
                  
                  if (_selectedFilter == 1) {
                    category = 'popular_tv';
                    title = 'Popular TV Shows';
                  } else if (_selectedFilter == 2) {
                    category = 'anime';
                    title = 'Popular Anime';
                  }
                  
                  context.push(Uri(path: '/list', queryParameters: {
                    'title': title,
                    'category': category
                  }).toString());
                }
              ),
            ),
            SliverToBoxAdapter(
              child: _buildHorizontalList(popularState),
            ),
            
            // Top Rated Section (Show only for Movies filter or reuse popular for others for now)
            if (_selectedFilter == 0) ...[
              SliverToBoxAdapter(
                child: _buildSectionTitle('Top Rated', onSeeAll: () {
                  context.push(Uri(path: '/list', queryParameters: {
                    'title': 'Top Rated Movies',
                    'category': 'top_rated_movie'
                  }).toString());
                }),
              ),
              SliverToBoxAdapter(
                child: _buildHorizontalList(topRatedState, showRating: true),
              ),
            ],
            
            // For You Section (Grid)
            SliverToBoxAdapter(
              child: _buildSectionTitle(
                 _selectedFilter == 1 ? 'Top TV Series' : _selectedFilter == 2 ? 'Top Anime' : 'For You',
                 // For You currently reuses top rated or popular, so we can link there
                 onSeeAll: () {
                    String category = 'top_rated_movie';
                    if (_selectedFilter == 1) category = 'popular_tv';
                    if (_selectedFilter == 2) category = 'anime';
                    
                    context.push(Uri(path: '/list', queryParameters: {
                      'title': _selectedFilter == 0 ? 'For You' : (_selectedFilter == 1 ? 'Top TV Series' : 'Top Anime'),
                      'category': category
                    }).toString());
                 }
              ),
            ),
            _buildForYouGrid(gridState),
            
            // Bottom Padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Icon(Icons.movie_filter, color: AppTheme.primary, size: 32),
              const SizedBox(width: 8),
              const Text(
                'Watchly',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Profile Avatar
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: ClipOval(
                child: Icon(Icons.person, color: AppTheme.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedFilter == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(_filters[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = index);
                _loadDataForFilter(index);
              },
              backgroundColor: AppTheme.surfaceContainer,
              selectedColor: AppTheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text(
                'See all',
                style: TextStyle(color: AppTheme.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrendingCarousel(MovieState state) {
    if (state is MovieLoading) {
      return const SizedBox(
        height: 280,
        child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }
    
    if (state is MovieError) {
      return SizedBox(
        height: 280,
        child: Center(child: Text(state.message, style: TextStyle(color: AppTheme.textSecondary))),
      );
    }
    
    if (state is MovieLoaded) {
      return SizedBox(
        height: 320, // Increased slightly for better spacing
        child: LayoutBuilder( // Use LayoutBuilder to access constraints if needed, or ScreenUtils
          builder: (context, constraints) {
            double viewportFraction = 0.85;
            if (ScreenUtils.isDesktop(context)) {
              viewportFraction = 0.25; // Show ~4 items
            } else if (ScreenUtils.isTablet(context)) {
              viewportFraction = 0.45; // Show ~2 items
            }

            return PageView.builder(
              controller: PageController(viewportFraction: viewportFraction),
              itemCount: state.movies.take(10).length, // Show more trending on huge screens
              padEnds: false, // Start from left
              itemBuilder: (context, index) {
                final movie = state.movies[index];
                return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    child: _buildTrendingCard(movie),
                );
              },
            );
          }
        ),
      );
    }
    
    return const SizedBox(height: 280);
  }

  Widget _buildTrendingCard(Movie movie) {
    return GestureDetector(
      onTap: () => context.push('/movie/${movie.id}?type=${movie.mediaType}'),
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
              // Background Image
              CachedNetworkImage(
                imageUrl: 'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppTheme.surfaceContainer,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppTheme.surfaceContainer,
                  child: const Icon(Icons.movie, size: 50),
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
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          movie.voteAverage.toStringAsFixed(1),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalList(MovieState state, {bool showRating = false}) {
    if (state is MovieLoading) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }
    
    if (state is MovieError) {
      return SizedBox(
        height: 180,
        child: Center(child: Text(state.message, style: TextStyle(color: AppTheme.textSecondary))),
      );
    }
    
    if (state is MovieLoaded) {
      return SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: state.movies.take(10).length,
          itemBuilder: (context, index) {
            final movie = state.movies[index];
            return _buildCompactCard(movie, showRating: showRating);
          },
        ),
      );
    }
    
    return const SizedBox(height: 180);
  }

  Widget _buildCompactCard(Movie movie, {bool showRating = false}) {
    return GestureDetector(
      onTap: () => context.push('/movie/${movie.id}?type=${movie.mediaType}'),
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: 'https://image.tmdb.org/t/p/w300${movie.posterPath}',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: AppTheme.surfaceContainer,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppTheme.surfaceContainer,
                        child: const Icon(Icons.movie),
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 12),
                            const SizedBox(width: 2),
                            Text(
                              movie.voteAverage.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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

  SliverGrid _buildForYouGrid(MovieState state) {
    if (state is MovieLoaded) {
      return SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= state.movies.length) return null;
            final movie = state.movies[index];
            return _buildGridCard(movie);
          },
          childCount: state.movies.take(6).length,
        ),
      );
    }
    
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 0.65,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => const SizedBox(),
        childCount: 0,
      ),
    );
  }

  Widget _buildGridCard(Movie movie) {
    return GestureDetector(
      onTap: () => context.push('/movie/${movie.id}?type=${movie.mediaType}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: 'https://image.tmdb.org/t/p/w300${movie.posterPath}',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(color: AppTheme.surfaceContainer),
                  errorWidget: (context, url, error) => Container(
                    color: AppTheme.surfaceContainer,
                    child: const Icon(Icons.movie),
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
                  style: TextStyle(
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
