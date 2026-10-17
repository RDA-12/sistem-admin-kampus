import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/academic_calendar/presentation/bloc/bloc.dart';
import 'package:sistem_admin/academic_calendar/presentation/widgets/academic_term_form.dart';
import 'package:sistem_admin/academic_calendar/presentation/widgets/academic_year_form.dart';
import 'package:sistem_admin/academic_calendar/presentation/widgets/academic_year_terms.dart';
import 'package:sistem_admin/common/common.dart';

/// Shows detail of an academic year
class AcademicYearDetail extends StatelessWidget {
  /// Creates new [AcademicYearDetail]
  ///
  /// It reacts to [AcademicYearDetailBloc] and mutation blocs state changes.
  /// So, ensure to provide it with those blocs.
  const new({
    this.onRetryPressed,
    this.onAcademicYearDeleted,
    this.onTermPressed,
    super.key,
  });

  /// Invoked when user presses retry button
  final void Function()? onRetryPressed;

  /// Invoked when an academic year has been deleted
  final void Function(AcademicYear)? onAcademicYearDeleted;

  /// Invoked when one of academic terms is pressed
  final void Function(AcademicTerm)? onTermPressed;

  void _showTermDialog(
    BuildContext context, {
    required AcademicYear academicYear,
    AcademicTerm? term,
  }) {
    final mutationBloc = context.read<AcademicTermMutationBloc>();
    unawaited(
      context.showAppDialog<void>(
        title: term == null ? 'Tambah Semester' : 'Ubah Semester',
        contentBuilder: (dialogContext) {
          return BlocProvider.value(
            value: mutationBloc,
            child: SingleChildScrollView(
              child: AcademicTermForm(
                academicYear: academicYear,
                initial: term,
                onSaved: (_) => Navigator.of(dialogContext).pop(),
                onAcademicTermDeleted: (_) => Navigator.of(dialogContext).pop(),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AcademicYearDetailBloc, AcademicYearDetailState>(
      builder: (context, state) {
        switch (state) {
          case AcademicYearDetailInitial():
          case LoadingAcademicYearDetail():
            return const Center(
              child: LoadingIndicator(),
            );
          case AcademicYearDetailLoaded(
            :final academicYear,
            :final terms,
          ):
            return Column(
              spacing: 24,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AcademicYearForm(
                  initial: academicYear,
                  onAcademicYearDeleted: onAcademicYearDeleted,
                ),
                const Divider(),
                Expanded(
                  child: AcademicYearTerms(
                    academicYear: academicYear,
                    terms: terms,
                    onAddTermPressed: () {
                      _showTermDialog(
                        context,
                        academicYear: academicYear,
                      );
                    },
                    onTermPressed: (term) {
                      if (onTermPressed != null) {
                        onTermPressed!(term);
                      } else {
                        _showTermDialog(
                          context,
                          academicYear: academicYear,
                          term: term,
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          case AcademicYearDetailLoadFailed(:final exception):
            return Center(
              child: AppExceptionBox(
                title: 'Gagal mengambil data tahun akademik',
                exception: exception,
                onRetryPressed: onRetryPressed,
              ),
            );
        }
      },
    );
  }
}
