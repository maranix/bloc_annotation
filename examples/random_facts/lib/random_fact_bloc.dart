import 'dart:io' show HttpStatus;

import 'package:http/http.dart' as http;

import 'package:bloc/bloc.dart';
import 'package:bloc_annotation/bloc_annotation.dart';
import 'package:random_facts/random_fact_model.dart';

part 'random_fact_bloc.g.dart';

const _randomFactURL = "https://uselessfacts.jsph.pl/api/v2/facts/random";

sealed class RandomFactEvent {
  const RandomFactEvent();

  factory RandomFactEvent.fetchRandomFact() = _FetchRandomFact;
}

final class _FetchRandomFact extends RandomFactEvent {
  const _FetchRandomFact();
}

@BlocClass<RandomFactEvent, List<Fact>>()
final class RandomFactBloc extends _$RandomFactBloc {
  RandomFactBloc({http.Client? client})
    : _client = client ?? http.Client(),
      super(const []) {
    on<_FetchRandomFact>(_onFetchRandomFact);
  }

  final http.Client _client;

  Fact? get latestFact => state.lastOrNull;

  List<Fact> get allFacts => state;

  void _onFetchRandomFact(
    _FetchRandomFact event,
    Emitter<List<Fact>> emit,
  ) async {
    try {
      final uri = Uri.tryParse(_randomFactURL);

      if (uri == null) throw InvalidURIException(_randomFactURL);
      final response = await _client.get(uri);

      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'Failed to fetch fact. Status: ${response.statusCode}',
        );
      }

      final fact = Fact.from(response.body);
      print('Fact Fetched: ${fact.text}');

      emit(List.from(state)..add(fact));
    } on BaseException catch (error) {
      print("Error: ${error.message}");
    } catch (error, stackTrace) {
      print('Something went wrong, Unable to fetch random fact.');
      print(stackTrace);
    }
  }

  @override
  Future<void> close() {
    _client.close();
    return super.close();
  }
}

sealed class BaseException implements Exception {
  const BaseException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class InvalidURIException extends BaseException {
  const InvalidURIException(String uri)
    : super('Invalid or malformed URI: $uri');
}

final class HttpException extends BaseException {
  const HttpException(super.message);
}
