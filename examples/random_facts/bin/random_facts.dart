import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:random_facts/random_facts.dart';

const _randomFactURL = "https://uselessfacts.jsph.pl/api/v2/facts/random";

void main() async {
  final client = http.Client();

  try {
    final uri = Uri.tryParse(_randomFactURL);

    if (uri == null) throw InvalidURIException(_randomFactURL);
    final response = await client.get(uri);

    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'Failed to fetch fact. Status: ${response.statusCode}',
      );
    }

    final fact = Fact.from(response.body);
    print('Fact: ${fact.text}');
    return;
  } on BaseException catch (error) {
    print("Error: ${error.message}");
  } catch (error, stackTrace) {
    print('Something went wrong, Unable to fetch random fact.');
    print(stackTrace);
  } finally {
    client.close();
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
