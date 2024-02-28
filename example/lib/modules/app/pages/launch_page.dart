import 'package:flutter/material.dart';
import 'package:oriole/oriole.dart';

class LaunchPage extends StatefulWidget {
  const LaunchPage({super.key});

  @override
  State<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Oriole.to.replaceAll('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Oriole",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              "Modular Routing Example",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
