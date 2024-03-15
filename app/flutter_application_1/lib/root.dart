import 'package:flutter/material.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/login_signup.dart';
import 'package:flutter_application_1/new_activity.dart';
import 'package:flutter_application_1/settings.dart';
import 'package:flutter_application_1/splash_screen.dart';
import 'package:flutter_application_1/theme.dart';

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
