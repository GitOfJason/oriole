import 'package:flutter/material.dart';

import '../routers/router.dart';

abstract class OrioleRouterState<T extends StatefulWidget> extends State<T> {
  OrioleRouter get router;

  @override
  void initState() {
    router.navigator.addListener(_update);
    super.initState();
  }

  void _update() {
    setState(() {});
  }

  @override
  void dispose() {
    router.navigator.removeListener(_update);
    super.dispose();
  }
}
