import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/common/common.dart';

/// Shows a [ListTile] with [AcademicCalendarEvent] data
class AcademicCalendarEventListTile extends StatelessWidget {
  /// Creates new [AcademicCalendarEventListTile]
  const new({
    required this.event,
    this.onPressed,
    this.selected = false,
    super.key,
  });

  /// [AcademicCalendarEvent] data that will be shown
  final AcademicCalendarEvent event;

  /// Invoked when this academic calendar event tile is pressed
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
    final start = _formatDate(event.start.date);
    final end = _formatDate(event.end.date);

    return AppListTile(
      selected: selected,
      title: Text(event.name),
      subtitle: Text('${event.type.label} • $start - $end'),
      trailing: const Icon(Icons.chevron_right_rounded),
      onPressed: onPressed,
    );
  }
}
