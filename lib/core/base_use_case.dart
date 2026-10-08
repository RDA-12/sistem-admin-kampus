import 'package:sistem_admin/core/app_result.dart';

/// Interface for use case returning Future
abstract interface class FutureBaseUseCase<P, R> {
  /// Run this use case
  Future<AppResult<R>> call(P params);
}

/// Interface for use case returning Stream
abstract interface class StreamBaseUseCase<P, R> {
  /// Watch this use case
  Stream<AppResult<R>> call(P params);
}
