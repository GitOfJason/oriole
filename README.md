The purpose of creating this routing library is to combine the functionalities of [Flutter_Modular ](https://pub.dev/packages/flutter_modular)and [Qlevar_Router](https://pub.dev/packages/qlevar_router) libraries, providing a more powerful and flexible solution for route management. By trimming and merging the code from these two libraries, it can leverage their respective strengths to achieve efficient route navigation and management.

This library aims to simplify route handling for developers in Flutter applications, offering an improved development experience and enhanced functionality.



```dart

void main() {
  runApp(
    OrioleApp(
      module: AppModule(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      routerDelegate: Oriole.routerDelegate,
      routeInformationParser: Oriole.routeInformationParser,
    );
  }
}

class AppModule extends OrioleModule {
  @override
  void binds(Injector i) {
    // binds
    i.addSingleton<UserService>(UserServiceImpl.new);
  }

  @override
  void routes(RouteManager manager) {
    // routes
    manager.shell(
      path: '/',
      builder: (router) => DashboardShell(router: router),
      children: [
        ChildRoute(
          path: '/home',
          builder: () => const HomePage(),
          pageType: const OrioleCustomPage(),
        ),
        ChildRoute(
          path: '/setting',
          builder: () => const SettingPage(),
          pageType: const OrioleCustomPage(),
        ),
      ],
    );
    
    manager.module(name: '/other', module: OtherModule());
    manager.child(path: '/other/page', builder: () => const OtherPage());
  }
}

```

```dart
// Navigation
Oriole.to.go("/");

// Push
Oriole.to.push("/");

// Replace
Oriole.to.replaceAll("/");

// Nested navigation
Oriole.switchTo('/home')

// Get service
Oriole.get<UserService>();

```

The documentation is not comprehensive, you can refer to the documentation of  [Flutter_Modular ](https://pub.dev/packages/flutter_modular) and [Qlevar_Router](https://pub.dev/packages/qlevar_router).

For more usage examples of this library, please refer to the provided examples.









