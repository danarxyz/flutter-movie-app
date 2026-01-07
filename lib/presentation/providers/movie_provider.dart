import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection_container.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';

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

// --- Providers ---

final movieRepositoryProvider = Provider<MovieRepository>((ref) => sl<MovieRepository>());

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

// --- Watchlist Notifier ---

class WatchlistNotifier extends StateNotifier<AsyncValue<List<Movie>>> {
  final MovieRepository _repository;
  WatchlistNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> loadWatchlist() async {
    state = const AsyncValue.loading();
    try {
      final movies = await _repository.getWatchlist();
      state = AsyncValue.data(movies);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addToWatchlist(Movie movie) async {
    try {
      await _repository.addToWatchlist(movie);
      // Optimistic update or reload
      final currentList = state.value ?? [];
      if (!currentList.any((m) => m.id == movie.id)) {
        state = AsyncValue.data([...currentList, movie]);
      }
    } catch (e, st) {
      // Handle error (maybe show toast via listener in UI)
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeFromWatchlist(int movieId) async {
    try {
      await _repository.removeFromWatchlist(movieId);
      // Optimistic update
      final currentList = state.value ?? [];
      state = AsyncValue.data(currentList.where((m) => m.id != movieId).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final watchlistProvider = StateNotifierProvider<WatchlistNotifier, AsyncValue<List<Movie>>>((ref) {
  return WatchlistNotifier(ref.watch(movieRepositoryProvider));
});
