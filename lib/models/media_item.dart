/// Base class for media items (Movies and TV Shows)
abstract class MediaItem {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String? releaseDate;
  final List<int> genreIds;
  final double popularity;
  final String originalLanguage;
  final String mediaType; // 'movie' or 'tv'

  MediaItem({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    this.releaseDate,
    required this.genreIds,
    required this.popularity,
    required this.originalLanguage,
    required this.mediaType,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson();

  // Helper to get formatted rating (out of 10)
  String get formattedRating => voteAverage.toStringAsFixed(1);

  // Helper to get year from release date
  String get releaseYear {
    if (releaseDate == null || releaseDate!.isEmpty) return 'N/A';
    try {
      return releaseDate!.split('-')[0];
    } catch (e) {
      return 'N/A';
    }
  }
}
