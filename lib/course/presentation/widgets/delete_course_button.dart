import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course/domain/domain.dart';

/// Creates a Button that will show confirmation dialog
/// to delete the [course]
class DeleteCourseButton extends StatelessWidget {
  /// Creates new [DeleteCourseButton]
  const new({
    required this.course,
    this.onConfirmed,
    this.isDeleting = false,
    this.disable = false,
    super.key,
  });

  /// [Course] that will be deleted
  final Course course;

  /// Invoked when user confirmed to delete [course]
  final void Function()? onConfirmed;

  /// Whether the [course] is in deleting process or not
  final bool isDeleting;

  /// Disable the button when set this to true
  final bool disable;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      type: AppButtonType.text,
      color: AppButtonColor.danger,
      leadingIcon: isDeleting
          ? const LoadingIndicator()
          : const Icon(Icons.close_rounded),
      label: 'Hapus',
      onPressed: disable
          ? null
          : () async {
              final shouldDelete = await context.showConfirmationDialog(
                title: 'Hapus ${course.name}',
                message:
                    'Data yang berhubungan dengan ${course.name} '
                    'akan tetap ada. Tapi, mata kuliah tersebut '
                    'tidak lagi bisa digunakan untuk proses lain',
              );
              if (!shouldDelete) return;
              onConfirmed?.call();
            },
    );
  }
}
