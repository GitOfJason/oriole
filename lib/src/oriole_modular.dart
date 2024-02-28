import 'package:flutter/cupertino.dart';
import 'package:oriole/src/routers/route_parser.dart';
import 'package:oriole/src/routers/router_delegate.dart';
import 'package:oriole/src/tracker/tracker.dart';
import 'package:oriole/oriole.dart';
import 'library_internal.dart';
import 'types/platform/url_strategy_web.dart'
    if (dart.library.io) 'types/platform/url_strategy_io.dart';

import 'errors/errors.dart';

abstract final class OrioleModular {
  RouterDelegate<Object> get routerDelegate;

  RouteInformationParser<Object> get routeInformationParser;

  OrioleNavigatorContext get to;

  Tracker get _tracker;

  OrioleSettings get settings;

  void init(OrioleModule module, {OrioleSettings? settings});

  void destroy();

  void log(String mes, [bool isDebug = false]);

  List<OrioleRoute> get routes;

  T get<T>();

  T? tryGet<T>();

  void reportPopRoute(OrioleRoute route);

  void reportPushRoute(OrioleRoute route);

  void bindModule(OrioleModule module, [String? tag]);

  void unbindModule<T extends OrioleModule>({String? type});

  bool disposeBind<T extends Object>([String? key]);

  void replaceInstance<T>(T instance, [String? key]);
}

final class OrioleModularImpl implements OrioleModular {
  OrioleModularImpl(this._tracker, this.to);

  bool _moduleHasBeenStarted = false;

  @override
  void destroy() {
    _moduleHasBeenStarted = false;
    _tracker.finishApp();
  }

  @override
  late final RouteInformationParser<Object> routeInformationParser;

  @override
  late final RouterDelegate<Object> routerDelegate;

  @override
  void init(OrioleModule module, {OrioleSettings? settings}) {
    if (_moduleHasBeenStarted == false) {
      this.settings = settings ?? OrioleSettings();
      _tracker.logger.config(
        logger: this.settings.logger,
        enableLog: this.settings.enableLog,
        enableDebugLog: this.settings.enableDebugLog,
      );

      if (this.settings.urlStrategy) {
        urlStrategy();
      }

      _tracker.runApp(module);
      routerDelegate = OrioleRouterDelegate();
      routeInformationParser = const OrioleRouteInformationParser();
    } else {
      throw OrioleError('Module ${module.runtimeType} is already started');
    }
  }

  @override
  final Tracker _tracker;

  @override
  OrioleNavigatorContext to;

  @override
  void reportPopRoute(OrioleRoute route) {
    _tracker.reportPopRoute(route);
  }

  @override
  void reportPushRoute(OrioleRoute route) {
    _tracker.reportPushRoute(route);
  }

  @override
  late final OrioleSettings settings;

  @override
  List<OrioleRoute> get routes => _tracker.routes.cast();

  @override
  T get<T>() {
    return _tracker.injector.get<T>();
  }

  @override
  T? tryGet<T>() {
    return _tracker.injector.tryGet<T>();
  }

  @override
  void log(String message, [bool isDebug = false]) {
    _tracker.logger.log(message, isDebug);
  }

  @override
  void bindModule(OrioleModule module, [String? tag]) {
    _tracker.bindModule(module, tag);
  }

  @override
  void unbindModule<T extends OrioleModule>({String? type}) {
    _tracker.unbindModule(type ?? T.toString());
  }

  @override
  bool disposeBind<T extends Object>([String? key]) {
    return _tracker.injector.disposeSingleton<T>(key: key) != null;
  }

  @override
  void replaceInstance<T>(T instance, [String? key]) {
    _tracker.injector.replaceInstance<T>(instance, key: key);
  }
}
