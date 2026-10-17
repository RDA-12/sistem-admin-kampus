import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/common/common.dart';

/// Creates a Button that will show confirmation dialog
/// to delete the [academicYear]
class DeleteAcademicYearButton extends StatelessWidget {
  /// Creates new [DeleteAcademicYearButton]
  const new({
    required this.academicYear,
    this.onConfirmed,
    this.isDeleting = false,
    this.disable = false,
    super.key,
  });

  /// [AcademicYear] that will be deleted
  final AcademicYear academicYear;

  /// Invoked when user confirmed to delete [academicYear]
  final void Function()? onConfirmed;

  /// Whether the [academicYear] is in deleting process or not
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
                title: 'Hapus ${academicYear.name}',
                message:
                    'Data yang berhubungan dengan ${academicYear.name} '
                    'akan tetap ada. Tapi, tahun akademik tersebut '
                    'tidak lagi bisa digunakan untuk proses lain',
              );
              if (!shouldDelete) return;
              onConfirmed?.call();
            },
    );
  }
}
