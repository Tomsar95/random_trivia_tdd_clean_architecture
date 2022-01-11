import 'package:clean_architecture_tdd_course/features/core/error/exceptions.dart';
import 'package:clean_architecture_tdd_course/features/core/error/failures.dart';
import 'package:clean_architecture_tdd_course/features/core/network/network_info.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late NumberTriviaRepositoryImplementation repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImplementation(
        remoteDataSource: mockRemoteDataSource,
        localDataSource: mockLocalDataSource,
        networkInfo: mockNetworkInfo);
  });

  void runTestsOnline(Function body) {
    group('Device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      body();
    });
  }

  void runTestsOffline(Function body) {
    group('Device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      body();
    });
  }

  group(('Get concrete number trivia'), () {
    const tNumber = 1;
    const tNumberTriviaModel =
    NumberTriviaModel(text: 'test trivia', number: tNumber);
    const NumberTrivia tNumberTrivia = tNumberTriviaModel;

    // TODO: Check this test with null safety (! operator)
    test('Should check if the device is online', () async {
      //arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      //act
      await repository.getConcreteNumberTrivia(tNumber);
      //assert
      verify(() => mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test(
          'should return remote data when the call to remote data source is successful',
              () async {
            // arrange
            when(() => mockRemoteDataSource.getConcreteNumberTrivia(any()))
                .thenAnswer((_) async => tNumberTriviaModel);
            // act
            final result = await repository.getConcreteNumberTrivia(tNumber);
            // assert
            verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
            expect(result, equals(const Right(tNumberTrivia)));
          });

      test(
          'should cache the data locally when the call to remote data source is successful',
              () async {
            // arrange
            when(() => mockRemoteDataSource.getConcreteNumberTrivia(any()))
                .thenAnswer((_) async => tNumberTriviaModel);
            // act
            await repository.getConcreteNumberTrivia(tNumber);
            // assert
            verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
            verify(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
          });

      test(
          'should return server failure when the call to remote data source is unsuccessful',
              () async {
            // arrange
            when(() => mockRemoteDataSource.getConcreteNumberTrivia(any()))
                .thenThrow(ServerException('server failure'));
            // act
            final result = await repository.getConcreteNumberTrivia(tNumber);
            // assert
            verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
            verifyZeroInteractions(mockLocalDataSource);
            expect(result, equals(Left(ServerFailure())));
          });
    });

    runTestsOffline(() {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
    });

    test('Should return last locally cached data when the cached data is present',
            () async {
          //arrange
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          //act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          //assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(const Right(tNumberTrivia)));
        });

    test('Should return CacheFailure when there is no cached data present',
            () async {
          //arrange
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException('No cached data present'));
          //act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          //assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Left(CacheFailure())));
        });
  });

  group(('Get Random number trivia'), () {
    const tNumberTriviaModel =
    NumberTriviaModel(text: 'test trivia', number: 123);
    const NumberTrivia tNumberTrivia = tNumberTriviaModel;

    // TODO: Check this test with null safety (! operator)
    test('Should check if the device is online', () async {
      //arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      //act
      await repository.getRandomNumberTrivia();
      //assert
      verify(() => mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test(
          'should return remote data when the call to remote data source is successful',
              () async {
            // arrange
            when(() => mockRemoteDataSource.getRandomNumberTrivia())
                .thenAnswer((_) async => tNumberTriviaModel);
            // act
            final result = await repository.getRandomNumberTrivia();
            // assert
            verify(() => mockRemoteDataSource.getRandomNumberTrivia());
            expect(result, equals(const Right(tNumberTrivia)));
          });

      test(
          'should cache the data locally when the call to remote data source is successful',
              () async {
            // arrange
            when(() => mockRemoteDataSource.getRandomNumberTrivia())
                .thenAnswer((_) async => tNumberTriviaModel);
            // act
            await repository.getRandomNumberTrivia();
            // assert
            verify(() => mockRemoteDataSource.getRandomNumberTrivia());
            verify(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
          });

      test(
          'should return server failure when the call to remote data source is unsuccessful',
              () async {
            // arrange
            when(() => mockRemoteDataSource.getRandomNumberTrivia())
                .thenThrow(ServerException('server failure'));
            // act
            final result = await repository.getRandomNumberTrivia();
            // assert
            verify(() => mockRemoteDataSource.getRandomNumberTrivia());
            verifyZeroInteractions(mockLocalDataSource);
            expect(result, equals(Left(ServerFailure())));
          });
    });

    runTestsOffline(() {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
    });

    test('Should return last locally cached data when the cached data is present',
            () async {
          //arrange
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          //act
          final result = await repository.getRandomNumberTrivia();
          //assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(const Right(tNumberTrivia)));
        });

    test('Should return CacheFailure when there is no cached data present',
            () async {
          //arrange
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException('No cached data present'));
          //act
          final result = await repository.getRandomNumberTrivia();
          //assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Left(CacheFailure())));
        });
  });
}
