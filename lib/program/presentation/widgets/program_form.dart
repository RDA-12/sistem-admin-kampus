import 'package:flutter/widgets.dart';
import 'package:sistem_admin/program/domain/domain.dart';

/// Form to create/update a [Program]
class ProgramForm extends StatelessWidget {
  /// Creates new [ProgramForm]
  const new({
    this.initial,
    this.onProgramDeleted,
    super.key,
  });

  /// Initial program data that will be showed
  final Program? initial;

  /// Invoked when [initial] program data is deleted successfully
  final void Function(Program)? onProgramDeleted;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
