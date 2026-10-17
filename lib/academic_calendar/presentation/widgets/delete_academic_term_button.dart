import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/common/common.dart';

/// Creates a Button that will show confirmation dialog
/// to delete the [academicTerm]
class DeleteAcademicTermButton extends StatelessWidget {
  /// Creates new [DeleteAcademicTermButton]
  const new({
    required this.academicTerm,
    this.onConfirmed,
    this.isDeleting = false,
    this.disable = false,
    super.key,
  });

  /// [AcademicTerm] that will be deleted
  final AcademicTerm academicTerm;

  /// Invoked when user confirmed to delete [academicTerm]
  final void Function()? onConfirmed;

  /// Whether the [academicTerm] is in deleting process or not
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
                title: 'Hapus ${academicTerm.name}',
                message:
                    'Data yang berhubungan dengan ${academicTerm.name} '
                    'akan tetap ada. Tapi, semester tersebut '
                    'tidak lagi bisa digunakan untuk proses lain',
              );
              if (!shouldDelete) return;
              onConfirmed?.call();
            },
    );
  }
}
