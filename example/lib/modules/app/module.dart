import 'package:example/modules/app/guard/auth_guard.dart';
import 'package:example/modules/app/page_types/bottom_sheet_page_type.dart';
import 'package:example/modules/app/page_types/dialog_page_type.dart';
import 'package:example/modules/app/pages/dialog_page.dart';
import 'package:example/modules/app/pages/home_page.dart';
import 'package:example/modules/app/pages/launch_page.dart';
import 'package:example/modules/app/pages/login_page.dart';
import 'package:example/modules/app/pages/page_type/bottom_sheet_page.dart';
import 'package:example/modules/app/pages/page_type/common_page.dart';
import 'package:example/modules/app/pages/page_type/index_page.dart';
import 'package:example/modules/app/pages/shell/dashboard_shell.dart';
import 'package:example/modules/app/pages/shell/setting_page.dart';
import 'package:example/modules/app/pages/shell/home_page.dart';
import 'package:example/modules/app/services/auth_service.dart';
import 'package:flutter/cupertino.dart';

import 'package:oriole/oriole.dart';

class AppModule extends OrioleModule {
  @override
  void binds(Injector i) {
    i.addSingleton<AuthService>(AuthServiceImpl.new);
  }

  @override
  void routes(RouteManager manager) {
    manager.child(
      path: '/launch',
      builder: () => const LaunchPage(),
      pageType: const OrioleCustomPageType(),
    );
    manager.child(
      path: '/home',
      builder: () => const HomePage(),
      pageType: const OrioleCustomPageType(),
    );
    manager.child(
      path: '/login',
      builder: () => const LoginPage(),
    );
    manager.child(
      path: '/dialog',
      pageType: const DialogPageType(),
      builder: () => const DialogPage(),
    );
    manager.shell(
      path: '/dashboard',
      initRoute: '/home',
      builder: (router) => DashboardShell(router: router),
      children: [
        ChildRoute(
          path: '/home',
          builder: () => const ShellHomePage(),
          pageType: const OrioleCustomPageType(),
        ),
        ChildRoute(
          path: '/setting',
          builder: () => const SettingPage(),
          pageType: const OrioleCustomPageType(),
        ),
      ],
    );
    manager.child(
      path: '/pageType',
      builder: () => const IndexPage(),
      children: [
        ChildRoute(
          path: '/platform',
          pageType: const OriolePlatformPageType(),
          builder: () => const CommonPage(
            title: 'Platform',
            content: 'Platform page',
          ),
        ),
        ChildRoute(
          path: '/material',
          pageType: const OrioleMaterialPageType(),
          builder: () => const CommonPage(
            title: 'Material',
            content: 'Material page',
          ),
        ),
        ChildRoute(
          path: '/cupertino',
          pageType: const OrioleCupertinoPageType(),
          builder: () => const CommonPage(
            title: 'Cupertino',
            content: 'Cupertino page',
          ),
        ),
        ChildRoute(
          path: '/slide',
          pageType: const OrioleSlidePageType(),
          builder: () => const CommonPage(
            title: 'Slide',
            content: 'Slide page',
          ),
        ),
        ChildRoute(
          path: '/fade',
          pageType: const OrioleFadePageType(),
          builder: () => const CommonPage(
            title: 'Fade',
            content: 'Fade page',
          ),
        ),
        ChildRoute(
          path: '/custom',
          pageType: const OrioleCustomPageType(),
          builder: () => const CommonPage(
            title: 'Custom',
            content: 'Custom page',
          ),
        ),
        ChildRoute(
          path: '/bottomSheet',
          pageType: const ModalBottomSheetPageType(isScrollControlled: false),
          builder: () => const BottomSheetPage(),
        )
      ],
    );
    manager.child(
      path: '/middleware',
      middlewares: [
        AuthGuard(),
        OrioleMiddlewareBuilder(
          canPopFunc: () async {
            final res = await Oriole.to.push(
              '/dialog',
              waitForResult: true,
              params: {"title": "Warning", "content": "Can pop middleware"},
            );
            return true == res;
          },
          onExitFunc: () async {
            debugPrint("Middleware -> onExit");
          },
          onExitedFunc: () async {
            debugPrint("Middleware -> onExited");
          },
          onEnterFunc: () async {
            debugPrint("Middleware -> onEnter");
          },
        )
      ],
      builder: () => const CommonPage(
        title: 'Middleware',
        content: 'Middleware page',
      ),
    );
  }
}
