import 'package:equatable/equatable.dart';
import 'package:sistem_admin/cohort/domain/entities.dart';

/// Params for creating a [Cohort]
final class CreateCohortParams extends Equatable {
  /// Creates new [CreateCohortParams]
  const new({
    required this.name,
    required this.entryYear,
  });

  /// Name of the cohort
  final String name;

  /// Entry year of the cohort
  final int entryYear;

  @override
  List<Object?> get props => [name, entryYear];
}
