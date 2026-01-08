import '../entities/movie.dart';

/// Repository interface for watchlist operations.
///
/// Provides real-time sync capabilities using Streams and
/// CRUD operations for managing user's watchlist.
abstract class WatchlistRepository {
  /// Get a real-time stream of the user's watchlist.
  ///
  /// Emits updates whenever the watchlist changes (add/remove).
  /// Returns an empty list if user has no items or is not logged in.
  Stream<List<Movie>> getWatchlistStream();

  /// Add a movie to the user's watchlist.
  ///
  /// Throws [WatchlistException] if the operation fails.
  Future<void> addToWatchlist(Movie movie);

  /// Remove a movie from the user's watchlist.
  ///
  /// Throws [WatchlistException] if the operation fails.
  Future<void> removeFromWatchlist(int movieId);

  /// Check if a movie is in the user's watchlist.
  ///
  /// Returns false if user is not logged in.
  Future<bool> isInWatchlist(int movieId);
}
