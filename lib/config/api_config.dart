import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // TMDB API Configuration
  // Priority: --dart-define > .env > empty string
  // Production: Use --dart-define when building AAB
  // Development: Use .env file
  
  static String get apiKey {
    // Try --dart-define first (for production builds)
    const dartDefineKey = String.fromEnvironment('TMDB_API_KEY');
    if (dartDefineKey.isNotEmpty) return dartDefineKey;
    
    // Fallback to .env (for development)
    return dotenv.env['TMDB_API_KEY'] ?? '';
  }
  
  static String get accessToken {
    // Try --dart-define first (for production builds)
    const dartDefineToken = String.fromEnvironment('TMDB_ACCESS_TOKEN');
    if (dartDefineToken.isNotEmpty) return dartDefineToken;
    
    // Fallback to .env (for development)
    return dotenv.env['TMDB_ACCESS_TOKEN'] ?? '';
  }

  // Validation: Check if API keys are configured
  static bool get isConfigured => 
    apiKey.isNotEmpty && accessToken.isNotEmpty;

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
