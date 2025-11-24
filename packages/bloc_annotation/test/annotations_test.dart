import 'package:bloc_annotation/bloc_annotation.dart';
import 'package:test/test.dart';

void main() {
  group('BlocClass', () {
    test('default values', () {
      const annotation = BlocClass();
      expect(annotation.name, '');
      expect(annotation.copyWith, true);
      expect(annotation.overrideEquality, true);
      expect(annotation.overrideToString, true);
    });

    test('custom values', () {
      const annotation = BlocClass(
        name: 'MyBloc',
        copyWith: false,
        overrideEquality: false,
        overrideToString: false,
      );
      expect(annotation.name, 'MyBloc');
      expect(annotation.copyWith, false);
      expect(annotation.overrideEquality, false);
      expect(annotation.overrideToString, false);
    });
  });

  group('CubitClass', () {
    test('default values', () {
      const annotation = CubitClass();
      expect(annotation.name, '');
      expect(annotation.copyWith, true);
      expect(annotation.overrideEquality, true);
      expect(annotation.overrideToString, true);
    });

    test('custom values', () {
      const annotation = CubitClass(
        name: 'MyCubit',
        copyWith: false,
        overrideEquality: false,
        overrideToString: false,
      );
      expect(annotation.name, 'MyCubit');
      expect(annotation.copyWith, false);
      expect(annotation.overrideEquality, false);
      expect(annotation.overrideToString, false);
    });
  });

  group('EventClass', () {
    test('default values', () {
      const annotation = EventClass();
      expect(annotation.name, '');
      expect(annotation.copyWith, true);
      expect(annotation.overrideEquality, true);
      expect(annotation.overrideToString, true);
    });

    test('custom values', () {
      const annotation = EventClass(
        name: 'MyEvent',
        copyWith: false,
        overrideEquality: false,
        overrideToString: false,
      );
      expect(annotation.name, 'MyEvent');
      expect(annotation.copyWith, false);
      expect(annotation.overrideEquality, false);
      expect(annotation.overrideToString, false);
    });
  });
}
