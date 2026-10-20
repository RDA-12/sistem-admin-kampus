import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';

/// Shows list of [Lecturer] belonging to a program as a sliver
class ProgramLecturersList extends StatelessWidget {
  /// Creates new [ProgramLecturersList]
  const new({
    required this.lecturers,
    this.onPressed,
    super.key,
  });

  /// List of [Lecturer] to show
  final List<Lecturer> lecturers;

  /// Invoked when one of lecturers is pressed
  final void Function(Lecturer)? onPressed;

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: lecturers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final lecturer = lecturers[index];
        return AppListTile(
          title: Text(lecturer.name),
          subtitle: Text(lecturer.pangkatGolongan),
          onPressed: onPressed == null ? null : () => onPressed!(lecturer),
        );
      },
    );
  }
}
