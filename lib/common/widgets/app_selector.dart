import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Controller for [AppSelector]
class AppSelectorController<T> extends ChangeNotifier {
  /// Creates new [AppSelectorController] with [initial] selected
  new({required this.itemAsString, T? initial, List<T>? initialItems}) {
    _items = initialItems ?? [];
    _selected = initial;
    _textEditingController = TextEditingController(
      text: initial == null ? null : itemAsString(initial),
    );
  }

  /// Function to get string of [T] that will be showed to user
  final String Function(T) itemAsString;

  late final TextEditingController _textEditingController;

  /// [TextEditingController] for this
  TextEditingController get textEditingController => _textEditingController;

  T? _selected;

  /// Current selected [T]
  T? get selected => _selected;

  set selected(T? value) {
    _selected = value;
    _textEditingController.text = value == null ? '' : itemAsString(value);
    notifyListeners();
  }

  List<T> _items = [];

  /// List of [T] that will be showed to users
  List<T> get items => _items;

  set items(List<T> items) {
    _items = items;
    notifyListeners();
  }

  bool _isLoading = false;

  /// Whether this selector is in loading state or not
  bool get isLoading => _isLoading;

  set isLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  AppException? _exception;

  /// Set exception to be showed to user
  ///
  /// When this is not null, selector dialog will shows [AppExceptionBox]
  AppException? get exception => _exception;

  set exception(AppException? exception) {
    _exception = exception;
    notifyListeners();
  }

  /// Clear selected item
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

/// Selector to select a [T]
///
/// It opening a dialog which contains all items of [T] that can be selected
class AppSelector<T> extends StatelessWidget {
  /// Creates new [AppSelector]
  const new({
    required this.label,
    required this.dialogTitle,
    required this.controller,
    this.onPressed,
    super.key,
  });

  /// Controls the [T] being selected
  final AppSelectorController<T> controller;

  /// Label for this selector
  final String label;

  /// Title for the dialog which contains list of [T] that can be selected
  final String dialogTitle;

  /// Invoked when user tap the selector to shows the dialog
  ///
  /// Typically use to populate data of [T], like adding new event to bloc.
  ///
  /// It will be called before opening the dialog.
  final VoidCallback? onPressed;

  Future<T?> _showSelector({
    required BuildContext context,
    required BreakPoint breakPoint,
  }) {
    return context.showAppDialog(
      constraints: const BoxConstraints(
        minWidth: 560,
        maxWidth: 560,
        maxHeight: 560,
      ),
      title: dialogTitle,
      contentBuilder: (_) {
        return ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            if (controller.isLoading) {
              return const Center(
                child: LoadingIndicator(),
              );
            }
            if (controller.exception != null) {
              return Center(
                child: AppExceptionBox(
                  title: 'Gagal mengambil data',
                  exception: controller.exception!,
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: .min,
                children: controller.items.map((it) {
                  final selected = it == controller.selected;
                  return CheckboxListTile(
                    value: selected,
                    title: Text(
                      controller.itemAsString(it),
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
            onPressed?.call();
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
