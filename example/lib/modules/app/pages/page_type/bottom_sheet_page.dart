import 'package:flutter/material.dart';
import 'package:oriole/oriole.dart';

class BottomSheetPage extends StatelessWidget {
  const BottomSheetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final title = Oriole.to.params["title"];
    final content = Oriole.to.params["content"];
    return Container(
      constraints: const BoxConstraints(
        minHeight: 300,
        minWidth: double.infinity
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
              Oriole.to.back();
            },
            child: const Text("Close"),
          )
        ],
      ),
    );
  }
}
