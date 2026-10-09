import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/di.config.dart';

/// Global getIt instance to get service
final GetIt getIt = GetIt.instance;

/// Initialize dependencies with [getIt] for apps
///
/// It should be run once
@InjectableInit(generateForEnvironments: {Environment(Environment.prod)})
void initializeDependencies() => getIt.init(environment: Environment.prod);
