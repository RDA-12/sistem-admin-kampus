import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course/course.dart';
import 'package:sistem_admin/course_schedule/domain/domain.dart';
import 'package:sistem_admin/course_schedule/presentation/bloc/bloc.dart';
import 'package:sistem_admin/course_schedule/presentation/models.dart';
import 'package:sistem_admin/course_schedule/presentation/widgets/delete_course_schedule_button.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';
import 'package:sistem_admin/room/room.dart';

enum _FormState {
  idle,
  creating,
  updating,
  deleting;

  bool get isProcessing => this != _FormState.idle;
}

/// Form to create/update a [CourseSchedule]
class CourseScheduleForm extends StatefulWidget {
  /// Creates new [CourseScheduleForm]
  ///
  /// It reacts to [CourseScheduleMutationBloc], [CohortsBloc], [CoursesBloc],
  /// [LecturersBloc], and [RoomsBloc] state changes.
  /// So, make sure to provide those blocs in the widget tree.
  const new({
    this.initial,
    this.academicYearId,
    this.termId,
    this.programId,
    this.onCourseScheduleDeleted,
    super.key,
  });

  /// Initial course schedule data that will be showed
  final CourseScheduleUI? initial;

  /// Parent academic year ID for creating course schedule
  final String? academicYearId;

  /// Parent term ID for creating course schedule
  final String? termId;

  /// Parent program ID for creating course schedule
  final String? programId;

  /// Invoked when [initial] course schedule data is deleted successfully
  final void Function(CourseSchedule)? onCourseScheduleDeleted;

  @override
  State<CourseScheduleForm> createState() => _CourseScheduleFormState();
}

class _CourseScheduleFormState extends State<CourseScheduleForm> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late final CohortSelectorController _cohortController;
  late final CourseSelectorController _courseController;
  late final LecturerSelectorController _lecturerController;
  late final RoomSelectorController _roomController;
  late final AppDateFormFieldController _dateController;
  late final TextEditingController _timeController;
  late final AppNumberFormFieldController _durationController;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController(text: widget.initial?.name);
    _cohortController = CohortSelectorController(
      initial: widget.initial?.cohort,
    );
    _courseController = CourseSelectorController(
      initial: widget.initial?.course,
    );
    _lecturerController = LecturerSelectorController(
      initial: widget.initial?.lecturer,
    );
    _roomController = RoomSelectorController(
      initial: widget.initial?.room,
    );
    _dateController = AppDateFormFieldController(
      initial: widget.initial?.start,
    );
    final initialStart = widget.initial?.start;
    final initialHour = initialStart?.hour.toString().padLeft(2, '0');
    final initialMinute = initialStart?.minute.toString().padLeft(2, '0');
    _timeController = TextEditingController(
      text: initialStart != null ? '$initialHour:$initialMinute' : null,
    );
    _durationController = AppNumberFormFieldController(
      initial: widget.initial?.duration.inMinutes,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cohortController.dispose();
    _courseController.dispose();
    _lecturerController.dispose();
    _roomController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      CourseScheduleMutationBloc,
      CourseScheduleMutationState
    >(
      listenWhen: (p, c) => p.notice != c.notice,
      listener: (context, state) async {
        switch (state.notice) {
          case CourseScheduleMutationFailedNotice(
            :final type,
            :final exception,
          ):
            late final String title;
            switch (type) {
              case CourseScheduleMutationType.create:
                title = 'Gagal menyimpan jadwal kuliah baru';
              case CourseScheduleMutationType.update:
                title = 'Gagal memperbarui jadwal kuliah';
              case CourseScheduleMutationType.delete:
                title = 'Gagal menghapus jadwal kuliah';
            }
            unawaited(
              context.showFailedDialog(
                title: title,
                message: exception.code.message,
              ),
            );
          case CourseScheduleUpdatedNotice(:final before, :final after):
            unawaited(
              context.showSuccessDialog(
                title: 'Jadwal kuliah "${before.name}" berhasil diperbarui',
                message:
                    'Jadwal kuliah "${before.name}" berhasil diperbarui '
                    'dengan nama "${after.name}"',
              ),
            );
          case CourseScheduleCreatedNotice(:final created):
            unawaited(
              context.showSuccessDialog(
                title: 'Jadwal kuliah berhasil disimpan',
                message:
                    'Jadwal kuliah dengan nama "${created.name}" '
                    'berhasil disimpan',
              ),
            );
            _nameController.clear();
            _cohortController.clear();
            _courseController.clear();
            _lecturerController.clear();
            _roomController.clear();
            _dateController.clear();
            _timeController.clear();
            _durationController.clear();
          case CourseScheduleDeletedNotice(:final deleted):
            await context.showSuccessDialog(
              title: 'Jadwal kuliah berhasil dihapus',
              message:
                  'Jadwal kuliah dengan nama "${deleted.name}" '
                  'berhasil dihapus',
            );
            widget.onCourseScheduleDeleted?.call(deleted);
          case null:
        }
      },
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            AppFormField(
              controller: _nameController,
              label: 'Nama Jadwal Kuliah',
            ),
            CohortSelector(
              label: 'Angkatan',
              controller: _cohortController,
            ),
            CourseSelector(
              label: 'Mata Kuliah',
              controller: _courseController,
            ),
            LecturerSelector(
              label: 'Dosen',
              controller: _lecturerController,
            ),
            RoomSelector(
              label: 'Ruangan',
              controller: _roomController,
            ),
            AppDateFormField(
              controller: _dateController,
              label: 'Tanggal Mulai',
            ),
            AppFormField(
              controller: _timeController,
              label: 'Jam Mulai',
              keyboardType: TextInputType.datetime,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Kolom ini wajib diisi';
                }
                final parts = value.trim().split(':');
                if (parts.length != 2) {
                  return 'Format jam tidak valid (contoh 08:00)';
                }
                final h = int.tryParse(parts[0]);
                final m = int.tryParse(parts[1]);
                if (h == null ||
                    m == null ||
                    h < 0 ||
                    h > 23 ||
                    m < 0 ||
                    m > 59) {
                  return 'Format jam tidak valid (contoh 08:00)';
                }
                return null;
              },
            ),
            AppNumberFormField(
              controller: _durationController,
              label: 'Durasi (menit)',
              validator: (value) {
                if (value is! int || value <= 0) {
                  return 'Durasi harus berupa angka positif';
                }
                return null;
              },
            ),
            BlocSelector<
              CourseScheduleMutationBloc,
              CourseScheduleMutationState,
              _FormState
            >(
              selector: (state) {
                if (state.isCreating) {
                  return _FormState.creating;
                } else if (state.updatingIds.contains(widget.initial?.id)) {
                  return _FormState.updating;
                } else if (state.deletingIds.contains(widget.initial?.id)) {
                  return _FormState.deleting;
                }
                return _FormState.idle;
              },
              builder: (context, formState) {
                return Column(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppButton(
                      leadingIcon:
                          [
                            _FormState.creating,
                            _FormState.updating,
                          ].contains(formState)
                          ? const LoadingIndicator()
                          : const Icon(Icons.save_rounded),
                      label: 'Simpan',
                      onPressed: formState.isProcessing
                          ? null
                          : () {
                              if (!_formKey.currentState!.validate()) return;
                              if (_cohortController.selected == null) return;
                              if (_courseController.selected == null) return;
                              if (_lecturerController.selected == null) return;
                              if (_roomController.selected == null) return;
                              if (_dateController.value == null) return;
                              if (_durationController.value <= 0) return;

                              final date = _dateController.value!;
                              final timeParts = _timeController.text
                                  .trim()
                                  .split(':');
                              final hour = int.parse(timeParts[0]);
                              final minute = int.parse(timeParts[1]);
                              final start = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                hour,
                                minute,
                              );
                              final duration = Duration(
                                minutes: _durationController.value.toInt(),
                              );
                              final name = _nameController.text.trim();
                              final cohortId = _cohortController.selected!.id;
                              final courseId = _courseController.selected!.id;
                              final lecturerId =
                                  _lecturerController.selected!.id;
                              final roomId = _roomController.selected!.id;
                              final academicYearId =
                                  widget.academicYearId ??
                                  widget.initial?.academicYearId;
                              final termId =
                                  widget.termId ?? widget.initial?.termId;
                              final programId =
                                  widget.programId ?? widget.initial?.programId;

                              if (widget.initial == null) {
                                if (academicYearId == null ||
                                    termId == null ||
                                    programId == null) {
                                  return;
                                }
                                context.read<CourseScheduleMutationBloc>().add(
                                  CourseScheduleMutationCreateRequested(
                                    academicYearId: academicYearId,
                                    termId: termId,
                                    programId: programId,
                                    name: name,
                                    start: start,
                                    duration: duration,
                                    cohortId: cohortId,
                                    courseId: courseId,
                                    lecturerId: lecturerId,
                                    roomId: roomId,
                                  ),
                                );
                              } else {
                                context.read<CourseScheduleMutationBloc>().add(
                                  CourseScheduleMutationUpdateRequested(
                                    courseSchedule: widget.initial!,
                                    name: name,
                                    start: start,
                                    duration: duration,
                                    cohortId: cohortId,
                                    courseId: courseId,
                                    lecturerId: lecturerId,
                                    roomId: roomId,
                                    academicYearId: academicYearId,
                                    termId: termId,
                                    programId: programId,
                                  ),
                                );
                              }
                            },
                    ),
                    if (widget.initial != null)
                      DeleteCourseScheduleButton(
                        courseSchedule: widget.initial!,
                        isDeleting: formState == _FormState.deleting,
                        disable: formState.isProcessing,
                        onConfirmed: () {
                          context.read<CourseScheduleMutationBloc>().add(
                            CourseScheduleMutationDeleteRequested(
                              courseSchedule: widget.initial!,
                            ),
                          );
                        },
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
}
