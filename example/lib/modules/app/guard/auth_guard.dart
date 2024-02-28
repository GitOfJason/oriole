import 'package:example/modules/app/services/auth_service.dart';
import 'package:oriole/oriole.dart';

class AuthGuard extends OrioleMiddleware {
  @override
  Future<String?> redirectGuard(String path) async {
    final user = Oriole.get<AuthService>();
    if (user.isLogin == false) {
      Oriole.to.params.addAsHidden("redirect", path);
      return '/login';
    }
    return null;
  }
}
