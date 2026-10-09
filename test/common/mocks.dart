import 'package:injectable/injectable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';

@LazySingleton(as: UidGenerator, env: [Environment.test])
class MockUidGenerator extends Mock implements UidGenerator;
