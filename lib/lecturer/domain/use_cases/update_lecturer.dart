import 'package:equatable/equatable.dart';
import 'package:sistem_admin/lecturer/domain/entities.dart';

/// Params for updating a [Lecturer]
final class UpdateLecturerParams extends Equatable {
  /// Creates new [UpdateLecturerParams]
  const new(
    this.lecturer, {
    this.name,
    this.pangkatGolongan,
    this.programId,
  });

  /// Lecturer that will be updated
  final Lecturer lecturer;

  /// Updated name
  final String? name;

  /// Updated pangkat / golongan
  final String? pangkatGolongan;

  /// Updated program ID
  final String? programId;

  @override
  List<Object?> get props => [lecturer, name, pangkatGolongan, programId];
}
