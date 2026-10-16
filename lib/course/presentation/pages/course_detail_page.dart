import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course/domain/domain.dart';
import 'package:sistem_admin/course/presentation/bloc/bloc.dart';
import 'package:sistem_admin/course/presentation/widgets/widgets.dart';
import 'package:sistem_admin/program/program.dart';

/// Page to show [Course] data
class CourseDetailPage extends StatelessWidget {
  /// Creates new [CourseDetailPage]
  const new({
    required this.id,
    this.onCourseDeleted,
    super.key,
  });

  /// ID of the [Course] that will be shown
  final String id;

  /// Invoked when a [Course] has been deleted
  final void Function(Course)? onCourseDeleted;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<CourseDetailBloc>()
                ..add(CourseDetailSubscriptionRequested(id: id)),
        ),
        BlocProvider(
          create: (context) => getIt<CourseMutationBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<ProgramsBloc>(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detail Mata Kuliah'),
        ),
        body: Padding(
          padding: AppSpacing.pagePadding,
          child: Builder(
            builder: (context) {
              return CourseDetail(
                onCourseDeleted: onCourseDeleted,
                onRetryPressed: () {
                  context.read<CourseDetailBloc>().add(
                    CourseDetailSubscriptionRequested(id: id),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
