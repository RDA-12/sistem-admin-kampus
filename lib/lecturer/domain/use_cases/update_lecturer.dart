import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/lecturer/domain/entities.dart';
import 'package:sistem_admin/lecturer/domain/repository.dart';

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

/// Use case for updating a [Lecturer]
@LazySingleton(env: [Environment.prod])
class UpdateLecturerUseCase
    with AppLoggerMixin
    implements FutureBaseUseCase<UpdateLecturerParams, Lecturer> {
  /// Creates new [UpdateLecturerUseCase]
  new({required this._lecturerRepository});

  final ILecturerRepository _lecturerRepository;

  @override
  Future<AppResult<Lecturer>> call(UpdateLecturerParams params) async {
    logDebug(
      'start updating lecturer',
      extra: {
        'id': params.lecturer.id,
        'name': params.name,
        'pangkatGolongan': params.pangkatGolongan,
        'programId': params.programId,
      },
    );
    final result = await _lecturerRepository.update(
      params.lecturer.id,
      args: params,
    );
    switch (result) {
      case AppSuccess(:final data):
        logDebug('lecturer updated');
        return AppResult.success(data);
      case AppFailure<Lecturer>(:final exception):
        logDebug('lecturer update failed');
        return AppResult.failure(exception);
    }
  }
}
