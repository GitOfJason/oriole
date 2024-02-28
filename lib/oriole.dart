library oriole;

import 'package:oriole/src/oriole_modular.dart';
import 'package:oriole/src/oriole_modular_module.dart';
export 'src/widgets/oriole_app.dart';
export 'src/widgets/router_state.dart';
export 'src/types/module.dart';
export 'src/types/setting.dart';
export 'src/types/observer.dart';
export 'src/routes/route.dart';
export 'src/library_internal.dart'
    show RouteManager, OrioleRouteManagerExt, OrioleNavigatorExt;
export 'src/pages/pages.dart';
export 'src/pages/page_internal.dart' show OriolePageInternal;
export 'src/routers/router.dart';
export 'src/types/middleware.dart';
export 'src/types/params.dart';
export 'src/types/oriole_key.dart';
export 'src/types/disposable.dart';
export 'src/types/pop_result.dart';
export 'package:auto_injector/auto_injector.dart';

OrioleModular? _modular;

// ignore: non_constant_identifier_names
OrioleModular get Oriole {
  _modular ??= injector.get<OrioleModular>();
  return _modular!;
}

void cleanModular() {
  _modular?.destroy();
  _modular = null;
}

void cleanGlobals() {
  cleanModular();
}
