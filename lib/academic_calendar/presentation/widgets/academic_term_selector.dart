import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/academic_calendar/presentation/bloc/bloc.dart';
import 'package:sistem_admin/common/common.dart';

/// Controller for [AcademicTermSelector]
final class AcademicTermSelectorController
    extends AppSelectorController<AcademicTerm> {
  /// Creates new [AcademicTermSelectorController] with [initial] selected
  new({super.initial, super.initialItems})
    : super(itemAsString: (it) => it.name);
}

/// Selector to select an [AcademicTerm]
class AcademicTermSelector extends StatelessWidget {
  /// Creates new [AcademicTermSelector]
  ///
  /// It reacts to [AcademicTermsBloc]'s state changes.
  /// So, make sure to provide it with that bloc.
  const new({
    required this.label,
    required this.controller,
    this.academicYearId,
    super.key,
  });

  /// Controls the [AcademicTerm] being selected
  final AcademicTermSelectorController controller;

  /// Label for this academic term selector
  final String label;

  /// Optional ID of the parent academic year to filter terms
  final String? academicYearId;

  void _syncState(AcademicTermsState state) {
    switch (state) {
      case AcademicTermsInitial():
      case LoadingAcademicTerms():
        controller.isLoading = true;
        controller.exception = null;
      case AcademicTermsLoaded(:final data):
        controller.isLoading = false;
        controller.exception = null;
        controller.items = data;
      case AcademicTermsFailure(:final exception):
        controller.isLoading = false;
        controller.exception = exception;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AcademicTermsBloc, AcademicTermsState>(
      listener: (context, state) => _syncState(state),
      child: AppSelector<AcademicTerm>(
        label: label,
        dialogTitle: 'Pilih Semester',
        controller: controller,
        onPressed: () {
          _syncState(context.read<AcademicTermsBloc>().state);
          context.read<AcademicTermsBloc>().add(
            AcademicTermsSubscriptionRequested(
              academicYearId: academicYearId,
            ),
          );
        },
      ),
    );
  }
}
