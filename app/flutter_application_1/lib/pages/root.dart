import 'package:flutter/material.dart';
import 'package:SportMates/pages/home.dart';
import 'package:SportMates/pages/login/login_signup.dart';
import 'package:SportMates/pages/new_activity/new_activity.dart';
import 'package:SportMates/pages/settings/settings.dart';
import 'package:SportMates/pages/general_purpuse/splash_screen.dart';
import 'package:SportMates/config/theme.dart';

class Root extends StatelessWidget {
  const Root({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: createLightTheme(),
        darkTheme: createDarkTheme(),
        home: SplashScreen(),
        routes: {
          '/login': (context) => LoginSignupScreen(),
          '/home': (context) => Home(),
          '/settings': (context) => SettingsPage(),
          '/create': (context) => CreateActivityWidget(),
        });
  }
}
