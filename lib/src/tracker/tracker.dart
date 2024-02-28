import 'package:auto_injector/auto_injector.dart';

import '../library_internal.dart';
import '../routes/route.dart';
import '../types/logger.dart';
import '../types/module.dart';

abstract class Tracker {

  AutoInjector get injector;

  OrioleModule get module;

  Logger get logger;

  factory Tracker(AutoInjector injector, Logger logger) => TrackerImpl(
        injector,
        logger,
      );

  void reportPopRoute(OrioleRoute route);

  void reportPushRoute(OrioleRoute route);


  void runApp(OrioleModule module);


  void bindModule(OrioleModule module, [String? tag]);


  void unbindModule(String moduleName);

  void finishApp();

  bool dispose<B>();

  List<OrioleRoute> get routes;

  OrioleRoute? getRouteByKey(String key);
}
