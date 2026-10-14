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
