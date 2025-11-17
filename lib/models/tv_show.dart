import 'media_item.dart';

class TVShow extends MediaItem {
  final String name;
  final String originalName;
  final String? firstAirDate;
  final List<String> originCountry;

  TVShow({
    required super.id,
    required this.name,
    required super.overview,
    super.posterPath,
    super.backdropPath,
    required super.voteAverage,
    required super.voteCount,
    this.firstAirDate,
    required super.genreIds,
    required super.popularity,
    required super.originalLanguage,
    required this.originalName,
    this.originCountry = const [],
  }) : super(
          title: name,
          releaseDate: firstAirDate,
          mediaType: 'tv',
        );

  // Factory constructor to create TVShow from JSON
  factory TVShow.fromJson(Map<String, dynamic> json) {
    return TVShow(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      originalName: json['original_name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      firstAirDate: json['first_air_date'],
      genreIds: (json['genre_ids'] as List<dynamic>?)?.cast<int>() ?? [],
      popularity: (json['popularity'] ?? 0).toDouble(),
      originalLanguage: json['original_language'] ?? '',
      originCountry:
          (json['origin_country'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  // Convert TVShow to JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'original_name': originalName,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'first_air_date': firstAirDate,
      'genre_ids': genreIds,
      'popularity': popularity,
      'original_language': originalLanguage,
      'origin_country': originCountry,
      'media_type': mediaType,
    };
  }

  // Create a copy with modified fields
  TVShow copyWith({
    int? id,
    String? name,
    String? originalName,
    String? overview,
    String? posterPath,
    String? backdropPath,
    double? voteAverage,
    int? voteCount,
    String? firstAirDate,
    List<int>? genreIds,
    double? popularity,
    String? originalLanguage,
    List<String>? originCountry,
  }) {
    return TVShow(
      id: id ?? this.id,
      name: name ?? this.name,
      originalName: originalName ?? this.originalName,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      voteAverage: voteAverage ?? this.voteAverage,
      voteCount: voteCount ?? this.voteCount,
      firstAirDate: firstAirDate ?? this.firstAirDate,
      genreIds: genreIds ?? this.genreIds,
      popularity: popularity ?? this.popularity,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      originCountry: originCountry ?? this.originCountry,
    );
  }
}
