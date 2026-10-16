import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course/domain/entities.dart';
import 'package:sistem_admin/course/domain/repository.dart';

/// Params for creating a [Course]
final class CreateCourseParams extends Equatable {
  /// Creates new [CreateCourseParams]
  const new({
    required this.programId,
    required this.code,
    required this.name,
    required this.semester,
    required this.credit,
  });

  /// ID of the affiliated program
  final String programId;

  /// Code for the course
  final String code;

  /// Name for the course
  final String name;

  /// Semester for the course
  final int semester;

  /// Weight / credit (SKS) for the course
  final int credit;

  @override
  List<Object?> get props => [programId, code, name, semester, credit];
}

/// Use case for creating new [Course]
@LazySingleton(env: [Environment.prod])
class CreateCourseUseCase
    with AppLoggerMixin
    implements FutureBaseUseCase<CreateCourseParams, Course> {
  /// Creates new [CreateCourseUseCase]
  new({required this._courseRepository});

  final ICourseRepository _courseRepository;

  /// Run creating new [Course]
  @override
  Future<AppResult<Course>> call(CreateCourseParams params) async {
    logDebug(
      'start creating course',
      extra: {
        'programId': params.programId,
        'code': params.code,
        'name': params.name,
        'semester': params.semester,
        'credit': params.credit,
      },
    );
    final result = await _courseRepository.save(params);
    switch (result) {
      case AppSuccess(:final data):
        logDebug('course created');
        return AppResult.success(data);
      case AppFailure<Course>(:final exception):
        logDebug('course creation failed');
        return AppResult.failure(exception);
    }
  }
}
