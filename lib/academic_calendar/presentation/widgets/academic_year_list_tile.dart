import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/common/common.dart';

/// Shows a [ListTile] with [AcademicYear] data
class AcademicYearListTile extends StatelessWidget {
  /// Creates new [AcademicYearListTile]
  const new({
    required this.academicYear,
    this.onPressed,
    this.selected = false,
    super.key,
  });

  /// [AcademicYear] data that will be shown
  final AcademicYear academicYear;

  /// Invoked when this academic year tile is pressed
  final VoidCallback? onPressed;

  /// Whether this tile is selected or not
  final bool selected;

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$d/$m/$y';
  }

  @override
  Widget build(BuildContext context) {
    final start = _formatDate(academicYear.startDate);
    final end = _formatDate(academicYear.endDate);

    return AppListTile(
      selected: selected,
      title: Text(academicYear.name),
      subtitle: Text('$start - $end'),
      trailing: const Icon(Icons.chevron_right_rounded),
      onPressed: onPressed,
    );
  }
}
