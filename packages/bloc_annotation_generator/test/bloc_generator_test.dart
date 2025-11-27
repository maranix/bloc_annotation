import 'package:bloc_annotation_generator/src/generators/bloc_generator.dart';
import 'package:bloc_annotation_generator/src/generators/cubit_generator.dart';
import 'package:bloc_annotation_generator/src/generators/event_generator.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen_test/source_gen_test.dart';

Future<void> main() async {
  initializeBuildLogTracking();

  String packageRoot;

  if (p.current.contains('bloc_annotation_generator')) {
    packageRoot = p.current;
  } else {
    packageRoot = p.join(p.current, 'packages', 'bloc_annotation_generator');
  }

  final cubitReader = await initializeLibraryReaderForDirectory(
    p.join(packageRoot, 'test', 'src'),
    'test_cubit.dart',
  );

  final blocReader = await initializeLibraryReaderForDirectory(
    p.join(packageRoot, 'test', 'src'),
    'test_bloc.dart',
  );

  final eventReader = await initializeLibraryReaderForDirectory(
    p.join(packageRoot, 'test', 'src'),
    'test_event.dart',
  );

  testAnnotatedElements(cubitReader, CubitGenerator());
  testAnnotatedElements(blocReader, BlocGenerator());
  testAnnotatedElements(eventReader, EventGenerator());
}
