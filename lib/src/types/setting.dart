import 'package:flutter/material.dart';

import '../pages/pages.dart';
import '../routes/route.dart';
import 'middleware.dart';
import 'observer.dart';

final class OrioleSettings {

  final Function(String) logger;

  final bool enableDebugLog;

  final bool enableLog;

  final Widget initPage;

  final ChildRoute notFoundPage;

  final bool oneRouteInstancePerStack;

  final OriolePageType pageType;

  final bool autoRestoration;

  final GlobalKey<NavigatorState> navigatorKey;

  final String? initPath;

  final bool alwaysAddInitPath;

  final List<NavigatorObserver> navigatorObserver;

  final List<OrioleObserver> observers;

  final String? restorationScopeId;

  final List<OrioleMiddleware> middlewares;

  final bool urlStrategy;

  OrioleSettings({
    this.enableDebugLog = false,
    this.enableLog = true,
    this.initPath,
    this.oneRouteInstancePerStack = false,
    this.pageType = const OriolePlatformPageType(),
    this.autoRestoration = false,
    this.alwaysAddInitPath = false,
    this.navigatorObserver = const [],
    this.observers = const [],
    this.restorationScopeId,
    this.urlStrategy = false,
    this.middlewares = const [],
    GlobalKey<NavigatorState>? key,
    Widget? initPage,
    ChildRoute? notFoundPage,
    void Function(String)? logger,
  })  : notFoundPage = notFoundPage ?? _notFoundPage,
        initPage = initPage ?? _iniPage,
        logger = logger ?? print,
        navigatorKey = key ?? GlobalKey<NavigatorState>();
}

const Widget _iniPage = Material(child: Center(child: Text('Loading')));
final _notFoundPage = ChildRoute(
  path: '/notFound',
  builder: () => const Material(child: Center(child: Text('Page Not Found'))),
);
