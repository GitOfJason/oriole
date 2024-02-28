import 'package:flutter/cupertino.dart';

import 'package:oriole/oriole.dart';


abstract class OrioleObserver {
  Future onNavigate(String path, OrioleRoute route);

  Future onPop(String path, OrioleRoute route);
}

class OrioleNavigatorObserver extends NavigatorObserver {
  final String name;

  OrioleNavigatorObserver(this.name);

  final List<Route> _routes = [];

  bool hasPopupRoute() {
    if (_routes.isEmpty) return false;
    return _routes.any((element) => element is PopupRoute);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _log('Push', route);
    _routes.add(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _log('Pop', route);
    _routes.remove(route);
    super.didRemove(route, previousRoute);
  }

  void didSwitchTo(RouteSettings route, RouteSettings? previousRoute) {}

  _log(String message, Route route) {
    if (route.settings is OriolePageInternal) {
      final page = route.settings as OriolePageInternal;
      Oriole.log('$name observer: $message: ${page.matchKey.name}');
      return;
    }
    Oriole.log('$name observer: $message: ${route.runtimeType}');
  }
}
