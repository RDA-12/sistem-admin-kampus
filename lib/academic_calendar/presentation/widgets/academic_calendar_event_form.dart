import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/common/common.dart';

/// Form to create/update an [AcademicCalendarEvent]
class AcademicCalendarEventForm extends StatefulWidget {
  /// Creates new [AcademicCalendarEventForm]
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

  /// Initial academic calendar event data that will be shown
  final AcademicCalendarEvent? initial;

  /// Whether form is currently processing a save or delete operation
  final bool isProcessing;

  /// Whether form is currently deleting [initial]
  final bool isDeleting;

  /// Invoked when form is submitted with valid data
  final void Function({
    required String name,
    required AcademicCalendarEventType type,
    required EventDateTime start,
    required EventDateTime end,
    List<String> recurrence,
  })
  onSave;

  /// Invoked when user confirms deletion of [initial]
  final VoidCallback? onDelete;

  @override
  State<AcademicCalendarEventForm> createState() =>
      _AcademicCalendarEventFormState();
}

class _AcademicCalendarEventFormState extends State<AcademicCalendarEventForm> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late final AppDateFormFieldController _startDateController;
  late final AppDateFormFieldController _endDateController;
  late AcademicCalendarEventType _type;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController(text: widget.initial?.name);
    _startDateController = AppDateFormFieldController(
      initial: widget.initial?.start.date,
    );
    _endDateController = AppDateFormFieldController(
      initial: widget.initial?.end.date,
    );
    _type = widget.initial?.type ?? AcademicCalendarEventType.holiday;
  }

  @override
  void didUpdateWidget(covariant AcademicCalendarEventForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial != widget.initial) {
      _nameController.text = widget.initial?.name ?? '';
      _startDateController.value = widget.initial?.start.date;
      _endDateController.value = widget.initial?.end.date;
      _type = widget.initial?.type ?? AcademicCalendarEventType.holiday;
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
    final startDate = _startDateController.value;
    final endDate = _endDateController.value;
    if (startDate == null || endDate == null) return;
    final name = _nameController.text.trim();

    final startTime =
        widget.initial?.start.time ?? const Time(hour: 0, minute: 0);
    final endTime =
        widget.initial?.end.time ?? const Time(hour: 23, minute: 59);

    widget.onSave(
      name: name,
      type: _type,
      start: EventDateTime(date: startDate, time: startTime),
      end: EventDateTime(date: endDate, time: endTime),
      recurrence: widget.initial?.recurrence ?? const [],
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
            label: 'Nama Kegiatan',
          ),
          DropdownButtonFormField<AcademicCalendarEventType>(
            initialValue: _type,
            decoration: const InputDecoration(
              labelText: 'Jenis Kegiatan *',
            ),
            items: AcademicCalendarEventType.values
                .map(
                  (type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.label),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _type = value;
                });
              }
            },
          ),
          AppDateFormField(
            controller: _startDateController,
            label: 'Tanggal Mulai',
            validator: (start) {
              if (!widget.academicYear.includes(start)) {
                return 'Tanggal mulai harus berada dalam tahun akademik';
              }
              return null;
            },
          ),
          AppDateFormField(
            controller: _endDateController,
            label: 'Tanggal Selesai',
            validator: (end) {
              if (!widget.academicYear.includes(end)) {
                return 'Tanggal selesai harus berada dalam tahun akademik';
              }
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
            ],
          ),
        ],
      ),
    );
  }
}
