import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/academic_calendar/presentation/bloc/bloc.dart';
import 'package:sistem_admin/academic_calendar/presentation/widgets/delete_academic_year_button.dart';
import 'package:sistem_admin/common/common.dart';

enum _FormState {
  idle,
  creating,
  updating,
  deleting;

  bool get isProcessing => this != _FormState.idle;
}

/// Form to create/update an [AcademicYear]
class AcademicYearForm extends StatefulWidget {
  /// Creates new [AcademicYearForm]
  ///
  /// It reacts to [AcademicCalendarMutationBloc]'s state changes.
  /// So, make sure to provide that bloc in the widget tree.
  const new({
    this.initial,
    this.onAcademicYearDeleted,
    super.key,
  });

  /// Initial academic year data that will be shown
  final AcademicYear? initial;

  /// Invoked when [initial] academic year data is deleted successfully
  final void Function(AcademicYear)? onAcademicYearDeleted;

  @override
  State<AcademicYearForm> createState() => _AcademicYearFormState();
}

class _AcademicYearFormState extends State<AcademicYearForm> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late final AppDateFormFieldController _startDateController;
  late final AppDateFormFieldController _endDateController;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController(text: widget.initial?.name);
    _startDateController = AppDateFormFieldController(
      initial: widget.initial?.startDate,
    );
    _endDateController = AppDateFormFieldController(
      initial: widget.initial?.endDate,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
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
          case AcademicCalendarMutationFailedNotice(
            :final type,
            :final target,
            :final exception,
          ) when target == AcademicCalendarTargetType.year:
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
          case AcademicYearCreatedNotice(:final created):
            unawaited(
              context.showSuccessDialog(
                title: 'Tahun akademik berhasil disimpan',
                message:
                    'Tahun akademik dengan nama "${created.name}" '
                    'berhasil disimpan',
              ),
            );
            _nameController.clear();
            _startDateController.clear();
            _endDateController.clear();
          case AcademicYearDeletedNotice(:final deleted):
            await context.showSuccessDialog(
              title: 'Tahun akademik berhasil dihapus',
              message:
                  'Tahun akademik dengan nama "${deleted.name}" '
                  'berhasil dihapus',
            );
            widget.onAcademicYearDeleted?.call(deleted);
          case _:
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppFormField(
              controller: _nameController,
              label: 'Nama Tahun Akademik',
            ),
            AppDateFormField(
              controller: _startDateController,
              label: 'Tanggal Mulai',
            ),
            AppDateFormField(
              controller: _endDateController,
              label: 'Tanggal Selesai',
              validator: (end) {
                final start = _startDateController.value;
                if (start != null && end.isBefore(start)) {
                  return 'Tanggal selesai harus setelah tanggal mulai';
                }
                return null;
              },
            ),
            BlocSelector<
              AcademicCalendarMutationBloc,
              AcademicCalendarMutationState,
              _FormState
            >(
              selector: (state) {
                if (state.isCreatingYear) {
                  return _FormState.creating;
                } else if (state.updatingYearIds.contains(widget.initial?.id)) {
                  return _FormState.updating;
                } else if (state.deletingYearIds.contains(widget.initial?.id)) {
                  return _FormState.deleting;
                }
                return _FormState.idle;
              },
              builder: (context, formState) {
                return Column(
                  spacing: 8,
                  crossAxisAlignment: .stretch,
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
                              final start = _startDateController.value;
                              final end = _endDateController.value;
                              if (start == null || end == null) return;
                              final name = _nameController.text.trim();
                              if (widget.initial == null) {
                                context
                                    .read<AcademicCalendarMutationBloc>()
                                    .add(
                                      AcademicCalendarYearCreateRequested(
                                        name: name,
                                        startDate: start,
                                        endDate: end,
                                      ),
                                    );
                              } else {
                                context
                                    .read<AcademicCalendarMutationBloc>()
                                    .add(
                                      AcademicCalendarYearUpdateRequested(
                                        academicYear: widget.initial!,
                                        name: name,
                                        startDate: start,
                                        endDate: end,
                                      ),
                                    );
                              }
                            },
                    ),
                    if (widget.initial != null)
                      DeleteAcademicYearButton(
                        academicYear: widget.initial!,
                        isDeleting: formState == _FormState.deleting,
                        disable: formState.isProcessing,
                        onConfirmed: () {
                          context.read<AcademicCalendarMutationBloc>().add(
                            AcademicCalendarYearDeleteRequested(
                              academicYear: widget.initial!,
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
    );
  }
}
