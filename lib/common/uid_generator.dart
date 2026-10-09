import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

/// Generator to generate unique ID
@Environment('prod')
@lazySingleton
class UidGenerator {
  /// Creates new [UidGenerator]
  new();

  final _uuid = const Uuid();

  /// Return new generated UID
  String generate() {
    return _uuid.v7();
  }
}
