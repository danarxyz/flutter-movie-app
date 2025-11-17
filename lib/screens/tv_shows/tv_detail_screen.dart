import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tv_provider.dart';
import '../../models/tv_show.dart';
import '../../widgets/rating_widget.dart';
import '../../widgets/favorite_button.dart';
import '../../widgets/backdrop_widget.dart';
import '../../widgets/info_row_widget.dart';

class TVDetailScreen extends StatefulWidget {
  final int? tvShowId;
  final TVShow? tvShow;

  const TVDetailScreen({
    super.key,
    this.tvShowId,
    this.tvShow,
  }) : assert(tvShowId != null || tvShow != null,
            'Either tvShowId or tvShow must be provided');

  @override
  State<TVDetailScreen> createState() => _TVDetailScreenState();
}

class _TVDetailScreenState extends State<TVDetailScreen> {
  TVShow? _selectedTVShow;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedTVShow = widget.tvShow;
    if (_selectedTVShow == null && widget.tvShowId != null) {
      _loadTVShow();
    }
  }

  Future<void> _loadTVShow() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tvProvider = context.read<TvProvider>();
      final tvShow = await tvProvider.getTVShowById(widget.tvShowId!);

      if (mounted) {
        setState(() {
          _selectedTVShow = tvShow;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load TV show details';
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
                onPressed: _loadTVShow,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_selectedTVShow == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('TV show not found'),
        ),
      );
    }

    final tvShow = _selectedTVShow!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with backdrop image
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
                backdropPath: tvShow.backdropPath,
                placeholderIcon: Icons.tv,
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    tvShow.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  // Original name (if different)
                  if (tvShow.originalName != tvShow.name) ...[
                    Text(
                      tvShow.originalName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Rating and first air date
                  Row(
                    children: [
                      RatingWidget(
                        rating: tvShow.voteAverage,
                        voteCount: tvShow.voteCount,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        tvShow.releaseYear,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Favorite button
                  FavoriteButton(mediaItem: tvShow),
                  const SizedBox(height: 24),
                  // Overview section
                  Text(
                    'Overview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tvShow.overview.isNotEmpty
                        ? tvShow.overview
                        : 'No overview available.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  // Additional info
                  InfoRowWidget(
                    label: 'Language',
                    value: tvShow.originalLanguage.toUpperCase(),
                  ),
                  InfoRowWidget(
                    label: 'Popularity',
                    value: tvShow.popularity.toStringAsFixed(1),
                  ),
                  if (tvShow.firstAirDate != null &&
                      tvShow.firstAirDate!.isNotEmpty) ...[
                    InfoRowWidget(
                      label: 'First Air Date',
                      value: tvShow.firstAirDate!,
                    ),
                  ],
                  if (tvShow.originCountry.isNotEmpty) ...[
                    InfoRowWidget(
                      label: 'Origin Country',
                      value: tvShow.originCountry.join(', '),
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
