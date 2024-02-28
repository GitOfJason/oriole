abstract class OrioleException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const OrioleException(this.message, {this.stackTrace});

  String _returnStackTrace() => stackTrace != null ? '\n$stackTrace' : '';

  @override
  String toString() {
    return '$runtimeType: $message${_returnStackTrace()}';
  }
}


class OrioleError extends OrioleException {
  const OrioleError(super.message, {super.stackTrace});
}
