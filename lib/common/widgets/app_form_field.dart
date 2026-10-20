import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/theme/theme.dart';

/// Styled [TextFormField] based on this app
class AppFormField extends StatelessWidget {
  /// Creates new [AppFormField]
  const new({
    required this.label,
    this.isRequired = true,
    this.readOnly = false,
    this.controller,
    this.validator,
    this.onPressed,
    this.keyboardType,
    this.inputFormatters,
    super.key,
  });

  /// Controller that will be passed to [TextFormField]
  final TextEditingController? controller;

  /// Label for this field
  final String label;

  /// Whether this field is required or not
  final bool isRequired;

  /// Optional validator to be passed to [TextFormField]
  ///
  /// When isRequired is true, it will be passed after required validator
  /// check. So, when set isRequired to true, no need to check for empty value
  /// again, the String passed to this validator will always be non null
  final String? Function(String?)? validator;

  /// Invoked when this form field is pressed
  final VoidCallback? onPressed;

  /// Whether this form field is readonly or not
  ///
  /// When its true, user cannot enter text to it.
  final bool readOnly;

  /// The type of information for which to optimize the text input control
  final TextInputType? keyboardType;

  /// Optional input validation and formatting overrides
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    var effectiveLabel = label;
    if (isRequired) {
      effectiveLabel += ' *';
    }

    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onPressed,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        label: Text(effectiveLabel),
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
      validator: (value) {
        if (isRequired) {
          if (value == null || value.isEmpty) {
            return 'Kolom ini wajib diisi';
          }
        }
        return validator?.call(value);
      },
    );
  }
}

/// Controls [AppNumberFormField] value
final class AppNumberFormFieldController {
  /// Creates new [AppNumberFormFieldController] with [initial] value
  new({num? initial})
    : _textEditingController = TextEditingController(
        text: initial?.toString(),
      ),
      _value = initial ?? 0 {
    _textEditingController.addListener(_onTextChanged);
  }

  final TextEditingController _textEditingController;

  /// Returns [TextEditingController] to be passed to [TextField]
  TextEditingController get textEditingController => _textEditingController;

  num _value;

  /// Returns value of this controller
  num get value => _value;

  /// Updates the value of this controller and syncs the text field
  set value(num newValue) {
    if (_value == newValue &&
        _textEditingController.text == newValue.toString()) {
      return;
    }
    _value = newValue;
    _textEditingController.text = newValue.toString();
  }

  void _onTextChanged() {
    final text = _textEditingController.text.trim();
    final parsed = num.tryParse(text);
    if (parsed == null) {
      _value = 0;
    } else {
      _value = parsed;
    }
  }

  /// Dispose this controller
  void dispose() {
    _textEditingController
      ..removeListener(_onTextChanged)
      ..dispose();
  }
}

/// [AppFormField] with number
class AppNumberFormField extends StatelessWidget {
  /// Creates new [AppNumberFormField]
  const new({
    required this.label,
    this.isRequired = true,
    this.readOnly = false,
    this.controller,
    this.validator,
    this.inputFormatters,
    super.key,
  });

  /// Controller that will be passed to [TextFormField]
  final AppNumberFormFieldController? controller;

  /// Label for this field
  final String label;

  /// Whether this field is required or not
  final bool isRequired;

  /// Optional validator to be passed to [TextFormField]
  ///
  /// When isRequired is true, it will be passed after required validator
  /// check. So, when set isRequired to true, no need to check for empty value
  /// again, the String passed to this validator will always be non null
  final String? Function(num)? validator;

  /// Whether this form field is readonly or not
  ///
  /// When its true, user cannot enter text to it.
  final bool readOnly;

  /// Optional input validation and formatting overrides
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return AppFormField(
      controller: controller?.textEditingController,
      label: label,
      isRequired: isRequired,
      readOnly: readOnly,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: inputFormatters,
      validator: (value) {
        if (!isRequired && (value == null || value.trim().isEmpty)) {
          return null;
        }
        final parsed = num.tryParse(value?.trim() ?? '');
        if (parsed == null) {
          return 'Angka tidak valid';
        }
        return validator?.call(parsed);
      },
    );
  }
}
