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

  // Page tracking for pagination
  int _popularPage = 1;
  int _topRatedPage = 1;
  int _trendingPage = 1;
  int _animePage = 1;

  // Loading states
  bool _isLoadingPopular = false;
  bool _isLoadingTopRated = false;
  bool _isLoadingTrending = false;
  bool _isLoadingOnTheAir = false;
  bool _isLoadingAnime = false;

  // Loading more states
  bool _isLoadingMorePopular = false;
  bool _isLoadingMoreTopRated = false;
  bool _isLoadingMoreTrending = false;
  bool _isLoadingMoreAnime = false;

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

  bool get isLoadingMorePopular => _isLoadingMorePopular;
  bool get isLoadingMoreTopRated => _isLoadingMoreTopRated;
  bool get isLoadingMoreTrending => _isLoadingMoreTrending;
  bool get isLoadingMoreAnime => _isLoadingMoreAnime;

  String? get popularError => _popularError;
  String? get topRatedError => _topRatedError;
  String? get trendingError => _trendingError;
  String? get onTheAirError => _onTheAirError;
  String? get animeError => _animeError;

  // Fetch popular TV shows (reset to page 1)
  Future<void> fetchPopularTVShows() async {
    _isLoadingPopular = true;
    _popularError = null;
    _popularPage = 1;
    notifyListeners();

    try {
      _popularTVShows = await _tmdbService.getPopularTVShows(page: _popularPage);
      _isLoadingPopular = false;
      notifyListeners();
    } catch (e) {
      _popularError = e.toString();
      _isLoadingPopular = false;
      notifyListeners();
    }
  }

  // Load more popular TV shows
  Future<void> loadMorePopularTVShows() async {
    if (_isLoadingMorePopular || _isLoadingPopular) return;

    _isLoadingMorePopular = true;
    notifyListeners();

    try {
      _popularPage++;
      final moreShows = await _tmdbService.getPopularTVShows(page: _popularPage);
      _popularTVShows.addAll(moreShows);
      _isLoadingMorePopular = false;
      notifyListeners();
    } catch (e) {
      _popularPage--;
      _isLoadingMorePopular = false;
      notifyListeners();
    }
  }

  // Fetch top rated TV shows (reset to page 1)
  Future<void> fetchTopRatedTVShows() async {
    _isLoadingTopRated = true;
    _topRatedError = null;
    _topRatedPage = 1;
    notifyListeners();

    try {
      _topRatedTVShows = await _tmdbService.getTopRatedTVShows(page: _topRatedPage);
      _isLoadingTopRated = false;
      notifyListeners();
    } catch (e) {
      _topRatedError = e.toString();
      _isLoadingTopRated = false;
      notifyListeners();
    }
  }

  // Load more top rated TV shows
  Future<void> loadMoreTopRatedTVShows() async {
    if (_isLoadingMoreTopRated || _isLoadingTopRated) return;

    _isLoadingMoreTopRated = true;
    notifyListeners();

    try {
      _topRatedPage++;
      final moreShows = await _tmdbService.getTopRatedTVShows(page: _topRatedPage);
      _topRatedTVShows.addAll(moreShows);
      _isLoadingMoreTopRated = false;
      notifyListeners();
    } catch (e) {
      _topRatedPage--;
      _isLoadingMoreTopRated = false;
      notifyListeners();
    }
  }

  // Fetch trending TV shows (reset to page 1)
  Future<void> fetchTrendingTVShows() async {
    _isLoadingTrending = true;
    _trendingError = null;
    _trendingPage = 1;
    notifyListeners();

    try {
      _trendingTVShows = await _tmdbService.getTrendingTVShows(page: _trendingPage);
      _isLoadingTrending = false;
      notifyListeners();
    } catch (e) {
      _trendingError = e.toString();
      _isLoadingTrending = false;
      notifyListeners();
    }
  }

  // Load more trending TV shows
  Future<void> loadMoreTrendingTVShows() async {
    if (_isLoadingMoreTrending || _isLoadingTrending) return;

    _isLoadingMoreTrending = true;
    notifyListeners();

    try {
      _trendingPage++;
      final moreShows = await _tmdbService.getTrendingTVShows(page: _trendingPage);
      _trendingTVShows.addAll(moreShows);
      _isLoadingMoreTrending = false;
      notifyListeners();
    } catch (e) {
      _trendingPage--;
      _isLoadingMoreTrending = false;
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

  // Fetch anime shows (reset to page 1)
  Future<void> fetchAnimeShows() async {
    _isLoadingAnime = true;
    _animeError = null;
    _animePage = 1;
    notifyListeners();

    try {
      _animeShows = await _tmdbService.getAnime(page: _animePage);
      _isLoadingAnime = false;
      notifyListeners();
    } catch (e) {
      _animeError = e.toString();
      _isLoadingAnime = false;
      notifyListeners();
    }
  }

  // Load more anime shows
  Future<void> loadMoreAnimeShows() async {
    if (_isLoadingMoreAnime || _isLoadingAnime) return;

    _isLoadingMoreAnime = true;
    notifyListeners();

    try {
      _animePage++;
      final moreShows = await _tmdbService.getAnime(page: _animePage);
      _animeShows.addAll(moreShows);
      _isLoadingMoreAnime = false;
      notifyListeners();
    } catch (e) {
      _animePage--;
      _isLoadingMoreAnime = false;
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
    final allLists = [
      _popularTVShows,
      _topRatedTVShows,
      _trendingTVShows,
      _onTheAirTVShows,
      _animeShows,
    ];

    for (var list in allLists) {
      try {
        return list.firstWhere((tv) => tv.id == id);
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  // Clear cache (useful for memory management)
  void clearCache() {
    _tvShowCache.clear();
    notifyListeners();
  }
}
