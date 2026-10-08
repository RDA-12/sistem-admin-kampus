import 'package:equatable/equatable.dart';

/// Represent single Faculty data
class Faculty extends Equatable {
  /// Creates new [Faculty]
  const new({required this.id, required this.name});

  /// ID of this faculty
  final String id;

  /// Name of this faculty
  final String name;

  @override
  List<Object?> get props => [id, name];
}
