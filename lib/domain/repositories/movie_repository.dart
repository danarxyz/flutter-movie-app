import '../entities/movie.dart';

abstract class MovieRepository {
  // --- Remote Data (TMDB) ---
  
  /// Get list of popular movies
  Future<List<Movie>> getPopularMovies();
  
  /// Get list of top rated movies
  Future<List<Movie>> getTopRatedMovies();
  
  /// Get trending movies
  Future<List<Movie>> getTrendingContent();

  /// Get trending TV shows
  Future<List<Movie>> getTrendingTVShows();
  
  /// Search for movies
  Future<List<Movie>> searchMovies(String query);

  /// Get movie/TV details
  Future<Movie> getContentDetail(int id, {String type = 'movie'});

  /// Get popular TV Shows
  Future<List<Movie>> getPopularTVShows();

  /// Get Anime (Animation TV Shows)
  Future<List<Movie>> getAnime();

  // --- User Data (Firebase) ---

  /// Add movie to user's watchlist
  Future<void> addToWatchlist(Movie movie);

  /// Remove movie from watchlist
  Future<void> removeFromWatchlist(int movieId);

  /// Check if a movie is in watchlist (for UI icon state)
  Future<bool> isAddedToWatchlist(int movieId);

  /// Get all watchlist movies
  Future<List<Movie>> getWatchlist();
}
