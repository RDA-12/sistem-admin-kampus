import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/domain/domain.dart';
import 'package:sistem_admin/faculty/presentation/bloc/bloc.dart';

/// Form to create/update a [Faculty]
class FacultyForm extends StatefulWidget {
  /// Creates new [FacultyForm]
  ///
  /// It reacts to [FacultyMutationBloc]'s state changes.
  /// So, make sure to provide that bloc in the widget tree.
  const new({
    this.initial,
    super.key,
  });

  /// Initial faculty data that will be showed
  final Faculty? initial;

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
      listener: (context, state) {
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
              case _:
                break;
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
          default:
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
            BlocSelector<FacultyMutationBloc, FacultyMutationState, bool>(
              selector: (state) {
                return state.isCreating ||
                    state.updatingIds.contains(widget.initial?.id);
              },
              builder: (context, isProcessing) {
                return AppButton(
                  leadingIcon: isProcessing
                      ? const LoadingIndicator()
                      : const Icon(Icons.save_rounded),
                  label: 'Simpan',
                  onPressed: isProcessing
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
