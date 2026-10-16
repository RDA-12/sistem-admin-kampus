import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course/domain/entities.dart';
import 'package:sistem_admin/course/domain/repository.dart';

/// Params for updating a [Course]
final class UpdateCourseParams extends Equatable {
  /// Creates new [UpdateCourseParams]
  const new(
    this.course, {
    this.code,
    this.name,
    this.semester,
    this.credit,
    this.programId,
  });

  /// Course that will be updated
  final Course course;

  /// Updated code
  final String? code;

  /// Updated name
  final String? name;

  /// Updated semester
  final int? semester;

  /// Updated weight / credit (SKS)
  final int? credit;

  /// Updated program ID
  final String? programId;

  @override
  List<Object?> get props => [course, code, name, semester, credit, programId];
}

/// Use case for updating a [Course]
@LazySingleton(env: [Environment.prod])
class UpdateCourseUseCase
    with AppLoggerMixin
    implements FutureBaseUseCase<UpdateCourseParams, Course> {
  /// Creates new [UpdateCourseUseCase]
  new({required this._courseRepository});

  final ICourseRepository _courseRepository;

  @override
  Future<AppResult<Course>> call(UpdateCourseParams params) async {
    logDebug(
      'start updating course',
      extra: {
        'id': params.course.id,
        'code': params.code,
        'name': params.name,
        'semester': params.semester,
        'credit': params.credit,
        'programId': params.programId,
      },
    );
    final result = await _courseRepository.update(
      params.course.id,
      args: params,
    );
    switch (result) {
      case AppSuccess(:final data):
        logDebug('course updated');
        return AppResult.success(data);
      case AppFailure<Course>(:final exception):
        logDebug('course update failed');
        return AppResult.failure(exception);
    }
  }
}
