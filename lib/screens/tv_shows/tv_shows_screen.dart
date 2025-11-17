import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tv_provider.dart';
import '../../widgets/media_list.dart';
import 'tv_detail_screen.dart';

class TVShowsScreen extends StatefulWidget {
  final TabController tabController;

  const TVShowsScreen({super.key, required this.tabController});

  @override
  State<TVShowsScreen> createState() => _TVShowsScreenState();
}

class _TVShowsScreenState extends State<TVShowsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TvProvider>().fetchAllTVShows();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: widget.tabController,
      children: [
        // Popular TV Shows
        Consumer<TvProvider>(
          builder: (context, tvProvider, child) {
            return MediaList(
              items: tvProvider.popularTVShows,
              isLoading: tvProvider.isLoadingPopular,
              errorMessage: tvProvider.popularError,
              onItemTap: (item) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TVDetailScreen(tvShowId: item.id),
                  ),
                );
              },
              onRetry: () => tvProvider.fetchPopularTVShows(),
            );
          },
        ),
        // Top Rated TV Shows
        Consumer<TvProvider>(
          builder: (context, tvProvider, child) {
            return MediaList(
              items: tvProvider.topRatedTVShows,
              isLoading: tvProvider.isLoadingTopRated,
              errorMessage: tvProvider.topRatedError,
              onItemTap: (item) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TVDetailScreen(tvShowId: item.id),
                  ),
                );
              },
              onRetry: () => tvProvider.fetchTopRatedTVShows(),
            );
          },
        ),
        // Trending TV Shows
        Consumer<TvProvider>(
          builder: (context, tvProvider, child) {
            return MediaList(
              items: tvProvider.trendingTVShows,
              isLoading: tvProvider.isLoadingTrending,
              errorMessage: tvProvider.trendingError,
              onItemTap: (item) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TVDetailScreen(tvShowId: item.id),
                  ),
                );
              },
              onRetry: () => tvProvider.fetchTrendingTVShows(),
            );
          },
        ),
        // Anime Shows
        Consumer<TvProvider>(
          builder: (context, tvProvider, child) {
            return MediaList(
              items: tvProvider.animeShows,
              isLoading: tvProvider.isLoadingAnime,
              errorMessage: tvProvider.animeError,
              onItemTap: (item) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TVDetailScreen(tvShowId: item.id),
                  ),
                );
              },
              onRetry: () => tvProvider.fetchAnimeShows(),
            );
          },
        ),
      ],
    );
  }
}
