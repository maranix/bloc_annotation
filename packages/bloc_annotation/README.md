# bloc_annotation

Annotations for the `bloc_annotation_generator` package. This package provides the annotations used to generate BLoC and Cubit classes, reducing boilerplate and improving developer experience.

## Features

- `@Bloc`: Annotate your class to generate a BLoC.
- `@Cubit`: Annotate your class to generate a Cubit.
- `@Event`: Annotate methods to generate BLoC events.
- `@State`: Annotate a method or field to define the state type.

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

@Bloc()
class CounterBloc {
  @State()
  int state() => 0;

  @Event()
  void increment();

  @Event()
  void decrement();
}
```

### Annotating a Cubit

```dart
import 'package:bloc_annotation/bloc_annotation.dart';

@Cubit()
class CounterCubit {
  @State()
  int state() => 0;

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}
```
