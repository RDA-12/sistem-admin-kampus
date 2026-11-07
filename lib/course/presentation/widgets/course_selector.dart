import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course/domain/domain.dart';
import 'package:sistem_admin/course/presentation/bloc/bloc.dart';

/// Controller for [CourseSelector]
final class CourseSelectorController extends AppSelectorController<Course> {
  /// Creates new [CourseSelectorController] with [initial] selected
  new({super.initial, super.initialItems})
    : super(itemAsString: (it) => it.name);
}

/// Selector to select a [Course]
class CourseSelector extends StatelessWidget {
  /// Creates new [CourseSelector]
  ///
  /// It reacts to [CoursesBloc]'s state changes.
  /// So, make sure to provide it with that bloc.
  const new({
    required this.label,
    required this.controller,
    super.key,
  });

  /// Controls the [Course] being selected
  final CourseSelectorController controller;

  /// Label for this course selector
  final String label;

  void _syncState(CoursesState state) {
    switch (state) {
      case CoursesInitial():
      case LoadingCourses():
        controller.isLoading = true;
        controller.exception = null;
      case CoursesLoaded(:final data):
        controller.isLoading = false;
        controller.exception = null;
        controller.items = data;
      case CoursesFailure(:final exception):
        controller.isLoading = false;
        controller.exception = exception;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CoursesBloc, CoursesState>(
      listener: (context, state) => _syncState(state),
      child: AppSelector<Course>(
        label: label,
        dialogTitle: 'Pilih Mata Kuliah',
        controller: controller,
        onPressed: () {
          _syncState(context.read<CoursesBloc>().state);
          context.read<CoursesBloc>().add(
            const CoursesSubscriptionRequested(),
          );
        },
      ),
    );
  }
}
