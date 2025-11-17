import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/movie_provider.dart';
import '../../models/movie.dart';
import '../../widgets/rating_widget.dart';
import '../../widgets/favorite_button.dart';
import '../../widgets/backdrop_widget.dart';
import '../../widgets/info_row_widget.dart';

class MovieDetailScreen extends StatefulWidget {
  final int? movieId;
  final Movie? movie;

  const MovieDetailScreen({super.key, this.movieId, this.movie})
    : assert(
        movieId != null || movie != null,
        'Either movieId or movie must be provided',
      );

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Movie? _selectedMovie;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedMovie = widget.movie;
    if (_selectedMovie == null && widget.movieId != null) {
      _loadMovie();
    }
  }

  Future<void> _loadMovie() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final movieProvider = context.read<MovieProvider>();
      final movie = await movieProvider.getMovieById(widget.movieId!);

      if (mounted) {
        setState(() {
          _selectedMovie = movie;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load movie details';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadMovie,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_selectedMovie == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Movie not found')),
      );
    }

    final selectedMovie = _selectedMovie!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            flexibleSpace: FlexibleSpaceBar(
              background: BackdropWidget(
                backdropPath: selectedMovie.backdropPath,
                placeholderIcon: Icons.movie,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedMovie.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (selectedMovie.originalTitle != selectedMovie.title) ...[
                    Text(
                      selectedMovie.originalTitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      RatingWidget(
                        rating: selectedMovie.voteAverage,
                        voteCount: selectedMovie.voteCount,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        selectedMovie.releaseYear,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FavoriteButton(mediaItem: selectedMovie),
                  const SizedBox(height: 24),
                  Text(
                    'Overview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedMovie.overview.isNotEmpty
                        ? selectedMovie.overview
                        : 'No overview available.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  InfoRowWidget(
                    label: 'Language',
                    value: selectedMovie.originalLanguage.toUpperCase(),
                  ),
                  InfoRowWidget(
                    label: 'Popularity',
                    value: selectedMovie.popularity.toStringAsFixed(1),
                  ),
                  if (selectedMovie.releaseDate != null &&
                      selectedMovie.releaseDate!.isNotEmpty) ...[
                    InfoRowWidget(
                      label: 'Release Date',
                      value: selectedMovie.releaseDate!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
