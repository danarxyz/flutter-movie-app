import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../domain/repositories/movie_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/remote/movie_remote_data_source.dart';
import '../../data/datasources/firebase/auth_data_source.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  sl.registerLazySingleton(() => Dio());
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseDatabase.instance);

  //! Data Sources
  sl.registerLazySingleton<MovieRemoteDataSource>(
    () => MovieRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuthDataSource>(
    () => AuthDataSourceImpl(firebaseAuth: sl()),
  );

  //! Repositories
  sl.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(
      remoteDataSource: sl(),
      firebaseDatabase: sl(),
      firebaseAuth: sl(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  //! Features - Authentication & Movies
  // ViewModels/Providers will be registered here later when Presentation layer is built
}
