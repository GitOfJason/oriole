import 'package:flutter/cupertino.dart';

abstract class AuthService with ChangeNotifier {
  bool get isLogin;

  void login();
}

class AuthServiceImpl extends AuthService  {
  bool _isLogin = false;

  @override
  bool get isLogin => _isLogin;

  @override
  void login() {
    _isLogin = !_isLogin;
    notifyListeners();
  }
}
