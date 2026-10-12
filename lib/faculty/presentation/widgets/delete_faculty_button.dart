import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/domain/domain.dart';

/// Creates a Button that will show confirmation dialog
/// to delete the [faculty]
class DeleteFacultyButton extends StatelessWidget {
  /// Creates new [DeleteFacultyButton]
  const new({
    required this.faculty,
    this.onConfirmed,
    this.isDeleting = false,
    this.disable = false,
    super.key,
  });

  /// [Faculty] that will be deleted
  final Faculty faculty;

  /// Invoked when user confirmed to delete [faculty]
  final void Function()? onConfirmed;

  /// Whether the [faculty] is in deleting process or not
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
                title: 'Hapus ${faculty.name}',
                message:
                    'Data yang berhubungan dengan ${faculty.name} '
                    'akan tetap ada. Tapi, fakultas tersebut '
                    'tidak lagi bisa digunakan untuk proses lain',
              );
              if (!shouldDelete) return;
              onConfirmed?.call();
            },
    );
  }
}
