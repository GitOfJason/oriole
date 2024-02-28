import 'dart:async';

import 'package:oriole/src/routes/route_children.dart';
import 'package:oriole/oriole.dart';

class OrioleRouteInternal {
  final OrioleKey key;
  final String fullPath;
  final OrioleRoute route;
  final bool isNotFound;
  OrioleRouteChildren? children;
  String? activePath;
  Completer? completer;
  OrioleParams? params;
  OrioleRouteInternal? parent;
  OrioleRouteInternal? child;
  bool isProcessed = false;

  OrioleRouteInternal({
    required this.key,
    required this.fullPath,
    required this.route,
    required this.isNotFound,
    this.children,
    this.activePath,
    this.child,
    this.params,
    this.parent,
  });

  factory OrioleRouteInternal.from(OrioleRoute route, String currentPath) {
    final key = OrioleKey(route.path);
    if (!route.path.startsWith('/')) {
      route = route.copyWith(path: '/${route.path}');
    }
    if (currentPath == '/!') {
      currentPath = '';
    }
    final fullPath = '$currentPath${route.path}';

    Oriole.to.treeInfo.namePath[route.path] = fullPath;
    return OrioleRouteInternal(
      key: key,
      route: route,
      fullPath: fullPath,
      isNotFound: false,
      children: route.children.isEmpty
          ? null
          : OrioleRouteChildren.from(route.children.cast(), key, fullPath),
    );
  }

  void complete(dynamic value) {
    if (completer != null && !completer!.isCompleted) {
      completer!.complete(value);
      completer = null;
    }
    if (child != null) child!.complete(value);
  }

  factory OrioleRouteInternal.notFound(String notFoundPath) {
    final route = Oriole.settings.notFoundPage;
    final key = OrioleKey(route.path);
    return OrioleRouteInternal(
      key: key,
      route: route,
      fullPath: route.path,
      isNotFound: true,
      params: OrioleParams(params: {}),
      activePath: notFoundPath,
      children: route.children.isEmpty
          ? null
          : OrioleRouteChildren.from(
              route.children.cast(),
              key,
              route.path,
            ),
    );
  }

  OrioleRouteInternal asNewMatch(String path, {OrioleParams? newParams}) {
    return OrioleRouteInternal(
      key: key,
      fullPath: fullPath,
      route: route,
      isNotFound: isNotFound,
      children: children,
      parent: parent,
      activePath: path,
      params: newParams,
    );
  }

  OrioleParams getAllParams() {
    OrioleRouteInternal? childRoute = this;
    final result = OrioleParams();
    while (childRoute != null) {
      if (childRoute.params != null) {
        result.addAll(childRoute.params!.asValueMap);
      }
      childRoute = childRoute.child;
    }
    return result;
  }

  Future<T> getFuture<T>() {
    if (child != null) return child!.getFuture();
    completer ??= Completer<T>();
    return completer!.future as Future<T>;
  }

  bool get hasChild => child != null;

  String get name => route.path;

  bool get hasMiddleware {
    return route.middlewares.isNotEmpty;
  }

  String getLastActivePath() {
    if (child != null) {
      return child!.getLastActivePath();
    }
    return activePath!;
  }

  bool isSame(OrioleRouteInternal other) =>
      key.isSame(other.key) &&
      (params != null && other.params != null && params!.isSame(other.params!));
}
