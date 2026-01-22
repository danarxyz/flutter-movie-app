import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../network/dio_client.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../../domain/repositories/user_management_repository.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/watchlist_repository_impl.dart';
import '../../data/repositories/user_management_repository_impl.dart';
import '../../data/datasources/remote/movie_remote_data_source.dart';
import '../../data/datasources/firebase/auth_data_source.dart';
import '../../data/datasources/firebase/user_management_data_source.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  sl.registerLazySingleton<DioClient>(() => DioClient());
  sl.registerLazySingleton<Dio>(() => sl<DioClient>().dio);
  
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseDatabase.instance);

  //! Data Sources
  sl.registerLazySingleton<MovieRemoteDataSource>(
    () => MovieRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuthDataSource>(
    () => AuthDataSourceImpl(firebaseAuth: sl(), firebaseDatabase: sl()),
  );
  sl.registerLazySingleton<UserManagementDataSource>(
    () => UserManagementDataSourceImpl(firebaseDatabase: sl()),
  );

  //! Repositories
  sl.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<WatchlistRepository>(
    () => WatchlistRepositoryImpl(
      firebaseDatabase: sl(),
      firebaseAuth: sl(),
    ),
  );
  sl.registerLazySingleton<UserManagementRepository>(
    () => UserManagementRepositoryImpl(dataSource: sl()),
  );

  //! Features - Authentication & Movies
  // ViewModels/Providers will be registered here later when Presentation layer is built
}
