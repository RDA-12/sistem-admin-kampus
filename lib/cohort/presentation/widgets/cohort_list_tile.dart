import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/cohort/domain/domain.dart';
import 'package:sistem_admin/common/common.dart';

/// Shows a [ListTile] with [Cohort] data
class CohortListTile extends StatelessWidget {
  /// Creates new [CohortListTile]
  const new({
    required this.cohort,
    this.onPressed,
    this.selected = false,
    super.key,
  });

  /// [Cohort] data that will be shown
  final Cohort cohort;

  /// Invoked when this cohort tile is pressed
  final VoidCallback? onPressed;

  /// Whether this tile is selected or not
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      selected: selected,
      title: Text(cohort.name),
      subtitle: Text('Tahun Masuk: ${cohort.entryYear}'),
      trailing: const Icon(Icons.chevron_right_rounded),
      onPressed: onPressed,
    );
  }
}
