import 'package:drift/drift.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/data/drift_table.dart';
import 'package:sistem_admin/room/domain/domain.dart';

/// Drift database model for [Room]
@DataClassName('RoomDb')
class RoomsDrift extends Table with AppClockMixin {
  @override
  String? get tableName => 'rooms';

  /// ID of the room
  TextColumn get id => text()();

  /// ID of the parent faculty
  TextColumn get facultyId =>
      text().references(FacultiesDrift, #id, onDelete: KeyAction.cascade)();

  /// Name of the room
  TextColumn get name => text()();

  /// When this room created
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(getCurrentDateTime)();

  /// When the last time this room updated
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(getCurrentDateTime)();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  List<Set<Column>>? get uniqueKeys => [
    {facultyId, name},
  ];
}

/// Helper to convert [RoomDb] to [Room]
extension ToDomainX on RoomDb {
  /// Returns [Room] of this [RoomDb]
  Room toDomain() => Room(
    id: id,
    facultyId: facultyId,
    name: name,
  );
}

/// Helper to convert [UpdateRoomParams] to [RoomsDriftCompanion]
extension ToCompanionX on UpdateRoomParams {
  /// Returns [RoomsDriftCompanion] of this [UpdateRoomParams]
  RoomsDriftCompanion toCompanion() => RoomsDriftCompanion(
    name: name == null ? const Value.absent() : Value(name!),
    facultyId: facultyId == null ? const Value.absent() : Value(facultyId!),
  );
}
