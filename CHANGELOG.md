# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2025-11-24

### Added
- **Annotations**: Introduced `@BlocClass`, `@CubitClass`, and `@EventClass` annotations for defining BLoC components.
- **Generators**: Added code generators for BLoC, Cubit, and Event classes.
- **Configuration**: Added global configuration support in `build.yaml` for customizing generated code (e.g., `copyWith`, `toString`, `equality`).
- **Event Generation**: Added `EventGenerator` to automatically generate sealed event class hierarchies.
- **Documentation**: Added comprehensive READMEs, `CONTRIBUTING.md`, and usage examples.

### Changed
- **Breaking**: Renamed `@BlocMeta` to `@BlocClass`, `@CubitMeta` to `@CubitClass`, and `@EventMeta` to `@EventClass`.

### Removed
- **Breaking**: Removed `@StateMeta` annotation and its associated generator. State type is now inferred from generics or defined explicitly.
