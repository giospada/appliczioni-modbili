import 'package:flutter/material.dart';
import 'package:flutter_application_1/Search.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/auth_provider.dart';
import 'package:flutter_application_1/login_signup.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider()..tryAutoLogin(),
      child: MaterialApp(
        home: Consumer<AuthProvider>(
          builder: (ctx, auth, _) => auth.loading
              ? const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : auth.isAuthenticated
                  ? SearchPage()
                  : LoginSignupScreen(),
        ),
      ),
    );
  }
}
