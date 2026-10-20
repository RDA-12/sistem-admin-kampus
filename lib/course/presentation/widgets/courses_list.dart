import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course/domain/domain.dart';
import 'package:sistem_admin/course/presentation/bloc/bloc.dart';
import 'package:sistem_admin/course/presentation/widgets/course_list_tile.dart';

/// Shows list of [Course] data
class CoursesList extends StatelessWidget {
  /// Creates new [CoursesList]
  ///
  /// It reacts to [CoursesBloc]'s state changes.
  /// So, make sure to provide it with that bloc.
  const new({
    this.onPressed,
    this.onCreatePressed,
    this.selectedId,
    super.key,
  });

  /// ID of selected course
  final String? selectedId;

  /// Invoked when one of courses is pressed
  final void Function(Course)? onPressed;

  /// Invoked when user press create button
  final void Function()? onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        Row(
          mainAxisAlignment: .end,
          children: [
            AppButton(
              label: 'Buat baru',
              onPressed: onCreatePressed,
            ),
          ],
        ),
        Expanded(
          child: BlocBuilder<CoursesBloc, CoursesState>(
            builder: (context, state) {
              switch (state) {
                case LoadingCourses():
                case CoursesInitial():
                  return const Center(
                    child: LoadingIndicator(size: 32),
                  );
                case CoursesLoaded(:final data):
                  if (data.isEmpty) {
                    return const Center(
                      child: AppEmptyBox(
                        message: 'Belum ada data mata kuliah',
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: data.length,
                    separatorBuilder: (_, _) => const Divider(height: 4),
                    itemBuilder: (context, index) {
                      final course = data[index];
                      return CourseListTile(
                        course: course,
                        selected: course.id == selectedId,
                        onPressed: onPressed == null
                            ? null
                            : () {
                                onPressed!(course);
                              },
                      );
                    },
                  );
                case CoursesFailure(:final exception):
                  return Center(
                    child: AppExceptionBox(
                      title: 'Gagal mengambil data mata kuliah',
                      exception: exception,
                      onRetryPressed: () {
                        context.read<CoursesBloc>().add(
                          const CoursesSubscriptionRequested(),
                        );
                      },
                    ),
                  );
              }
            },
          ),
        ),
      ],
    );
  }
}
