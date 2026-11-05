import 'package:equatable/equatable.dart';

/// Base class for all filters used in repositories
abstract class Filter extends Equatable {
  /// Creates new [Filter]
  const new();

  @override
  List<Object?> get props => [];
}

/// Represents an absence of filters for repositories that do not
/// support filtering
final class NoFilter extends Filter {
  /// Creates new [NoFilter]
  const new();
}
