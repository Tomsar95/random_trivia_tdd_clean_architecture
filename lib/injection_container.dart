import 'package:clean_architecture_tdd_course/features/core/network/network_info.dart';
import 'package:clean_architecture_tdd_course/features/core/util/input_converter.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'features/number_trivia/data/datasources/number_trivia_local_data_source.dart';

final serviceLocator = GetIt.instance;

Future<void> init() async {
  // Features - Number Trivia
  initFeatures();
  // Core
  initCore();
  // External
  await initExternal();
}

void initFeatures() {
  // BLoC
  serviceLocator.registerFactory(() => NumberTriviaBloc(
      getConcreteNumberTrivia: serviceLocator(),
      getRandomNumberTrivia: serviceLocator(),
      inputConverter: serviceLocator()));

  // Use Cases
  serviceLocator
      .registerLazySingleton(() => GetConcreteNumberTrivia(serviceLocator()));
  serviceLocator
      .registerLazySingleton(() => GetRandomNumberTrivia(serviceLocator()));

  // Repository
  serviceLocator.registerLazySingleton<NumberTriviaRepository>(() =>
      NumberTriviaRepositoryImpl(
          remoteDataSource: serviceLocator(),
          localDataSource: serviceLocator(),
          networkInfo: serviceLocator()));

  // Data sources
  serviceLocator.registerLazySingleton<NumberTriviaRemoteDataSource>(
      () => NumberTriviaRemoteDataSourceImpl(client: serviceLocator()));
  serviceLocator.registerLazySingleton<NumberTriviaLocalDataSource>(() =>
      NumberTriviaLocalDataSourceImpl(sharedPreferences: serviceLocator()));
}

void initCore() {
  serviceLocator.registerLazySingleton(() => InputConverter());
  serviceLocator.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(serviceLocator()));
}

Future<void> initExternal() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton(() => sharedPreferences);
  serviceLocator.registerLazySingleton(() => http.Client());
  serviceLocator.registerLazySingleton(() => InternetConnectionChecker());
}
