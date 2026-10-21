import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/cohort/domain/domain.dart';
import 'package:sistem_admin/cohort/presentation/bloc/bloc.dart';
import 'package:sistem_admin/cohort/presentation/widgets/delete_cohort_button.dart';
import 'package:sistem_admin/common/common.dart';

enum _FormState {
  idle,
  creating,
  updating,
  deleting;

  bool get isProcessing => this != _FormState.idle;
}

/// Form to create/update a [Cohort]
class CohortForm extends StatefulWidget {
  /// Creates new [CohortForm]
  ///
  /// It reacts to [CohortMutationBloc]'s state changes.
  /// So, make sure to provide that bloc in the widget tree.
  const new({
    this.initial,
    this.onCohortDeleted,
    super.key,
  });

  /// Initial cohort data that will be showed
  final Cohort? initial;

  /// Invoked when [initial] cohort data is deleted successfully
  final void Function(Cohort)? onCohortDeleted;

  @override
  State<CohortForm> createState() => _CohortFormState();
}

class _CohortFormState extends State<CohortForm> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late final AppNumberFormFieldController _entryYearController;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController(text: widget.initial?.name);
    _entryYearController = AppNumberFormFieldController(
      initial: widget.initial?.entryYear,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _entryYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CohortMutationBloc, CohortMutationState>(
      listenWhen: (p, c) => p.notice != c.notice,
      listener: (context, state) async {
        switch (state.notice) {
          case CohortMutationFailedNotice(
            :final type,
            :final exception,
          ):
            late final String title;
            switch (type) {
              case CohortMutationType.create:
                title = 'Gagal menyimpan angkatan baru';
              case CohortMutationType.update:
                title = 'Gagal memperbarui angkatan';
              case CohortMutationType.delete:
                title = 'Gagal menghapus angkatan';
            }
            unawaited(
              context.showFailedDialog(
                title: title,
                message: exception.code.message,
              ),
            );
          case CohortUpdatedNotice(:final before, :final after):
            unawaited(
              context.showSuccessDialog(
                title: 'Angkatan "${before.name}" berhasil diperbarui',
                message:
                    'Angkatan "${before.name}" berhasil diperbarui '
                    'dengan nama "${after.name}"',
              ),
            );
          case CohortCreatedNotice(:final created):
            unawaited(
              context.showSuccessDialog(
                title: 'Angkatan berhasil disimpan',
                message:
                    'Angkatan dengan nama "${created.name}" berhasil disimpan',
              ),
            );
            _nameController.clear();
            _entryYearController.clear();
          case CohortDeletedNotice(:final deleted):
            await context.showSuccessDialog(
              title: 'Angkatan berhasil dihapus',
              message:
                  'Angkatan dengan nama "${deleted.name}" berhasil dihapus',
            );
            widget.onCohortDeleted?.call(deleted);
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
              label: 'Nama Angkatan',
            ),
            AppNumberFormField(
              controller: _entryYearController,
              label: 'Tahun Masuk',
              validator: (value) {
                if (value is! int || value <= 0) {
                  return 'Tahun masuk harus berupa angka positif';
                }
                return null;
              },
            ),
            BlocSelector<CohortMutationBloc, CohortMutationState, _FormState>(
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
                              final entryYear = _entryYearController.value
                                  .toInt();
                              if (widget.initial == null) {
                                context.read<CohortMutationBloc>().add(
                                  CohortMutationCreateRequested(
                                    name: name,
                                    entryYear: entryYear,
                                  ),
                                );
                              } else {
                                context.read<CohortMutationBloc>().add(
                                  CohortMutationUpdateRequested(
                                    cohort: widget.initial!,
                                    name: name,
                                    entryYear: entryYear,
                                  ),
                                );
                              }
                            },
                    ),
                    if (widget.initial != null)
                      DeleteCohortButton(
                        cohort: widget.initial!,
                        isDeleting: formState == _FormState.deleting,
                        disable: formState.isProcessing,
                        onConfirmed: () {
                          context.read<CohortMutationBloc>().add(
                            CohortMutationDeleteRequested(
                              cohort: widget.initial!,
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
