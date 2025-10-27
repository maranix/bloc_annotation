import 'dart:convert';

import 'package:bloc_annotation/bloc_annotation.dart';

final class Fact {
  const Fact({
    required this.id,
    required this.text,
    required this.source,
    required this.sourceUrl,
    required this.language,
    required this.permaLink,
  });

  final String id;
  final String text;
  final String source;
  final String sourceUrl;
  final String language;
  final String permaLink;

  factory Fact.from(dynamic body) {
    Map<String, dynamic> json = {};

    if (body is String) {
      json = jsonDecode(body);
    }

    if (json case {
      'id': String id,
      'text': String text,
      'source': String source,
      'source_url': String sourceUrl,
      'language': String language,
      'permalink': String permaLink,
    }) {
      return Fact(
        id: id,
        text: text,
        source: source,
        sourceUrl: sourceUrl,
        language: language,
        permaLink: permaLink,
      );
    }

    throw FormatException(
      'Invalid server response, Unable to decode body into Fact model.\nExpected: Map<String, dynamic>\tGot: ${body.runtimeType}',
      body,
    );
  }
}

@StateEnum()
enum RandomFactStatesEnum {
  initial(),
  loading(),
  loaded._(Attributes.of({AttributeValue(name: 'fact', type: Fact)})),
  failure();

  /// The data associated with this state (if any).
  final Attributes data;

  /// Default constructor — creates a state with no data.
  const RandomFactStatesEnum() : data = const Attributes();

  /// Internal constructor for variants that carry data.
  const RandomFactStatesEnum._(this.data);
}
