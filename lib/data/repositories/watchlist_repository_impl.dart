import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/error/exceptions.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../models/movie_model.dart';

/// Implementation of [WatchlistRepository] using Firebase Realtime Database.
///
/// Provides real-time sync via [Stream] and handles user authentication context.
class WatchlistRepositoryImpl implements WatchlistRepository {
  final FirebaseDatabase _firebaseDatabase;
  final FirebaseAuth _firebaseAuth;

  WatchlistRepositoryImpl({
    required FirebaseDatabase firebaseDatabase,
    required FirebaseAuth firebaseAuth,
  })  : _firebaseDatabase = firebaseDatabase,
        _firebaseAuth = firebaseAuth;

  /// Helper to get current user ID.
  String? get _userId => _firebaseAuth.currentUser?.uid;

  /// Gets the DatabaseReference for the user's watchlist.
  DatabaseReference _watchlistRef(String userId) =>
      _firebaseDatabase.ref('users/$userId/watchlist');

  @override
  Stream<List<Movie>> getWatchlistStream() {
    final userId = _userId;
    if (userId == null) {
      // Return empty stream if not logged in.
      return Stream.value(<Movie>[]);
    }

    return _watchlistRef(userId).onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return <Movie>[];
      }

      // Firebase RTDB returns Map<Object?, Object?>
      final data = event.snapshot.value as Map<Object?, Object?>;

      return data.entries.map((entry) {
        final movieData = Map<String, dynamic>.from(entry.value as Map);
        return MovieModel.fromJson(movieData);
      }).toList();
    }).handleError((error) {
      // Log error but don't break the stream, emit empty list as fallback.
      // In production, consider more sophisticated error handling/reporting.
      // ignore: avoid_print
      print('Watchlist stream error: $error');
      return <Movie>[];
    });
  }

  @override
  Future<void> addToWatchlist(Movie movie) async {
    final userId = _userId;
    if (userId == null) {
      throw const WatchlistException('User not logged in');
    }

    try {
      final movieModel = MovieModel(
        id: movie.id,
        title: movie.title,
        overview: movie.overview,
        posterPath: movie.posterPath,
        backdropPath: movie.backdropPath,
        voteAverage: movie.voteAverage,
        releaseDate: movie.releaseDate,
        genres: movie.genres,
        mediaType: movie.mediaType,
      );

      await _watchlistRef(userId).child('${movie.id}').set({
        ...movieModel.toJson(),
        'addedAt': ServerValue.timestamp,
      });
    } catch (e) {
      throw WatchlistException('Failed to add to watchlist', e);
    }
  }

  @override
  Future<void> removeFromWatchlist(int movieId) async {
    final userId = _userId;
    if (userId == null) {
      throw const WatchlistException('User not logged in');
    }

    try {
      await _watchlistRef(userId).child('$movieId').remove();
    } catch (e) {
      throw WatchlistException('Failed to remove from watchlist', e);
    }
  }

  @override
  Future<bool> isInWatchlist(int movieId) async {
    final userId = _userId;
    if (userId == null) {
      return false;
    }

    try {
      final snapshot = await _watchlistRef(userId).child('$movieId').get();
      return snapshot.exists;
    } catch (e) {
      // If error checking, assume not in watchlist.
      return false;
    }
  }
}
