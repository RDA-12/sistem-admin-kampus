import 'package:material_ui/material_ui.dart';

/// Creates [CircularProgressIndicator] with [size]
class LoadingIndicator extends StatelessWidget {
  /// Creates new [LoadingIndicator]
  const new({this.size = 24, super.key});

  /// Size of the indicator
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: const CircularProgressIndicator(),
    );
  }
}
