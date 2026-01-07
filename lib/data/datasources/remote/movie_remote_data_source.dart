import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/constants/app_constants.dart';
import '../../models/movie_model.dart';

abstract class MovieRemoteDataSource {
  Future<List<MovieModel>> getPopularMovies();
  Future<List<MovieModel>> getTopRatedMovies();
  Future<List<MovieModel>> getTrendingMovies();
  Future<List<MovieModel>> searchMovies(String query);
  Future<MovieModel> getMovieDetails(int id);
  Future<List<MovieModel>> getPopularTVShows();
  Future<List<MovieModel>> getTrendingTVShows();
  Future<List<MovieModel>> getAnime();
  Future<MovieModel> getTVDetails(int id);
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final Dio client;
  // API Key loaded from .env
  String get _apiKey => dotenv.env['TMDB_API_KEY'] ?? '';

  MovieRemoteDataSourceImpl({required this.client});

  @override
  Future<List<MovieModel>> getPopularMovies() async {
    final response = await client.get(
      '${AppConstants.tmdbBaseUrl}/movie/popular',
      queryParameters: {'api_key': _apiKey},
    );
    if (response.statusCode == 200) {
      final List results = response.data['results'];
      return results.map((e) => MovieModel.fromJson(e, mediaType: 'movie')).toList();
    } else {
      throw Exception('Failed to load popular movies');
    }
  }

  @override
  Future<List<MovieModel>> getTopRatedMovies() async {
    final response = await client.get(
      '${AppConstants.tmdbBaseUrl}/movie/top_rated',
      queryParameters: {'api_key': _apiKey},
    );
     if (response.statusCode == 200) {
      final List results = response.data['results'];
      return results.map((e) => MovieModel.fromJson(e, mediaType: 'movie')).toList();
    } else {
      throw Exception('Failed to load top rated movies');
    }
  }

  @override
  Future<List<MovieModel>> getTrendingMovies() async {
     final response = await client.get(
      '${AppConstants.tmdbBaseUrl}/trending/movie/week',
      queryParameters: {'api_key': _apiKey},
    );
     if (response.statusCode == 200) {
      final List results = response.data['results'];
      return results.map((e) => MovieModel.fromJson(e, mediaType: 'movie')).toList();
    } else {
      throw Exception('Failed to load trending movies');
    }
  }

  @override
  Future<List<MovieModel>> searchMovies(String query) async {
     final response = await client.get(
      '${AppConstants.tmdbBaseUrl}/search/multi', // Use multi search to find both
      queryParameters: {'api_key': _apiKey, 'query': query},
    );
     if (response.statusCode == 200) {
      final List results = response.data['results'];
      return results.map((e) {
        final type = e['media_type'] ?? 'movie';
        return MovieModel.fromJson(e, mediaType: type);
      }).toList();
    } else {
      throw Exception('Failed to search movies');
    }
  }

  @override
  Future<MovieModel> getMovieDetails(int id) async {
    final response = await client.get(
      '${AppConstants.tmdbBaseUrl}/movie/$id',
      queryParameters: {
        'api_key': _apiKey,
        'append_to_response': 'credits',
      },
    );
    if (response.statusCode == 200) {
      return MovieModel.fromJson(response.data, mediaType: 'movie');
    } else {
      throw Exception('Failed to load movie details');
    }
  }
  
  // New: Get TV Details
  Future<MovieModel> getTVDetails(int id) async {
    final response = await client.get(
      '${AppConstants.tmdbBaseUrl}/tv/$id',
      queryParameters: {
        'api_key': _apiKey,
        'append_to_response': 'credits',
      },
    );
    if (response.statusCode == 200) {
      return MovieModel.fromJson(response.data, mediaType: 'tv');
    } else {
      throw Exception('Failed to load tv details');
    }
  }

  // TV Shows
  @override
  Future<List<MovieModel>> getPopularTVShows() async {
    final response = await client.get(
      '${AppConstants.tmdbBaseUrl}/tv/popular',
      queryParameters: {'api_key': _apiKey},
    );
    if (response.statusCode == 200) {
      final List results = response.data['results'];
      return results.map((e) => MovieModel.fromJson(e, mediaType: 'tv')).toList();
    } else {
      throw Exception('Failed to load popular TV shows');
    }
  }
  
  // Trending TV
  @override
  Future<List<MovieModel>> getTrendingTVShows() async {
    final response = await client.get(
      '${AppConstants.tmdbBaseUrl}/trending/tv/week',
      queryParameters: {'api_key': _apiKey},
    );
    if (response.statusCode == 200) {
      final List results = response.data['results'];
      return results.map((e) => MovieModel.fromJson(e, mediaType: 'tv')).toList();
    } else {
      throw Exception('Failed to load trending TV shows');
    }
  }

  // Anime (TV Shows with Genre ID 16)
  @override
  Future<List<MovieModel>> getAnime() async {
    final response = await client.get(
      '${AppConstants.tmdbBaseUrl}/discover/tv',
      queryParameters: {
        'api_key': _apiKey,
        'with_genres': '16', 
        'with_original_language': 'ja',
        'sort_by': 'popularity.desc'
      },
    );
    if (response.statusCode == 200) {
      final List results = response.data['results'];
      return results.map((e) => MovieModel.fromJson(e, mediaType: 'tv')).toList();
    } else {
      throw Exception('Failed to load anime');
    }
  }
}
