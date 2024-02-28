part of '../library_internal.dart';

extension OrioleRouteManagerExt on RouteManager {
  void module({
    required String name,
    required OrioleModule module,
    List<OrioleMiddleware> middlewares = const [],
  }) {
    _add(ModuleRoute(
      name: name,
      module: module,
      middlewares: middlewares,
    ));
  }

  void child({
    required String path,
    required PageBuilder builder,
    OriolePageType? pageType,
    List<OrioleRoute>? children,
    String? initRoute,
    List<OrioleMiddleware> middlewares = const [],
    Map<String, dynamic> meta = const {},
  }) {
    _add(ChildRoute(
      path: path,
      builder: builder,
      pageType: pageType,
      children: children ?? [],
      initRoute: initRoute,
      middlewares: middlewares,
      meta: meta,
    ));
  }

  void shell({
    required String path,
    required ShellBuilder builder,
    required List<ChildRoute> children,
    String? initRoute,
    List<OrioleMiddleware> middlewares = const [],
    List<NavigatorObserver>? observers,
  }) {
    _add(ShellRoute(
      path: path,
      builder: builder,
      children: children,
      initRoute: initRoute,
      middlewares: middlewares,
      observers: observers,
    ));
  }
}
