import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/room/domain/domain.dart';
import 'package:sistem_admin/room/presentation/bloc/bloc.dart';
import 'package:sistem_admin/room/presentation/models.dart';
import 'package:sistem_admin/room/presentation/widgets/delete_room_button.dart';

enum _FormState {
  idle,
  creating,
  updating,
  deleting;

  bool get isProcessing => this != _FormState.idle;
}

/// Form to create/update a [Room]
class RoomForm extends StatefulWidget {
  /// Creates new [RoomForm]
  ///
  /// It reacts to [RoomMutationBloc] and [FacultiesBloc] state changes.
  /// So, make sure to provide that bloc in the widget tree.
  const new({
    this.initial,
    this.onRoomDeleted,
    super.key,
  });

  /// Initial room data that will be showed
  final RoomUI? initial;

  /// Invoked when [initial] room data is deleted successfully
  final void Function(Room)? onRoomDeleted;

  @override
  State<RoomForm> createState() => _RoomFormState();
}

class _RoomFormState extends State<RoomForm> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late final FacultySelectorController _facultyController;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController(text: widget.initial?.name);
    _facultyController = FacultySelectorController(
      initial: widget.initial?.faculty,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _facultyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoomMutationBloc, RoomMutationState>(
      listenWhen: (p, c) => p.notice != c.notice,
      listener: (context, state) async {
        switch (state.notice) {
          case RoomMutationFailedNotice(
            :final type,
            :final exception,
          ):
            late final String title;
            switch (type) {
              case RoomMutationType.create:
                title = 'Gagal menyimpan ruangan baru';
              case RoomMutationType.update:
                title = 'Gagal memperbarui ruangan';
              case RoomMutationType.delete:
                title = 'Gagal menghapus ruangan';
            }
            unawaited(
              context.showFailedDialog(
                title: title,
                message: exception.code.message,
              ),
            );
          case RoomUpdatedNotice(:final before, :final after):
            unawaited(
              context.showSuccessDialog(
                title: 'Ruangan "${before.name}" berhasil diperbarui',
                message:
                    'Ruangan "${before.name}" berhasil diperbarui '
                    'dengan nama "${after.name}"',
              ),
            );
          case RoomCreatedNotice(:final created):
            unawaited(
              context.showSuccessDialog(
                title: 'Ruangan berhasil disimpan',
                message:
                    'Ruangan dengan nama "${created.name}" '
                    'berhasil disimpan',
              ),
            );
            _nameController.clear();
            _facultyController.clear();
          case RoomDeletedNotice(:final deleted):
            await context.showSuccessDialog(
              title: 'Ruangan berhasil dihapus',
              message:
                  'Ruangan dengan nama "${deleted.name}" '
                  'berhasil dihapus',
            );
            widget.onRoomDeleted?.call(deleted);
          case null:
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FacultySelector(
              label: 'Fakultas',
              controller: _facultyController,
            ),
            AppFormField(
              controller: _nameController,
              label: 'Nama Ruangan',
            ),
            BlocSelector<RoomMutationBloc, RoomMutationState, _FormState>(
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
                              if (_facultyController.selected == null) {
                                return;
                              }
                              final name = _nameController.text.trim();
                              final facultyId = _facultyController.selected!.id;
                              if (widget.initial == null) {
                                context.read<RoomMutationBloc>().add(
                                  RoomMutationCreateRequested(
                                    facultyId: facultyId,
                                    name: name,
                                  ),
                                );
                              } else {
                                context.read<RoomMutationBloc>().add(
                                  RoomMutationUpdateRequested(
                                    room: widget.initial!,
                                    name: name,
                                    facultyId: facultyId,
                                  ),
                                );
                              }
                            },
                    ),
                    if (widget.initial != null)
                      DeleteRoomButton(
                        room: widget.initial!,
                        isDeleting: formState == _FormState.deleting,
                        disable: formState.isProcessing,
                        onConfirmed: () {
                          context.read<RoomMutationBloc>().add(
                            RoomMutationDeleteRequested(
                              room: widget.initial!,
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
