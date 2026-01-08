import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/remote/movie_remote_data_source.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;

  MovieRepositoryImpl({
    required this.remoteDataSource,
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
}

