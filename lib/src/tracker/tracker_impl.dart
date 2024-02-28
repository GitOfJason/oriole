part of '../library_internal.dart';


final class TrackerImpl implements Tracker {
  OrioleModule? _nullableModule;
  final _disposeTags = <Type, List<String>>{};
  final _importedInjector = <String, AutoInjector>{};

  @visibleForTesting
  final routeMap = <OrioleKey, OrioleRoute>{};

  @override
  AutoInjector injector;


  @override
  Logger logger;

  @override
  OrioleModule get module {
    if (_nullableModule != null) {
      return _nullableModule!;
    }
    throw const OrioleError('Execute Tracker.runApp');
  }

  TrackerImpl(this.injector, this.logger);


  @override
  void runApp(OrioleModule module, [String initialRoutePath = '/']) {
    _nullableModule = module;
    _disposeTags[module.runtimeType] = [initialRoutePath];
    bindModule(module);
    addRoutes(module);
  }

  @override
  void finishApp() {
    injector.disposeRecursive();
    _disposeTags.clear();
    routeMap.clear();
    _nullableModule = null;
  }


  @override
  void bindModule(OrioleModule module, [String? tag]) {
    final newInjector = _createInjector(module, tag);
    injector.uncommit();
    injector.addInjector(newInjector);
    injector.commit();
  }


  AutoInjector _createInjector(OrioleModule module, [String? tag]) {
    final newInjector = AutoInjector(tag: tag ?? module.runtimeType.toString());
    for (final importedModule in module.imports) {
      final exportInject = _createExportedInjector(importedModule);
      newInjector.addInjector(exportInject);
    }
    module.binds(newInjector);
    return newInjector;
  }

  AutoInjector _createExportedInjector(OrioleModule importedModule) {
    final tag = importedModule.runtimeType.toString();
    return _importedInjector.putIfAbsent(tag, () {
      final exportedInject = _createInjector(importedModule, '${tag}_Imported');
      importedModule.exportedBinds(exportedInject);
      return exportedInject;
    });
  }

  @override
  void unbindModule(String moduleName) {
    _removeRegisters(moduleName);
  }


  void _removeRegisters(String tag) {
    injector.disposeInjectorByTag(tag, _disposeInstance);
    logger.log('$tag DISPOSED');
  }

  @override
  bool dispose<B>() {
    final dead = injector.disposeSingleton<B>();
    _disposeInstance(dead);
    return dead != null;
  }

  void _disposeInstance(dynamic instance) {
    if (instance is Disposable) {
      instance.dispose();
    }
  }

  void addRoutes(OrioleModule module) {
    final manager = RouteManager();
    module.routes(manager);
    final routes = manager._routes;
    final routeMap = <OrioleKey, OrioleRoute>{};
    for (final route in routes) {
      routeMap.addAll(_assembleRoute(route));
    }
    final orderedMap = Map.fromEntries(_orderRouteKeys(routeMap.keys)
        .map((key) => MapEntry(key, routeMap[key]!)));
    this.routeMap.addAll(orderedMap);
  }


  List<OrioleKey> _orderRouteKeys(Iterable<OrioleKey> keys) {
    final orderedKeys = <OrioleKey>[...keys];
    orderedKeys.sort((preview, actual) {
      if (preview.name.contains('/:') && !actual.name.contains('**')) {
        return 1;
      }

      if (preview.name.contains('**')) {
        final isActualLonger =
            actual.name.split('/').length > preview.name.split('/').length;
        if (!actual.name.contains('**') || isActualLonger) {
          return 1;
        }
      }

      return 0;
    });
    return orderedKeys;
  }

  Map<OrioleKey, OrioleRoute> _assembleRoute(OrioleRoute route) {
    final map = <OrioleKey, OrioleRoute>{};

    if (route.module == null) {
      map[route.key] = route;
      map.addAll(_addChildren(route));
    } else {
      map.addAll(_addModule(route));
    }

    return map;
  }


  Map<OrioleKey, OrioleRoute> _addModule(OrioleRoute route) {
    final map = <OrioleKey, OrioleRoute>{};
    final module = route.module!;
    final manager = RouteManager();
    module.routes(manager);
    final routes = manager._routes;
    _disposeTags[module.runtimeType] = [];
    for (var child in routes) {
      child = child.addParent(route);
      child = child.copyWith(
        path: "${route.path}${child.path}",
        innerModules: {
          ...child.innerModules,
          module.runtimeType: module,
        },
        parent: route.parent,
      );
      map.addAll(_assembleRoute(child));
    }

    return map;
  }


  Map<OrioleKey, OrioleRoute> _addChildren(OrioleRoute route) {
    final map = <OrioleKey, OrioleRoute>{};
    for (var child in route.children) {
      child = child.addParent(route);
      map.addAll(_assembleRoute(child));
    }
    return map;
  }

  @override
  List<OrioleRoute> get routes {
    return routeMap.values.toList();
  }

  @override
  void reportPopRoute(OrioleRoute route) {
    final tag = route.path;

    for (final key in _disposeTags.keys) {
      final moduleTags = _disposeTags[key]!;

      if (moduleTags.isEmpty) {
        continue;
      }

      moduleTags.remove(tag);
      if (tag.characters.last == '/') {
        moduleTags.remove('$tag/'.replaceAll('//', ''));
      }

      if (moduleTags.isEmpty) {
        unbindModule(key.toString());
      }
    }
  }

  @override
  void reportPushRoute(OrioleRoute route) {
    for (final module in [...route.innerModules.values, module]) {
      final key = module.runtimeType;
      if (_disposeTags[key]!.isEmpty) {
        bindModule(module);
        logger.log('${module.runtimeType} INITIALIZED');
      }
      _disposeTags[key]!.add(route.path.toString());
    }
  }

  @override
  OrioleRoute? getRouteByKey(String key) {
    return routeMap[OrioleKey(key)];
  }
}
