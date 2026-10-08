import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/domain/domain.dart';
import 'package:sistem_admin/faculty/presentation/widgets/widgets.dart';

/// Page for creating new [Faculty]
class CreateFacultyPage extends StatelessWidget {
  /// Creates new [CreateFacultyPage]
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: context.pagePadding,
        child: const FacultyForm(),
      ),
    );
  }
}
