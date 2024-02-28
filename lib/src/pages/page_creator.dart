import 'package:flutter/cupertino.dart';
import 'package:oriole/src/pages/page_internal.dart';

import 'package:oriole/oriole.dart';
import '../types/platform/platform_web.dart'
    if (dart.library.io) '../types/platform/platform_io.dart';
import '../routes/route_internal.dart';

abstract class _PageConverter {
  _PageConverter(
    this.internalRoute,
  ) {
    pageType = internalRoute.route.pageType ?? Oriole.settings.pageType;
    matchKey = internalRoute.key;
    pageName = internalRoute.route.path;
  }

  late final key = ValueKey<int>(hashCode);
  late final OrioleKey matchKey;
  late final String? pageName;
  late final OriolePageType pageType;
  final OrioleRouteInternal internalRoute;

  OrioleRoute get route => internalRoute.route;

  OriolePageInternal createWithChild(Widget child) {
    final page = switch (pageType) {
      OriolePlatformPageType() =>
        OriolePlatform.isWeb == false && OriolePlatform.isIOS
            ? _getCupertinoPage(pageName, child)
            : _getMaterialPage(child),
      OrioleCupertinoPageType page => _getCupertinoPage(page.title, child),
      OrioleCustomPageType() => _getCustomPage(child),
      OriolePageTypeCustomCreator page => page.createPageInternal(child, route),
      OriolePageType() => _getMaterialPage(child),
    };
    return page;
  }

  String? _getRestorationId() {
    var id = pageType.restorationId;
    if (id == null && Oriole.settings.autoRestoration) {
      id = 'page:${matchKey.name}';
    }
    return id;
  }

  OrioleMaterialPageInternal _getMaterialPage(Widget child) {
    bool addMaterialWidget = true;
    if (pageType is OrioleMaterialPageType) {
      final page = pageType as OrioleMaterialPageType;
      addMaterialWidget = page.addMaterialWidget;
    }
    return OrioleMaterialPageInternal(
      name: pageName,
      child: child,
      maintainState: pageType.maintainState,
      fullScreenDialog: pageType.fullScreenDialog,
      restorationId: _getRestorationId(),
      key: key,
      addMaterialWidget: addMaterialWidget,
      matchKey: matchKey,
      meta: route.meta,
    );
  }

  OrioleCupertinoPageInternal _getCupertinoPage(String? title, Widget child) {
    return OrioleCupertinoPageInternal(
      name: pageName,
      child: child,
      maintainState: pageType.maintainState,
      fullScreenDialog: pageType.fullScreenDialog,
      restorationId: _getRestorationId(),
      title: title,
      key: key,
      matchKey: matchKey,
      meta: route.meta,
    );
  }

  OrioleCustomPageInternal _getCustomPage(Widget child) {
    final page = pageType as OrioleCustomPageType;
    return OrioleCustomPageInternal(
      name: pageName,
      child: child,
      maintainState: pageType.maintainState,
      fullScreenDialog: pageType.fullScreenDialog,
      restorationId: _getRestorationId(),
      key: key,
      matchKey: matchKey,
      barrierColor: page.barrierColor,
      barrierDismissible: page.barrierDismissible,
      barrierLabel: page.barrierLabel,
      opaque: page.opaque,
      transitionDuration: page.transitionDuration,
      reverseTransitionDuration: page.reverseTransitionDuration,
      transitionsBuilder: page.transitionsBuilder ?? _buildTransaction,
      meta: route.meta,
    );
  }

  Widget _buildTransaction(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _getTransaction(
      pageType as OrioleCustomPageType,
      child,
      animation,
    );
  }

  Widget _getTransaction(
    OrioleCustomPageType type,
    Widget child,
    Animation<double> animation,
  ) {
    switch (type.runtimeType) {
      case OrioleSlidePageType:
        final slide = type as OrioleSlidePageType;
        child = SlideTransition(
          position: CurvedAnimation(
            parent: animation,
            curve: slide.curve ?? Curves.easeIn,
          ).drive(
            Tween<Offset>(
              end: Offset.zero,
              begin: slide.offset ?? const Offset(1, 0),
            ),
          ),
          child: child,
        );
        break;
      case OrioleFadePageType:
        child = FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: (type as OrioleFadePageType).curve ?? Curves.easeIn,
          ).drive(
            Tween<double>(end: 1, begin: 0),
          ),
          child: child,
        );
        break;
    }

    return type.withType == null
        ? child
        : _getTransaction(type.withType!, child, animation);
  }
}

class PageCreator extends _PageConverter {
  PageCreator(super.internalRoute);

  Future<OriolePageInternal> create() async {
    return super.createWithChild(await build());
  }

  Future<Widget> build() async {
    if (route.withChildRouter) {
      final router = await Oriole.to.createNavigator(
        route.path,
        cRoutes: internalRoute.children,
        initPath: route.initRoute ?? '/',
        initRoute: internalRoute.child,
        observers: route.observers,
        restorationId: route.restorationId,
      );
      if (route.initRoute != null && internalRoute.child == null) {
        internalRoute.activePath =
            '${internalRoute.activePath}${route.initRoute}';
      }
      return route.shellBuilder!(router);
    }

    return route.builder!();
  }
}
