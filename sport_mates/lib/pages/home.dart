import 'package:flutter/material.dart';
import 'package:sport_mates/provider/data_provider.dart';
import 'package:sport_mates/config/theme.dart';
import 'package:sport_mates/pages/search/Search.dart';
import 'package:provider/provider.dart';
import 'package:sport_mates/provider/auth_provider.dart';
import 'package:sport_mates/pages/login/login_signup.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthProvider()..tryAutoLogin()),
        ChangeNotifierProvider(create: (ctx) => DataProvider())
      ],
      child: MaterialApp(
        theme: createLightTheme(),
        darkTheme: createDarkTheme(),
        home: Consumer<AuthProvider>(builder: (ctx, auth, _) {
          return auth.loading
              ? const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : auth.isAuthenticated
                  ? SearchPage()
                  : LoginSignupPage();
        }),
      ),
    );
  }
}
