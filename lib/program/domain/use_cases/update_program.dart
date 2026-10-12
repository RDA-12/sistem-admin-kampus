import 'package:equatable/equatable.dart';
import 'package:sistem_admin/program/domain/entities.dart';

/// Params for updating a [Program]
final class UpdateProgramParams extends Equatable {
  /// Creates new [UpdateProgramParams]
  const new(this.program, {required this.name});

  /// Program that will be updated
  final Program program;

  /// Updated name
  final String? name;

  @override
  List<Object?> get props => [program, name];
}
