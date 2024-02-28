import 'package:example/modules/app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:oriole/oriole.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: FilledButton(
              onPressed: () async {
                Oriole.get<AuthService>().login();
                final redirect = Oriole.to.params['redirect'];
                if (redirect != null) {
                  Oriole.to.params.addAsHidden('abc', false);
                  await Oriole.to.back();
                  Oriole.to.go(redirect.asString);
                }
              },
              child: const Text("Confirm"),
            ),
          )
        ],
      ),
    );
  }
}
