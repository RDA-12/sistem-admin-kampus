import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/lecturer/domain/domain.dart';
import 'package:sistem_admin/lecturer/presentation/bloc/bloc.dart';
import 'package:sistem_admin/lecturer/presentation/widgets/lecturer_form.dart';
import 'package:sistem_admin/program/program.dart';

/// Shows detail of a lecturer
class LecturerDetail extends StatelessWidget {
  /// Creates new [LecturerDetail]
  ///
  /// It reacts to [LecturerDetailBloc], [ProgramsBloc],
  /// and [LecturerMutationBloc] state changes.
  /// So, ensure to provide it with that bloc.
  const new({
    this.onRetryPressed,
    this.onLecturerDeleted,
    super.key,
  });

  /// Invoked when user press retry button
  final void Function()? onRetryPressed;

  /// Invoked when a lecturer has been deleted
  final void Function(Lecturer)? onLecturerDeleted;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LecturerDetailBloc, LecturerDetailState>(
      builder: (context, state) {
        switch (state) {
          case LecturerDetailInitial():
          case LoadingLecturerDetail():
            return const Center(
              child: LoadingIndicator(),
            );
          case LecturerDetailLoaded(:final lecturer):
            return LecturerForm(
              initial: lecturer,
              onLecturerDeleted: onLecturerDeleted,
            );
          case LecturerDetailLoadFailed(:final exception):
            return Center(
              child: AppExceptionBox(
                title: 'Gagal mengambil data dosen',
                exception: exception,
                onRetryPressed: onRetryPressed,
              ),
            );
        }
      },
    );
  }
}
