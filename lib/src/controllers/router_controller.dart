import 'package:flutter/cupertino.dart';
import 'package:oriole/src/controllers/pages_controller.dart';

import 'package:oriole/oriole.dart';
import '../library_internal.dart';
import '../routes/route_children.dart';
import '../routes/route_internal.dart';
import '../types/history.dart';
import 'match_controller.dart';
import 'middleware_controller.dart';
import 'navigator.dart';

final class OrioleRouterController extends OrioleNavigator {
  bool isDisposed = false;
  late GlobalKey<NavigatorState> navKey;
  final OrioleKey key;
  late final observer = OrioleNavigatorObserver(key.name);
  final _pagesController = PagesController();
  final OrioleRouteChildren routes;
  late Function(RouteSettings, RouteSettings?) didSwitchTo;

  OrioleRouterController(this.key, this.routes);

  List<OriolePageInternal> get pages =>
      List.unmodifiable(_pagesController.pages);

  Future<void> initialize({
    String? initPath,
    OrioleRouteInternal? initRoute,
  }) async {
    if (initRoute != null) {
      await addRouteAsync(initRoute);
    } else if (initPath != null) {
      await push(initPath);
    }
  }

  @override
  Future<T?> push<T>(String path,
      {Map<String, dynamic>? params, bool waitForResult = false}) async {
    final match = await findPath(path, params: params);
    await addRouteAsync(match);
    return waitForResult ? match.getFuture() : null;
  }

  void closePopup<T>(T? result) {
    Navigator.pop(navKey.currentContext!, result);
  }

  @override
  Future<PopResult> removeLast({result}) async {
    final isPopped = await _pagesController.removeLast(result: result);
    if (isPopped == PopResult.popped) {
      update(withParams: true);
    }
    return isPopped;
  }

  Future<void> disposeAsync() async {
    await _pagesController.removeAll();
    isDisposed = true;
    super.dispose();
  }

  void update({bool withParams = false}) {
    if (withParams && Oriole.to.history.entries.isNotEmpty) {
      Oriole.to.params.updateParams(Oriole.to.history.current.params);
    }
    notifyListeners();
  }

  Future<OrioleRouteInternal> findPath(
    String path, {
    Map<String, dynamic>? params,
  }) =>
      MatchController(
        path,
        routes.parentFullPath,
        routes,
        params: params,
      ).match;

  @override
  void updateUrl(
    String url, {
    Map<String, dynamic>? params,
    OrioleKey? mKey,
    String? navigator,
    bool updateParams = false,
    bool addHistory = true,
  }) {
    if (key.name != OrioleNavigatorContext.rootRouterName) {
      Oriole.log(
        'Only ${OrioleNavigatorContext.rootRouterName} can update the url',
      );
      return;
    }
    final newParams = OrioleParams();
    newParams.addAll(params ?? Uri.parse(url).queryParameters);
    Oriole.to.history.add(
      OrioleHistoryEntry(
        mKey ?? OrioleKey('Out Route'),
        url,
        newParams,
        navigator ?? 'Out Route',
        false,
      ),
    );
    update(withParams: updateParams);
    if (!addHistory) {
      Oriole.to.history.removeLast();
    }
  }

  String _currentSwitchPath = '';

  Future<void> popUntilOrPushMatch(
    OrioleRouteInternal match, {
    bool checkChild = true,
    PageAlreadyExistAction pageAlreadyExistAction =
        PageAlreadyExistAction.remove,
  }) async {
    final index =
        _pagesController.routes.indexWhere((element) => element.isSame(match));
    // Page not exist add it.
    if (index == -1) {
      if (Oriole.settings.oneRouteInstancePerStack) {
        final sameRouteIndex = _pagesController.routes
            .indexWhere((element) => element.key.isSame(match.key));
        if (sameRouteIndex != -1) {
          await _pagesController.removeIndex(sameRouteIndex);
        }
      }
      await addRouteAsync(match, checkChild: checkChild);
      _currentSwitchPath = match.fullPath;
      return;
    }

    if (match.hasChild) {
      // page exist and has children
      if (checkChild) {
        await popUntilOrPushMatch(match.child!);
      }

      // See [#56]
      // if the parent have a navigator then just insure that the
      // page is on the top
      if (Oriole.to.hasNavigator(match.name) &&
          this != Oriole.to.navigatorOf(match.name)) {
        // here the bring on to should ignore any children, because the route has a navigator and the navigator will handle the children
        _bringPageToTop(index, true);
      }

      return;
    }

    switch (pageAlreadyExistAction) {
      case PageAlreadyExistAction.bringToTop:
      case PageAlreadyExistAction.ignoreChildrenAndBringToTop:
        var shouldIgnoreChildren = pageAlreadyExistAction ==
            PageAlreadyExistAction.ignoreChildrenAndBringToTop;
        if (match.route.path == '/') {
          // if the path is / then we have to ignore the children, because
          // in this case the children are the siblings of the route
          shouldIgnoreChildren = true;
        }
        final route = _bringPageToTop(index, shouldIgnoreChildren);
        if (shouldIgnoreChildren) _updatePathWhenBringingPageToTop(route);
        if (_currentSwitchPath != route.fullPath) {
          final index = pages.length - 2;
          didSwitchTo.call(pages.last,index < 0 ? null : pages[index]);
        }
        Oriole.log('${route.fullPath} is on to top of the stack');
        _currentSwitchPath = route.fullPath;
        match.isProcessed = true;
        break;
      case PageAlreadyExistAction.remove:
      default:
        // page is exist and has no children
        // then pop until it or replace it
        if (index == _pagesController.pages.length - 1) {
          // if the same page is on the top, then replace it.
          // remove it from the top and add it again
          if (await _pagesController.removeLast(allowEmptyPages: true) !=
              PopResult.popped) return;
          await addRouteAsync(match, checkChild: checkChild);
          return;
        }
        // page exist remove unit it
        final pagesLength = _pagesController.pages.length;
        for (var i = index + 1; i < pagesLength; i++) {
          if (await _pagesController.removeLast() != PopResult.popped) return;
        }
    }

    update();
  }

  Future<void> addRouteAsync(OrioleRouteInternal match,
      {bool notify = true, bool checkChild = true}) async {
    //print('adding $match to the navigator with $key');
    await _addRoute(match);
    while (checkChild &&
        match.hasChild &&
        !match.route.withChildRouter &&
        !match.isProcessed) {
      await _addRoute(match.child!);
      match = match.child!;
    }

    if (notify && !match.isProcessed && !isDisposed) {
      update();
      updatePathIfNeeded(match);
    }
  }

  void updatePathIfNeeded(OrioleRouteInternal match,
      {bool updateParams = false}) {
    if (key.name != OrioleNavigatorContext.rootRouterName) {
      Oriole.to.updateUrlInfo(
        match.activePath!,
        mKey: match.key,
        params: match.params!.asValueMap,
        navigator: key.name,
        updateParams: updateParams,
      );
    }
  }

  Future<void> _addRoute(OrioleRouteInternal route) async {
    if (_pagesController.exist(route) && route.hasChild) {
      // if page already exist, and has a child, that means the child need
      // to be added, so do not run the middleware for it or add it again
      return;
    }
    if (route.hasMiddleware ||
        (Oriole.settings.middlewares.isNotEmpty && !route.isNotFound)) {
      final medCont = MiddlewareController(route);
      final result = await medCont.runRedirect();
      if (result != null) {
        Oriole.log('redirect from [${route.activePath}] to [$result]');
        await Oriole.to.go(result);
        route.isProcessed = true;
        return;
      }
    }
    Oriole.to.history.add(OrioleHistoryEntry(
      route.key,
      route.activePath!,
      route.params!,
      key.name,
      route.hasChild,
    ));
    await _pagesController.add(route);
  }

  OrioleRouteInternal _bringPageToTop(int index, bool shouldIgnoreChildren) {
    var route = _pagesController.routes[index];
    if (shouldIgnoreChildren) {
      final page = _pagesController.pages[index];
      _pagesController.routes.remove(route);
      _pagesController.pages.remove(page);
      _pagesController.routes.add(route);
      _pagesController.pages.add(page);
      return route;
    }
    // if page children should not be ignored, then bring the page to the top
    // with its children too in the same order
    final routesWithSamePath = _pagesController.routes
        .where((element) => element.fullPath.contains(route.fullPath))
        .toList();
    Oriole.log('bring page to top with children: $routesWithSamePath');
    for (route in routesWithSamePath) {
      index = _pagesController.routes.indexOf(route);
      final page = _pagesController.pages[index];
      _pagesController.routes.remove(route);
      _pagesController.pages.remove(page);
      _pagesController.routes.add(route);
      _pagesController.pages.add(page);
      _updatePathWhenBringingPageToTop(route);
    }

    return route;
  }

  void _updatePathWhenBringingPageToTop(OrioleRouteInternal route) {
    // if this route has his own navigator, then update its path to the last page seen in it
    final lastFoundRoute = Oriole.to.history.findLastForNavigator(route.name);
    if (lastFoundRoute != null) {
      Oriole.log(
        'update path to the last seen route for ${route.name} which is ${lastFoundRoute.path}',
      );
      Oriole.to.rootNavigator.updateUrl(
        lastFoundRoute.path,
        addHistory: true,
        params: lastFoundRoute.params.asValueMap,
        navigator: lastFoundRoute.navigator,
        updateParams: true,
      );
    } else {
      // update the path to this page
      updatePathIfNeeded(route);
    }
  }

  @override
  OrioleRoute get currentRoute => _pagesController.routes.last.route;

  @override
  Future<void> switchTo(String path) async {
    await popUntilOrPushMatch(await findPath(path),
        pageAlreadyExistAction: PageAlreadyExistAction.bringToTop);
  }

  @override
  Future<void> replace(String path, String withPath) async {
    final match = await findPath(path);
    final index = _pagesController.routes.indexWhere((e) => e.isSame(match));
    assert(index != -1, 'Path $path was not found in the stack');
    if (!await _pagesController.removeIndex(index)) return;
    await push(withPath);
  }

  @override
  Future<void> replaceAll(String path) async {
    final match = await findPath(path);
    if (await _pagesController.removeAll() != PopResult.popped) return;
    await addRouteAsync(match);
  }

  @override
  Future<void> popUntilOrPush(String path) async {
    await popUntilOrPushMatch(await findPath(path));
  }

  @override
  Future<void> replaceLast(String path) async {
    final last = _pagesController.routes.last;
    return replace(last.activePath!, path);
  }

  @override
  void addRoutes(List<OrioleRoute> routes) => this.routes.add(routes);

  @override
  void removeRoutes(List<String> routesNames) => routes.remove(routesNames);
}
