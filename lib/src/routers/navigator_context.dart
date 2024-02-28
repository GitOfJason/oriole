part of '../library_internal.dart';

class OrioleNavigatorContext {
  static const rootRouterName = 'Root';
  String activeNavigatorName = OrioleNavigatorContext.rootRouterName;

  OrioleNavigatorContext();

  final ControllerManager _manager = ControllerManager();
  final OrioleHistory history = OrioleHistory();
  final params = OrioleParams();
  final treeInfo = _QTreeInfo();

  Future<OrioleRouterController> createRouterController(
    String name, {
    List<OrioleRoute>? routes,
    OrioleRouteChildren? cRoutes,
    String? initPath,
    OrioleRouteInternal? initRoute,
  }) async {
    return _manager.createController(
      name,
      routes: routes,
      cRoutes: cRoutes,
      initRoute: initRoute,
      initPath: initPath,
    );
  }

  OrioleNavigator get navigator => navigatorOf(activeNavigatorName);

  String get currentPath => history.isEmpty ? '/' : history.current.path;

  OrioleNavigator navigatorOf(String name) => _manager.withName(name);

  Future<bool> removeNavigator(String name) => _manager.removeNavigator(name);

  OrioleNavigator get rootNavigator =>
      navigatorOf(OrioleNavigatorContext.rootRouterName);

  bool isCurrentPath(String path) => currentPath == path;

  bool isCurrentName(String name, {Map<String, dynamic>? params}) {
    return currentPath ==
        MatchController.findPathFromName(
          name,
          params ?? <String, dynamic>{},
        );
  }

  bool hasNavigator(String name) => _manager.hasController(name);

  Future<OrioleRouter> createNavigator(
    String name, {
    List<OrioleRoute>? routes,
    OrioleRouteChildren? cRoutes,
    String? initPath,
    OrioleRouteInternal? initRoute,
    List<NavigatorObserver>? observers,
    String? restorationId,
  }) async {
    final controller = await createRouterController(
      name,
      routes: routes,
      cRoutes: cRoutes,
      initPath: initPath,
      initRoute: initRoute,
    );
    return OrioleRouter(
      controller,
      observers: observers,
      restorationId: restorationId,
    );
  }
}

class _QTreeInfo {
  final Map<String, String> namePath = {
    OrioleNavigatorContext.rootRouterName: '/'
  };
  int routeIndexer = -1;
}
