import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/academic_calendar/presentation/bloc/bloc.dart';
import 'package:sistem_admin/academic_calendar/presentation/widgets/delete_academic_term_button.dart';
import 'package:sistem_admin/common/common.dart';

enum _FormState {
  idle,
  creating,
  updating,
  deleting;

  bool get isProcessing => this != _FormState.idle;
}

/// Form to create/update an [AcademicTerm]
class AcademicTermForm extends StatefulWidget {
  /// Creates new [AcademicTermForm]
  ///
  /// It reacts to [AcademicTermMutationBloc]'s state changes.
  /// So, make sure to provide that bloc in the widget tree.
  const new({
    required this.academicYear,
    this.initial,
    this.onAcademicTermDeleted,
    this.onSaved,
    super.key,
  });

  /// Parent [AcademicYear]
  final AcademicYear academicYear;

  /// Initial academic term data that will be shown
  final AcademicTerm? initial;

  /// Invoked when [initial] academic term data is deleted successfully
  final void Function(AcademicTerm)? onAcademicTermDeleted;

  /// Invoked when academic term is saved successfully
  final void Function(AcademicTerm)? onSaved;

  @override
  State<AcademicTermForm> createState() => _AcademicTermFormState();
}

class _AcademicTermFormState extends State<AcademicTermForm> {
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
    return BlocListener<AcademicTermMutationBloc, AcademicTermMutationState>(
      listenWhen: (p, c) => p.notice != c.notice,
      listener: (context, state) async {
        switch (state.notice) {
          case AcademicTermMutationFailedNotice(
            :final type,
            :final exception,
          ):
            late final String title;
            switch (type) {
              case AcademicTermMutationType.create:
                title = 'Gagal menyimpan semester baru';
              case AcademicTermMutationType.update:
                title = 'Gagal memperbarui semester';
              case AcademicTermMutationType.delete:
                title = 'Gagal menghapus semester';
            }
            unawaited(
              context.showFailedDialog(
                title: title,
                message: exception.code.message,
              ),
            );
          case AcademicTermUpdatedNotice(:final before, :final after):
            await context.showSuccessDialog(
              title: 'Semester "${before.name}" berhasil diperbarui',
              message:
                  'Semester "${before.name}" berhasil diperbarui '
                  'dengan nama "${after.name}"',
            );
            widget.onSaved?.call(after);
          case AcademicTermCreatedNotice(:final created):
            await context.showSuccessDialog(
              title: 'Semester berhasil disimpan',
              message:
                  'Semester dengan nama "${created.name}" berhasil disimpan',
            );
            _nameController.clear();
            _startDateController.clear();
            _endDateController.clear();
            widget.onSaved?.call(created);
          case AcademicTermDeletedNotice(:final deleted):
            await context.showSuccessDialog(
              title: 'Semester berhasil dihapus',
              message:
                  'Semester dengan nama "${deleted.name}" berhasil dihapus',
            );
            widget.onAcademicTermDeleted?.call(deleted);
          case null:
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppFormField(
              controller: _nameController,
              label: 'Nama Semester',
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
              AcademicTermMutationBloc,
              AcademicTermMutationState,
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
                                context.read<AcademicTermMutationBloc>().add(
                                  AcademicTermMutationCreateRequested(
                                    academicYearId: widget.academicYear.id,
                                    name: name,
                                    startDate: start,
                                    endDate: end,
                                  ),
                                );
                              } else {
                                context.read<AcademicTermMutationBloc>().add(
                                  AcademicTermMutationUpdateRequested(
                                    academicTerm: widget.initial!,
                                    name: name,
                                    startDate: start,
                                    endDate: end,
                                  ),
                                );
                              }
                            },
                    ),
                    if (widget.initial != null)
                      DeleteAcademicTermButton(
                        academicTerm: widget.initial!,
                        isDeleting: formState == _FormState.deleting,
                        disable: formState.isProcessing,
                        onConfirmed: () {
                          context.read<AcademicTermMutationBloc>().add(
                            AcademicTermMutationDeleteRequested(
                              academicTerm: widget.initial!,
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
