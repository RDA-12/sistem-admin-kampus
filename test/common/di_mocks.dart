import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';

import 'di_mocks.config.dart';

/// Initialize dependencies with [getIt] for testing
///
/// It should be run once
@InjectableInit(
  generateForEnvironments: {Environment(Environment.test)},
  generateForDir: ['test'],
  preferRelativeImports: true,
)
void initializeMockDependencies() => getIt.init(environment: Environment.test);
