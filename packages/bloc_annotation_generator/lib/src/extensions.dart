import 'package:analyzer/dart/element/element.dart';
import 'package:bloc_annotation_generator/src/types.dart';
import 'package:source_gen/source_gen.dart';

extension ElementX on Element {
  bool kindOf(ElementKind ek) => kind == ek;

  bool get isClass => kind == ElementKind.CLASS;

  bool get isEnum => kind == ElementKind.ENUM;

  List<String> get genericParamaters => [];
}

// The following extension provides helpful methods to extract necessary annotation
// properties to reduce code repetition and mental overhead of working with [Annotation] properties.
//
// Each method must always be kept updated and in-sync with their respective Annotation counterpart
// described in `bloc_annotation` package and as well as [type] described in `types.dart` for
// consistency.
//
extension ConstantReaderAnnotationPropertiesX on ConstantReader {
  /// Extracts the [BaseAnnotation] properties from the given ConstantReader
  ///
  /// [BaseAnnotation] class is provided via `bloc_annotation` package. This class
  /// describes the commonly inherited properties used by the [Annotation]'s.
  BaseAnnotationProperties getBaseAnnotationProperties() => (
    name: read("name").stringValue,
    copyWith: read("copyWith").boolValue,
    overrideEquality: read("overrideEquality").boolValue,
    overrideToString: read("overrideToString").boolValue,
  );

  /// Extracts the [Cubit] annotation properties from the given ConstantReader
  ///
  /// [Cubit] annotation is provided via `bloc_annotation` package.
  CubitAnnotationProperties getCubitAnnotationProperties() {
    final baseProps = getBaseAnnotationProperties();
    final state = read('state').isNull
        ? null
        : read('state').typeValue.getDisplayString();

    return (
      name: baseProps.name,
      copyWith: baseProps.copyWith,
      overrideEquality: baseProps.overrideEquality,
      overrideToString: baseProps.overrideToString,
      state: state,
    );
  }

  /// Extracts the [Bloc] annotation properties from the given ConstantReader
  ///
  /// [Bloc] annotation is provided via `bloc_annotation` package.
  BlocAnnotationProperties getBlocAnnotationProperties() {
    final baseProps = getBaseAnnotationProperties();
    final state = read('state').isNull
        ? null
        : read('state').typeValue.getDisplayString();

    return (
      name: baseProps.name,
      copyWith: baseProps.copyWith,
      overrideEquality: baseProps.overrideEquality,
      overrideToString: baseProps.overrideToString,
      state: state,
    );
  }
}
