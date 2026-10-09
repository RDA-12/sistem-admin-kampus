import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';

@Environment(Environment.test)
@module
abstract class RegisterTestModule {
  @lazySingleton
  AppDriftDatabase get database => AppDriftDatabase.forTesting(
    DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true,
    ),
  );
}
