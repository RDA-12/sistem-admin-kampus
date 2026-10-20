import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course/course.dart';

/// Shows list of [Course] belonging to a program as a sliver
class ProgramCoursesList extends StatelessWidget {
  /// Creates new [ProgramCoursesList]
  const new({
    required this.courses,
    this.onPressed,
    super.key,
  });

  /// List of [Course] to show
  final List<Course> courses;

  /// Invoked when one of courses is pressed
  final void Function(Course)? onPressed;

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: courses.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final course = courses[index];
        return AppListTile(
          title: Text(course.name),
          subtitle: Text(
            '${course.code} • ${course.credit} SKS • '
            'Semester ${course.semester}',
          ),
          onPressed: onPressed == null ? null : () => onPressed!(course),
        );
      },
    );
  }
}
