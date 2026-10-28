import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/academic_calendar/presentation/widgets/delete_academic_term_button.dart';
import 'package:sistem_admin/common/common.dart';

/// Form to create/update an [AcademicTerm]
class AcademicTermForm extends StatefulWidget {
  /// Creates new [AcademicTermForm]
  const new({
    required this.academicYear,
    required this.onSave,
    this.initial,
    this.onDelete,
    this.isProcessing = false,
    this.isDeleting = false,
    super.key,
  });

  /// Parent [AcademicYear]
  final AcademicYear academicYear;

  /// Initial academic term data that will be shown
  final AcademicTerm? initial;

  /// Whether form is currently processing a save or delete operation
  final bool isProcessing;

  /// Whether form is currently deleting [initial]
  final bool isDeleting;

  /// Invoked when form is submitted with valid data
  final void Function({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
  }) onSave;

  /// Invoked when user confirms deletion of [initial]
  final void Function()? onDelete;

  @override
  State<AcademicTermForm> createState() => _AcademicTermFormState();
}

class _AcademicTermFormState extends State<AcademicTermForm> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late final AppDateFormFieldController _startDateController;
  late final AppDateFormFieldController _endDateController;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController(text: widget.initial?.name);
    _startDateController = AppDateFormFieldController(
      initial: widget.initial?.startDate,
    );
    _endDateController = AppDateFormFieldController(
      initial: widget.initial?.endDate,
    );
  }

  @override
  void didUpdateWidget(covariant AcademicTermForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial != widget.initial) {
      _nameController.text = widget.initial?.name ?? '';
      _startDateController.value = widget.initial?.startDate;
      _endDateController.value = widget.initial?.endDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final start = _startDateController.value;
    final end = _endDateController.value;
    if (start == null || end == null) return;
    final name = _nameController.text.trim();
    widget.onSave(
      name: name,
      startDate: start,
      endDate: end,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFormField(
            controller: _nameController,
            label: 'Nama Semester',
          ),
          AppDateFormField(
            controller: _startDateController,
            label: 'Tanggal Mulai',
          ),
          AppDateFormField(
            controller: _endDateController,
            label: 'Tanggal Selesai',
            validator: (end) {
              final start = _startDateController.value;
              if (start != null && end.isBefore(start)) {
                return 'Tanggal selesai harus setelah tanggal mulai';
              }
              return null;
            },
          ),
          Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppButton(
                leadingIcon: widget.isProcessing && !widget.isDeleting
                    ? const LoadingIndicator()
                    : const Icon(Icons.save_rounded),
                label: 'Simpan',
                onPressed: widget.isProcessing ? null : _submit,
              ),
              if (widget.initial != null && widget.onDelete != null)
                DeleteAcademicTermButton(
                  academicTerm: widget.initial!,
                  isDeleting: widget.isDeleting,
                  disable: widget.isProcessing,
                  onConfirmed: widget.onDelete,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
