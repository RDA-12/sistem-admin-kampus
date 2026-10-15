import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/lecturer/domain/entities.dart';
import 'package:sistem_admin/lecturer/domain/repository.dart';

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

/// Use case for creating new [Lecturer]
@LazySingleton(env: [Environment.prod])
class CreateLecturerUseCase
    with AppLoggerMixin
    implements FutureBaseUseCase<CreateLecturerParams, Lecturer> {
  /// Creates new [CreateLecturerUseCase]
  new({required this._lecturerRepository});

  final ILecturerRepository _lecturerRepository;

  /// Run creating new [Lecturer]
  @override
  Future<AppResult<Lecturer>> call(CreateLecturerParams params) async {
    logDebug(
      'start creating lecturer',
      extra: {
        'programId': params.programId,
        'name': params.name,
        'pangkatGolongan': params.pangkatGolongan,
      },
    );
    final result = await _lecturerRepository.save(params);
    switch (result) {
      case AppSuccess(:final data):
        logDebug('lecturer created');
        return AppResult.success(data);
      case AppFailure<Lecturer>(:final exception):
        logDebug('lecturer creation failed');
        return AppResult.failure(exception);
    }
  }
}
