import 'package:equatable/equatable.dart';
import 'package:sistem_admin/lecturer/domain/entities.dart';

/// Params for creating a [Lecturer]
final class CreateLecturerParams extends Equatable {
  /// Creates new [CreateLecturerParams]
  const new({
    required this.programId,
    required this.name,
    required this.pangkatGolongan,
  });

  /// ID of the affiliated program
  final String programId;

  /// Name for the lecturer
  final String name;

  /// Pangkat / golongan for the lecturer
  final String pangkatGolongan;

  @override
  List<Object?> get props => [programId, name, pangkatGolongan];
}
