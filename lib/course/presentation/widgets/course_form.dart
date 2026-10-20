import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course/domain/domain.dart';
import 'package:sistem_admin/course/presentation/bloc/bloc.dart';
import 'package:sistem_admin/course/presentation/models.dart';
import 'package:sistem_admin/course/presentation/widgets/delete_course_button.dart';
import 'package:sistem_admin/course/presentation/widgets/semester_dropdown.dart';
import 'package:sistem_admin/program/program.dart';

enum _FormState {
  idle,
  creating,
  updating,
  deleting;

  bool get isProcessing => this != _FormState.idle;
}

/// Form to create/update a [Course]
class CourseForm extends StatefulWidget {
  /// Creates new [CourseForm]
  ///
  /// It reacts to [CourseMutationBloc] and [ProgramsBloc] state changes.
  /// So, make sure to provide that bloc in the widget tree.
  const new({
    this.initial,
    this.onCourseDeleted,
    super.key,
  });

  /// Initial course data that will be showed
  final CourseUI? initial;

  /// Invoked when [initial] course data is deleted successfully
  final void Function(Course)? onCourseDeleted;

  @override
  State<CourseForm> createState() => _CourseFormState();
}

class _CourseFormState extends State<CourseForm> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late final SemesterDropdownController _semesterController;
  late final AppNumberFormFieldController _creditController;
  late final ProgramSelectorController _programController;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _codeController = TextEditingController(text: widget.initial?.code);
    _nameController = TextEditingController(text: widget.initial?.name);
    _semesterController = SemesterDropdownController(
      initial: widget.initial?.semester,
    );
    _creditController = AppNumberFormFieldController(
      initial: widget.initial?.credit,
    );
    _programController = ProgramSelectorController(
      initial: widget.initial?.program,
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _semesterController.dispose();
    _creditController.dispose();
    _programController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CourseMutationBloc, CourseMutationState>(
      listenWhen: (p, c) => p.notice != c.notice,
      listener: (context, state) async {
        switch (state.notice) {
          case CourseMutationFailedNotice(
            :final type,
            :final exception,
          ):
            late final String title;
            switch (type) {
              case CourseMutationType.create:
                title = 'Gagal menyimpan mata kuliah baru';
              case CourseMutationType.update:
                title = 'Gagal memperbarui mata kuliah';
              case CourseMutationType.delete:
                title = 'Gagal menghapus mata kuliah';
            }
            unawaited(
              context.showFailedDialog(
                title: title,
                message: exception.code.message,
              ),
            );
          case CourseUpdatedNotice(:final before, :final after):
            unawaited(
              context.showSuccessDialog(
                title: 'Mata kuliah "${before.name}" berhasil diperbarui',
                message:
                    'Mata kuliah "${before.name}" berhasil diperbarui '
                    'dengan nama "${after.name}"',
              ),
            );
          case CourseCreatedNotice(:final created):
            unawaited(
              context.showSuccessDialog(
                title: 'Mata kuliah berhasil disimpan',
                message:
                    'Mata kuliah dengan nama "${created.name}" '
                    'berhasil disimpan',
              ),
            );
            _codeController.clear();
            _nameController.clear();
            _semesterController.clear();
            _creditController.clear();
            _programController.clear();
          case CourseDeletedNotice(:final deleted):
            await context.showSuccessDialog(
              title: 'Mata kuliah berhasil dihapus',
              message:
                  'Mata kuliah dengan nama "${deleted.name}" '
                  'berhasil dihapus',
            );
            widget.onCourseDeleted?.call(deleted);
          case null:
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProgramSelector(
              label: 'Program Studi',
              controller: _programController,
            ),
            AppFormField(
              controller: _codeController,
              label: 'Kode Mata Kuliah',
            ),
            AppFormField(
              controller: _nameController,
              label: 'Nama Mata Kuliah',
            ),
            SemesterDropdown(
              controller: _semesterController,
            ),
            AppNumberFormField(
              controller: _creditController,
              label: 'Bobot SKS',
              validator: (value) {
                if (value is! int || value <= 0) {
                  return 'SKS harus berupa angka positif';
                }
                return null;
              },
            ),
            BlocSelector<CourseMutationBloc, CourseMutationState, _FormState>(
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
                              if (_programController.selected == null) {
                                return;
                              }
                              final semester = _semesterController.value;
                              if (semester <= 0) {
                                return;
                              }
                              final code = _codeController.text.trim();
                              final name = _nameController.text.trim();
                              final credit = _creditController.value.toInt();
                              final programId = _programController.selected!.id;
                              if (widget.initial == null) {
                                context.read<CourseMutationBloc>().add(
                                  CourseMutationCreateRequested(
                                    programId: programId,
                                    code: code,
                                    name: name,
                                    semester: semester,
                                    credit: credit,
                                  ),
                                );
                              } else {
                                context.read<CourseMutationBloc>().add(
                                  CourseMutationUpdateRequested(
                                    course: widget.initial!,
                                    code: code,
                                    name: name,
                                    semester: semester,
                                    credit: credit,
                                    programId: programId,
                                  ),
                                );
                              }
                            },
                    ),
                    if (widget.initial != null)
                      DeleteCourseButton(
                        course: widget.initial!,
                        isDeleting: formState == _FormState.deleting,
                        disable: formState.isProcessing,
                        onConfirmed: () {
                          context.read<CourseMutationBloc>().add(
                            CourseMutationDeleteRequested(
                              course: widget.initial!,
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
