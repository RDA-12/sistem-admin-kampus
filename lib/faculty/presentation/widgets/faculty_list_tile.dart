import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/faculty.dart';

/// Shows a [ListTile] with [Faculty] data
class FacultyListTile extends StatelessWidget {
  /// Creates new [FacultyListTile]
  const new({
    required this.faculty,
    this.onPressed,
    this.selected = false,
    super.key,
  });

  /// [Faculty] data that will be shown
  final Faculty faculty;

  /// Invoked when this faculty tile is pressed
  final VoidCallback? onPressed;

  /// Whether this tile is selected or not
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      selected: selected,
      title: Text(faculty.name),
      trailing: const Icon(Icons.chevron_right_rounded),
      onPressed: onPressed,
    );
  }
}
