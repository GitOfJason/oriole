import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:oriole/oriole.dart';

class OrioleRouteInformationParser extends RouteInformationParser<String> {
  const OrioleRouteInformationParser();

  @override
  Future<String> parseRouteInformation(RouteInformation routeInformation) async {
    return SynchronousFuture(routeInformation.uri.path);
  }

  @override
  RouteInformation restoreRouteInformation(String configuration) {
    return RouteInformation(
      uri: Uri.parse(
        Oriole.to.currentPath
      ),
    );
  }
}
