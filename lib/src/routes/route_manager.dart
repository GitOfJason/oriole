part of '../library_internal.dart';

class RouteManager {
  final List<OrioleRoute> _routes = [];

  @visibleForTesting
  List<OrioleRoute> get allRoutes => List.unmodifiable(_routes);

  void _add(OrioleRoute route) {
    _routes.add(route);
  }
}
