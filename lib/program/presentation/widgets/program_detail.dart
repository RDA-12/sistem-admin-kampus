import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/program/domain/domain.dart';
import 'package:sistem_admin/program/presentation/bloc/bloc.dart';
import 'package:sistem_admin/program/presentation/widgets/program_courses_list.dart';
import 'package:sistem_admin/program/presentation/widgets/program_form.dart';
import 'package:sistem_admin/program/presentation/widgets/program_lecturers_list.dart';

/// Shows detail of a program
class ProgramDetail extends StatelessWidget {
  /// Creates new [ProgramDetail]
  ///
  /// It reacts to [ProgramDetailBloc], [FacultiesBloc],
  /// and [ProgramMutationBloc] state changes.
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
          case ProgramDetailLoaded(
            :final program,
            :final lecturers,
            :final courses,
          ):
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ProgramForm(
                    initial: program,
                    onProgramDeleted: onProgramDeleted,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 12),
                    child: Text(
                      'Daftar Dosen',
                      style: context.text.titleMedium,
                    ),
                  ),
                ),
                ProgramLecturersList(
                  lecturers: lecturers,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 12),
                    child: Text(
                      'Daftar Mata Kuliah',
                      style: context.text.titleMedium,
                    ),
                  ),
                ),
                ProgramCoursesList(
                  courses: courses,
                ),
              ],
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
