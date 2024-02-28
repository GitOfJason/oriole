import 'package:example/modules/app/module.dart';
import 'package:flutter/material.dart';
import 'package:oriole/oriole.dart';

final OrioleSettings settings = OrioleSettings(
  initPath: '/launch',
);

void main() {
  runApp(
    OrioleApp(
      module: AppModule(),
      settings: settings,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerDelegate: Oriole.routerDelegate,
      routeInformationParser: Oriole.routeInformationParser,
    );
  }
}
