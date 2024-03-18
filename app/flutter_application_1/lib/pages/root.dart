import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/home.dart';
import 'package:flutter_application_1/pages/login_signup.dart';
import 'package:flutter_application_1/pages/new_activity.dart';
import 'package:flutter_application_1/pages/settings.dart';
import 'package:flutter_application_1/pages/splash_screen.dart';
import 'package:flutter_application_1/config/theme.dart';

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
