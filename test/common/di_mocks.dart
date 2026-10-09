import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'di_mocks.config.dart';

/// Global getIt instance to get service for testing
final GetIt getItMock = GetIt.instance;

/// Initialize dependencies with [getItMock] for testing
///
/// It should be run once
@InjectableInit(
  generateForEnvironments: {Environment(Environment.test)},
  generateForDir: ['test'],
  preferRelativeImports: true,
)
void initializeMockDependencies() =>
    getItMock.init(environment: Environment.test);
