import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/search_provider.dart';
import '../../widgets/media_card.dart';
import '../../models/movie.dart';
import '../../models/tv_show.dart';
import '../movies/movie_detail_screen.dart';
import '../tv_shows/tv_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      context.read<SearchProvider>().searchMulti(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SearchBar(
            controller: _searchController,
            hintText: 'Search movies, TV shows, anime...',
            leading: const Icon(Icons.search),
            trailing: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<SearchProvider>().clearSearch();
                  },
                ),
            ],
            onSubmitted: _performSearch,
            onChanged: (value) {
              setState(() {}); // Update UI to show/hide clear button
              if (value.isEmpty) {
                context.read<SearchProvider>().clearSearch();
              }
            },
          ),
        ),
        // Search results
        Expanded(
          child: Consumer<SearchProvider>(
            builder: (context, searchProvider, child) {
              // Loading state
              if (searchProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Error state
              if (searchProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Oops! Something went wrong',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        searchProvider.error!,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              // Empty state (no search performed yet)
              if (!searchProvider.hasResults &&
                  searchProvider.searchQuery.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Search for movies, TV shows, and anime',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              // No results found
              if (!searchProvider.hasResults) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.movie_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No results found',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try searching with different keywords',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              }

              // Results found
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Results summary
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Found ${searchProvider.totalResults} results',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Movies section
                    if (searchProvider.movieResults.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Movies (${searchProvider.movieResults.length})',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildResultsGrid(searchProvider.movieResults, true),
                      const SizedBox(height: 24),
                    ],
                    // TV Shows section
                    if (searchProvider.tvShowResults.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'TV Shows (${searchProvider.tvShowResults.length})',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildResultsGrid(searchProvider.tvShowResults, false),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultsGrid(List<dynamic> items, bool isMovie) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return MediaCard(
          item: item,
          onTap: () {
            if (isMovie) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailScreen(movie: item as Movie),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TVDetailScreen(tvShow: item as TVShow),
                ),
              );
            }
          },
        );
      },
    );
  }
}
