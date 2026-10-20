import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';

/// Shows an empty state message in a box with minimum size constraints.
class AppEmptyBox extends StatelessWidget {
  /// Creates a new [AppEmptyBox].
  const new({
    this.message = 'Belum ada data',
    this.constraints = const BoxConstraints(minWidth: 120, minHeight: 120),
    super.key,
  });

  /// The message displayed inside the box.
  final String message;

  /// Size constraints for the box.
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: constraints,
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: Text(
          message,
          style: context.text.bodyMedium,
          textAlign: .center,
        ),
      ),
    );
  }
}
