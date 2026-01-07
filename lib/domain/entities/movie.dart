import 'package:equatable/equatable.dart'; // Recommended: Add 'equatable' to pubspec.yaml

class Cast extends Equatable {
  final String name;
  final String character;
  final String? profilePath;

  const Cast({
    required this.name,
    required this.character,
    this.profilePath,
  });

  @override
  List<Object?> get props => [name, character, profilePath];
}

class Movie extends Equatable {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final String releaseDate;
  final List<String> genres;
  final List<Cast> cast;
  final String? director;
  final int? runtime;
  final String mediaType; // 'movie' or 'tv'

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    this.genres = const [],
    this.cast = const [],
    this.director,
    this.runtime,
    this.mediaType = 'movie',
  });

  @override
  List<Object?> get props => [
        id,
        title,
        overview,
        posterPath,
        backdropPath,
        voteAverage,
        releaseDate,
        genres,
        cast,
        director,
        runtime,
        mediaType,
      ];
}
