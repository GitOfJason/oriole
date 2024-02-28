import 'package:auto_injector/auto_injector.dart';
import 'package:oriole/src/tracker/tracker.dart';
import 'package:oriole/src/types/logger.dart';

import 'library_internal.dart';
import 'oriole_modular.dart';

final _innerInjector = AutoInjector(
  tag: 'OrioleApp',
  on: (i) {
    i.addInstance<AutoInjector>(i);
    i.commit();
  },
);

final injector = AutoInjector(
  tag: 'OrioleCore',
  on: (i) {
    i.addInstance<AutoInjector>(_innerInjector);
    i.addSingleton<Logger>(Logger.new);
    i.addSingleton<Tracker>(TrackerImpl.new);
    i.addSingleton<OrioleNavigatorContext>(OrioleNavigatorContext.new);
    i.addLazySingleton<OrioleModular>(OrioleModularImpl.new);
    i.commit();
  },
);
