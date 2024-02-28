import 'package:oriole/oriole.dart';
import '../pages/page_creator.dart';
import '../pages/page_internal.dart';
import '../routes/route_internal.dart';
import 'middleware_controller.dart';

class PagesController {
  final routes = <OrioleRouteInternal>[];

  static const String _initPageKey = 'Init Page';

  OrioleMaterialPageInternal get _initPage {
    return OrioleMaterialPageInternal(
      child: Oriole.settings.initPage,
      matchKey: OrioleKey(_initPageKey),
    );
  }

  late final pages = <OriolePageInternal>[_initPage];

  Future<PopResult> removeLast({
    dynamic result,
    bool allowEmptyPages = false,
  }) async {
    if (routes.isEmpty) {
      return PopResult.notPopped;
    }
    final route = routes.last; // find the page

    final middleware = MiddlewareController(route);
    if (!await middleware.runCanPop()) return PopResult.notAllowedToPop;

    if (!allowEmptyPages && routes.length == 1) {
      return PopResult.notPopped;
    }

    await middleware.runOnExit(); // run on exit
    middleware.scheduleOnExited(); // schedule on exited

    if (await Oriole.to.removeNavigator(route.name)) {
      // if this route has navigator then remove it to remove this route too.
      // and remove all histories to this route
      Oriole.to.history.removeWithNavigator(route.name);
    }

    Oriole.to.history.removeLast();
    if (Oriole.to.history.hasLast &&
        Oriole.to.history.current.path == route.activePath) {
      Oriole.to.history.removeLast();
    }
    await _notifyObserverOnPop(route);
    routes.removeLast(); // remove from the routes
    pages.removeLast(); // remove from the pages
    route.complete(result);
    _checkEmptyStack();
    return PopResult.popped;
  }

  Future<PopResult> removeAll() async {
    for (var i = 0; i < routes.length; i++) {
      final popResult = await removeLast(allowEmptyPages: true);
      if (popResult != PopResult.popped) {
        return popResult;
      }
      i--;
    }
    return PopResult.popped;
  }

  void _checkEmptyStack() {
    if (pages.isEmpty) {
      pages.add(_initPage);
    }
  }

  Future<bool> removeIndex(int index) async {
    final route = routes[index]; // find the page
    final middleware = MiddlewareController(route);
    if (!await middleware.runCanPop()) return false;
    await middleware.runOnExit(); // run on exit
    middleware.scheduleOnExited(); // schedule on exited

    Oriole.to.removeNavigator(route.name); // remove navigator if exist
    Oriole.to.history.remove(route); // remove history for this route
    await _notifyObserverOnPop(route);
    if (routes.isNotEmpty) routes.removeAt(index); // remove from the routes
    if (pages.isNotEmpty) pages.removeAt(index); // remove from the pages
    _checkEmptyStack();
    return true;
  }

  bool exist(OrioleRouteInternal route) =>
      routes.any((element) => element.key.isSame(route.key));

  Future<void> add(OrioleRouteInternal route) async {
    routes.add(route);
    await MiddlewareController(route).runOnEnter();
    await _notifyObserverOnNavigation(route);
    pages.add(await PageCreator(route).create());
    if (pages.any((element) => element.matchKey.hasName(_initPageKey))) {
      pages.removeWhere((element) => element.matchKey.hasName(_initPageKey));
    }
  }

  Future _notifyObserverOnPop(OrioleRouteInternal route) async {
    Oriole.reportPopRoute(route.route);
    for (var observer in Oriole.settings.observers) {
      observer.onPop(route.activePath!, route.route);
    }
  }

  Future _notifyObserverOnNavigation(OrioleRouteInternal route) async {
    Oriole.reportPushRoute(route.route);
    for (var observer in Oriole.settings.observers) {
      observer.onNavigate(route.activePath!, route.route);
    }
  }
}
