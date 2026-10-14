import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/program/program.dart';

/// Shows a [ListTile] with [Program] data
class ProgramListTile extends StatelessWidget {
  /// Creates new [ProgramListTile]
  const new({
    required this.program,
    this.onPressed,
    this.selected = false,
    super.key,
  });

  /// [Program] data that will be shown
  final ProgramUI program;

  /// Invoked when this program tile is pressed
  final VoidCallback? onPressed;

  /// Whether this tile is selected or not
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      selected: selected,
      title: Text(program.name),
      subtitle: Chip(
        label: Text(program.faculty.name),
        backgroundColor: context.color.primaryContainer,
        color: WidgetStatePropertyAll(context.color.onPrimaryContainer),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onPressed: onPressed,
    );
  }
}
