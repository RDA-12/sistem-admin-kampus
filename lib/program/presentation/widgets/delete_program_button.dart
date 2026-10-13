import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/program/domain/domain.dart';

/// Creates a Button that will show confirmation dialog
/// to delete the [program]
class DeleteProgramButton extends StatelessWidget {
  /// Creates new [DeleteProgramButton]
  const new({
    required this.program,
    this.onConfirmed,
    this.isDeleting = false,
    this.disable = false,
    super.key,
  });

  /// [Program] that will be deleted
  final Program program;

  /// Invoked when user confirmed to delete [program]
  final void Function()? onConfirmed;

  /// Whether the [program] is in deleting process or not
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
                title: 'Hapus ${program.name}',
                message:
                    'Data yang berhubungan dengan ${program.name} '
                    'akan tetap ada. Tapi, program studi tersebut '
                    'tidak lagi bisa digunakan untuk proses lain',
              );
              if (!shouldDelete) return;
              onConfirmed?.call();
            },
    );
  }
}
