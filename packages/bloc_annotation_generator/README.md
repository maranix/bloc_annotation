# bloc_annotation_generator

Code generator for `bloc_annotation`. This package processes `@BlocMeta`, `@CubitMeta`, `@EventMeta`, and `@StateMeta` annotations to generate boilerplate code for BLoC and Cubit classes.

## Features

- Generates BLoC classes with event handling logic.
- Generates Cubit classes.
- Generates Event classes (sealed class hierarchy).
- Generates `copyWith`, `toString`, `hashCode`, and `==` overrides for states and events (configurable).

## Getting started

Add `bloc_annotation_generator` to your `dev_dependencies`:

```yaml
dev_dependencies:
  bloc_annotation_generator: ^0.5.0
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

### Examples

#### BLoC with Explicit State Type (Recommended)

Input:

```dart
import 'package:bloc_annotation/bloc_annotation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'counter_bloc.g.dart';

@BlocMeta(state: int)
final class CounterBloc extends _$CounterBloc {
  CounterBloc() : super(0);

  @EventMeta()
  void increment() => emit(state + 1);

  @EventMeta()
  void decrement() => emit(state - 1);
}
```

Generated Output (`counter_bloc.g.dart`):

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter_bloc.dart';

sealed class CounterBlocEvent {}

class Increment extends CounterBlocEvent {
  const Increment();
}

class Decrement extends CounterBlocEvent {
  const Decrement();
}

abstract class _$CounterBloc extends Bloc<CounterBlocEvent, int> {
  _$CounterBloc(super.initialState) {
    on<Increment>((event, emit) => increment());
    on<Decrement>((event, emit) => decrement());
  }

  void increment();
  void decrement();
}
```

#### BLoC with Field-Based State Inference

Input:

```dart
import 'package:bloc_annotation/bloc_annotation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'counter_bloc.g.dart';

@BlocMeta()
final class CounterBloc extends _$CounterBloc {
  CounterBloc() : super(0);

  @StateMeta()
  // ignore: unused_field
  late final int _state;

  @EventMeta()
  void increment() => emit(state + 1);
}
```

#### Cubit with Explicit State Type (Recommended)

Input:

```dart
import 'package:bloc_annotation/bloc_annotation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'counter_cubit.g.dart';

@CubitMeta(state: int)
final class CounterCubit extends _$CounterCubit {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}
```

Generated Output (`counter_cubit.g.dart`):

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter_cubit.dart';

abstract class _$CounterCubit extends Cubit<int> {
  _$CounterCubit(super.initialState);
}
```

#### Cubit with Field-Based State Inference

Input:

```dart
import 'package:bloc_annotation/bloc_annotation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'counter_cubit.g.dart';

@CubitMeta()
final class CounterCubit extends _$CounterCubit {
  CounterCubit() : super(0);

  @StateMeta()
  // ignore: unused_field
  late final int _state;

  void increment() => emit(state + 1);
}
```

## State Inference Methods

There are two ways to specify the state type:

1. **Explicit State Parameter (Recommended):**
   ```dart
   @BlocMeta(state: int)
   @CubitMeta(state: int)
   ```
   - No linter warnings
   - Clear and explicit
   - Easier to read

2. **Field-Based Inference:**
   ```dart
   @StateMeta()
   // ignore: unused_field
   late final int _state;
   ```
   - Requires `// ignore: unused_field` comment
   - Useful when you want to keep state type close to the class definition
