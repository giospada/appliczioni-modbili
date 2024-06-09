import 'package:flutter/material.dart';
import 'package:sport_mates/config/config.dart';
import 'package:sport_mates/provider/data_provider.dart';
import 'package:sport_mates/config/theme.dart';
import 'package:sport_mates/pages/search/Search.dart';
import 'package:provider/provider.dart';
import 'package:sport_mates/provider/auth_provider.dart';
import 'package:sport_mates/pages/login/login_signup.dart';
import 'package:uni_links/uni_links.dart';

class Home extends StatelessWidget {
  Future<void> setToActivity() async {
    try {
      Uri? initialUri = await getInitialUri();
      if (initialUri != null && initialUri.queryParameters.containsKey("id")) {
        int? id = int.tryParse(initialUri.queryParameters["id"]!);
        if (id != null) Config().goToActivity = id;
      }
    } on Exception {}
  }

  @override
  Widget build(BuildContext context) {
    setToActivity();
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
