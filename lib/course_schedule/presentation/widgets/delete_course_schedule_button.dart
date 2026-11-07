import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course_schedule/domain/domain.dart';

/// Creates a Button that will show confirmation dialog
/// to delete the [courseSchedule]
class DeleteCourseScheduleButton extends StatelessWidget {
  /// Creates new [DeleteCourseScheduleButton]
  const new({
    required this.courseSchedule,
    this.onConfirmed,
    this.isDeleting = false,
    this.disable = false,
    super.key,
  });

  /// [CourseSchedule] that will be deleted
  final CourseSchedule courseSchedule;

  /// Invoked when user confirmed to delete [courseSchedule]
  final void Function()? onConfirmed;

  /// Whether the [courseSchedule] is in deleting process or not
  final bool isDeleting;

  /// Disable the button when set this to true
  final bool disable;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      type: .text,
      color: .danger,
      leadingIcon: isDeleting
          ? const LoadingIndicator()
          : const Icon(Icons.close_rounded),
      label: 'Hapus',
      onPressed: disable
          ? null
          : () async {
              final shouldDelete = await context.showConfirmationDialog(
                title: 'Hapus ${courseSchedule.name}',
                message:
                    'Data yang berhubungan dengan ${courseSchedule.name} '
                    'akan tetap ada. Tapi, jadwal kuliah tersebut '
                    'tidak lagi bisa digunakan untuk proses lain',
              );
              if (!shouldDelete) return;
              onConfirmed?.call();
            },
    );
  }
}
