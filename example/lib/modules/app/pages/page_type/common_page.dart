import 'package:flutter/material.dart';
import 'package:oriole/oriole.dart';

class CommonPage extends StatelessWidget {
  final String title;
  final String content;

  const CommonPage({super.key,  required this.title,required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(content),
      ),
    );
  }
}
