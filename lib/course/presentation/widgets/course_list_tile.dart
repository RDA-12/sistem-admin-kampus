import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course/presentation/models.dart';

/// Shows a [ListTile] with [CourseUI] data
class CourseListTile extends StatelessWidget {
  /// Creates new [CourseListTile]
  const new({
    required this.course,
    this.onPressed,
    this.selected = false,
    super.key,
  });

  /// [CourseUI] data that will be shown
  final CourseUI course;

  /// Invoked when this course tile is pressed
  final VoidCallback? onPressed;

  /// Whether this tile is selected or not
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      selected: selected,
      title: Text(course.name),
      subtitle: Text(
        '${course.code} • ${course.credit} SKS • '
        'Semester ${course.semester} • ${course.program.name}',
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onPressed: onPressed,
    );
  }
}
