import 'package:flutter/material.dart';
import 'package:oriole/oriole.dart';

class ModalBottomSheetPageType extends OriolePageTypeCustomCreator {
  final bool isScrollControlled;

  const ModalBottomSheetPageType({
    this.isScrollControlled = false,
  });

  @override
  OriolePageInternal createPageInternal(Widget child, OrioleRoute route) {
    return _ModalBottomSheetRoutePageInternal(
      matchKey: route.key,
      child: child,
      isScrollControlled: isScrollControlled,
    );
  }
}

class _ModalBottomSheetRoutePageInternal extends OriolePageInternal {
  final Widget child;
  final bool isScrollControlled;

  const _ModalBottomSheetRoutePageInternal({
    required super.matchKey,
    required this.child,
    this.isScrollControlled = false,
  });

  @override
  Route createRoute(BuildContext context) {
    final theme = Theme.of(context);
    return ModalBottomSheetRoute(
      builder: (_) => child,
      settings: this,
      useSafeArea: true,
      isScrollControlled: isScrollControlled,
    );
  }
}
