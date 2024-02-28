import 'package:flutter/material.dart';
import 'package:oriole/oriole.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: const Text(
          "Oriole",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () {
              Oriole.to.push('/dashboard');
            },
            title: const Text("Shell Route"),
          ),
          ListTile(
            onTap: () {
              Oriole.to.push('/pageType');
            },
            title: const Text("Page Types"),
          ),
          ListTile(
            onTap: () {
              Oriole.to.push('/middleware');
            },
            title: const Text("Middleware"),
          )
        ],
      ),
    );
  }
}
