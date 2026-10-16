import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/lecturer/domain/domain.dart';
import 'package:sistem_admin/lecturer/presentation/bloc/bloc.dart';
import 'package:sistem_admin/lecturer/presentation/models.dart';
import 'package:sistem_admin/lecturer/presentation/widgets/delete_lecturer_button.dart';
import 'package:sistem_admin/program/program.dart';

enum _FormState {
  idle,
  creating,
  updating,
  deleting;

  bool get isProcessing => this != _FormState.idle;
}

/// Form to create/update a [Lecturer]
class LecturerForm extends StatefulWidget {
  /// Creates new [LecturerForm]
  ///
  /// It reacts to [LecturerMutationBloc] and [ProgramsBloc] state changes.
  /// So, make sure to provide that bloc in the widget tree.
  const new({
    this.initial,
    this.onLecturerDeleted,
    super.key,
  });

  /// Initial lecturer data that will be showed
  final LecturerUI? initial;

  /// Invoked when [initial] lecturer data is deleted successfully
  final void Function(Lecturer)? onLecturerDeleted;

  @override
  State<LecturerForm> createState() => _LecturerFormState();
}

class _LecturerFormState extends State<LecturerForm> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late final TextEditingController _pangkatGolonganController;
  late final ProgramSelectorController _programController;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController(text: widget.initial?.name);
    _pangkatGolonganController = TextEditingController(
      text: widget.initial?.pangkatGolongan,
    );
    _programController = ProgramSelectorController(
      initial: widget.initial?.program,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pangkatGolonganController.dispose();
    _programController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LecturerMutationBloc, LecturerMutationState>(
      listenWhen: (p, c) => p.notice != c.notice,
      listener: (context, state) async {
        switch (state.notice) {
          case LecturerMutationFailedNotice(
            :final type,
            :final exception,
          ):
            late final String title;
            switch (type) {
              case LecturerMutationType.create:
                title = 'Gagal menyimpan dosen baru';
              case LecturerMutationType.update:
                title = 'Gagal memperbarui dosen';
              case LecturerMutationType.delete:
                title = 'Gagal menghapus dosen';
            }
            unawaited(
              context.showFailedDialog(
                title: title,
                message: exception.code.message,
              ),
            );
          case LecturerUpdatedNotice(:final before, :final after):
            unawaited(
              context.showSuccessDialog(
                title: 'Dosen "${before.name}" berhasil diperbarui',
                message:
                    'Dosen "${before.name}" berhasil diperbarui '
                    'dengan nama "${after.name}"',
              ),
            );
          case LecturerCreatedNotice(:final created):
            unawaited(
              context.showSuccessDialog(
                title: 'Dosen berhasil disimpan',
                message:
                    'Dosen dengan nama "${created.name}" '
                    'berhasil disimpan',
              ),
            );
            _nameController.clear();
            _pangkatGolonganController.clear();
            _programController.clear();
          case LecturerDeletedNotice(:final deleted):
            await context.showSuccessDialog(
              title: 'Dosen berhasil dihapus',
              message:
                  'Dosen dengan nama "${deleted.name}" '
                  'berhasil dihapus',
            );
            widget.onLecturerDeleted?.call(deleted);
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
              controller: _nameController,
              label: 'Nama Dosen',
            ),
            AppFormField(
              controller: _pangkatGolonganController,
              label: 'Pangkat / Golongan',
            ),
            BlocSelector<
              LecturerMutationBloc,
              LecturerMutationState,
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
                              if (_programController.selected == null) {
                                return;
                              }
                              final name = _nameController.text.trim();
                              final pangkatGolongan = _pangkatGolonganController
                                  .text
                                  .trim();
                              final programId = _programController.selected!.id;
                              if (widget.initial == null) {
                                context.read<LecturerMutationBloc>().add(
                                  LecturerMutationCreateRequested(
                                    programId: programId,
                                    name: name,
                                    pangkatGolongan: pangkatGolongan,
                                  ),
                                );
                              } else {
                                context.read<LecturerMutationBloc>().add(
                                  LecturerMutationUpdateRequested(
                                    lecturer: widget.initial!,
                                    name: name,
                                    pangkatGolongan: pangkatGolongan,
                                    programId: programId,
                                  ),
                                );
                              }
                            },
                    ),
                    if (widget.initial != null)
                      DeleteLecturerButton(
                        lecturer: widget.initial!,
                        isDeleting: formState == _FormState.deleting,
                        disable: formState.isProcessing,
                        onConfirmed: () {
                          context.read<LecturerMutationBloc>().add(
                            LecturerMutationDeleteRequested(
                              lecturer: widget.initial!,
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
