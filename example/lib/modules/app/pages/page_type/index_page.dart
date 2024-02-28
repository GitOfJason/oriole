import 'package:flutter/material.dart';
import 'package:oriole/oriole.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Type'),
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () {
              Oriole.to.push('/pageType/platform');
            },
            title: const Text("Platform"),
          ),
          ListTile(
            onTap: () {
              Oriole.to.push('/pageType/material');
            },
            title: const Text("Material"),
          ),
          ListTile(
            onTap: () {
              Oriole.to.push('/pageType/cupertino');
            },
            title: const Text("Cupertino"),
          ),
          ListTile(
            onTap: () {
              Oriole.to.push('/pageType/slide');
            },
            title: const Text("Slide"),
          ),
          ListTile(
            onTap: () {
              Oriole.to.push('/pageType/fade');
            },
            title: const Text("Fade"),
          ),
          ListTile(
            onTap: () {
              Oriole.to.push('/pageType/custom');
            },
            title: const Text("Custom"),
          ),
          ListTile(
            onTap: () {
              Oriole.to.push(
                '/dialog',
                params: {"title": 'Oriole', "content": "Oriole dialog page."},
              );
            },
            title: const Text("Dialog"),
          ),
          ListTile(
            onTap: () {
              Oriole.to.push(
                '/pageType/bottomSheet',
                params: {"title": 'Oriole', "content": "Oriole dialog page."},
              );
            },
            title: const Text("Bottom Sheet"),
          ),
        ],
      ),
    );
  }
}
