import 'package:flutter/cupertino.dart';

import 'package:oriole/oriole.dart';
import '../controllers/navigator.dart';
import '../controllers/router_controller.dart';

class OrioleRouter extends StatefulWidget {

  final navKey = GlobalKey<NavigatorState>();

  final OrioleRouterController _controller;

  late final List<NavigatorObserver> observers = [_controller.observer];

  OrioleRouter(
    this._controller, {
    List<NavigatorObserver>? observers,
    Key? key,
    this.restorationId,
  }) : super(key: key) {
    if (observers != null) {
      this.observers.addAll(observers);
    }
  }

  final String? restorationId;


  String get routeName => _controller.currentRoute.path;

  OrioleNavigator get navigator => _controller;

  @override
  State createState() => _QRouterState();
}

class _QRouterState extends State<OrioleRouter> {
  @override
  void initState() {
    super.initState();
    if (widget._controller.isDisposed) return;
    widget._controller.addListener(update);
    widget._controller.didSwitchTo = _didSwitchTo;
    widget._controller.navKey = widget.navKey;
  }

  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var scopeId = widget.restorationId;
    if (scopeId == null && Oriole.settings.autoRestoration) {
      scopeId = 'router:${widget._controller.key.name}';
    }

    return Navigator(
      key: widget.navKey,
      observers: widget.observers,
      pages: widget._controller.pages,
      onPopPage: _onPopPage,
      restorationScopeId: scopeId,
    );
  }

  bool _onPopPage(route, result) {
    Oriole.to.back();
    return false;
  }

  void _didSwitchTo(RouteSettings current, RouteSettings? pre) {
    for (var observer in widget.observers) {
      if (observer is OrioleNavigatorObserver) {
        observer.didSwitchTo(current, pre);
      }
    }
  }

  @override
  void dispose() {
    if (!widget._controller.isDisposed) {
      widget._controller.removeListener(update);
    }
    super.dispose();
  }
}
