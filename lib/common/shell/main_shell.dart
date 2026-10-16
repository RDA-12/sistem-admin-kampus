import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';

final class _MainDestination {
  const new({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

const _destinations = <_MainDestination>[
  _MainDestination(
    icon: Icons.school_rounded,
    label: 'Fakultas',
  ),
  _MainDestination(
    icon: Icons.book_rounded,
    label: 'Program Studi',
  ),
  _MainDestination(
    icon: Icons.person_rounded,
    label: 'Dosen',
  ),
  _MainDestination(
    icon: Icons.menu_book_rounded,
    label: 'Mata Kuliah',
  ),
  _MainDestination(
    icon: Icons.meeting_room_rounded,
    label: 'Ruangan',
  ),
];

/// Main shell which contains nav rail for large screen and
/// nav drawer for smaller screen
class MainShell extends StatelessWidget {
  /// Creates new [MainShell]
  const new({
    required this.child,
    required this.currentIndex,
    required this.onDestinationChanged,
    super.key,
  });

  /// Invoked when user tap on other destinations
  final void Function(int) onDestinationChanged;

  /// [Widget] that will be shown to the user
  final Widget child;

  /// Current active index
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, breakpoint, _) {
        final navRailShouldExpanded = !breakpoint.inside([.medium, .expanded]);
        final navRail = NavigationRail(
          extended: navRailShouldExpanded,
          labelType: navRailShouldExpanded ? null : NavigationRailLabelType.all,
          selectedIndex: currentIndex,
          onDestinationSelected: onDestinationChanged,
          indicatorColor: context.color.primaryContainer,
          backgroundColor: breakpoint > BreakPoint.compact
              ? context.mainShellSurface
              : null,
          destinations: _destinations.indexed.map((value) {
            final (index, it) = value;
            final isActive = index == currentIndex;
            return NavigationRailDestination(
              icon: Icon(
                it.icon,
                color: isActive
                    ? context.color.onPrimaryContainer
                    : context.color.onSurface,
              ),
              label: Text(
                it.label,
                style: context.text.bodyMedium?.copyWith(
                  color: isActive
                      ? context.color.onPrimaryContainer
                      : context.color.onSurface,
                ),
              ),
            );
          }).toList(),
        );
        late final Widget body;
        switch (breakpoint) {
          case BreakPoint.compact:
            body = child;
          case BreakPoint.medium:
          case BreakPoint.expanded:
          case BreakPoint.large:
            body = Row(
              children: [
                navRail,
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadiusGeometry.only(
                      topLeft: Radius.circular(16),
                    ),
                    child: child,
                  ),
                ),
              ],
            );
        }
        return Scaffold(
          backgroundColor: context.mainShellSurface,
          appBar: AppBar(
            backgroundColor: breakpoint > BreakPoint.compact
                ? context.mainShellSurface
                : null,
            title: breakpoint == BreakPoint.compact
                ? null
                : const Text('Sistem Administrasi'),
          ),
          drawer: breakpoint < BreakPoint.medium
              ? Drawer(child: navRail)
              : null,
          body: body,
        );
      },
    );
  }
}
