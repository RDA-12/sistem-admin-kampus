import 'package:equatable/equatable.dart';

/// Represent single Cohort data
class Cohort extends Equatable {
  /// Creates new [Cohort]
  const new({
    required this.id,
    required this.name,
    required this.entryYear,
  });

  /// ID of this cohort
  final String id;

  /// Name of this cohort
  final String name;

  /// Entry year of this cohort
  final int entryYear;

  @override
  List<Object?> get props => [id, name, entryYear];
}
