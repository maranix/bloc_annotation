import 'package:build/build.dart';

/// {@template generator_config}
/// Configuration for the `bloc_annotation_generator` builders.
///
/// These options can be configured globally in `build.yaml`.
/// {@endtemplate}
class GeneratorConfig {
  /// {@macro generator_config}
  const GeneratorConfig({
    this.copyWith = true,
    this.overrideToString = true,
    this.overrideEquality = true,
  });

  /// Creates a [GeneratorConfig] from [BuilderOptions].
  factory GeneratorConfig.fromOptions(BuilderOptions options) {
    final config = options.config;
    return GeneratorConfig(
      copyWith: config['copyWith'] as bool? ?? true,
      overrideToString: config['overrideToString'] as bool? ?? true,
      overrideEquality: config['overrideEquality'] as bool? ?? true,
    );
  }

  /// Whether to generate `copyWith` methods.
  ///
  /// Default: `true`
  final bool copyWith;

  /// Whether to override `toString`.
  ///
  /// Default: `true`
  final bool overrideToString;

  /// Whether to override `operator ==` and `hashCode`.
  ///
  /// Default: `true`
  final bool overrideEquality;
}
