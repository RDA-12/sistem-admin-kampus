import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/lecturer/domain/domain.dart';

/// Creates a Button that will show confirmation dialog
/// to delete the [lecturer]
class DeleteLecturerButton extends StatelessWidget {
  /// Creates new [DeleteLecturerButton]
  const new({
    required this.lecturer,
    this.onConfirmed,
    this.isDeleting = false,
    this.disable = false,
    super.key,
  });

  /// [Lecturer] that will be deleted
  final Lecturer lecturer;

  /// Invoked when user confirmed to delete [lecturer]
  final void Function()? onConfirmed;

  /// Whether the [lecturer] is in deleting process or not
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
                title: 'Hapus ${lecturer.name}',
                message:
                    'Data yang berhubungan dengan ${lecturer.name} '
                    'akan tetap ada. Tapi, dosen tersebut '
                    'tidak lagi bisa digunakan untuk proses lain',
              );
              if (!shouldDelete) return;
              onConfirmed?.call();
            },
    );
  }
}
