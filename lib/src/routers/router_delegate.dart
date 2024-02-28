import 'dart:async';
import 'package:flutter/material.dart';

import 'package:oriole/oriole.dart';
import '../controllers/navigator.dart';
import '../controllers/router_controller.dart';
import '../library_internal.dart';

class OrioleRouterDelegate extends RouterDelegate<String> with ChangeNotifier {
  OrioleRouterDelegate() {
    _createController();
  }

  late OrioleRouterController _controller;

  @override
  String? get currentConfiguration => Oriole.to.currentPath;

  Navigator get navigator {
    return Navigator(
      key: Oriole.settings.navigatorKey,
      pages: _controller.pages,
      observers: Oriole.settings.navigatorObserver,
      onPopPage: (route, result) {
        _controller.removeLast();
        return false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _controllerCompleter.future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return navigator;
        }
        return const Material(
          child: Center(
            child: Text('Loading'),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.disposeAsync();
    super.dispose();
  }

  @override
  Future<bool> popRoute() async {
    final result = await Oriole.to.back();
    switch (result) {
      case PopResult.notPopped:
        return false;
      default:
        return true;
    }
  }

  @override
  Future<void> setNewRoutePath(String configuration) async {
    try {
      configuration = Uri.decodeFull(configuration).toString();
    } catch (_) {
      Oriole.log('Error while decoding the route $configuration');
    }
    if (Oriole.to.history.hasLast &&
        Oriole.to.history.last.path == Oriole.settings.notFoundPage.path) {
      if (Oriole.to.history.length > 2 &&
          configuration == Oriole.to.history.beforeLast.path) {
        Oriole.to.history.removeLast();
      }
    }
    if (Oriole.to.history.hasLast &&
        configuration == Oriole.to.history.last.path) {
      Oriole.log(
        'New route reported that was last visited. using QR.back() to response',
      );
      Oriole.to.back();
      return;
    }
    await Oriole.to.go(configuration, ignoreSamePath: false);
    return;
  }

  @override
  Future<void> setInitialRoutePath(String configuration) async {
    await _controllerCompleter.future;
    if (configuration != _slash) {
      Oriole.log('incoming init path $configuration');
      if (Oriole.settings.alwaysAddInitPath) {
        Oriole.log('adding init path ${Oriole.settings.initPath} because QRouterDelegate.alwaysAddInitPath is true');
        await Oriole.to.go(Oriole.settings.initPath ?? _slash);
      }
      await Oriole.to.go(configuration);
      return;
    }
    await _controller.push(Oriole.settings.initPath ?? _slash);
  }

  final _controllerCompleter = Completer<OrioleNavigator>();

  Future<void> _createController() async {
    final routes = Oriole.routes;
    _controller = await Oriole.to.createRouterController(
      OrioleNavigatorContext.rootRouterName,
      routes: routes,
    );
    _controllerCompleter.complete(_controller);
    _controller.addListener(notifyListeners);
  }
}

const _slash = '/';
