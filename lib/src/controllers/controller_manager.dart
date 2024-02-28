import 'package:oriole/src/controllers/router_controller.dart';
import 'package:oriole/oriole.dart';

import '../errors/errors.dart';
import '../routes/route_children.dart';
import '../routes/route_internal.dart';

final class ControllerManager {
  final routerControllers = <OrioleRouterController>[];

  Future<OrioleRouterController> createController(
    String name, {
    List<OrioleRoute>? routes,
    OrioleRouteChildren? cRoutes,
    String? initPath,
    OrioleRouteInternal? initRoute,
  }) async {
    // 有名字相同的控制器直接返回
    if (hasController(name)) {
      return routerControllers.firstWhere(
        (controller) => controller.key.hasName(name),
      );
    }

    final routePath = Oriole.to.treeInfo.namePath[name];
    if (routePath == null) {
      throw const OrioleError('Route');
    }

    final key = OrioleKey(name);
    routes = _resolveRoutes(routes, null);
    cRoutes ??= OrioleRouteChildren.from(
      routes,
      key,
      routePath == '/' ? '' : routePath,
    );
    final controller = OrioleRouterController(key, cRoutes);
    controller.initialize(initPath: initPath, initRoute: initRoute);
    routerControllers.add(controller);
    return controller;
  }

  List<OrioleRoute> _resolveRoutes(List<OrioleRoute>? routes, String? parent) {
    List<OrioleRoute> result = [];
    if (routes == null) return result;
    for (var route in routes) {
      if (route.parent == parent || parent == null) {
        var children = _resolveRoutes(routes, route.path);
        route.children.clear();
        route.children.addAll(children);
        var path = route.path.replaceFirst(route.parent ?? '', '');
        if (path.endsWith('/')) {
          path = path.substring(0, path.length - 1);
        }
        if (path.startsWith('/') == false) {
          path = '/$path';
        }
        result.add(route.copyWith(path: path));
      }
    }
    return result;
  }

  bool hasController(String name) {
    return routerControllers.any((controller) => controller.key.hasName(name));
  }

  OrioleRouterController? controllerWithPopup() {
    for (var controller in routerControllers) {
      if (controller.observer.hasPopupRoute()) {
        return controller;
      }
    }
    return null;
  }

  OrioleRouterController withName(String name) {
    if (routerControllers.any((controller) => controller.key.hasName(name))) {
      return routerControllers.firstWhere(
        (controller) => controller.key.hasName(name),
      );
    }
    throw const OrioleError('No router was set in the app');
  }

  Future<bool> removeNavigator(String name) async {
    if (!hasController(name)) {
      return false;
    }
    final controller = withName(name);
    await controller.disposeAsync();
    routerControllers.remove(controller);
    Oriole.log('Navigator with name [$name] was removed');
    return true;
  }
}
