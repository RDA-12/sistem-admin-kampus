import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/program/domain/domain.dart';
import 'package:sistem_admin/program/presentation/bloc/bloc.dart';

enum _FormState {
  idle,
  creating,
  updating,
  deleting;

  bool get isProcessing => this != _FormState.idle;
}

/// Form to create/update a [Program]
class ProgramForm extends StatefulWidget {
  /// Creates new [ProgramForm]
  ///
  /// It reacts to [ProgramMutationBloc]'s state changes.
  /// So, make sure to provide that bloc in the widget tree.
  const new({
    this.initial,
    this.onProgramDeleted,
    super.key,
  });

  /// Initial program data that will be showed
  final Program? initial;

  /// Invoked when [initial] program data is deleted successfully
  final void Function(Program)? onProgramDeleted;

  @override
  State<ProgramForm> createState() => _ProgramFormState();
}

class _ProgramFormState extends State<ProgramForm> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late final TextEditingController _facultyIdController;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController(text: widget.initial?.name);
    _facultyIdController = TextEditingController(
      text: widget.initial?.facultyId,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _facultyIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProgramMutationBloc, ProgramMutationState>(
      listenWhen: (p, c) => p.notice != c.notice,
      listener: (context, state) async {
        switch (state.notice) {
          case ProgramMutationFailedNotice(
            :final type,
            :final exception,
          ):
            late final String title;
            switch (type) {
              case ProgramMutationType.create:
                title = 'Gagal menyimpan program studi baru';
              case ProgramMutationType.update:
                title = 'Gagal memperbarui program studi';
              case ProgramMutationType.delete:
                title = 'Gagal menghapus program studi';
            }
            unawaited(
              context.showFailedDialog(
                title: title,
                message: exception.code.message,
              ),
            );
          case ProgramUpdatedNotice(:final before, :final after):
            unawaited(
              context.showSuccessDialog(
                title: 'Program studi "${before.name}" berhasil diperbarui',
                message:
                    'Program studi "${before.name}" berhasil diperbarui '
                    'dengan nama "${after.name}"',
              ),
            );
          case ProgramCreatedNotice(:final created):
            unawaited(
              context.showSuccessDialog(
                title: 'Program studi berhasil disimpan',
                message:
                    'Program studi dengan nama "${created.name}" '
                    'berhasil disimpan',
              ),
            );
            _nameController.clear();
            _facultyIdController.clear();
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
              controller: _facultyIdController,
              label: 'ID Fakultas',
            ),
            AppFormField(
              controller: _nameController,
              label: 'Nama Program Studi',
            ),
            BlocSelector<ProgramMutationBloc, ProgramMutationState, _FormState>(
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
                              final name = _nameController.text.trim();
                              final facultyId = _facultyIdController.text
                                  .trim();
                              if (widget.initial == null) {
                                context.read<ProgramMutationBloc>().add(
                                  ProgramMutationCreateRequested(
                                    facultyId: facultyId,
                                    name: name,
                                  ),
                                );
                              } else {
                                context.read<ProgramMutationBloc>().add(
                                  ProgramMutationUpdateRequested(
                                    program: widget.initial!,
                                    name: name,
                                  ),
                                );
                              }
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
