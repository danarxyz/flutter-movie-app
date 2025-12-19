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

  // Page tracking for pagination
  int _popularPage = 1;
  int _topRatedPage = 1;
  int _trendingPage = 1;
  int _nowPlayingPage = 1;
  int _upcomingPage = 1;

  // Loading states
  bool _isLoadingPopular = false;
  bool _isLoadingTopRated = false;
  bool _isLoadingTrending = false;
  bool _isLoadingNowPlaying = false;
  bool _isLoadingUpcoming = false;

  // Loading more states
  bool _isLoadingMorePopular = false;
  bool _isLoadingMoreTopRated = false;
  bool _isLoadingMoreTrending = false;

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

  bool get isLoadingMorePopular => _isLoadingMorePopular;
  bool get isLoadingMoreTopRated => _isLoadingMoreTopRated;
  bool get isLoadingMoreTrending => _isLoadingMoreTrending;

  String? get popularError => _popularError;
  String? get topRatedError => _topRatedError;
  String? get trendingError => _trendingError;
  String? get nowPlayingError => _nowPlayingError;
  String? get upcomingError => _upcomingError;

  // Fetch popular movies (reset to page 1)
  Future<void> fetchPopularMovies() async {
    _isLoadingPopular = true;
    _popularError = null;
    _popularPage = 1;
    notifyListeners();

    try {
      _popularMovies = await _tmdbService.getPopularMovies(page: _popularPage);
      _isLoadingPopular = false;
      notifyListeners();
    } catch (e) {
      _popularError = e.toString();
      _isLoadingPopular = false;
      notifyListeners();
    }
  }

  // Load more popular movies (pagination)
  Future<void> loadMorePopularMovies() async {
    if (_isLoadingMorePopular || _isLoadingPopular) return;

    _isLoadingMorePopular = true;
    notifyListeners();

    try {
      _popularPage++;
      final moreMovies = await _tmdbService.getPopularMovies(page: _popularPage);
      _popularMovies.addAll(moreMovies);
      _isLoadingMorePopular = false;
      notifyListeners();
    } catch (e) {
      _popularPage--; // Rollback on error
      _isLoadingMorePopular = false;
      notifyListeners();
    }
  }

  // Fetch top rated movies (reset to page 1)
  Future<void> fetchTopRatedMovies() async {
    _isLoadingTopRated = true;
    _topRatedError = null;
    _topRatedPage = 1;
    notifyListeners();

    try {
      _topRatedMovies = await _tmdbService.getTopRatedMovies(page: _topRatedPage);
      _isLoadingTopRated = false;
      notifyListeners();
    } catch (e) {
      _topRatedError = e.toString();
      _isLoadingTopRated = false;
      notifyListeners();
    }
  }

  // Load more top rated movies
  Future<void> loadMoreTopRatedMovies() async {
    if (_isLoadingMoreTopRated || _isLoadingTopRated) return;

    _isLoadingMoreTopRated = true;
    notifyListeners();

    try {
      _topRatedPage++;
      final moreMovies = await _tmdbService.getTopRatedMovies(page: _topRatedPage);
      _topRatedMovies.addAll(moreMovies);
      _isLoadingMoreTopRated = false;
      notifyListeners();
    } catch (e) {
      _topRatedPage--;
      _isLoadingMoreTopRated = false;
      notifyListeners();
    }
  }

  // Fetch trending movies (reset to page 1)
  Future<void> fetchTrendingMovies() async {
    _isLoadingTrending = true;
    _trendingError = null;
    _trendingPage = 1;
    notifyListeners();

    try {
      _trendingMovies = await _tmdbService.getTrendingMovies(page: _trendingPage);
      _isLoadingTrending = false;
      notifyListeners();
    } catch (e) {
      _trendingError = e.toString();
      _isLoadingTrending = false;
      notifyListeners();
    }
  }

  // Load more trending movies
  Future<void> loadMoreTrendingMovies() async {
    if (_isLoadingMoreTrending || _isLoadingTrending) return;

    _isLoadingMoreTrending = true;
    notifyListeners();

    try {
      _trendingPage++;
      final moreMovies = await _tmdbService.getTrendingMovies(page: _trendingPage);
      _trendingMovies.addAll(moreMovies);
      _isLoadingMoreTrending = false;
      notifyListeners();
    } catch (e) {
      _trendingPage--;
      _isLoadingMoreTrending = false;
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
    final allLists = [
      _popularMovies,
      _topRatedMovies,
      _trendingMovies,
      _nowPlayingMovies,
      _upcomingMovies,
    ];

    for (var list in allLists) {
      try {
        return list.firstWhere((m) => m.id == id);
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  // Clear cache (useful for memory management)
  void clearCache() {
    _movieCache.clear();
    notifyListeners();
  }
}
