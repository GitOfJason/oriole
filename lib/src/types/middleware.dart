abstract class OrioleMiddleware {
  final int priority;

  const OrioleMiddleware({this.priority = 500});

  Future<String?> redirectGuard(String path) async => null;

  Future<bool> canPop() async => true;

  Future onMatch() async {}

  Future onEnter() async {}

  Future onExit() async {}

  void onExited() {}
}

final class OrioleMiddlewareBuilder extends OrioleMiddleware {
  final Future<String?> Function(String)? redirectGuardFunc;

  final Future Function()? onMatchFunc;

  final Future Function()? onEnterFunc;

  final Future Function()? onExitFunc;

  final Function? onExitedFunc;

  final Future<bool> Function()? canPopFunc;

  OrioleMiddlewareBuilder({
    this.redirectGuardFunc,
    this.onMatchFunc,
    this.onEnterFunc,
    this.canPopFunc,
    this.onExitFunc,
    this.onExitedFunc,
    int priority = 500,
  }) : super(priority: priority);

  @override
  Future onEnter() async {
    if (onEnterFunc != null) {
      await onEnterFunc!();
    }
  }

  @override
  Future onExit() async {
    if (onExitFunc != null) {
      await onExitFunc!();
    }
  }

  @override
  void onExited() {
    if (onExitedFunc != null) {
      onExitedFunc!();
    }
  }

  @override
  Future onMatch() async {
    if (onMatchFunc != null) {
      await onMatchFunc!();
    }
  }

  @override
  Future<String?> redirectGuard(String path) async {
    if (redirectGuardFunc != null) {
      return redirectGuardFunc!(path);
    }
    return null;
  }

  @override
  Future<bool> canPop() async {
    if (canPopFunc != null) {
      return await canPopFunc!();
    }
    return true;
  }
}
