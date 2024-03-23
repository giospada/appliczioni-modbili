import 'package:flutter/material.dart';
import 'package:SportMates/pages/search/Search.dart';
import 'package:provider/provider.dart';
import 'package:SportMates/config/auth_provider.dart';
import 'package:SportMates/pages/login/login_signup.dart';

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
