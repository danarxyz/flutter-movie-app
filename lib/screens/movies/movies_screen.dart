import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/movie_provider.dart';
import '../../widgets/media_list.dart';
import 'movie_detail_screen.dart';

class MoviesScreen extends StatefulWidget {
  final TabController tabController;

  const MoviesScreen({super.key, required this.tabController});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MovieProvider>().fetchAllMovies();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: widget.tabController,
      children: [
        // Popular Movies
        Consumer<MovieProvider>(
          builder: (context, movieProvider, child) {
            return MediaList(
              items: movieProvider.popularMovies,
              isLoading: movieProvider.isLoadingPopular,
              errorMessage: movieProvider.popularError,
              onItemTap: (item) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetailScreen(movieId: item.id),
                  ),
                );
              },
              onRetry: () => movieProvider.fetchPopularMovies(),
            );
          },
        ),
        // Top Rated Movies
        Consumer<MovieProvider>(
          builder: (context, movieProvider, child) {
            return MediaList(
              items: movieProvider.topRatedMovies,
              isLoading: movieProvider.isLoadingTopRated,
              errorMessage: movieProvider.topRatedError,
              onItemTap: (item) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetailScreen(movieId: item.id),
                  ),
                );
              },
              onRetry: () => movieProvider.fetchTopRatedMovies(),
            );
          },
        ),
        // Trending Movies
        Consumer<MovieProvider>(
          builder: (context, movieProvider, child) {
            return MediaList(
              items: movieProvider.trendingMovies,
              isLoading: movieProvider.isLoadingTrending,
              errorMessage: movieProvider.trendingError,
              onItemTap: (item) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetailScreen(movieId: item.id),
                  ),
                );
              },
              onRetry: () => movieProvider.fetchTrendingMovies(),
            );
          },
        ),
      ],
    );
  }
}
