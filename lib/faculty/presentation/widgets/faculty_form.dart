import 'package:flutter/widgets.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/domain/domain.dart';

/// Form to create/update a [Faculty]
class FacultyForm extends StatefulWidget {
  /// Creates new [FacultyForm]
  ///
  /// Save button's label default to "Perbarui" when [initial] is provided.
  /// Otherwise, it shows "Simpan"
  const new({this.initial, this.onSaved, super.key});

  /// Initial faculty data that will be showed
  final Faculty? initial;

  /// Invoked when user pressed save button and the form is valid
  final void Function(String)? onSaved;

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
    return Form(
      key: _formKey,
      child: Column(
        spacing: 16,
        children: [
          AppFormField(
            controller: _nameController,
            label: 'Nama Fakultas',
          ),
          AppButton(
            label: widget.initial == null ? 'Simpan' : 'Perbarui',
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              final name = _nameController.text.trim();
              widget.onSaved?.call(name);
            },
          ),
        ],
      ),
    );
  }
}
