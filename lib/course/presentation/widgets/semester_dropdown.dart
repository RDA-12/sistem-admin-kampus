import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/theme/theme.dart';

/// Controls [SemesterDropdown] value
final class SemesterDropdownController {
  /// Creates new [SemesterDropdownController] with [initial] value
  new({int? initial})
    : _textEditingController = TextEditingController(
        text: initial?.toString(),
      ),
      _value = initial ?? 0 {
    _textEditingController.addListener(_onTextChanged);
  }

  final TextEditingController _textEditingController;

  /// Returns [TextEditingController] to be passed to [DropdownMenu]
  TextEditingController get textEditingController => _textEditingController;

  int _value;

  /// Returns current selected semester value
  int get value => _value;

  /// Updates the value of this controller and syncs the text field
  set value(int newValue) {
    if (_value == newValue &&
        _textEditingController.text == newValue.toString()) {
      return;
    }
    _value = newValue;
    _textEditingController.text = newValue.toString();
  }

  void _onTextChanged() {
    final text = _textEditingController.text.trim();
    final parsed = int.tryParse(text);
    if (parsed == null) {
      _value = 0;
    } else {
      _value = parsed;
    }
  }

  /// Clear the text field and reset value to 0
  void clear() {
    _value = 0;
    _textEditingController.clear();
  }

  /// Dispose this controller
  void dispose() {
    _textEditingController
      ..removeListener(_onTextChanged)
      ..dispose();
  }
}

/// Dropdown menu to select semester from 1 to 14
class SemesterDropdown extends StatelessWidget {
  /// Creates new [SemesterDropdown]
  const new({
    this.controller,
    super.key,
  });

  /// Controller for this dropdown
  final SemesterDropdownController? controller;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<int>(
      controller: controller?.textEditingController,
      initialSelection:
          controller != null && controller!.value > 0 ? controller!.value : null,
      expandedInsets: EdgeInsets.zero,
      label: const Text('Semester *'),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        fillColor: context.color.surfaceContainer,
        filled: true,
        border: WidgetStateInputBorder.resolveWith((states) {
          final basicBorder = UnderlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          );
          if (states.contains(WidgetState.error)) {
            return basicBorder.copyWith(
              borderSide: const BorderSide(color: Colors.red),
            );
          }
          if (states.contains(WidgetState.focused)) {
            return basicBorder.copyWith(
              borderSide: BorderSide(color: context.color.primary),
            );
          }
          return basicBorder;
        }),
      ),
      dropdownMenuEntries: List.generate(
        14,
        (index) {
          final semester = index + 1;
          return DropdownMenuEntry(
            value: semester,
            label: '$semester',
          );
        },
      ),
    );
  }
}
