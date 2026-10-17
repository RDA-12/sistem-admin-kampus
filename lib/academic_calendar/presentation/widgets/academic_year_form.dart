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
  /// It reacts to [AcademicYearMutationBloc]'s state changes.
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
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;
  DateTime? _startDate;
  DateTime? _endDate;

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController(text: widget.initial?.name);
    _startDate = widget.initial?.startDate;
    _endDate = widget.initial?.endDate;
    _startDateController = TextEditingController(
      text: _startDate != null ? _formatDate(_startDate!) : '',
    );
    _endDateController = TextEditingController(
      text: _endDate != null ? _formatDate(_endDate!) : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _startDateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? now),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _endDateController.text = _formatDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AcademicYearMutationBloc, AcademicYearMutationState>(
      listenWhen: (p, c) => p.notice != c.notice,
      listener: (context, state) async {
        switch (state.notice) {
          case AcademicYearMutationFailedNotice(
            :final type,
            :final exception,
          ):
            late final String title;
            switch (type) {
              case AcademicYearMutationType.create:
                title = 'Gagal menyimpan tahun akademik baru';
              case AcademicYearMutationType.update:
                title = 'Gagal memperbarui tahun akademik';
              case AcademicYearMutationType.delete:
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
            _startDate = null;
            _endDate = null;
          case AcademicYearDeletedNotice(:final deleted):
            await context.showSuccessDialog(
              title: 'Tahun akademik berhasil dihapus',
              message:
                  'Tahun akademik dengan nama "${deleted.name}" '
                  'berhasil dihapus',
            );
            widget.onAcademicYearDeleted?.call(deleted);
          case null:
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
            AppFormField(
              controller: _startDateController,
              label: 'Tanggal Mulai',
              onPressed: _pickStartDate,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Harap isi bidang ini';
                }
                if (DateTime.tryParse(val.trim()) == null) {
                  return 'Format tanggal tidak valid';
                }
                return null;
              },
            ),
            AppFormField(
              controller: _endDateController,
              label: 'Tanggal Selesai',
              onPressed: _pickEndDate,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Harap isi bidang ini';
                }
                final end = DateTime.tryParse(val.trim());
                if (end == null) {
                  return 'Format tanggal tidak valid';
                }
                final start =
                    _startDate != null &&
                        _startDateController.text.trim() ==
                            _formatDate(_startDate!)
                    ? _startDate
                    : DateTime.tryParse(_startDateController.text.trim());
                if (start != null && end.isBefore(start)) {
                  return 'Tanggal selesai harus setelah tanggal mulai';
                }
                return null;
              },
            ),
            BlocSelector<
              AcademicYearMutationBloc,
              AcademicYearMutationState,
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
                              final name = _nameController.text.trim();
                              final start =
                                  _startDate != null &&
                                      _startDateController.text.trim() ==
                                          _formatDate(_startDate!)
                                  ? _startDate!
                                  : DateTime.parse(
                                      _startDateController.text.trim(),
                                    );
                              final end =
                                  _endDate != null &&
                                      _endDateController.text.trim() ==
                                          _formatDate(_endDate!)
                                  ? _endDate!
                                  : DateTime.parse(
                                      _endDateController.text.trim(),
                                    );
                              if (widget.initial == null) {
                                context.read<AcademicYearMutationBloc>().add(
                                  AcademicYearMutationCreateRequested(
                                    name: name,
                                    startDate: start,
                                    endDate: end,
                                  ),
                                );
                              } else {
                                context.read<AcademicYearMutationBloc>().add(
                                  AcademicYearMutationUpdateRequested(
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
                          context.read<AcademicYearMutationBloc>().add(
                            AcademicYearMutationDeleteRequested(
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
