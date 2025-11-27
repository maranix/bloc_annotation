/// Properties described in [BaseAnnotation] from `bloc_annotation` package
typedef BaseAnnotationProperties = ({
  String name,
  bool copyWith,
  bool overrideEquality,
  bool overrideToString,
});

/// Properties described in [Cubit] annotaion from `bloc_annotation` package
typedef CubitAnnotationProperties = ({
  String name,
  bool copyWith,
  bool overrideEquality,
  bool overrideToString,
});

/// Properties described in [Bloc] annotaion from `bloc_annotation` package
typedef BlocAnnotationProperties = ({
  String name,
  bool copyWith,
  bool overrideEquality,
  bool overrideToString,
});

/// Record type for describing a attributes of a Class
///
/// ```dart
/// class Some {
///   final String attribute1;
///   final int attribute2;
///   final double attribute3;
/// }
/// ```
typedef ElementAttribute = ({String type, String name});
