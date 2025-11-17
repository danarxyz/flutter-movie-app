import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/movie.dart';
import '../models/tv_show.dart';

class TMDBService {
  // Singleton pattern
  static final TMDBService _instance = TMDBService._internal();
  factory TMDBService() => _instance;
  TMDBService._internal();

  // ========== MOVIE ENDPOINTS ==========

  /// Get popular movies
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/movie/popular?page=$page');
    return _fetchMovies(url);
  }

  /// Get top rated movies
  Future<List<Movie>> getTopRatedMovies({int page = 1}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/movie/top_rated?page=$page');
    return _fetchMovies(url);
  }

  /// Get trending movies (week)
  Future<List<Movie>> getTrendingMovies({int page = 1}) async {
    final url =
        Uri.parse('${ApiConfig.baseUrl}/trending/movie/week?page=$page');
    return _fetchMovies(url);
  }

  /// Get now playing movies
  Future<List<Movie>> getNowPlayingMovies({int page = 1}) async {
    final url =
        Uri.parse('${ApiConfig.baseUrl}/movie/now_playing?page=$page');
    return _fetchMovies(url);
  }

  /// Get upcoming movies
  Future<List<Movie>> getUpcomingMovies({int page = 1}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/movie/upcoming?page=$page');
    return _fetchMovies(url);
  }

  /// Get movie details by ID
  Future<Movie> getMovieDetails(int id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/movie/$id');
    try {
      final response = await http.get(url, headers: ApiConfig.headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Movie.fromJson(data);
      } else {
        throw Exception('Failed to load movie details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching movie details: $e');
    }
  }

  // ========== TV SHOW ENDPOINTS ==========

  /// Get popular TV shows
  Future<List<TVShow>> getPopularTVShows({int page = 1}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/tv/popular?page=$page');
    return _fetchTVShows(url);
  }

  /// Get top rated TV shows
  Future<List<TVShow>> getTopRatedTVShows({int page = 1}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/tv/top_rated?page=$page');
    return _fetchTVShows(url);
  }

  /// Get trending TV shows (week)
  Future<List<TVShow>> getTrendingTVShows({int page = 1}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/trending/tv/week?page=$page');
    return _fetchTVShows(url);
  }

  /// Get on the air TV shows
  Future<List<TVShow>> getOnTheAirTVShows({int page = 1}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/tv/on_the_air?page=$page');
    return _fetchTVShows(url);
  }

  /// Get anime TV shows (using discover with animation genre)
  Future<List<TVShow>> getAnime({int page = 1}) async {
    // Genre ID 16 is Animation
    // Filter by Japanese origin country for more accurate anime results
    final url = Uri.parse(
        '${ApiConfig.baseUrl}/discover/tv?with_genres=16&with_origin_country=JP&sort_by=popularity.desc&page=$page');
    return _fetchTVShows(url);
  }

  /// Get TV show details by ID
  Future<TVShow> getTVShowDetails(int id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/tv/$id');
    try {
      final response = await http.get(url, headers: ApiConfig.headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TVShow.fromJson(data);
      } else {
        throw Exception('Failed to load TV show details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching TV show details: $e');
    }
  }

  // ========== SEARCH ENDPOINTS ==========

  /// Search for movies
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query.isEmpty) return [];
    final url = Uri.parse(
        '${ApiConfig.baseUrl}/search/movie?query=${Uri.encodeComponent(query)}&page=$page');
    return _fetchMovies(url);
  }

  /// Search for TV shows
  Future<List<TVShow>> searchTVShows(String query, {int page = 1}) async {
    if (query.isEmpty) return [];
    final url = Uri.parse(
        '${ApiConfig.baseUrl}/search/tv?query=${Uri.encodeComponent(query)}&page=$page');
    return _fetchTVShows(url);
  }

  /// Search for both movies and TV shows (multi search)
  Future<Map<String, List<dynamic>>> searchMulti(String query,
      {int page = 1}) async {
    if (query.isEmpty) return {'movies': [], 'tvShows': []};

    final url = Uri.parse(
        '${ApiConfig.baseUrl}/search/multi?query=${Uri.encodeComponent(query)}&page=$page');

    try {
      final response = await http.get(url, headers: ApiConfig.headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>;

        final movies = <Movie>[];
        final tvShows = <TVShow>[];

        for (var item in results) {
          final mediaType = item['media_type'];
          if (mediaType == 'movie') {
            movies.add(Movie.fromJson(item));
          } else if (mediaType == 'tv') {
            tvShows.add(TVShow.fromJson(item));
          }
        }

        return {'movies': movies, 'tvShows': tvShows};
      } else {
        throw Exception('Failed to search: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching: $e');
    }
  }

  // ========== PRIVATE HELPER METHODS ==========

  /// Fetch movies from API
  Future<List<Movie>> _fetchMovies(Uri url) async {
    try {
      final response = await http.get(url, headers: ApiConfig.headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>;
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching movies: $e');
    }
  }

  /// Fetch TV shows from API
  Future<List<TVShow>> _fetchTVShows(Uri url) async {
    try {
      final response = await http.get(url, headers: ApiConfig.headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>;
        return results.map((json) => TVShow.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load TV shows: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching TV shows: $e');
    }
  }
}
