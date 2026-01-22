import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_extensions.dart';
import '../../providers/movie_provider.dart';
import '../../widgets/error_screen.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/home_movie_cards.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Use Enum for cleaner logic
  ContentFilter _selectedFilter = ContentFilter.movies;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _loadDataForFilter(ContentFilter.movies);
    });
  }

  void _loadDataForFilter(ContentFilter filter) {
    switch (filter) {
      case ContentFilter.movies:
        ref.read(trendingMoviesProvider.notifier).loadTrendingMovies();
        ref.read(popularMoviesProvider.notifier).loadPopularMovies();
        ref.read(topRatedMoviesProvider.notifier).loadTopRatedMovies();
        break;
      case ContentFilter.tvShows:
        ref.read(trendingTVProvider.notifier).loadTrendingTVShows();
        ref.read(popularTVProvider.notifier).loadPopularTVShows();
        break;
      case ContentFilter.anime:
        ref.read(trendingTVProvider.notifier).loadTrendingTVShows(); // Reusing trending TV for now
        ref.read(animeProvider.notifier).loadAnime();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine Providers based on filter
    final trendingState = _selectedFilter == ContentFilter.movies 
        ? ref.watch(trendingMoviesProvider)
        : ref.watch(trendingTVProvider);
    
    final popularState = _selectedFilter == ContentFilter.movies 
        ? ref.watch(popularMoviesProvider)
        : _selectedFilter == ContentFilter.tvShows
            ? ref.watch(popularTVProvider)
            : ref.watch(animeProvider);
    
    final topRatedState = ref.watch(topRatedMoviesProvider);
    
    // For You / Grid Content
    final gridState = _selectedFilter == ContentFilter.movies 
        ? topRatedState 
        : popularState;

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(), // UX Detail: Bouncing scroll feels better
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildFilterChips()),
            
            // Trending
            SliverToBoxAdapter(
              child: _buildSectionTitle(AppConstants.trendingTitle, onSeeAll: () {
                HapticFeedback.lightImpact();
                final category = _selectedFilter == ContentFilter.movies 
                    ? AppConstants.catTrendingMovie 
                    : AppConstants.catTrendingTV;
                _navigateToSeeAll(AppConstants.trendingTitle, category);
              }),
            ),
            SliverToBoxAdapter(child: _buildTrendingCarousel(trendingState)),
            
            // Popular
            SliverToBoxAdapter(
              child: _buildSectionTitle(
                _getPopularTitle(), 
                onSeeAll: () {
                  HapticFeedback.lightImpact();
                  _navigateToSeeAll(_getPopularTitle(), _getPopularCategory());
                }
              ),
            ),
            SliverToBoxAdapter(child: _buildHorizontalList(popularState)),
            
            // Top Rated (Only for Movies)
            if (_selectedFilter == ContentFilter.movies) ...[
              SliverToBoxAdapter(
                child: _buildSectionTitle(AppConstants.topRatedMoviesTitle, onSeeAll: () {
                  HapticFeedback.lightImpact();
                  _navigateToSeeAll(AppConstants.topRatedMoviesTitle, AppConstants.catTopRatedMovie);
                }),
              ),
              SliverToBoxAdapter(child: _buildHorizontalList(topRatedState, showRating: true)),
            ],
            
            // For You / Grid
            SliverToBoxAdapter(
              child: _buildSectionTitle(
                 _getForYouTitle(),
                 onSeeAll: () {
                    HapticFeedback.lightImpact();
                    // Just reuse popular/top rated for the "See all" of grid for now
                    final category = _selectedFilter == ContentFilter.movies 
                        ? AppConstants.catTopRatedMovie 
                        : (_selectedFilter == ContentFilter.tvShows ? AppConstants.catPopularTV : AppConstants.catAnime);
                    _navigateToSeeAll(_getForYouTitle(), category);
                 }
              ),
            ),
            _buildForYouGrid(gridState),
            
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  void _navigateToSeeAll(String title, String category) {
    context.push(Uri(path: AppConstants.routeList, queryParameters: {
      'title': title,
      'category': category
    }).toString());
  }

  String _getPopularTitle() {
    switch (_selectedFilter) {
      case ContentFilter.movies: return AppConstants.popularMoviesTitle;
      case ContentFilter.tvShows: return AppConstants.popularTVTitle;
      case ContentFilter.anime: return AppConstants.popularAnimeTitle;
    }
  }

  String _getPopularCategory() {
    switch (_selectedFilter) {
      case ContentFilter.movies: return AppConstants.catPopularMovie;
      case ContentFilter.tvShows: return AppConstants.catPopularTV;
      case ContentFilter.anime: return AppConstants.catAnime;
    }
  }

  String _getForYouTitle() {
     switch (_selectedFilter) {
      case ContentFilter.movies: return AppConstants.forYouTitle;
      case ContentFilter.tvShows: return AppConstants.topTVTitle;
      case ContentFilter.anime: return AppConstants.topAnimeTitle;
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.movie_filter, color: AppTheme.primary, size: 32),
              const SizedBox(width: 8),
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.push(AppConstants.routeProfile);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: const ClipOval(
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
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ContentFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final filter = ContentFilter.values[index];
          final isSelected = _selectedFilter == filter;
          return FilterChip(
            label: Text(filter.label),
            selected: isSelected,
            showCheckmark: false,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onSelected: (selected) {
              if (!isSelected) { // Prevent reload if already selected
                HapticFeedback.selectionClick(); // UX Detail
                setState(() => _selectedFilter = filter);
                _loadDataForFilter(filter);
              }
            },
            backgroundColor: AppTheme.surfaceContainer,
            selectedColor: AppTheme.primary,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            side: BorderSide.none,
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
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(AppConstants.seeAll),
            ),
        ],
      ),
    );
  }

  Widget _buildTrendingCarousel(MovieState state) {
    if (state is MovieLoading) {
      return SizedBox(
        height: 320,
        child: PageView.builder(
           controller: PageController(viewportFraction: 0.85),
           itemCount: 3,
           itemBuilder: (context, index) {
             return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: ShimmerLoading(width: double.infinity, height: double.infinity, borderRadius: BorderRadius.all(Radius.circular(16))),
             );
           }
        ),
      );
    }
    
    if (state is MovieError) {
      // Simplification: Reusing logic from original code but cleaned up
      return SizedBox(
        height: 280,
        child: isNetworkError(state.message) 
          ? ErrorScreen.noInternet(onRetry: () => _loadDataForFilter(_selectedFilter), isFullScreen: false)
          : ErrorScreen.generalError(message: state.message, onRetry: () => _loadDataForFilter(_selectedFilter), isFullScreen: false),
      );
    }
    
    if (state is MovieLoaded) {
      return SizedBox(
        height: 320,
        child: LayoutBuilder(
          builder: (context, constraints) {
            double viewportFraction = context.isDesktop ? 0.25 : (context.isTablet ? 0.45 : 0.85);
            return PageView.builder(
              controller: PageController(viewportFraction: viewportFraction),
              itemCount: state.movies.take(10).length,
              padEnds: false,
              itemBuilder: (context, index) {
                return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    child: TrendingCard(movie: state.movies[index]),
                );
              },
            );
          }
        ),
      );
    }
    return const SizedBox(height: 280);
  }

  Widget _buildHorizontalList(MovieState state, {bool showRating = false}) {
    if (state is MovieLoading) {
      return SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 5,
          itemBuilder: (context, index) => const MovieCardShimmer(),
        ),
      );
    }
    
    if (state is MovieError) {
       return SizedBox(
        height: 180,
        child: isNetworkError(state.message) 
          ? ErrorScreen.noInternet(onRetry: () => _loadDataForFilter(_selectedFilter), isFullScreen: false)
          : ErrorScreen.generalError(message: state.message, onRetry: () => _loadDataForFilter(_selectedFilter), isFullScreen: false),
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
            return CompactMovieCard(movie: state.movies[index], showRating: showRating);
          },
        ),
      );
    }
    return const SizedBox(height: 180);
  }

  Widget _buildForYouGrid(MovieState state) {
    if (state is MovieLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: MovieGridShimmer(),
        ),
      );
    }
    
    if (state is MovieLoaded) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverLayoutBuilder(
          builder: (context, constraints) {
            return SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: context.gridColumns,
                childAspectRatio: context.gridAspectRatio,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= state.movies.length) return null;
                  return GridMovieCard(movie: state.movies[index]);
                },
                childCount: state.movies.take(context.gridColumns * 2).length,
              ),
            );
          },
        ),
      );
    }
    
    // Empty placeholder if needed
    return const SliverToBoxAdapter(child: SizedBox());
  }
}
