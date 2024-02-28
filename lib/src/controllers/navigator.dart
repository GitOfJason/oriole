import 'package:flutter/cupertino.dart';

import '../routes/route.dart';
import '../types/oriole_key.dart';
import '../types/pop_result.dart';

abstract class OrioleNavigator extends ChangeNotifier {
  OrioleRoute get currentRoute;

  Future<T?> push<T>(String path, {
    Map<String, dynamic>? params,
    bool waitForResult,
  });

  Future<void> replace(String path, String withPath);

  Future<void> replaceAll(String path);

  Future<void> popUntilOrPush(String path);

  Future<void> replaceLast(String path);

  Future<void> switchTo(String path);

  Future<PopResult> removeLast({dynamic result});

  void addRoutes(List<OrioleRoute> routes);

  void removeRoutes(List<String> routesNames);

  void updateUrl(String url, {
    Map<String, dynamic>? params,
    OrioleKey? mKey,
    String? navigator = '',
    bool updateParams = false,
    bool addHistory = true,
  });
}
