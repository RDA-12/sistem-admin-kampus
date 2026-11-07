import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course_schedule/presentation/models.dart';

/// Presentation card widget to display a single [CourseScheduleUI]
class CourseScheduleCard extends StatelessWidget {
  /// Creates new [CourseScheduleCard]
  const new({
    required this.schedule,
    this.onPressed,
    super.key,
  });

  /// The course schedule data to display
  final CourseScheduleUI schedule;

  /// Optional callback invoked when the card is pressed
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final startTime = schedule.start.timeFormat();
    final endTime = schedule.start.add(schedule.duration).timeFormat();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: context.color.primaryContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: context.color.primary.withValues(alpha: 0.3),
            ),
          ),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: [
                Text(
                  schedule.course.name,
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: .bold,
                    color: context.color.onPrimaryContainer,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$startTime - $endTime',
                  style: context.text.labelSmall?.copyWith(
                    color: context.color.onPrimaryContainer.withValues(
                      alpha: 0.8,
                    ),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${schedule.room.name} • ${schedule.cohort.name}',
                  style: context.text.labelSmall?.copyWith(
                    color: context.color.onPrimaryContainer.withValues(
                      alpha: 0.8,
                    ),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (schedule.lecturer.name.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    schedule.lecturer.name,
                    style: context.text.labelSmall?.copyWith(
                      color: context.color.onPrimaryContainer.withValues(
                        alpha: 0.8,
                      ),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
