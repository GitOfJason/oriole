part of '../library_internal.dart';

extension OrioleNavigatorExt on OrioleNavigatorContext {
  Future<T?> go<T>(
    String path, {
    Map<String, dynamic>? params,
    bool ignoreSamePath = true,
    PageAlreadyExistAction? pageAlreadyExistAction,
    bool waitForResult = false,
  }) async {
    if (ignoreSamePath &&
        isCurrentPath(path) &&
        isCurrentName(path, params: params)) {
      return null;
    }
    final controller = _manager.withName(OrioleNavigatorContext.rootRouterName);
    var match = await controller.findPath(path, params: params);
    await _toMatch(match, pageAlreadyExistAction: pageAlreadyExistAction);
    if (waitForResult) return match.getFuture();
    return null;
  }

  Future<PopResult> back([dynamic result]) async {
    if (history.isEmpty) return PopResult.notPopped;
    final popupController = _manager.controllerWithPopup();
    if (popupController != null) {
      popupController.closePopup(result);
      return PopResult.popupDismissed;
    }

    final lastNavigator = history.current.navigator;
    if (_manager.hasController(lastNavigator)) {
      final popNavigatorOptions = [lastNavigator];
      if (history.hasLast && lastNavigator != history.last.navigator) {
        popNavigatorOptions.add(history.last.navigator);
      }

      for (final navigator in popNavigatorOptions) {
        final controller = navigatorOf(navigator);
        final popResult = await controller.removeLast(result: result);

        switch (popResult) {
          case PopResult.notPopped:
            if (navigator == popNavigatorOptions.last) {
              if (history.hasLast) {
                continue;
              }
              return popResult;
            }
            if (_isOnlyNavigatorLeft(popNavigatorOptions)) {
              history.removeWithNavigator(navigator);
            }
            break;
          case PopResult.popped:
            if (navigator != OrioleNavigatorContext.rootRouterName) {
              (rootNavigator as OrioleRouterController)
                  .update(withParams: false);
            }
            return PopResult.popped;
          default:
            return popResult;
        }
      }
    }

    go(history.last.path);
    history.removeLast(count: 2);
    return PopResult.popped;
  }

  Future<T?> push<T>(
    String path, {
    Map<String, dynamic>? params,
    bool waitForResult = false,
  }) {
    return navigator.push(
      path,
      params: params,
      waitForResult: waitForResult,
    );
  }

  Future<void> replace(String path, String withPath) {
    return navigator.replace(path, withPath);
  }

  Future<void> replaceAll(String path) => navigator.replaceAll(path);

  Future<void> replaceLast(String path) => navigator.replaceLast(path);

  Future<void> popUntilOrPush(String path) => navigator.popUntilOrPush(path);

  void addRoutes(List<OrioleRoute> routes) => navigator.addRoutes(routes);

  void removeRoutes(List<String> routesNames) {
    return navigator.removeRoutes(routesNames);
  }

  bool _isOnlyNavigatorLeft(List<String> navigators) {
    for (var navigator in navigators) {
      if (history.entries.where((h) => h.navigator == navigator).length > 1) {
        return false;
      }
    }
    return true;
  }

  Future<void> _toMatch(
    OrioleRouteInternal match, {
    String forController = OrioleNavigatorContext.rootRouterName,
    PageAlreadyExistAction? pageAlreadyExistAction,
  }) async {
    final controller = _manager.withName(forController);
    await controller.popUntilOrPushMatch(
      match,
      checkChild: false,
      pageAlreadyExistAction:
          pageAlreadyExistAction ?? PageAlreadyExistAction.remove,
    );
    if (match.hasChild && !match.isProcessed) {
      final newControllerName =
          _manager.hasController(match.name) ? match.name : forController;
      await _toMatch(match.child!,
          forController: newControllerName,
          pageAlreadyExistAction: pageAlreadyExistAction);
      return;
    }

    if (match.isProcessed) return;
    if (currentPath != match.activePath!) {
      final samePathFromInit = match.route.withChildRouter &&
          match.route.initRoute != null &&
          currentPath == (match.activePath! + match.route.initRoute!);
      if (!samePathFromInit) {
        updateUrlInfo(match.activePath!,
            mKey: match.key,
            params: match.params!.asValueMap,
            navigator: match.route.path,
            addHistory: true);
        return;
      }
    }
    if (forController != OrioleNavigatorContext.rootRouterName) {
      (rootNavigator as OrioleRouterController).update(withParams: false);
    }
  }

  void updateUrlInfo(
    String url, {
    Map<String, dynamic>? params,
    OrioleKey? mKey,
    String? navigator,
    bool addHistory = true,
    bool updateParams = false,
  }) =>
      rootNavigator.updateUrl(
        url,
        mKey: mKey,
        params: params,
        navigator: navigator,
        updateParams: updateParams,
        addHistory: addHistory,
      );
}
