import 'package:flutter/foundation.dart';
import '../models/tv_show.dart';
import '../services/tmdb_service.dart';

class TvProvider extends ChangeNotifier {
  final TMDBService _tmdbService = TMDBService();

  // TV Show lists
  List<TVShow> _popularTVShows = [];
  List<TVShow> _topRatedTVShows = [];
  List<TVShow> _trendingTVShows = [];
  List<TVShow> _onTheAirTVShows = [];
  List<TVShow> _animeShows = [];

  // Cache for TV show details by ID
  final Map<int, TVShow> _tvShowCache = {};

  // Loading states
  bool _isLoadingPopular = false;
  bool _isLoadingTopRated = false;
  bool _isLoadingTrending = false;
  bool _isLoadingOnTheAir = false;
  bool _isLoadingAnime = false;

  // Error states
  String? _popularError;
  String? _topRatedError;
  String? _trendingError;
  String? _onTheAirError;
  String? _animeError;

  // Getters
  List<TVShow> get popularTVShows => _popularTVShows;
  List<TVShow> get topRatedTVShows => _topRatedTVShows;
  List<TVShow> get trendingTVShows => _trendingTVShows;
  List<TVShow> get onTheAirTVShows => _onTheAirTVShows;
  List<TVShow> get animeShows => _animeShows;

  bool get isLoadingPopular => _isLoadingPopular;
  bool get isLoadingTopRated => _isLoadingTopRated;
  bool get isLoadingTrending => _isLoadingTrending;
  bool get isLoadingOnTheAir => _isLoadingOnTheAir;
  bool get isLoadingAnime => _isLoadingAnime;

  String? get popularError => _popularError;
  String? get topRatedError => _topRatedError;
  String? get trendingError => _trendingError;
  String? get onTheAirError => _onTheAirError;
  String? get animeError => _animeError;

  // Fetch popular TV shows
  Future<void> fetchPopularTVShows() async {
    _isLoadingPopular = true;
    _popularError = null;
    notifyListeners();

    try {
      _popularTVShows = await _tmdbService.getPopularTVShows();
      _isLoadingPopular = false;
      notifyListeners();
    } catch (e) {
      _popularError = e.toString();
      _isLoadingPopular = false;
      notifyListeners();
    }
  }

  // Fetch top rated TV shows
  Future<void> fetchTopRatedTVShows() async {
    _isLoadingTopRated = true;
    _topRatedError = null;
    notifyListeners();

    try {
      _topRatedTVShows = await _tmdbService.getTopRatedTVShows();
      _isLoadingTopRated = false;
      notifyListeners();
    } catch (e) {
      _topRatedError = e.toString();
      _isLoadingTopRated = false;
      notifyListeners();
    }
  }

  // Fetch trending TV shows
  Future<void> fetchTrendingTVShows() async {
    _isLoadingTrending = true;
    _trendingError = null;
    notifyListeners();

    try {
      _trendingTVShows = await _tmdbService.getTrendingTVShows();
      _isLoadingTrending = false;
      notifyListeners();
    } catch (e) {
      _trendingError = e.toString();
      _isLoadingTrending = false;
      notifyListeners();
    }
  }

  // Fetch on the air TV shows
  Future<void> fetchOnTheAirTVShows() async {
    _isLoadingOnTheAir = true;
    _onTheAirError = null;
    notifyListeners();

    try {
      _onTheAirTVShows = await _tmdbService.getOnTheAirTVShows();
      _isLoadingOnTheAir = false;
      notifyListeners();
    } catch (e) {
      _onTheAirError = e.toString();
      _isLoadingOnTheAir = false;
      notifyListeners();
    }
  }

  // Fetch anime shows
  Future<void> fetchAnimeShows() async {
    _isLoadingAnime = true;
    _animeError = null;
    notifyListeners();

    try {
      _animeShows = await _tmdbService.getAnime();
      _isLoadingAnime = false;
      notifyListeners();
    } catch (e) {
      _animeError = e.toString();
      _isLoadingAnime = false;
      notifyListeners();
    }
  }

  // Fetch all TV show categories at once
  Future<void> fetchAllTVShows() async {
    await Future.wait([
      fetchPopularTVShows(),
      fetchTopRatedTVShows(),
      fetchTrendingTVShows(),
      fetchAnimeShows(),
    ]);
  }

  // Get TV show by ID (from cache or API)
  Future<TVShow?> getTVShowById(int id) async {
    // Check cache first
    if (_tvShowCache.containsKey(id)) {
      return _tvShowCache[id];
    }

    // Try to find in existing lists
    TVShow? tvShow = _findInLists(id);
    if (tvShow != null) {
      _tvShowCache[id] = tvShow;
      return tvShow;
    }

    // Fetch from API
    try {
      tvShow = await _tmdbService.getTVShowDetails(id);
      _tvShowCache[id] = tvShow;
      notifyListeners();
      return tvShow;
    } catch (e) {
      debugPrint('Error fetching TV show by ID $id: $e');
      return null;
    }
  }

  // Helper: Find TV show in existing lists
  TVShow? _findInLists(int id) {
    try {
      return _popularTVShows.firstWhere((tv) => tv.id == id);
    } catch (_) {
      try {
        return _topRatedTVShows.firstWhere((tv) => tv.id == id);
      } catch (_) {
        try {
          return _trendingTVShows.firstWhere((tv) => tv.id == id);
        } catch (_) {
          try {
            return _onTheAirTVShows.firstWhere((tv) => tv.id == id);
          } catch (_) {
            try {
              return _animeShows.firstWhere((tv) => tv.id == id);
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
    _tvShowCache.clear();
    notifyListeners();
  }
}
