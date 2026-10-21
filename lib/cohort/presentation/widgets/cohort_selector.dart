import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/cohort/domain/domain.dart';
import 'package:sistem_admin/cohort/presentation/bloc/bloc.dart';
import 'package:sistem_admin/common/common.dart';

/// Controller for [CohortSelector]
final class CohortSelectorController extends AppSelectorController<Cohort> {
  /// Creates new [CohortSelectorController] with [initial] selected
  new({super.initial, super.initialItems})
    : super(itemAsString: (it) => it.name);
}

/// Selector to select a [Cohort]
class CohortSelector extends StatelessWidget {
  /// Creates new [CohortSelector]
  ///
  /// It reacts to [CohortsBloc]'s state changes.
  /// So, make sure to provide it with that bloc.
  const new({
    required this.label,
    required this.controller,
    super.key,
  });

  /// Controls the [Cohort] being selected
  final CohortSelectorController controller;

  /// Label for this cohort selector
  final String label;

  void _syncState(CohortsState state) {
    switch (state) {
      case CohortsInitial():
      case LoadingCohorts():
        controller.isLoading = true;
        controller.exception = null;
      case CohortsLoaded(:final data):
        controller.isLoading = false;
        controller.exception = null;
        controller.items = data;
      case CohortsFailure(:final exception):
        controller.isLoading = false;
        controller.exception = exception;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CohortsBloc, CohortsState>(
      listener: (context, state) => _syncState(state),
      child: AppSelector<Cohort>(
        label: label,
        dialogTitle: 'Pilih Angkatan',
        controller: controller,
        onPressed: () {
          _syncState(context.read<CohortsBloc>().state);
          context.read<CohortsBloc>().add(
            const CohortsSubscriptionRequested(),
          );
        },
      ),
    );
  }
}
