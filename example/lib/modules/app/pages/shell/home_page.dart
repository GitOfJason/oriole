import 'package:flutter/material.dart';
import 'package:oriole/oriole.dart';

class ShellHomePage extends StatefulWidget {
  const ShellHomePage({super.key});

  @override
  State<ShellHomePage> createState() => _HomePageState();
}

class _HomePageState extends State<ShellHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text("Home page"),
          ],
        ),
      ),
    );
  }
}
