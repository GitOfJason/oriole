import 'package:flutter/cupertino.dart';

import 'package:oriole/oriole.dart';

class OrioleApp extends StatefulWidget {
  final OrioleModule module;
  final Widget child;
  final OrioleSettings? settings;

  const OrioleApp({super.key, required this.module, required this.child, this.settings});

  @override
  State<OrioleApp> createState() => _OrioleAppState();
}

class _OrioleAppState extends State<OrioleApp> {
  @override
  void initState() {
    super.initState();
    Oriole.init(widget.module, settings: widget.settings);
  }

  @override
  void dispose() {
    Oriole.destroy();
    cleanModular();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
