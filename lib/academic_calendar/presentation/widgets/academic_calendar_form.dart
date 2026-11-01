import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/academic_calendar/presentation/bloc/bloc.dart';
import 'package:sistem_admin/academic_calendar/presentation/widgets/academic_calendar_event_form.dart';
import 'package:sistem_admin/academic_calendar/presentation/widgets/academic_calendar_event_list_tile.dart';
import 'package:sistem_admin/academic_calendar/presentation/widgets/academic_term_form.dart';
import 'package:sistem_admin/academic_calendar/presentation/widgets/academic_term_list_tile.dart';
import 'package:sistem_admin/academic_calendar/presentation/widgets/academic_year_form.dart';
import 'package:sistem_admin/common/common.dart';

/// Form to creates new AcademicCalendar
///
/// It sets the year, terms, and general events
class AcademicCalendarForm extends StatefulWidget {
  /// Creates new [AcademicCalendarForm]
  ///
  /// It reacts to [AcademicCalendarMutationBloc]
  /// state changes. So, make sure to provide that bloc.
  const new({
    this.onCalendarCreated,
    super.key,
  });

  /// Invoked when academic calendar creation flow is completed
  final void Function(AcademicCalendar)? onCalendarCreated;

  @override
  State<AcademicCalendarForm> createState() => _AcademicCalendarFormState();
}

class _AcademicCalendarFormState extends State<AcademicCalendarForm> {
  var _stepperIndex = 0;
  final academicYear = ValueNotifier<AcademicYear?>(null);
  final academicTerms = ValueNotifier<List<AcademicTerm>>([]);
  final academicEvents = ValueNotifier<List<AcademicCalendarEvent>>([]);

  @override
  void dispose() {
    academicYear.dispose();
    academicTerms.dispose();
    academicEvents.dispose();
    super.dispose();
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
          case AcademicCalendarMutationFailedNotice(:final exception):
            unawaited(
              context.showFailedDialog(
                title: 'Gagal menyimpan kalender akademik',
                message: exception.code.message,
              ),
            );
          case AcademicYearCreatedNotice(:final created):
            academicYear.value = created;
            setState(() {
              _stepperIndex = 1;
            });
            unawaited(
              context.showSuccessDialog(
                title: 'Tahun akademik berhasil disimpan',
                message:
                    'Tahun akademik "${created.name}" berhasil disimpan. '
                    'Silakan lanjutkan menambahkan semester.',
              ),
            );
          case AcademicTermCreatedNotice(:final created):
            academicTerms.value = [...academicTerms.value, created];
            unawaited(
              context.showSuccessDialog(
                title: 'Semester berhasil disimpan',
                message: 'Semester "${created.name}" berhasil disimpan.',
              ),
            );
          case AcademicCalendarEventCreatedNotice(:final created):
            academicEvents.value = [...academicEvents.value, created];
            unawaited(
              context.showSuccessDialog(
                title: 'Kegiatan berhasil disimpan',
                message: 'Kegiatan "${created.name}" berhasil disimpan.',
              ),
            );
          case _:
        }
      },
      child:
          BlocBuilder<
            AcademicCalendarMutationBloc,
            AcademicCalendarMutationState
          >(
            builder: (context, state) {
              return Stepper(
                currentStep: _stepperIndex,
                controlsBuilder: (context, details) {
                  return const SizedBox.shrink();
                },
                onStepTapped: (index) {
                  setState(() {
                    _stepperIndex = index;
                  });
                },
                steps: [
                  Step(
                    title: const Text('Tahun Akademik'),
                    isActive: _stepperIndex >= 0,
                    state: academicYear.value != null
                        ? StepState.complete
                        : StepState.indexed,
                    content: ListenableBuilder(
                      listenable: academicYear,
                      builder: (context, _) {
                        return AcademicYearForm(
                          initial: academicYear.value,
                          isProcessing: state.isCreatingYear,
                          onSave:
                              ({
                                required name,
                                required startDate,
                                required endDate,
                              }) {
                                context
                                    .read<AcademicCalendarMutationBloc>()
                                    .add(
                                      AcademicCalendarYearCreateRequested(
                                        name: name,
                                        startDate: startDate,
                                        endDate: endDate,
                                      ),
                                    );
                              },
                        );
                      },
                    ),
                  ),
                  Step(
                    title: const Text('Semester Akademik'),
                    isActive: _stepperIndex >= 1,
                    state: academicTerms.value.isNotEmpty
                        ? StepState.complete
                        : StepState.indexed,
                    content: ListenableBuilder(
                      listenable: academicYear,
                      builder: (context, _) {
                        final year = academicYear.value;
                        if (year == null) {
                          return const Center(
                            child: AppEmptyBox(
                              message: 'Harap buat tahun akademik dahulu',
                            ),
                          );
                        }
                        return Column(
                          spacing: 16,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ListenableBuilder(
                              listenable: academicTerms,
                              builder: (context, _) {
                                if (academicTerms.value.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Semester yang telah ditambahkan:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    const SizedBox(height: 8),
                                    ...academicTerms.value.map(
                                      (term) => Card(
                                        child: AcademicTermListTile(
                                          academicTerm: term,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            AcademicTermForm(
                              academicYear: year,
                              isProcessing: state.isCreatingTerm,
                              onSave:
                                  ({
                                    required name,
                                    required startDate,
                                    required endDate,
                                  }) {
                                    context
                                        .read<AcademicCalendarMutationBloc>()
                                        .add(
                                          AcademicCalendarTermCreateRequested(
                                            academicYearId: year.id,
                                            name: name,
                                            startDate: startDate,
                                            endDate: endDate,
                                          ),
                                        );
                                  },
                            ),
                            AppButton(
                              label: 'Lanjut ke Kegiatan',
                              onPressed: () {
                                setState(() {
                                  _stepperIndex = 2;
                                });
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Step(
                    title: const Text('Kegiatan Akademik'),
                    subtitle: const Text(
                      'Kegiatan ini akan dimasukkan '
                      'ke setiap kalender program studi. '
                      'Jika ingin mengatur jadwal mata kuliah, '
                      'gunakan fitur jadwal kuliah',
                    ),
                    isActive: _stepperIndex >= 2,
                    state: academicEvents.value.isNotEmpty
                        ? StepState.complete
                        : StepState.indexed,
                    content: ListenableBuilder(
                      listenable: academicYear,
                      builder: (context, _) {
                        final year = academicYear.value;
                        if (year == null) {
                          return const Center(
                            child: AppEmptyBox(
                              message: 'Harap buat tahun akademik dahulu',
                            ),
                          );
                        }
                        return Column(
                          spacing: 16,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ListenableBuilder(
                              listenable: academicEvents,
                              builder: (context, _) {
                                if (academicEvents.value.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Kegiatan yang telah ditambahkan:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    const SizedBox(height: 8),
                                    ...academicEvents.value.map(
                                      (event) => Card(
                                        child: AcademicCalendarEventListTile(
                                          event: event,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            AcademicCalendarEventForm(
                              academicYear: year,
                              isProcessing: state.isCreatingEvent,
                              onSave:
                                  ({
                                    required name,
                                    required type,
                                    required start,
                                    required end,
                                    recurrence = const [],
                                  }) {
                                    context
                                        .read<AcademicCalendarMutationBloc>()
                                        .add(
                                          AcademicCalendarEventCreateRequested(
                                            academicYearId: year.id,
                                            name: name,
                                            type: type,
                                            start: start,
                                            end: end,
                                            recurrence: recurrence,
                                          ),
                                        );
                                  },
                            ),
                            if (widget.onCalendarCreated != null)
                              AppButton(
                                label: 'Selesai',
                                onPressed: () {
                                  widget.onCalendarCreated!(
                                    AcademicCalendar(
                                      year: year,
                                      terms: academicTerms.value,
                                      events: academicEvents.value,
                                    ),
                                  );
                                },
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }
}
