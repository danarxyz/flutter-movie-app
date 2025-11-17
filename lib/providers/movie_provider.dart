import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';

class MovieProvider extends ChangeNotifier {
  final TMDBService _tmdbService = TMDBService();

  // Movie lists
  List<Movie> _popularMovies = [];
  List<Movie> _topRatedMovies = [];
  List<Movie> _trendingMovies = [];
  List<Movie> _nowPlayingMovies = [];
  List<Movie> _upcomingMovies = [];

  // Cache for movie details by ID
  final Map<int, Movie> _movieCache = {};

  // Loading states
  bool _isLoadingPopular = false;
  bool _isLoadingTopRated = false;
  bool _isLoadingTrending = false;
  bool _isLoadingNowPlaying = false;
  bool _isLoadingUpcoming = false;

  // Error states
  String? _popularError;
  String? _topRatedError;
  String? _trendingError;
  String? _nowPlayingError;
  String? _upcomingError;

  // Getters
  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get topRatedMovies => _topRatedMovies;
  List<Movie> get trendingMovies => _trendingMovies;
  List<Movie> get nowPlayingMovies => _nowPlayingMovies;
  List<Movie> get upcomingMovies => _upcomingMovies;

  bool get isLoadingPopular => _isLoadingPopular;
  bool get isLoadingTopRated => _isLoadingTopRated;
  bool get isLoadingTrending => _isLoadingTrending;
  bool get isLoadingNowPlaying => _isLoadingNowPlaying;
  bool get isLoadingUpcoming => _isLoadingUpcoming;

  String? get popularError => _popularError;
  String? get topRatedError => _topRatedError;
  String? get trendingError => _trendingError;
  String? get nowPlayingError => _nowPlayingError;
  String? get upcomingError => _upcomingError;

  // Fetch popular movies
  Future<void> fetchPopularMovies() async {
    _isLoadingPopular = true;
    _popularError = null;
    notifyListeners();

    try {
      _popularMovies = await _tmdbService.getPopularMovies();
      _isLoadingPopular = false;
      notifyListeners();
    } catch (e) {
      _popularError = e.toString();
      _isLoadingPopular = false;
      notifyListeners();
    }
  }

  // Fetch top rated movies
  Future<void> fetchTopRatedMovies() async {
    _isLoadingTopRated = true;
    _topRatedError = null;
    notifyListeners();

    try {
      _topRatedMovies = await _tmdbService.getTopRatedMovies();
      _isLoadingTopRated = false;
      notifyListeners();
    } catch (e) {
      _topRatedError = e.toString();
      _isLoadingTopRated = false;
      notifyListeners();
    }
  }

  // Fetch trending movies
  Future<void> fetchTrendingMovies() async {
    _isLoadingTrending = true;
    _trendingError = null;
    notifyListeners();

    try {
      _trendingMovies = await _tmdbService.getTrendingMovies();
      _isLoadingTrending = false;
      notifyListeners();
    } catch (e) {
      _trendingError = e.toString();
      _isLoadingTrending = false;
      notifyListeners();
    }
  }

  // Fetch now playing movies
  Future<void> fetchNowPlayingMovies() async {
    _isLoadingNowPlaying = true;
    _nowPlayingError = null;
    notifyListeners();

    try {
      _nowPlayingMovies = await _tmdbService.getNowPlayingMovies();
      _isLoadingNowPlaying = false;
      notifyListeners();
    } catch (e) {
      _nowPlayingError = e.toString();
      _isLoadingNowPlaying = false;
      notifyListeners();
    }
  }

  // Fetch upcoming movies
  Future<void> fetchUpcomingMovies() async {
    _isLoadingUpcoming = true;
    _upcomingError = null;
    notifyListeners();

    try {
      _upcomingMovies = await _tmdbService.getUpcomingMovies();
      _isLoadingUpcoming = false;
      notifyListeners();
    } catch (e) {
      _upcomingError = e.toString();
      _isLoadingUpcoming = false;
      notifyListeners();
    }
  }

  // Fetch all movie categories at once
  Future<void> fetchAllMovies() async {
    await Future.wait([
      fetchPopularMovies(),
      fetchTopRatedMovies(),
      fetchTrendingMovies(),
    ]);
  }

  // Get movie by ID (from cache or API)
  Future<Movie?> getMovieById(int id) async {
    // Check cache first
    if (_movieCache.containsKey(id)) {
      return _movieCache[id];
    }

    // Try to find in existing lists
    Movie? movie = _findInLists(id);
    if (movie != null) {
      _movieCache[id] = movie;
      return movie;
    }

    // Fetch from API
    try {
      movie = await _tmdbService.getMovieDetails(id);
      _movieCache[id] = movie;
      notifyListeners();
      return movie;
    } catch (e) {
      debugPrint('Error fetching movie by ID $id: $e');
      return null;
    }
  }

  // Helper: Find movie in existing lists
  Movie? _findInLists(int id) {
    try {
      return _popularMovies.firstWhere((m) => m.id == id);
    } catch (_) {
      try {
        return _topRatedMovies.firstWhere((m) => m.id == id);
      } catch (_) {
        try {
          return _trendingMovies.firstWhere((m) => m.id == id);
        } catch (_) {
          try {
            return _nowPlayingMovies.firstWhere((m) => m.id == id);
          } catch (_) {
            try {
              return _upcomingMovies.firstWhere((m) => m.id == id);
            } catch (_) {
              return null;
            }
          }
        }
      }
    }
  }

  // Clear cache (useful for memory management)
  void clearCache() {
    _movieCache.clear();
    notifyListeners();
  }
}
