import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/academic_calendar/presentation/bloc/bloc.dart';
import 'package:sistem_admin/common/common.dart';

/// Controller for [AcademicYearSelector]
final class AcademicYearSelectorController
    extends AppSelectorController<AcademicYear> {
  /// Creates new [AcademicYearSelectorController] with [initial] selected
  new({super.initial, super.initialItems})
    : super(itemAsString: (it) => it.name);
}

/// Selector to select an [AcademicYear]
class AcademicYearSelector extends StatelessWidget {
  /// Creates new [AcademicYearSelector]
  ///
  /// It reacts to [AcademicYearsBloc]'s state changes.
  /// So, make sure to provide it with that bloc.
  const new({
    required this.label,
    required this.controller,
    super.key,
  });

  /// Controls the [AcademicYear] being selected
  final AcademicYearSelectorController controller;

  /// Label for this academic year selector
  final String label;

  void _syncState(AcademicYearsState state) {
    switch (state) {
      case AcademicYearsInitial():
      case LoadingAcademicYears():
        controller.isLoading = true;
        controller.exception = null;
      case AcademicYearsLoaded(:final data):
        controller.isLoading = false;
        controller.exception = null;
        controller.items = data;
      case AcademicYearsFailure(:final exception):
        controller.isLoading = false;
        controller.exception = exception;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AcademicYearsBloc, AcademicYearsState>(
      listener: (context, state) => _syncState(state),
      child: AppSelector<AcademicYear>(
        label: label,
        dialogTitle: 'Pilih Tahun Ajaran',
        controller: controller,
        onPressed: () {
          _syncState(context.read<AcademicYearsBloc>().state);
          context.read<AcademicYearsBloc>().add(
            const AcademicYearsSubscriptionRequested(),
          );
        },
      ),
    );
  }
}
