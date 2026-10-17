import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/academic_calendar/presentation/bloc/bloc.dart';
import 'package:sistem_admin/academic_calendar/presentation/widgets/academic_year_list_tile.dart';
import 'package:sistem_admin/common/common.dart';

/// Shows list of [AcademicYear] data
class AcademicYearsList extends StatelessWidget {
  /// Creates new [AcademicYearsList]
  ///
  /// It reacts to [AcademicYearsBloc]'s state changes.
  /// So, make sure to provide it with that bloc.
  const new({
    this.onPressed,
    this.onCreatePressed,
    this.selectedId,
    super.key,
  });

  /// ID of selected academic year
  final String? selectedId;

  /// Invoked when one of academic years is pressed
  final void Function(AcademicYear)? onPressed;

  /// Invoked when user press create button
  final void Function()? onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        Row(
          mainAxisAlignment: .end,
          children: [
            AppButton(
              label: 'Buat baru',
              onPressed: onCreatePressed,
            ),
          ],
        ),
        Expanded(
          child: BlocBuilder<AcademicYearsBloc, AcademicYearsState>(
            builder: (context, state) {
              switch (state) {
                case LoadingAcademicYears():
                case AcademicYearsInitial():
                  return const Center(
                    child: LoadingIndicator(size: 32),
                  );
                case AcademicYearsLoaded(:final data):
                  return ListView.separated(
                    itemCount: data.length,
                    separatorBuilder: (_, _) => const Divider(height: 4),
                    itemBuilder: (context, index) {
                      final academicYear = data[index];
                      return AcademicYearListTile(
                        academicYear: academicYear,
                        selected: academicYear.id == selectedId,
                        onPressed: onPressed == null
                            ? null
                            : () => onPressed!(academicYear),
                      );
                    },
                  );
                case AcademicYearsFailure(:final exception):
                  return Center(
                    child: AppExceptionBox(
                      title: 'Gagal mengambil data tahun akademik',
                      exception: exception,
                      onRetryPressed: () {
                        context.read<AcademicYearsBloc>().add(
                          const AcademicYearsSubscriptionRequested(),
                        );
                      },
                    ),
                  );
              }
            },
          ),
        ),
      ],
    );
  }
}
