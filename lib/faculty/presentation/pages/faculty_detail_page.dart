import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/faculty/domain/domain.dart';

/// Page to shows [Faculty] data
class FacultyDetailPage extends StatelessWidget {
  /// Creates new [FacultyDetailPage]
  ///
  /// When [faculty] is null, it will try to get the [Faculty] based on [id]
  const new({
    required this.id,
    this.faculty,
    super.key,
  });

  /// ID of the [Faculty] that will be showed
  final String id;

  /// [Faculty] data that will be showed
  final Faculty? faculty;

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
