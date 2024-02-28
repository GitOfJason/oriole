import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../types/oriole_key.dart';

abstract class OriolePageInternal<T> extends Page {
  const OriolePageInternal({
    required this.matchKey,
    LocalKey? key,
    String? restorationId,
    String? name,
    Object? arguments,
    this.meta,
  }) : super(
          arguments: arguments,
          key: key,
          name: name,
          restorationId: restorationId,
        );

  final OrioleKey matchKey;
  final Map<String, dynamic>? meta;

  bool sameKey(OriolePageInternal other) => matchKey == other.matchKey;
}

final class OrioleMaterialPageInternal<T> extends OriolePageInternal<T> {
  const OrioleMaterialPageInternal({
    required this.child,
    required OrioleKey matchKey,
    this.maintainState = true,
    this.addMaterialWidget = true,
    this.fullScreenDialog = false,
    LocalKey? key,
    String? restorationId,
    String? name,
    Object? arguments,
    super.meta,
  }) : super(
          matchKey: matchKey,
          key: key,
          name: name,
          arguments: arguments,
          restorationId: restorationId,
        );
  final bool addMaterialWidget;
  final Widget child;
  final bool fullScreenDialog;
  final bool maintainState;

  @override
  Route<T> createRoute(BuildContext context) {
    return _PageBasedMaterialPageRoute<T>(page: this);
  }
}

class _PageBasedMaterialPageRoute<T> extends PageRoute<T>
    with MaterialRouteTransitionMixin<T> {
  _PageBasedMaterialPageRoute({
    required OrioleMaterialPageInternal<T> page,
  }) : super(settings: page) {
    assert(opaque);
  }

  @override
  Widget buildContent(BuildContext context) {
    return _page.addMaterialWidget ? Material(child: _page.child) : _page.child;
  }

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';

  @override
  bool get fullscreenDialog => _page.fullScreenDialog;

  @override
  bool get maintainState => _page.maintainState;

  OrioleMaterialPageInternal<T> get _page =>
      settings as OrioleMaterialPageInternal<T>;
}

final class OrioleCupertinoPageInternal<T> extends OriolePageInternal<T> {
  const OrioleCupertinoPageInternal({
    required OrioleKey matchKey,
    required this.child,
    this.title,
    this.maintainState = true,
    this.fullScreenDialog = false,
    LocalKey? key,
    String? restorationId,
    String? name,
    Object? arguments,
    super.meta,
  }) : super(
          key: key,
          name: name,
          restorationId: restorationId,
          arguments: arguments,
          matchKey: matchKey,
        );

  final Widget child;
  final bool fullScreenDialog;
  final bool maintainState;
  final String? title;

  @override
  Route<T> createRoute(BuildContext context) {
    return _PageBasedCupertinoPageRoute<T>(page: this);
  }
}

class _PageBasedCupertinoPageRoute<T> extends PageRoute<T>
    with CupertinoRouteTransitionMixin<T> {
  _PageBasedCupertinoPageRoute({
    required OrioleCupertinoPageInternal<T> page,
  }) : super(settings: page) {
    assert(opaque);
  }

  @override
  Widget buildContent(BuildContext context) => _page.child;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';

  @override
  bool get fullscreenDialog => _page.fullScreenDialog;

  @override
  bool get maintainState => _page.maintainState;

  @override
  String? get title => _page.title;

  OrioleCupertinoPageInternal<T> get _page =>
      settings as OrioleCupertinoPageInternal<T>;
}

final class OrioleCustomPageInternal extends OriolePageInternal {
  const OrioleCustomPageInternal({
    required this.child,
    required OrioleKey matchKey,
    required this.transitionDuration,
    required this.reverseTransitionDuration,
    required this.transitionsBuilder,
    this.maintainState = true,
    this.fullScreenDialog = false,
    this.barrierColor,
    this.barrierLabel,
    this.barrierDismissible,
    this.opaque,
    LocalKey? key,
    String? restorationId,
    String? name,
    Object? arguments,
    super.meta,
  }) : super(
          key: key,
          name: name,
          arguments: arguments,
          matchKey: matchKey,
          restorationId: restorationId,
        );

  final Color? barrierColor;
  final bool? barrierDismissible;
  final String? barrierLabel;
  final Widget child;
  final bool fullScreenDialog;
  final bool maintainState;
  final bool? opaque;
  final Duration transitionDuration;
  final Duration reverseTransitionDuration;
  final RouteTransitionsBuilder transitionsBuilder;

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      pageBuilder: (c, a1, a2) => child,
      settings: this,
      opaque: opaque ?? true,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: reverseTransitionDuration,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible ?? false,
      barrierLabel: barrierLabel,
      transitionsBuilder: transitionsBuilder,
      fullscreenDialog: fullScreenDialog,
      maintainState: maintainState,
    );
  }
}
