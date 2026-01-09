import '../../domain/entities/movie.dart';

class MovieModel extends Movie {
  const MovieModel({
    required super.id,
    required super.title,
    required super.overview,
    required super.posterPath,
    required super.backdropPath,
    required super.voteAverage,
    required super.releaseDate,
    super.genres,
    super.cast,
    super.director,
    super.runtime,
    super.mediaType = 'movie',
  });

  factory MovieModel.fromJson(Map<String, dynamic> json, {String mediaType = 'movie'}) {
    // Genre Mapping
    final Map<int, String> genreMap = {
      28: 'Action', 12: 'Adventure', 16: 'Animation', 35: 'Comedy',
      80: 'Crime', 99: 'Documentary', 18: 'Drama', 10751: 'Family',
      14: 'Fantasy', 36: 'History', 27: 'Horror', 10402: 'Music',
      9648: 'Mystery', 10749: 'Romance', 878: 'Science Fiction',
      10770: 'TV Movie', 53: 'Thriller', 10752: 'War', 37: 'Western',
      10759: 'Action & Adventure', 10762: 'Kids', 10763: 'News',
      10764: 'Reality', 10765: 'Sci-Fi & Fantasy', 10766: 'Soap',
      10767: 'Talk', 10768: 'War & Politics',
    };
    
    List<String> genres = [];
    if (json['genre_ids'] != null) {
      genres = (json['genre_ids'] as List)
          .map((id) => genreMap[id] ?? 'Unknown')
          .toList()
          .cast<String>();
    } else if (json['genres'] != null) {
      final genresList = json['genres'] as List;
      if (genresList.isNotEmpty) {
        // Handle both object format (from TMDB) and string format (from Firebase)
        if (genresList.first is String) {
          genres = genresList.cast<String>();
        } else if (genresList.first is Map) {
          for (var v in genresList) {
            genres.add(v['name'] ?? '');
          }
        }
      }
    }

    // Parse runtime logic
    int? runtime = json['runtime'];
    if (mediaType == 'tv' && json['episode_run_time'] != null && (json['episode_run_time'] as List).isNotEmpty) {
       runtime = (json['episode_run_time'] as List).first;
    }

    return MovieModel(
      id: json['id'],
      title: json['title'] ?? json['name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: json['release_date'] ?? json['first_air_date'] ?? '',
      genres: genres,
      runtime: runtime,
      mediaType: mediaType,
      cast: json['credits'] != null && json['credits']['cast'] != null
          ? (json['credits']['cast'] as List)
              .take(10)
              .map((c) => Cast(
                    name: c['name'],
                    character: c['character'] ?? '',
                    profilePath: c['profile_path'],
                  ))
              .toList()
          : [],
      director: json['credits'] != null && json['credits']['crew'] != null
          ? (json['credits']['crew'] as List)
              .firstWhere(
                (crew) => crew['job'] == 'Director',
                orElse: () => <String, dynamic>{}, 
              )['name']
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'release_date': releaseDate,
      'genres': genres,
      // Simplify toJson for now (we mainly read this)
    };
  }
}
