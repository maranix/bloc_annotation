# bloc_annotation_generator

Code generator for `bloc_annotation`. This package processes `@Bloc`, `@Cubit`, `@Event`, and `@State` annotations to generate boilerplate code for BLoC and Cubit classes.

## Features

- Generates BLoC classes with event handling logic.
- Generates Cubit classes.
- Generates Event classes (sealed class hierarchy).
- Generates `copyWith`, `toString`, `hashCode`, and `==` overrides for states and events (configurable).

## Getting started

Add `bloc_annotation_generator` to your `dev_dependencies`:

```yaml
dev_dependencies:
  bloc_annotation_generator: ^1.0.0
  build_runner: ^2.4.0
```

## Usage

Run the build runner to generate code:

```bash
dart run build_runner build
```

Or watch for changes:

```bash
dart run build_runner watch
```

### Configuration

You can configure the generator globally in your `build.yaml` file. The following options are available:

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `copyWith` | `bool` | `true` | Generates `copyWith` method for the class. |
| `overrideToString` | `bool` | `true` | Overrides `toString` method. |
| `overrideEquality` | `bool` | `true` | Overrides `operator ==` and `hashCode`. |

**Example `build.yaml`:**

```yaml
targets:
  $default:
    builders:
      bloc_annotation_generator:
        options:
          copyWith: true
          overrideToString: false
          overrideEquality: true
```

### Example

Input:

```dart
import 'package:bloc_annotation/bloc_annotation.dart';

part 'counter_bloc.g.dart';

@Bloc()
class CounterBloc {
  @State()
  int state() => 0;

  @Event()
  void increment();
}
```

Generated Output (`counter_bloc.g.dart`):

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter_bloc.dart';

sealed class CounterBlocEvent {
  const CounterBlocEvent();
}

class Increment extends CounterBlocEvent {
  const Increment();
}

abstract class _$CounterBloc extends Bloc<CounterBlocEvent, int> {
  _$CounterBloc(super.initialState) {
    on<Increment>((event, emit) => increment());
  }

  void increment();
}
```
