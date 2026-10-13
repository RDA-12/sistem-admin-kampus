import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/program/domain/domain.dart';
import 'package:sistem_admin/program/presentation/bloc/bloc.dart';
import 'package:sistem_admin/program/presentation/widgets/program_form.dart';

/// Shows detail of a program
class ProgramDetail extends StatelessWidget {
  /// Creates new [ProgramDetail]
  ///
  /// It reacts to [ProgramDetailBloc] state changes.
  /// So, ensure to provide it with that bloc.
  const new({
    this.onRetryPressed,
    this.onProgramDeleted,
    super.key,
  });

  /// Invoked when user press retry button
  final void Function()? onRetryPressed;

  /// Invoked when a program has been deleted
  final void Function(Program)? onProgramDeleted;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgramDetailBloc, ProgramDetailState>(
      builder: (context, state) {
        switch (state) {
          case ProgramDetailInitial():
          case LoadingProgramDetail():
            return const Center(
              child: LoadingIndicator(),
            );
          case ProgramDetailLoaded(:final program):
            return ProgramForm(
              initial: program,
              onProgramDeleted: onProgramDeleted,
            );
          case ProgramDetailLoadFailed(:final exception):
            return Center(
              child: AppExceptionBox(
                title: 'Gagal mengambil data program studi',
                exception: exception,
                onRetryPressed: onRetryPressed,
              ),
            );
        }
      },
    );
  }
}
