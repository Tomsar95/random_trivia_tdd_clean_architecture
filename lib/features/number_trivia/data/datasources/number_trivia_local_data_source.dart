import 'dart:convert';
import 'package:clean_architecture_tdd_course/features/core/error/exceptions.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class NumberTriviaLocalDataSource {
  /// Gets the cached [NumberTriviaModel] which was gotten the last time
  /// the user had an internet connection.
  ///
  /// Throws [CacheException] if no cached data is present.
  Future<NumberTriviaModel>? getLastNumberTrivia();

  Future<void>? cacheNumberTrivia(NumberTriviaModel triviaToCache);
}

const cachedNumberTriviaKey = 'CACHED_NUMBER_TRIVIA';

class NumberTriviaLocalDataSourceImpl implements NumberTriviaLocalDataSource {
  final SharedPreferences sharedPreferences;

  NumberTriviaLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<NumberTriviaModel> getLastNumberTrivia() {
    final jsonString = sharedPreferences.getString(cachedNumberTriviaKey);
    if (jsonString != null) {
      return Future.value(NumberTriviaModel.fromJson(json.decode(jsonString)));
    } else {
      throw CacheException('cache is null');
    }
  }

  @override
  Future<void>? cacheNumberTrivia(NumberTriviaModel triviaToCache) {
    return sharedPreferences.setString(
        cachedNumberTriviaKey, json.encode(triviaToCache.toJson()));
  }
}
