import 'package:equatable/equatable.dart';
import 'package:sistem_admin/cohort/domain/entities.dart';

/// Params for updating a [Cohort]
final class UpdateCohortParams extends Equatable {
  /// Creates new [UpdateCohortParams]
  const new(
    this.cohort, {
    this.name,
    this.entryYear,
  });

  /// Cohort that will be updated
  final Cohort cohort;

  /// Updated name
  final String? name;

  /// Updated entry year
  final int? entryYear;

  @override
  List<Object?> get props => [cohort, name, entryYear];
}
