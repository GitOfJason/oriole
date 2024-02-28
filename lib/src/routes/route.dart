import 'package:flutter/material.dart';
import 'package:oriole/src/routers/router.dart';

import '../pages/pages.dart';
import '../types/middleware.dart';
import '../types/module.dart';
import '../types/oriole_key.dart';

typedef PageBuilder = Widget Function();
typedef ShellBuilder = Widget Function(OrioleRouter);

final class OrioleRoute {
  late final OrioleKey key;
  final String path;
  final String? initRoute;
  final PageBuilder? builder;
  final ShellBuilder? shellBuilder;
  final OriolePageType? pageType;
  final List<OrioleRoute> children;
  final List<OrioleMiddleware> middlewares;
  final String? parent;
  final Map<Type, OrioleModule> innerModules;
  final OrioleModule? module;
  final List<NavigatorObserver>? observers;
  final String? restorationId;
  final Map<String, dynamic> meta;

  OrioleRoute._({
    required this.path,
    this.builder,
    this.shellBuilder,
    this.children = const [],
    this.middlewares = const [],
    this.innerModules = const {},
    this.module,
    this.parent,
    this.initRoute,
    this.pageType,
    this.restorationId,
    this.observers,
    this.meta = const {},
  }) {
    key = OrioleKey(path);
  }

  OrioleRoute copyWith({
    String? path,
    List<OrioleRoute>? children,
    List<OrioleMiddleware>? middlewares,
    Map<Type, OrioleModule>? innerModules,
    OrioleModule? module,
    String? parent,
    PageBuilder? builder,
    ShellBuilder? shellBuilder,
    String? initRoute,
    OriolePageType? pageType,
    List<NavigatorObserver>? observers,
    String? restorationId,
    bool? parentIsModule,
    String? moduleId,
    Map<String, dynamic>? meta,
  }) {
    return OrioleRoute._(
      path: path ?? this.path,
      builder: builder ?? this.builder,
      children: children ?? this.children,
      middlewares: middlewares ?? this.middlewares,
      innerModules: innerModules ?? this.innerModules,
      module: module ?? this.module,
      parent: parent ?? this.parent,
      shellBuilder: shellBuilder ?? this.shellBuilder,
      initRoute: initRoute ?? this.initRoute,
      observers: observers ?? this.observers,
      restorationId: restorationId ?? this.restorationId,
      pageType: pageType ?? this.pageType,
      meta: meta ?? this.meta,
    );
  }

  bool get withChildRouter => shellBuilder != null;

  OrioleRoute addParent(OrioleRoute parent) {
    final newPath = '${parent.path}$path'.replaceFirst('//', '/');
    return copyWith(
        path: newPath,
        parent: parent.path,
        middlewares: [
          ...parent.middlewares,
          ...middlewares,
        ],
        innerModules: {
          ...parent.innerModules,
          ...innerModules,
        },
        parentIsModule: parent.module != null);
  }

  OrioleRoute addModule(String name, {required OrioleModule module}) {
    final innerModules = {module.runtimeType: module};
    return copyWith(
      path: name,
      innerModules: innerModules,
      module: module,
    );
  }
}

base class ModuleRoute extends OrioleRoute {
  ModuleRoute({
    required String name,
    required OrioleModule module,
    super.middlewares,
  }) : super._(path: name, module: module, builder: null);
}

base class ChildRoute extends OrioleRoute {
  ChildRoute(
      {required String path,
      List<OrioleRoute>? children,
      required super.builder,
      super.initRoute,
      super.pageType,
      super.middlewares,
      super.meta})
      : super._(path: path, children: children ?? []);
}

base class ShellRoute extends OrioleRoute {
  ShellRoute({
    required String path,
    required ShellBuilder builder,
    List<ChildRoute> children = const [],
    super.initRoute,
    super.middlewares,
    super.observers,
  })  : assert(children.isNotEmpty, 'ShellRoute children is not empty'),
        super._(
          path: path,
          builder: null,
          shellBuilder: builder,
          children: children.cast<OrioleRoute>().toList(),
        );
}
