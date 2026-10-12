import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/presentation/bloc/bloc.dart';
import 'package:sistem_admin/faculty/presentation/widgets/faculty_form.dart';

/// Shows detail of a faculty
class FacultyDetail extends StatelessWidget {
  /// Creates new [FacultyDetail]
  ///
  /// It reacts to [FacultyDetailBloc] and [FacultyMutationBloc] state changes.
  /// So, ensure to provide it with those blocs.
  const new({
    this.onRetryPressed,
    super.key,
  });

  /// Invoked when user press retry button
  final void Function()? onRetryPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FacultyDetailBloc, FacultyDetailState>(
      builder: (context, state) {
        switch (state) {
          case FacultyDetailInitial():
          case LoadingFacultyDetail():
            return const Center(
              child: LoadingIndicator(),
            );
          case FacultyDetailLoaded(:final faculty):
            return FacultyForm(
              initial: faculty,
            );
          case FacultyDetailLoadFailed(:final exception):
            return Center(
              child: AppExceptionBox(
                title: 'Gagal mengambil data fakultas',
                exception: exception,
                onRetryPressed: onRetryPressed,
              ),
            );
        }
      },
    );
  }
}
