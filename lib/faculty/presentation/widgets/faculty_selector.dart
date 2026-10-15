import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/domain/domain.dart';
import 'package:sistem_admin/faculty/presentation/bloc/bloc.dart';

/// Controller for [FacultySelector]
final class FacultySelectorController extends AppSelectorController<Faculty> {
  /// Creates new [FacultySelectorController] with [initial] selected
  new({super.initial, super.initialItems})
    : super(itemAsString: (it) => it.name);
}

/// Selector to select a [Faculty]
class FacultySelector extends StatelessWidget {
  /// Creates new [FacultySelector]
  ///
  /// It reacts to [FacultiesBloc]'s state changes.
  /// So, make sure to provide it with that bloc.
  const new({
    required this.label,
    required this.controller,
    super.key,
  });

  /// Controls the [Faculty] being selected
  final FacultySelectorController controller;

  /// Label for this faculty selector
  final String label;

  void _syncState(FacultiesState state) {
    switch (state) {
      case FacultiesInitial():
      case LoadingFaculties():
        controller.isLoading = true;
        controller.exception = null;
      case FacultiesLoaded(:final data):
        controller.isLoading = false;
        controller.exception = null;
        controller.items = data;
      case FacultiesFailure(:final exception):
        controller.isLoading = false;
        controller.exception = exception;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FacultiesBloc, FacultiesState>(
      listener: (context, state) => _syncState(state),
      child: AppSelector<Faculty>(
        label: label,
        dialogTitle: 'Pilih Fakultas',
        controller: controller,
        onPressed: () {
          _syncState(context.read<FacultiesBloc>().state);
          context.read<FacultiesBloc>().add(
            const FacultiesSubscriptionRequested(),
          );
        },
      ),
    );
  }
}
