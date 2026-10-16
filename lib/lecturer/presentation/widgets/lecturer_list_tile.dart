import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/lecturer/presentation/models.dart';

/// Shows a [ListTile] with [LecturerUI] data
class LecturerListTile extends StatelessWidget {
  /// Creates new [LecturerListTile]
  const new({
    required this.lecturer,
    this.onPressed,
    this.selected = false,
    super.key,
  });

  /// [LecturerUI] data that will be shown
  final LecturerUI lecturer;

  /// Invoked when this lecturer tile is pressed
  final VoidCallback? onPressed;

  /// Whether this tile is selected or not
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      selected: selected,
      title: Text(lecturer.name),
      subtitle: Text('${lecturer.pangkatGolongan} • ${lecturer.program.name}'),
      trailing: const Icon(Icons.chevron_right_rounded),
      onPressed: onPressed,
    );
  }
}
