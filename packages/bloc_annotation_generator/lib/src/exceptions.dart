import 'package:analyzer/dart/element/element.dart';

final class InvalidSourceElementException implements Exception {
  const InvalidSourceElementException({
    required this.got,
    required this.expected,
  });

  final Element got;
  final ElementKind expected;

  String get message =>
      'Invalid element ${got.kind.displayName}, expected ${expected.displayName}';

  @override
  String toString() => message;
}
