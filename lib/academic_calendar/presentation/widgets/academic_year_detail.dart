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
  /// It reacts to [AcademicYearDetailBloc] and
  /// [AcademicCalendarMutationBloc] state changes.
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
    final mutationBloc = context.read<AcademicCalendarMutationBloc>();
    unawaited(
      context.showAppDialog<void>(
        title: term == null ? 'Tambah Semester' : 'Ubah Semester',
        contentBuilder: (dialogContext) {
          return BlocProvider.value(
            value: mutationBloc,
            child:
                BlocConsumer<
                  AcademicCalendarMutationBloc,
                  AcademicCalendarMutationState
                >(
                  listenWhen: (p, c) => p.notice != c.notice,
                  listener: (context, state) async {
                    switch (state.notice) {
                      case AcademicCalendarMutationFailedNotice(
                            :final type,
                            :final target,
                            :final exception,
                          )
                          when target == AcademicCalendarTargetType.term:
                        late final String title;
                        switch (type) {
                          case AcademicCalendarMutationType.create:
                            title = 'Gagal menyimpan semester baru';
                          case AcademicCalendarMutationType.update:
                            title = 'Gagal memperbarui semester';
                          case AcademicCalendarMutationType.delete:
                            title = 'Gagal menghapus semester';
                        }
                        unawaited(
                          context.showFailedDialog(
                            title: title,
                            message: exception.code.message,
                          ),
                        );
                      case AcademicTermCreatedNotice(:final created):
                        await context.showSuccessDialog(
                          title: 'Semester berhasil disimpan',
                          message:
                              'Semester dengan nama "${created.name}" '
                              'berhasil disimpan',
                        );
                        if (!context.mounted) return;
                        Navigator.of(dialogContext).pop();
                      case AcademicTermUpdatedNotice(
                        :final before,
                        :final after,
                      ):
                        await context.showSuccessDialog(
                          title:
                              'Semester "${before.name}" berhasil diperbarui',
                          message:
                              'Semester "${before.name}" berhasil diperbarui '
                              'dengan nama "${after.name}"',
                        );
                        if (!context.mounted) return;
                        Navigator.of(dialogContext).pop();
                      case AcademicTermDeletedNotice(:final deleted):
                        await context.showSuccessDialog(
                          title: 'Semester berhasil dihapus',
                          message:
                              'Semester dengan nama "${deleted.name}" '
                              'berhasil dihapus',
                        );
                        if (!context.mounted) return;
                        Navigator.of(dialogContext).pop();
                      case _:
                    }
                  },
                  builder: (context, state) {
                    final isProcessing = term == null
                        ? state.isCreatingTerm
                        : state.updatingTermIds.contains(term.id) ||
                              state.deletingTermIds.contains(term.id);
                    final isDeleting =
                        term != null && state.deletingTermIds.contains(term.id);

                    return SingleChildScrollView(
                      child: AcademicTermForm(
                        academicYear: academicYear,
                        initial: term,
                        isProcessing: isProcessing,
                        isDeleting: isDeleting,
                        onSave:
                            ({
                              required name,
                              required startDate,
                              required endDate,
                            }) {
                              if (term == null) {
                                context
                                    .read<AcademicCalendarMutationBloc>()
                                    .add(
                                      AcademicCalendarTermCreateRequested(
                                        academicYearId: academicYear.id,
                                        name: name,
                                        startDate: startDate,
                                        endDate: endDate,
                                      ),
                                    );
                              } else {
                                context
                                    .read<AcademicCalendarMutationBloc>()
                                    .add(
                                      AcademicCalendarTermUpdateRequested(
                                        academicTerm: term,
                                        name: name,
                                        startDate: startDate,
                                        endDate: endDate,
                                      ),
                                    );
                              }
                            },
                        onDelete: term == null
                            ? null
                            : () {
                                context
                                    .read<AcademicCalendarMutationBloc>()
                                    .add(
                                      AcademicCalendarTermDeleteRequested(
                                        academicTerm: term,
                                      ),
                                    );
                              },
                      ),
                    );
                  },
                ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      AcademicCalendarMutationBloc,
      AcademicCalendarMutationState
    >(
      listenWhen: (p, c) => p.notice != c.notice,
      listener: (context, state) async {
        switch (state.notice) {
          case AcademicCalendarMutationFailedNotice(
                :final type,
                :final target,
                :final exception,
              )
              when target == AcademicCalendarTargetType.year:
            late final String title;
            switch (type) {
              case AcademicCalendarMutationType.create:
                title = 'Gagal menyimpan tahun akademik baru';
              case AcademicCalendarMutationType.update:
                title = 'Gagal memperbarui tahun akademik';
              case AcademicCalendarMutationType.delete:
                title = 'Gagal menghapus tahun akademik';
            }
            unawaited(
              context.showFailedDialog(
                title: title,
                message: exception.code.message,
              ),
            );
          case AcademicYearUpdatedNotice(:final before, :final after):
            unawaited(
              context.showSuccessDialog(
                title: 'Tahun akademik "${before.name}" berhasil diperbarui',
                message:
                    'Tahun akademik "${before.name}" berhasil diperbarui '
                    'dengan nama "${after.name}"',
              ),
            );
          case AcademicYearDeletedNotice(:final deleted):
            await context.showSuccessDialog(
              title: 'Tahun akademik berhasil dihapus',
              message:
                  'Tahun akademik dengan nama "${deleted.name}" '
                  'berhasil dihapus',
            );
            onAcademicYearDeleted?.call(deleted);
          case _:
        }
      },
      child: BlocBuilder<AcademicYearDetailBloc, AcademicYearDetailState>(
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
                  BlocSelector<
                    AcademicCalendarMutationBloc,
                    AcademicCalendarMutationState,
                    ({bool isProcessing, bool isDeleting})
                  >(
                    selector: (mutationState) => (
                      isProcessing:
                          mutationState.updatingYearIds.contains(
                            academicYear.id,
                          ) ||
                          mutationState.deletingYearIds.contains(
                            academicYear.id,
                          ),
                      isDeleting: mutationState.deletingYearIds.contains(
                        academicYear.id,
                      ),
                    ),
                    builder: (context, mutationStatus) {
                      return AcademicYearForm(
                        initial: academicYear,
                        isProcessing: mutationStatus.isProcessing,
                        isDeleting: mutationStatus.isDeleting,
                        onSave:
                            ({
                              required name,
                              required startDate,
                              required endDate,
                            }) {
                              context.read<AcademicCalendarMutationBloc>().add(
                                AcademicCalendarYearUpdateRequested(
                                  academicYear: academicYear,
                                  name: name,
                                  startDate: startDate,
                                  endDate: endDate,
                                ),
                              );
                            },
                        onDelete: () {
                          context.read<AcademicCalendarMutationBloc>().add(
                            AcademicCalendarYearDeleteRequested(
                              academicYear: academicYear,
                            ),
                          );
                        },
                      );
                    },
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
      ),
    );
  }
}
