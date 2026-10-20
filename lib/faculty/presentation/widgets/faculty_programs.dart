import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/program/program.dart';

/// Shows list of [Program] belonging to a faculty as a sliver
class FacultyPrograms extends StatelessWidget {
  /// Creates new [FacultyPrograms]
  const new({
    required this.programs,
    this.onPressed,
    super.key,
  });

  /// List of [Program] to show
  final List<Program> programs;

  /// Invoked when one of programs is pressed
  final void Function(Program)? onPressed;

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: programs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final program = programs[index];
        return AppListTile(
          title: Text(program.name),
          onPressed: onPressed == null ? null : () => onPressed!(program),
        );
      },
    );
  }
}
