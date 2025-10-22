import 'package:analyzer/dart/element/element.dart';
import 'package:bloc_annotation/bloc_annotation.dart';
import 'package:bloc_annotation_generator/src/element_code_producer.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

final class StateClassGenerator extends GeneratorForAnnotation<StateClass> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final _ = ClassCodeProducer(element);

    return super.generateForAnnotatedElement(element, annotation, buildStep);
  }
}

final class StateEnumGenerator extends GeneratorForAnnotation<StateEnum> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    return super.generateForAnnotatedElement(element, annotation, buildStep);
  }
}
