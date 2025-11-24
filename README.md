# bloc_annotation

**bloc_annotation** is a complementary package designed to streamline BLoC code generation for Dart and Flutter applications. By leveraging code generation, this package accelerates development time, reduces boilerplate code writing, and aims to improve overall developer experience while working with BLoC state management.

## Overview

- **bloc_annotation**  
  Defines annotation classes (`@BlocClass`, `@CubitClass`, `@EventClass`) used to mark BLoC-related elements in your Dart/Flutter codebase.

- **bloc_annotation_generator**  
  Provides a code generator that processes annotations (via source_gen/build_runner) and generates boilerplate BLoC, Event, and State code automatically.

## Features

- **Reduce Boilerplate:**  
    - Generate Cubit, BLoC (classes, events, and states) with minimal manual effort.
    - Automatically wire up events to handler methods.

- **Modern Architecture:**  
  Follows community patterns for annotation/codegen separation, inspired by `json_serializable`, `freezed` & `dart_mappable`.

## Installation

Add dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  bloc_annotation: ^0.5.0
  flutter_bloc: ^8.1.3 # or bloc

dev_dependencies:
  bloc_annotation_generator: ^0.5.0
  build_runner: ^2.4.0
```

Run:

```bash
flutter pub get
```

---

## Usage

### 1. Annotate Your Classes

#### BLoC Example

```dart
import 'package:bloc_annotation/bloc_annotation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'counter_bloc.g.dart';

@BlocClass(state: int)
final class CounterBloc extends _$CounterBloc {
  CounterBloc() : super(0);

  @EventClass()
  void increment() => emit(state + 1);

  @EventClass()
  void decrement() => emit(state - 1);
}
```

#### Cubit Example

```dart
import 'package:bloc_annotation/bloc_annotation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'counter_cubit.g.dart';

@CubitClass(state: int)
final class CounterCubit extends _$CounterCubit {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}
```

### 2. Run Code Generation

```bash
dart run build_runner build
# or
dart run build_runner build --delete-conflicting-outputs
# or
dart run build_runner watch
```

### 3. Configuration

The generator supports global configuration options in `build.yaml` (e.g., enabling/disabling `copyWith`, `toString`, `equality`). See the [bloc_annotation_generator README](packages/bloc_annotation_generator/README.md#configuration) for details.

Generated files will appear alongside your annotated source code.

**Note:** Requires `// ignore: unused_field` comment to suppress linter warnings.

## Example

See the [`example/`](example/) directory for a full working sample, including annotated class definitions and generated output.

## Contributing

We welcome pull requests, issues, and feature suggestions!  
See [`CONTRIBUTING.md`](CONTRIBUTING.md) for guidelines.

## License

MIT License.  
See [`LICENSE`](https://github.com/Myrkheimr/bloc_annotation) for details.

## Credits
- Dart/Flutter community's efforts on building amazing code generation packages.
- BLoC package by felangel.
