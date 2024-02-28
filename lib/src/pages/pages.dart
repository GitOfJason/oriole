import 'package:flutter/material.dart';
import 'package:oriole/oriole.dart';

const defaultDuration = Duration(milliseconds: 300);

abstract class OriolePageType {
  const OriolePageType(
    this.fullScreenDialog,
    this.maintainState,
    this.restorationId,
  );

  final bool fullScreenDialog;
  final bool maintainState;
  final String? restorationId;
}

abstract class OriolePageTypeCustomCreator extends OriolePageType {
  const OriolePageTypeCustomCreator() : super(false, false, null);

  OriolePageInternal createPageInternal(Widget child, OrioleRoute route);
}

class OriolePlatformPageType extends OriolePageType {
  const OriolePlatformPageType({
    bool fullscreenDialog = false,
    bool maintainState = true,
    String? restorationId,
  }) : super(fullscreenDialog, maintainState, restorationId);
}

class OrioleMaterialPageType extends OriolePageType {
  const OrioleMaterialPageType({
    bool fullscreenDialog = false,
    bool maintainState = true,
    this.addMaterialWidget = true,
    String? restorationId,
  }) : super(fullscreenDialog, maintainState, restorationId);

  final bool addMaterialWidget;
}

class OrioleCupertinoPageType extends OriolePageType {
  const OrioleCupertinoPageType({
    bool fullscreenDialog = false,
    bool maintainState = true,
    String? restorationId,
    this.title,
  }) : super(fullscreenDialog, maintainState, restorationId);

  final String? title;
}

class OrioleCustomPageType extends OriolePageType {
  const OrioleCustomPageType({
    bool fullscreenDialog = false,
    bool maintainState = true,
    this.barrierColor,
    this.barrierDismissible,
    this.barrierLabel,
    this.opaque,
    this.transitionDuration = defaultDuration,
    this.reverseTransitionDuration = defaultDuration,
    this.transitionsBuilder,
    String? restorationId,
    this.withType,
  }) : super(fullscreenDialog, maintainState, restorationId);

  final Color? barrierColor;
  final bool? barrierDismissible;
  final String? barrierLabel;
  final bool? opaque;
  final Duration transitionDuration;
  final Duration reverseTransitionDuration;
  final RouteTransitionsBuilder? transitionsBuilder;
  final OrioleCustomPageType? withType;
}

class OrioleSlidePageType extends OrioleCustomPageType {
  const OrioleSlidePageType({
    bool fullscreenDialog = false,
    bool maintainState = true,
    Color? barrierColor,
    bool? barrierDismissible,
    String? barrierLabel,
    bool? opaque,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    String? restorationId,
    OrioleCustomPageType? withType,
    this.curve,
    this.offset,
  }) : super(
          barrierColor: barrierColor,
          barrierDismissible: barrierDismissible,
          barrierLabel: barrierLabel,
          fullscreenDialog: fullscreenDialog,
          maintainState: maintainState,
          opaque: opaque,
          transitionDuration: transitionDuration ?? defaultDuration,
          reverseTransitionDuration:
              reverseTransitionDuration ?? defaultDuration,
          restorationId: restorationId,
          withType: withType,
        );

  final Curve? curve;
  final Offset? offset;
}

class OrioleFadePageType extends OrioleCustomPageType {
  const OrioleFadePageType({
    bool fullscreenDialog = false,
    bool maintainState = true,
    Color? barrierColor,
    bool? barrierDismissible,
    String? barrierLabel,
    bool? opaque,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    String? restorationId,
    OrioleCustomPageType? withType,
    this.curve,
  }) : super(
            barrierColor: barrierColor,
            barrierDismissible: barrierDismissible,
            barrierLabel: barrierLabel,
            fullscreenDialog: fullscreenDialog,
            maintainState: maintainState,
            opaque: opaque,
            transitionDuration: transitionDuration ?? defaultDuration,
            reverseTransitionDuration:
                reverseTransitionDuration ?? defaultDuration,
            restorationId: restorationId,
            withType: withType);

  final Curve? curve;
}
