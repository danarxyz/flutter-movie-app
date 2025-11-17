import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/media_item.dart';
import '../models/movie.dart';
import '../models/tv_show.dart';

class FavoritesProvider extends ChangeNotifier {
  static const String _favoritesKey = 'favorites';

  List<MediaItem> _favorites = [];
  bool _isLoading = false;

  List<MediaItem> get favorites => _favorites;
  List<Movie> get favoriteMovies =>
      _favorites.whereType<Movie>().toList();
  List<TVShow> get favoriteTVShows =>
      _favorites.whereType<TVShow>().toList();
  bool get isLoading => _isLoading;
  int get favoritesCount => _favorites.length;

  // Initialize and load favorites from SharedPreferences
  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      _favorites = favoritesJson.map((jsonStr) {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        final mediaType = json['media_type'];

        if (mediaType == 'movie') {
          return Movie.fromJson(json);
        } else if (mediaType == 'tv') {
          return TVShow.fromJson(json);
        }
        throw Exception('Unknown media type: $mediaType');
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      _favorites = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson =
          _favorites.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList(_favoritesKey, favoritesJson);
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  // Check if an item is in favorites
  bool isFavorite(int id, String mediaType) {
    return _favorites.any((item) => item.id == id && item.mediaType == mediaType);
  }

  // Add item to favorites
  Future<void> addFavorite(MediaItem item) async {
    if (!isFavorite(item.id, item.mediaType)) {
      _favorites.insert(0, item); // Add to beginning
      notifyListeners();
      await _saveFavorites();
    }
  }

  // Remove item from favorites
  Future<void> removeFavorite(int id, String mediaType) async {
    _favorites.removeWhere((item) => item.id == id && item.mediaType == mediaType);
    notifyListeners();
    await _saveFavorites();
  }

  // Toggle favorite status
  Future<void> toggleFavorite(MediaItem item) async {
    if (isFavorite(item.id, item.mediaType)) {
      await removeFavorite(item.id, item.mediaType);
    } else {
      await addFavorite(item);
    }
  }

  // Clear all favorites
  Future<void> clearFavorites() async {
    _favorites.clear();
    notifyListeners();
    await _saveFavorites();
  }

  // Get a specific favorite by id and type
  MediaItem? getFavorite(int id, String mediaType) {
    try {
      return _favorites.firstWhere(
        (item) => item.id == id && item.mediaType == mediaType,
      );
    } catch (e) {
      return null;
    }
  }
}
