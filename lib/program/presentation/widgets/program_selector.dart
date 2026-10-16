import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/program/domain/domain.dart';
import 'package:sistem_admin/program/presentation/bloc/bloc.dart';

/// Controller for [ProgramSelector]
final class ProgramSelectorController extends AppSelectorController<Program> {
  /// Creates new [ProgramSelectorController] with [initial] selected
  new({super.initial, super.initialItems})
    : super(itemAsString: (it) => it.name);
}

/// Selector to select a [Program]
class ProgramSelector extends StatelessWidget {
  /// Creates new [ProgramSelector]
  ///
  /// It reacts to [ProgramsBloc]'s state changes.
  /// So, make sure to provide it with that bloc.
  const new({
    required this.label,
    required this.controller,
    super.key,
  });

  /// Controls the [Program] being selected
  final ProgramSelectorController controller;

  /// Label for this program selector
  final String label;

  void _syncState(ProgramsState state) {
    switch (state) {
      case ProgramsInitial():
      case LoadingPrograms():
        controller.isLoading = true;
        controller.exception = null;
      case ProgramsLoaded(:final data):
        controller.isLoading = false;
        controller.exception = null;
        controller.items = data;
      case ProgramsFailure(:final exception):
        controller.isLoading = false;
        controller.exception = exception;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProgramsBloc, ProgramsState>(
      listener: (context, state) => _syncState(state),
      child: AppSelector<Program>(
        label: label,
        dialogTitle: 'Pilih Program Studi',
        controller: controller,
        onPressed: () {
          _syncState(context.read<ProgramsBloc>().state);
          context.read<ProgramsBloc>().add(
            const ProgramsSubscriptionRequested(),
          );
        },
      ),
    );
  }
}
