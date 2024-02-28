import 'package:oriole/src/routes/route_internal.dart';

import 'package:oriole/oriole.dart';

class OrioleRouteChildren {
  final OrioleKey parentKey;
  final String parentFullPath;
  final List<OrioleRouteInternal> _routes;

  List<OrioleRouteInternal> get routes => _routes;

  OrioleRouteChildren(this._routes, this.parentKey, this.parentFullPath);

  factory OrioleRouteChildren.from(List<OrioleRoute> routes, OrioleKey parentKey, String currentPath) {
    final result = <OrioleRouteInternal>[];

    for (final route in routes) {
      final internal = OrioleRouteInternal.from(route, currentPath);
      result.add(internal);
    }
    return OrioleRouteChildren(result, parentKey, currentPath);
  }

  void add(List<OrioleRoute> routes) {
    for (var route in routes) {
      if (_routes.any((element) => element.route.path == route.path)) {
        Oriole.log('Path ${route.path} already exist, cannot add');
        continue;
      }
      final internal = OrioleRouteInternal.from(route, parentFullPath);
      _routes.add(internal);
      Oriole.log('$internal was add to $parentKey');
    }
  }

  void remove(List<String> routesNames) {
    for (var name in routesNames) {
      bool finder(OrioleRouteInternal element) => element.key.hasName(name);
      if (_routes.any(finder)) {
        _routes.removeWhere(finder);
        Oriole.log('$name is removed from $parentKey');
        return;
      }
      Oriole.log('$name is not child of from $parentKey. Can not remove it');
    }
  }
}
