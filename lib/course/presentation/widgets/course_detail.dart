import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course/domain/domain.dart';
import 'package:sistem_admin/course/presentation/bloc/bloc.dart';
import 'package:sistem_admin/course/presentation/widgets/course_form.dart';
import 'package:sistem_admin/program/program.dart';

/// Shows detail of a course
class CourseDetail extends StatelessWidget {
  /// Creates new [CourseDetail]
  ///
  /// It reacts to [CourseDetailBloc], [ProgramsBloc],
  /// and [CourseMutationBloc] state changes.
  /// So, ensure to provide it with that bloc.
  const new({
    this.onRetryPressed,
    this.onCourseDeleted,
    super.key,
  });

  /// Invoked when user press retry button
  final void Function()? onRetryPressed;

  /// Invoked when a course has been deleted
  final void Function(Course)? onCourseDeleted;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseDetailBloc, CourseDetailState>(
      builder: (context, state) {
        switch (state) {
          case CourseDetailInitial():
          case LoadingCourseDetail():
            return const Center(
              child: LoadingIndicator(),
            );
          case CourseDetailLoaded(:final course):
            return CourseForm(
              initial: course,
              onCourseDeleted: onCourseDeleted,
            );
          case CourseDetailLoadFailed(:final exception):
            return Center(
              child: AppExceptionBox(
                title: 'Gagal mengambil data mata kuliah',
                exception: exception,
                onRetryPressed: onRetryPressed,
              ),
            );
        }
      },
    );
  }
}
