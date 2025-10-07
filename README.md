# bloc_annotation

**bloc_annotation** is a complementary package designed to streamline BLoC code generation for Dart and Flutter applications. By leveraging code generation, this package accelerates development time & reduces boilerplate code writing and aims to improve overall developer experience while working with BLoC state management.


## Overview

- **bloc_annotation**  
  Defines annotation classes (`@Bloc`, `@Event`, `@State` & `@Cubit`) used to mark BLoC-related elements in your Dart/Flutter codebase.

- **bloc_annotation_gen**  
  Provides a code generator that processes annotations (via source_gen/build_runner) and generates boilerplate BLoC, Event, and State code automatically.


## Features

- **Reduce Boilerplate:**  
    - Generate Cubit, BLoC (classes, events, and states) with minimal manual effort.

- **Modern Architecture:**  
  Follows community patterns for annotation/codegen separation, inspired by `json_serializable`, `freezed` & `dart_mappable`.


## Installation

Add dependencies to your `pubspec.yaml`:

```yaml
    dependencies:
    bloc_annotation: ^0.1.0

    dev_dependencies:
    bloc_annotation_gen: ^0.1.0
    build_runner: ^2.4.0
```

Run:

```bash
    flutter pub get
```

---

## Usage

### 1. Annotate Your Classes

```dart
import 'package:bloc_annotation/bloc_annotation.dart';

@Bloc()
class CounterBloc {
    @State()
    state() => 0;

    @Event()
    void increment();

    @Event()
    void decrement();
}
```
### 2. Run Code Generation

```dart
    dart run build_runner build
    # or
    dart run build_runner build --delete-conflicting-outputs
    # or
    dart run build_runner watch
```

Generated files will appear alongside your annotated source code.


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
