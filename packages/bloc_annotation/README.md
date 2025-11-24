# bloc_annotation

Annotations for the `bloc_annotation_generator` package. This package provides the annotations used to generate BLoC and Cubit classes, reducing boilerplate and improving developer experience.

## Features

- `@BlocClass`: Annotate your class to generate a BLoC.
- `@CubitClass`: Annotate your class to generate a Cubit.
- `@EventClass`: Annotate methods to generate BLoC events.

## Getting started

Add `bloc_annotation` to your `pubspec.yaml`:

```yaml
dependencies:
  bloc_annotation: ^1.0.0

dev_dependencies:
  bloc_annotation_generator: ^1.0.0
  build_runner: ^2.4.0
```

## Usage

### Annotating a BLoC

```dart
import 'package:bloc_annotation/bloc_annotation.dart';

@BlocClass(state: int)
class CounterBloc {
  @EventClass()
  void increment();

  @EventClass()
  void decrement();
}
```

### Annotating a Cubit

```dart
import 'package:bloc_annotation/bloc_annotation.dart';

@CubitClass(state: int)
class CounterCubit {
  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}
```
