import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/lecturer/domain/domain.dart';
import 'package:sistem_admin/lecturer/presentation/bloc/bloc.dart';

/// Controller for [LecturerSelector]
final class LecturerSelectorController extends AppSelectorController<Lecturer> {
  /// Creates new [LecturerSelectorController] with [initial] selected
  new({super.initial, super.initialItems})
    : super(itemAsString: (it) => it.name);
}

/// Selector to select a [Lecturer]
class LecturerSelector extends StatelessWidget {
  /// Creates new [LecturerSelector]
  ///
  /// It reacts to [LecturersBloc]'s state changes.
  /// So, make sure to provide it with that bloc.
  const new({
    required this.label,
    required this.controller,
    super.key,
  });

  /// Controls the [Lecturer] being selected
  final LecturerSelectorController controller;

  /// Label for this lecturer selector
  final String label;

  void _syncState(LecturersState state) {
    switch (state) {
      case LecturersInitial():
      case LoadingLecturers():
        controller.isLoading = true;
        controller.exception = null;
      case LecturersLoaded(:final data):
        controller.isLoading = false;
        controller.exception = null;
        controller.items = data;
      case LecturersFailure(:final exception):
        controller.isLoading = false;
        controller.exception = exception;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LecturersBloc, LecturersState>(
      listener: (context, state) => _syncState(state),
      child: AppSelector<Lecturer>(
        label: label,
        dialogTitle: 'Pilih Dosen',
        controller: controller,
        onPressed: () {
          _syncState(context.read<LecturersBloc>().state);
          context.read<LecturersBloc>().add(
            const LecturersSubscriptionRequested(),
          );
        },
      ),
    );
  }
}
