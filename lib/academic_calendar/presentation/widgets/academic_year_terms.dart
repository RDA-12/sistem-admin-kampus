import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/academic_calendar/presentation/widgets/academic_term_list_tile.dart';
import 'package:sistem_admin/common/common.dart';

/// Shows list of [AcademicTerm] belonging to an academic year
class AcademicYearTerms extends StatelessWidget {
  /// Creates new [AcademicYearTerms]
  const new({
    required this.academicYear,
    required this.terms,
    this.onTermPressed,
    this.onAddTermPressed,
    super.key,
  });

  /// Parent [AcademicYear]
  final AcademicYear academicYear;

  /// List of [AcademicTerm] to show
  final List<AcademicTerm> terms;

  /// Invoked when one of terms is pressed
  final void Function(AcademicTerm)? onTermPressed;

  /// Invoked when user press add term button
  final void Function()? onAddTermPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Daftar Semester',
                style: context.text.titleMedium,
              ),
            ),
            AppButton(
              leadingIcon: const Icon(Icons.add_rounded),
              label: 'Tambah',
              onPressed: onAddTermPressed,
            ),
          ],
        ),
        if (terms.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text('Belum ada semester'),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              itemCount: terms.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final term = terms[index];
                return AcademicTermListTile(
                  academicTerm: term,
                  onPressed: onTermPressed == null
                      ? null
                      : () => onTermPressed!(term),
                );
              },
            ),
          ),
      ],
    );
  }
}
