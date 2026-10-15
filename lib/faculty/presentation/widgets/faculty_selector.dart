import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/domain/domain.dart';
import 'package:sistem_admin/faculty/presentation/bloc/bloc.dart';

/// Controller for [FacultySelector]
final class FacultySelectorController extends ChangeNotifier {
  /// Creates new [FacultySelectorController] with [initial] selected
  new({Faculty? initial}) {
    _selected = initial;
    _textEditingController = TextEditingController(text: initial?.name);
  }

  late final TextEditingController _textEditingController;

  /// [TextEditingController] for this
  TextEditingController get textEditingController => _textEditingController;

  Faculty? _selected;

  /// Current selected [Faculty]
  Faculty? get selected => _selected;

  set selected(Faculty? faculty) {
    _selected = faculty;
    _textEditingController.text = faculty?.name ?? '';
    notifyListeners();
  }

  /// Clear selected faculty
  void clear() {
    _selected = null;
    _textEditingController.text = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}

/// Selector to select a [Faculty]
class FacultySelector extends StatelessWidget {
  /// Creates new [FacultySelector]
  ///
  /// It reacts to [FacultiesBloc]'s state changes.
  /// So, make sure to provide it with that bloc.
  const new({
    required this.label,
    required this.controller,
    super.key,
  });

  /// Controls the [Faculty] being selected
  final FacultySelectorController controller;

  /// Label for this faculty selector
  final String label;

  Future<Faculty?> _showSelector({
    required BuildContext context,
    required BreakPoint breakPoint,
  }) {
    return context.showAppDialog(
      constraints: const BoxConstraints(
        minWidth: 560,
        maxWidth: 560,
        maxHeight: 560,
      ),
      title: 'Pilih Fakultas',
      contentBuilder: (_) {
        return BlocBuilder<FacultiesBloc, FacultiesState>(
          bloc: context.read<FacultiesBloc>(),
          builder: (context, state) {
            switch (state) {
              case FacultiesInitial():
              case LoadingFaculties():
                return const Center(
                  child: LoadingIndicator(),
                );
              case FacultiesLoaded(:final data):
                return ListenableBuilder(
                  listenable: controller,
                  builder: (context, child) {
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: .min,
                        children: data.map((it) {
                          final selected = it == controller.selected;
                          return CheckboxListTile(
                            value: selected,
                            title: Text(
                              it.name,
                              style: context.text.titleMedium?.copyWith(
                                color: selected
                                    ? context.color.onPrimaryContainer
                                    : null,
                              ),
                            ),
                            selected: selected,
                            selectedTileColor: context.color.primaryContainer,
                            onChanged: (checked) {
                              final selected = checked ?? false;
                              if (selected) {
                                Navigator.pop(context, it);
                              } else {
                                Navigator.pop(context);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              case FacultiesFailure(:final exception):
                return Center(
                  child: AppExceptionBox(
                    title: 'Gagal mengambil data fakultas',
                    exception: exception,
                  ),
                );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, breakPoint, _) {
        return AppFormField(
          readOnly: true,
          controller: controller.textEditingController,
          label: label,
          onPressed: () async {
            context.read<FacultiesBloc>().add(
              const FacultiesSubscriptionRequested(),
            );
            final result = await _showSelector(
              context: context,
              breakPoint: breakPoint,
            );
            controller.selected = result;
          },
        );
      },
    );
  }
}
