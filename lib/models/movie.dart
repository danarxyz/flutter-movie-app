import 'media_item.dart';

class Movie extends MediaItem {
  final String originalTitle;
  final bool adult;
  final bool video;

  Movie({
    required super.id,
    required super.title,
    required super.overview,
    super.posterPath,
    super.backdropPath,
    required super.voteAverage,
    required super.voteCount,
    super.releaseDate,
    required super.genreIds,
    required super.popularity,
    required super.originalLanguage,
    required this.originalTitle,
    this.adult = false,
    this.video = false,
  }) : super(
          mediaType: 'movie',
        );

  // Factory constructor to create Movie from JSON
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      originalTitle: json['original_title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      releaseDate: json['release_date'],
      genreIds: (json['genre_ids'] as List<dynamic>?)?.cast<int>() ?? [],
      popularity: (json['popularity'] ?? 0).toDouble(),
      originalLanguage: json['original_language'] ?? '',
      adult: json['adult'] ?? false,
      video: json['video'] ?? false,
    );
  }

  // Convert Movie to JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'original_title': originalTitle,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'release_date': releaseDate,
      'genre_ids': genreIds,
      'popularity': popularity,
      'original_language': originalLanguage,
      'adult': adult,
      'video': video,
      'media_type': mediaType,
    };
  }

  // Create a copy with modified fields
  Movie copyWith({
    int? id,
    String? title,
    String? originalTitle,
    String? overview,
    String? posterPath,
    String? backdropPath,
    double? voteAverage,
    int? voteCount,
    String? releaseDate,
    List<int>? genreIds,
    double? popularity,
    String? originalLanguage,
    bool? adult,
    bool? video,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      originalTitle: originalTitle ?? this.originalTitle,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      voteAverage: voteAverage ?? this.voteAverage,
      voteCount: voteCount ?? this.voteCount,
      releaseDate: releaseDate ?? this.releaseDate,
      genreIds: genreIds ?? this.genreIds,
      popularity: popularity ?? this.popularity,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      adult: adult ?? this.adult,
      video: video ?? this.video,
    );
  }
}
