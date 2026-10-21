import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/cohort/domain/domain.dart';
import 'package:sistem_admin/common/common.dart';

/// Creates a Button that will show confirmation dialog
/// to delete the [cohort]
class DeleteCohortButton extends StatelessWidget {
  /// Creates new [DeleteCohortButton]
  const new({
    required this.cohort,
    this.onConfirmed,
    this.isDeleting = false,
    this.disable = false,
    super.key,
  });

  /// [Cohort] that will be deleted
  final Cohort cohort;

  /// Invoked when user confirmed to delete [cohort]
  final void Function()? onConfirmed;

  /// Whether the [cohort] is in deleting process or not
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
                title: 'Hapus ${cohort.name}',
                message:
                    'Data yang berhubungan dengan ${cohort.name} '
                    'akan tetap ada. Tapi, angkatan tersebut '
                    'tidak lagi bisa digunakan untuk proses lain',
              );
              if (!shouldDelete) return;
              onConfirmed?.call();
            },
    );
  }
}
