import 'package:bloc_annotation_generator/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('generateToString', () {
    test('generates correct string for class with state (default)', () {
      final fields = [(name: 'index', type: 'int')];
      final result = generateToString('MyClass', fields);
      expect(result, "'MyClass(index: \${state.index}, state: \$state)'");
    });

    test('generates correct string for class without state', () {
      final fields = [(name: 'index', type: 'int')];
      final result = generateToString('MyClass', fields, hasState: false);
      expect(result, "'MyClass(index: \$index)'");
    });

    test('generates correct string with escaped class name', () {
      final fields = [(name: 'index', type: 'int')];
      final result = generateToString('_\$MyClass', fields, hasState: false);
      expect(result, "'_\\\$MyClass(index: \$index)'");
    });

    test('generates correct string for empty fields', () {
      final result = generateToString('MyClass', []);
      expect(result, "'MyClass(state: \$state)'");
    });

    test('generates correct string for empty fields without state', () {
      final result = generateToString('MyClass', [], hasState: false);
      expect(result, "'MyClass()'");
    });
  });

  group('generateHashCode', () {
    test('generates correct hashCode for class with state (default)', () {
      final fields = [(name: 'index', type: 'int')];
      final result = generateHashCode(fields);
      expect(result, 'Object.hashAll([state.index])');
    });

    test('generates correct hashCode for class without state', () {
      final fields = [(name: 'index', type: 'int')];
      final result = generateHashCode(fields, hasState: false);
      expect(result, 'Object.hashAll([index])');
    });

    test('generates correct hashCode for empty fields', () {
      final result = generateHashCode([]);
      expect(result, 'state.hashCode');
    });

    test('generates correct hashCode for empty fields without state', () {
      final result = generateHashCode([], hasState: false);
      expect(result, '0');
    });
  });

  group('generateEquality', () {
    test('generates correct equality for class with state (default)', () {
      final fields = [(name: 'index', type: 'int')];
      final result = generateEquality('_\$MyClass', fields);
      expect(result, contains('other is _\$MyClass'));
      expect(result, contains('state.index == other.state.index'));
    });

    test('generates correct equality for class without state', () {
      final fields = [(name: 'index', type: 'int')];
      final result = generateEquality('_\$MyClass', fields, hasState: false);
      expect(result, contains('other is _\$MyClass'));
      expect(result, contains('index == other.index'));
    });

    test('generates correct equality for empty fields', () {
      final result = generateEquality('_\$MyClass', []);
      expect(result, contains('other is _\$MyClass'));
      expect(result, contains('other.state == state'));
    });

    test('generates correct equality for empty fields without state', () {
      final result = generateEquality('_\$MyClass', [], hasState: false);
      expect(result, contains('other is _\$MyClass'));
      expect(result, contains('true'));
    });
  });
}
