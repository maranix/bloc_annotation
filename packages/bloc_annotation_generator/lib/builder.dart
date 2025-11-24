import 'package:bloc_annotation_generator/src/configuration.dart';
import 'package:bloc_annotation_generator/src/generators/bloc_generator.dart';
import 'package:bloc_annotation_generator/src/generators/cubit_generator.dart';
import 'package:bloc_annotation_generator/src/generators/event_generator.dart';
import 'package:bloc_annotation_generator/src/generators/state_generator.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

Builder blocAnnotationGenerator(BuilderOptions options) {
  final config = GeneratorConfig.fromOptions(options);
  return SharedPartBuilder(
    [
      BlocGenerator(config),
      CubitGenerator(config),
      StateGenerator(config),
      EventGenerator(config),
    ],
    'bloc_annotation_generator',
  );
}
