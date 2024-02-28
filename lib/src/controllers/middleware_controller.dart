import 'package:flutter/cupertino.dart';

import 'package:oriole/oriole.dart';
import '../routes/route_internal.dart';

final class MiddlewareController {
  final OrioleRouteInternal route;

  MiddlewareController(this.route);

  List<OrioleMiddleware> get middleware {
    final list = <OrioleMiddleware>[];
    if (route.hasMiddleware) {
      list.addAll(route.route.middlewares);
    }
    list.addAll(Oriole.settings.middlewares);
    list.sort((a, b) => a.priority.compareTo(b.priority));
    return list;
  }

  Future<String?> runRedirect() async {
    final path = route.getLastActivePath();
    for (var middle in middleware) {
      final result = await middle.redirectGuard(path);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  Future runOnEnter() async {
    for (var middle in middleware) {
      await middle.onEnter();
    }
  }

  Future runOnExit() async {
    for (var middle in middleware) {
      await middle.onExit();
    }
  }

  Future scheduleOnExited() async {
    if (middleware.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.endOfFrame.then((_) {
        for (var middle in middleware) {
          middle.onExited();
        }
      });
    });
  }

  Future runOnMatch() async {
    for (var middle in middleware) {
      await middle.onMatch();
    }
  }

  Future<bool> runCanPop() async {
    for (var middle in middleware) {
      if (!await middle.canPop()) return false;
    }
    return true;
  }
}
