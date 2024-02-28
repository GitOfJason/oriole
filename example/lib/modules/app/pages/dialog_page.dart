import 'package:flutter/material.dart';
import 'package:oriole/oriole.dart';

class DialogPage extends StatelessWidget {
  const DialogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final title = Oriole.to.params["title"];
    final content = Oriole.to.params["content"];
    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 200,
            minWidth: 300,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title?.asString ?? 'Title',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(content?.asString ?? 'Content'),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: () {
                  Oriole.to.back(true);
                },
                child: const Text("Close"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
