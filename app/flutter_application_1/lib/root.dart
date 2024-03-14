import 'package:flutter/material.dart';
import 'package:flutter_application_1/login_signup.dart';
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
      home:  SplashScreen(),
    );
  }
}