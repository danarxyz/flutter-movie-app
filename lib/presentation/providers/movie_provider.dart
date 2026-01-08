import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection_container.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../domain/repositories/watchlist_repository.dart';

// --- State Classes ---
abstract class MovieState {}
class MovieInitial extends MovieState {}
class MovieLoading extends MovieState {}
class MovieLoaded extends MovieState {
  final List<Movie> movies;
  MovieLoaded(this.movies);
}
class MovieError extends MovieState {
  final String message;
  MovieError(this.message);
}

// --- Notifiers ---

class TrendingMoviesNotifier extends StateNotifier<MovieState> {
  final MovieRepository _repository;
  TrendingMoviesNotifier(this._repository) : super(MovieInitial());

  Future<void> loadTrendingMovies() async {
    state = MovieLoading();
    try {
      final movies = await _repository.getTrendingContent();
      state = MovieLoaded(movies);
    } catch (e) {
      state = MovieError(e.toString());
    }
  }
}

class PopularMoviesNotifier extends StateNotifier<MovieState> {
  final MovieRepository _repository;
  PopularMoviesNotifier(this._repository) : super(MovieInitial());

  Future<void> loadPopularMovies() async {
    state = MovieLoading();
    try {
      final movies = await _repository.getPopularMovies();
      state = MovieLoaded(movies);
    } catch (e) {
      state = MovieError(e.toString());
    }
  }
}

class TopRatedMoviesNotifier extends StateNotifier<MovieState> {
  final MovieRepository _repository;
  TopRatedMoviesNotifier(this._repository) : super(MovieInitial());

  Future<void> loadTopRatedMovies() async {
    state = MovieLoading();
    try {
      final movies = await _repository.getTopRatedMovies();
      state = MovieLoaded(movies);
    } catch (e) {
      state = MovieError(e.toString());
    }
  }
}

// --- TV & Anime Notifiers ---

class PopularTVNotifier extends StateNotifier<MovieState> {
  final MovieRepository _repository;
  PopularTVNotifier(this._repository) : super(MovieInitial());

  Future<void> loadPopularTVShows() async {
    state = MovieLoading();
    try {
      final movies = await _repository.getPopularTVShows();
      state = MovieLoaded(movies);
    } catch (e) {
      state = MovieError(e.toString());
    }
  }
}

class AnimeNotifier extends StateNotifier<MovieState> {
  final MovieRepository _repository;
  AnimeNotifier(this._repository) : super(MovieInitial());

  Future<void> loadAnime() async {
    state = MovieLoading();
    try {
      final movies = await _repository.getAnime();
      state = MovieLoaded(movies);
    } catch (e) {
      state = MovieError(e.toString());
    }
  }
}

class TrendingTVNotifier extends StateNotifier<MovieState> {
  final MovieRepository _repository;
  TrendingTVNotifier(this._repository) : super(MovieInitial());

  Future<void> loadTrendingTVShows() async {
    state = MovieLoading();
    try {
      final movies = await _repository.getTrendingTVShows();
      state = MovieLoaded(movies);
    } catch (e) {
      state = MovieError(e.toString());
    }
  }
}

// --- Repository Providers ---

final movieRepositoryProvider = Provider<MovieRepository>((ref) => sl<MovieRepository>());

final watchlistRepositoryProvider = Provider<WatchlistRepository>((ref) => sl<WatchlistRepository>());

// --- Movie Providers ---

final trendingMoviesProvider = StateNotifierProvider<TrendingMoviesNotifier, MovieState>((ref) {
  return TrendingMoviesNotifier(ref.watch(movieRepositoryProvider));
});

final trendingTVProvider = StateNotifierProvider<TrendingTVNotifier, MovieState>((ref) {
  return TrendingTVNotifier(ref.watch(movieRepositoryProvider));
});

final popularMoviesProvider = StateNotifierProvider<PopularMoviesNotifier, MovieState>((ref) {
  return PopularMoviesNotifier(ref.watch(movieRepositoryProvider));
});

final topRatedMoviesProvider = StateNotifierProvider<TopRatedMoviesNotifier, MovieState>((ref) {
  return TopRatedMoviesNotifier(ref.watch(movieRepositoryProvider));
});

final popularTVProvider = StateNotifierProvider<PopularTVNotifier, MovieState>((ref) {
  return PopularTVNotifier(ref.watch(movieRepositoryProvider));
});

final animeProvider = StateNotifierProvider<AnimeNotifier, MovieState>((ref) {
  return AnimeNotifier(ref.watch(movieRepositoryProvider));
});

// --- Watchlist Provider (Stream-based for real-time sync) ---

/// StreamProvider for real-time watchlist updates from Firebase RTDB.
/// Automatically disposes when no longer listened to.
final watchlistStreamProvider = StreamProvider.autoDispose<List<Movie>>((ref) {
  final repository = ref.watch(watchlistRepositoryProvider);
  return repository.getWatchlistStream();
});

/// Notifier for watchlist actions (add/remove).
/// The actual list is managed by [watchlistStreamProvider].
class WatchlistActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final WatchlistRepository _repository;
  WatchlistActionsNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> addToWatchlist(Movie movie) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addToWatchlist(movie);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeFromWatchlist(int movieId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.removeFromWatchlist(movieId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> isInWatchlist(int movieId) async {
    return await _repository.isInWatchlist(movieId);
  }
}

final watchlistActionsProvider = StateNotifierProvider<WatchlistActionsNotifier, AsyncValue<void>>((ref) {
  return WatchlistActionsNotifier(ref.watch(watchlistRepositoryProvider));
});

/// Legacy provider for backward compatibility.
/// Wraps the stream into AsyncValue for existing consumers.
final watchlistProvider = Provider<AsyncValue<List<Movie>>>((ref) {
  return ref.watch(watchlistStreamProvider);
});

