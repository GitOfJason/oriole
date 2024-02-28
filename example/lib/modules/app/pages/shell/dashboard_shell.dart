import 'package:flutter/material.dart';
import 'package:oriole/oriole.dart';

class DashboardShell extends StatefulWidget {
  final OrioleRouter router;

  const DashboardShell({super.key, required this.router});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends OrioleRouterState<DashboardShell> {
  final List<String> pages = ['/home', '/setting'];

  @override
  Widget build(BuildContext context) {
    final index = pages.indexOf(widget.router.routeName);
    return Scaffold(
      appBar: AppBar(),
      body: widget.router,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
        ],
        currentIndex: index == -1 ? 0 : index,
        onTap: (index) {
          Oriole.to.navigatorOf('/dashboard').switchTo(pages[index]);
        },
      ),
    );
  }

  @override
  OrioleRouter get router => widget.router;
}
