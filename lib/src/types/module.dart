import 'package:auto_injector/auto_injector.dart';

import '../library_internal.dart';

abstract class OrioleModule {
  List<OrioleModule> get imports => const [];

  void binds(Injector i) {}

  void exportedBinds(Injector i) {}

  void routes(RouteManager manager) {}
}
