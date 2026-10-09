import 'package:sistem_admin/core/core.dart';

/// Base class for all repositories within this app
abstract class BaseRepository<T, SaveArgs, UpdateArgs> {
  /// Save new [T] with [args]
  Future<AppResult<T>> save(SaveArgs args);

  /// Delete [T] with [id]
  Future<AppResult<Null>> delete(String id);

  /// Watch for [T] data changes
  Stream<AppResult<List<T>>> watch();

  /// Update [T] with [id] based on [args]
  Future<AppResult<T>> update(String id, {required UpdateArgs args});
}
