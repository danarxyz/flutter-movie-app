import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/remote/movie_remote_data_source.dart';
import '../models/movie_model.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;
  final FirebaseDatabase firebaseDatabase;
  final FirebaseAuth firebaseAuth;

  MovieRepositoryImpl({
    required this.remoteDataSource,
    required this.firebaseDatabase,
    required this.firebaseAuth,
  });

  // --- Remote Data (TMDB) ---

  @override
  Future<List<Movie>> getPopularMovies() async {
    return await remoteDataSource.getPopularMovies();
  }

  @override
  Future<List<Movie>> getTopRatedMovies() async {
    return await remoteDataSource.getTopRatedMovies();
  }

  @override
  Future<List<Movie>> getTrendingContent() async {
    return await remoteDataSource.getTrendingMovies();
  }

  @override
  Future<List<Movie>> getTrendingTVShows() async {
    return await remoteDataSource.getTrendingTVShows();
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    return await remoteDataSource.searchMovies(query);
  }

  @override
  Future<Movie> getContentDetail(int id, {String type = 'movie'}) async {
    if (type == 'tv') {
      return await remoteDataSource.getTVDetails(id);
    }
    return await remoteDataSource.getMovieDetails(id);
  }

  @override
  Future<List<Movie>> getPopularTVShows() async {
    return await remoteDataSource.getPopularTVShows();
  }

  @override
  Future<List<Movie>> getAnime() async {
    return await remoteDataSource.getAnime();
  }

  // --- User Data (Firebase) ---
  
  // Helper to get current user ID
  String? get _userId => firebaseAuth.currentUser?.uid;

  @override
  Future<void> addToWatchlist(Movie movie) async {
    final uid = _userId;
    if (uid == null) throw Exception("User not logged in");

    final movieModel = MovieModel(
      id: movie.id,
      title: movie.title,
      overview: movie.overview,
      posterPath: movie.posterPath,
      backdropPath: movie.backdropPath,
      voteAverage: movie.voteAverage,
      releaseDate: movie.releaseDate,
    );
    
    // Save to /users/{uid}/watchlist/{movieId}
    await firebaseDatabase.ref('users/$uid/watchlist/${movie.id}').set(movieModel.toJson());
  }

  @override
  Future<void> removeFromWatchlist(int movieId) async {
    final uid = _userId;
    if (uid == null) throw Exception("User not logged in");
    
    await firebaseDatabase.ref('users/$uid/watchlist/$movieId').remove();
  }

  @override
  Future<bool> isAddedToWatchlist(int movieId) async {
    final uid = _userId;
    if (uid == null) return false;

    final event = await firebaseDatabase.ref('users/$uid/watchlist/$movieId').once();
    return event.snapshot.exists;
  }

  @override
  Future<List<Movie>> getWatchlist() async {
    final uid = _userId;
    if (uid == null) throw Exception("User not logged in");

    final event = await firebaseDatabase.ref('users/$uid/watchlist').once();
    if (event.snapshot.exists && event.snapshot.value != null) {
      final Map<dynamic, dynamic> map = event.snapshot.value as Map<dynamic, dynamic>;
      return map.values.map((v) => MovieModel.fromJson(Map<String, dynamic>.from(v))).toList();
    }
    return [];
  }
}
