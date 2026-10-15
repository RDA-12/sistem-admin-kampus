import 'package:equatable/equatable.dart';

/// Represent single Lecturer data
class Lecturer extends Equatable {
  /// Creates new [Lecturer]
  const new({
    required this.id,
    required this.programId,
    required this.name,
    required this.pangkatGolongan,
  });

  /// ID of this lecturer
  final String id;

  /// ID of the affiliated program
  final String programId;

  /// Name of this lecturer
  final String name;

  /// Pangkat/Golongan of this lecturer
  final String pangkatGolongan;

  @override
  List<Object?> get props => [id, programId, name, pangkatGolongan];
}
