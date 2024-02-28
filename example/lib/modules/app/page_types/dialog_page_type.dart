import 'package:flutter/material.dart';
import 'package:oriole/oriole.dart';

class DialogPageType extends OriolePageTypeCustomCreator {
  final bool barrierDismissible;

  const DialogPageType({
    this.barrierDismissible = true,
  });

  @override
  OriolePageInternal createPageInternal(Widget child, OrioleRoute route) {
    return _DialogPageInternal(
      matchKey: route.key,
      child: child,
      barrierDismissible: barrierDismissible,
    );
  }
}

class _DialogPageInternal extends OriolePageInternal {
  final Widget child;
  final bool barrierDismissible;

  const _DialogPageInternal({
    required super.matchKey,
    required this.child,
    this.barrierDismissible = true,
  });

  @override
  Route createRoute(BuildContext context) {
    return DialogRoute(
      context: context,
      builder: (_) => child,
      settings: this,
      useSafeArea: true,
      barrierDismissible: barrierDismissible,
    );
  }
}
