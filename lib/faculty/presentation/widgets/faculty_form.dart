import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/domain/domain.dart';
import 'package:sistem_admin/faculty/presentation/bloc/bloc.dart';
import 'package:sistem_admin/faculty/presentation/widgets/delete_faculty_button.dart';

enum _FormState {
  idle,
  creating,
  updating,
  deleting;

  bool get isProcessing => this != _FormState.idle;
}

/// Form to create/update a [Faculty]
class FacultyForm extends StatefulWidget {
  /// Creates new [FacultyForm]
  ///
  /// It reacts to [FacultyMutationBloc]'s state changes.
  /// So, make sure to provide that bloc in the widget tree.
  const new({
    this.initial,
    this.onFacultyDeleted,
    super.key,
  });

  /// Initial faculty data that will be showed
  final Faculty? initial;

  /// Invoked when [initial] faculty data is deleted successfully
  final void Function(Faculty)? onFacultyDeleted;

  @override
  State<FacultyForm> createState() => _FacultyFormState();
}

class _FacultyFormState extends State<FacultyForm> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController(text: widget.initial?.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FacultyMutationBloc, FacultyMutationState>(
      listenWhen: (p, c) => p.notice != c.notice,
      listener: (context, state) async {
        switch (state.notice) {
          case FacultyMutationFailedNotice(
            :final type,
            :final exception,
          ):
            late final String title;
            switch (type) {
              case FacultyMutationType.create:
                title = 'Gagal menyimpan fakultas baru';
              case FacultyMutationType.update:
                title = 'Gagal memperbarui fakultas';
              case FacultyMutationType.delete:
                title = 'Gagal menghapus fakultas';
            }
            unawaited(
              context.showFailedDialog(
                title: title,
                message: exception.code.message,
              ),
            );
          case FacultyUpdatedNotice(:final before, :final after):
            unawaited(
              context.showSuccessDialog(
                title: 'Fakultas "${before.name}" berhasil diperbarui',
                message:
                    'Fakulas "${before.name}" berhasil diperbarui '
                    'dengan nama "${after.name}"',
              ),
            );
          case FacultyCreatedNotice(:final created):
            unawaited(
              context.showSuccessDialog(
                title: 'Fakultas berhasil disimpan',
                message:
                    'Fakulas dengan nama "${created.name}" berhasil disimpan',
              ),
            );
            _nameController.clear();
          case FacultyDeletedNotice(:final deleted):
            await context.showSuccessDialog(
              title: 'Fakultas berhasil dihapus',
              message: 'Fakulas dengan nama "${deleted.name}" berhasil dihapus',
            );
            widget.onFacultyDeleted?.call(deleted);
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
              label: 'Nama Fakultas',
            ),
            BlocSelector<FacultyMutationBloc, FacultyMutationState, _FormState>(
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
                              if (widget.initial == null) {
                                context.read<FacultyMutationBloc>().add(
                                  FacultyMutationCreateRequested(name: name),
                                );
                              } else {
                                context.read<FacultyMutationBloc>().add(
                                  FacultyMutationUpdateRequested(
                                    faculty: widget.initial!,
                                    name: name,
                                  ),
                                );
                              }
                            },
                    ),
                    if (widget.initial != null)
                      DeleteFacultyButton(
                        faculty: widget.initial!,
                        isDeleting: formState == _FormState.deleting,
                        disable: formState.isProcessing,
                        onConfirmed: () {
                          context.read<FacultyMutationBloc>().add(
                            FacultyMutationDeleteRequested(
                              faculty: widget.initial!,
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
