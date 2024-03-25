import 'package:flutter/material.dart';
import 'package:sport_mates/pages/search/Search.dart';
import 'package:provider/provider.dart';
import 'package:sport_mates/config/auth_provider.dart';
import 'package:sport_mates/pages/login/login_signup.dart';

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
                  : LoginSignupPage(),
        ),
      ),
    );
  }
}
