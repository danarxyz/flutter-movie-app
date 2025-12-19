import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // TMDB API Configuration - loaded from environment variables
  static String get apiKey => dotenv.env['TMDB_API_KEY'] ?? '';
  static String get accessToken => dotenv.env['TMDB_ACCESS_TOKEN'] ?? '';

  // Base URLs
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';

  // Image sizes
  static const String posterSizeSmall = 'w185';
  static const String posterSizeMedium = 'w342';
  static const String posterSizeLarge = 'w500';
  static const String backdropSize = 'w780';
  static const String originalSize = 'original';

  // Helper methods for image URLs
  static String getPosterUrl(String? path, {String size = posterSizeMedium}) {
    if (path == null || path.isEmpty) return '';
    return '$imageBaseUrl/$size$path';
  }

  static String getBackdropUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return '$imageBaseUrl/$backdropSize$path';
  }

  static String getOriginalImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return '$imageBaseUrl/$originalSize$path';
  }

  // Headers for API requests
  static Map<String, String> get headers => {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };
}
