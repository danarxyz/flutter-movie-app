class ApiConfig {
  // TMDB API Configuration
  static const String apiKey = '7ba061875d74dfd040a26973110fefb0';
  static const String accessToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI3YmEwNjE4NzVkNzRkZmQwNDBhMjY5NzMxMTBmZWZiMCIsIm5iZiI6MTc2MzI4NzY0Ny43MzcsInN1YiI6IjY5MTlhMjVmMmVhMDQ2MWU1MzljNjRlNCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.oGL_LrL-FE2mlAbx95nmIG9KCRVrIOyYSthnxLXoK6E';

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
