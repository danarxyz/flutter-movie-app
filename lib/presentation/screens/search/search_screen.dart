import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/movie.dart';
import '../../providers/movie_provider.dart';
import '../../widgets/error_screen.dart';

// Search Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Movie>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  
  final repository = ref.watch(movieRepositoryProvider);
  return await repository.searchMovies(query);
});

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Movies', 'TV Shows', 'Action'];
  
  final List<String> _trendingSearches = [
    'Dune: Part Two',
    'Poor Things',
    'Civil War',
    'Godzilla x Kong',
    'Fallout',
  ];

  @override
  void initState() {
    super.initState();
    // Load recommendations on init
    Future.microtask(() {
      ref.read(topRatedMoviesProvider.notifier).loadTopRatedMovies();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topRatedState = ref.watch(topRatedMoviesProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          ref.read(searchQueryProvider.notifier).state = value;
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search movies, actors...',
                          hintStyle: TextStyle(color: AppTheme.textSecondary),
                          prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Voice Search
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.mic, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            
            // Filter Chips
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilter == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_filters[index]),
                      selected: isSelected,
                      showCheckmark: false, // Prevents size change
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onSelected: (selected) {
                        setState(() => _selectedFilter = index);
                      },
                      backgroundColor: AppTheme.surfaceContainer,
                      selectedColor: AppTheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide.none,
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Content
            Expanded(
              child: searchQuery.isEmpty
                  ? _buildDefaultContent(topRatedState)
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultContent(MovieState topRatedState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trending Searches
          const Text(
            'Trending Searches',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _trendingSearches.map((search) {
              return ActionChip(
                avatar: Icon(Icons.trending_up, size: 16, color: AppTheme.textSecondary),
                label: Text(search),
                onPressed: () {
                  _searchController.text = search;
                  ref.read(searchQueryProvider.notifier).state = search;
                },
                backgroundColor: AppTheme.surfaceContainer,
                labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide.none,
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // Recommended for you
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recommended for you',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('See all', style: TextStyle(color: AppTheme.primary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Movie Grid
          if (topRatedState is MovieLoaded)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: topRatedState.movies.take(6).length,
              itemBuilder: (context, index) {
                final movie = topRatedState.movies[index];
                return _buildMovieCard(movie);
              },
            )
          else if (topRatedState is MovieLoading)
            const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          else
            const SizedBox(),
            
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final searchResults = ref.watch(searchResultsProvider);
    
    return searchResults.when(
      data: (movies) {
        if (movies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: AppTheme.textSecondary),
                const SizedBox(height: 16),
                Text(
                  'No results found',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                ),
              ],
            ),
          );
        }
        
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 0.65,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: movies.length,
          itemBuilder: (context, index) => _buildMovieCard(movies[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      error: (error, stack) {
        if (isNetworkError(error)) {
          return ErrorScreen.noInternet(
            onRetry: () => ref.invalidate(searchResultsProvider),
          );
        }
        return ErrorScreen.generalError(
          message: error.toString(),
          onRetry: () => ref.invalidate(searchResultsProvider),
        );
      },
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () => context.push('/movie/${movie.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
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
                // Rating Badge
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
          Text(
            '${movie.releaseDate.split('-').first} • ${movie.genres.isNotEmpty ? movie.genres.first : 'Movie'}',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
