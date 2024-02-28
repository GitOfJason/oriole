final class Logger {
  Function(String) _logger = print;
  bool _enableDebugLog = false;
  bool _enableLog = false;

  config({
    bool enableLog = false,
    bool enableDebugLog = false,
    Function(String) logger = print,
  }) {
    _logger = logger;
    _enableLog = enableLog;
    _enableDebugLog = enableDebugLog;
  }

  log(String message, [bool isDebug = false]) {
    if (_enableLog && (!isDebug || _enableDebugLog)) {
      _logger('Oriole: $message');
    }
  }
}
