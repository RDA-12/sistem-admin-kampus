import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course/presentation/bloc/bloc.dart';
import 'package:sistem_admin/course/presentation/pages/course_detail_page.dart';
import 'package:sistem_admin/course/presentation/pages/create_course_page.dart';
import 'package:sistem_admin/course/presentation/widgets/widgets.dart';

/// Page to show courses data
class CoursesListPage extends StatelessWidget {
  /// Creates new [CoursesListPage]
  const new({
    this.onCoursePressed,
    this.onCreatePressed,
    super.key,
  });

  /// Invoked when a course is pressed
  final void Function(String courseId)? onCoursePressed;

  /// Invoked when create button is pressed
  final void Function()? onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<CoursesBloc>()..add(const CoursesSubscriptionRequested()),
      child: TwoPaneLayoutBuilder<String?>(
        initialAdditionalData: null,
        leftBuilder: (context, controller, breakPoint, constraints) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Daftar Mata Kuliah'),
            ),
            body: Padding(
              padding: AppSpacing.pagePadding,
              child: CoursesList(
                selectedId: controller.data == 'create'
                    ? null
                    : controller.data,
                onPressed: (course) {
                  final courseId = course.id;
                  if (breakPoint < BreakPoint.expanded) {
                    if (onCoursePressed != null) {
                      onCoursePressed?.call(courseId);
                    } else if (breakPoint == BreakPoint.compact) {
                      unawaited(
                        CourseDetailCompactRoute(courseId).push<void>(context),
                      );
                    } else {
                      unawaited(
                        CourseDetailRoute(courseId).push<void>(context),
                      );
                    }
                  } else {
                    controller.data = courseId;
                  }
                },
                onCreatePressed: () {
                  if (breakPoint < BreakPoint.expanded) {
                    if (onCreatePressed != null) {
                      onCreatePressed?.call();
                    } else if (breakPoint == BreakPoint.compact) {
                      unawaited(
                        const CreateCourseCompactRoute().push<void>(context),
                      );
                    } else {
                      unawaited(
                        const CreateCourseRoute().push<void>(context),
                      );
                    }
                  } else {
                    controller.data = 'create';
                  }
                },
              ),
            ),
          );
        },
        rightBuilder: (context, controller, breakPoint, constraints) {
          if (controller.data == null) return const SizedBox.shrink();
          if (controller.data == 'create') {
            return const CreateCoursePage();
          }
          return CourseDetailPage(
            key: ValueKey(controller.data!),
            id: controller.data!,
            onCourseDeleted: (_) {
              controller.data = null;
            },
          );
        },
      ),
    );
  }
}
