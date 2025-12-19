import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../models/tv_show.dart';
import '../services/tmdb_service.dart';

class SearchProvider extends ChangeNotifier {
  final TMDBService _tmdbService = TMDBService();

  // Search results
  List<Movie> _movieResults = [];
  List<TVShow> _tvShowResults = [];

  // Current search query
  String _searchQuery = '';

  // Loading state
  bool _isLoading = false;

  // Error state
  String? _error;

  // Debounce timer
  Timer? _debounce;

  // Getters
  List<Movie> get movieResults => _movieResults;
  List<TVShow> get tvShowResults => _tvShowResults;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasResults => _movieResults.isNotEmpty || _tvShowResults.isNotEmpty;
  int get totalResults => _movieResults.length + _tvShowResults.length;

  // Search for both movies and TV shows with debouncing
  void searchMulti(String query) {
    // Cancel previous timer if exists
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    // Set loading state immediately for UX feedback
    _searchQuery = query;
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Start new debounce timer
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearchMulti(query);
    });
  }

  // Actual search execution (private)
  Future<void> _performSearchMulti(String query) async {
    try {
      final results = await _tmdbService.searchMulti(query);
      _movieResults = results['movies'] as List<Movie>;
      _tvShowResults = results['tvShows'] as List<TVShow>;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search only movies with debouncing
  void searchMovies(String query) {
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      _movieResults = [];
      notifyListeners();
      return;
    }

    _searchQuery = query;
    _isLoading = true;
    _error = null;
    notifyListeners();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearchMovies(query);
    });
  }

  Future<void> _performSearchMovies(String query) async {
    try {
      _movieResults = await _tmdbService.searchMovies(query);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search only TV shows with debouncing
  void searchTVShows(String query) {
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      _tvShowResults = [];
      notifyListeners();
      return;
    }

    _searchQuery = query;
    _isLoading = true;
    _error = null;
    notifyListeners();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearchTVShows(query);
    });
  }

  Future<void> _performSearchTVShows(String query) async {
    try {
      _tvShowResults = await _tmdbService.searchTVShows(query);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear search results
  void clearSearch() {
    _debounce?.cancel();
    _movieResults = [];
    _tvShowResults = [];
    _searchQuery = '';
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
