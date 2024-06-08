import 'package:flutter/material.dart';
import 'package:sport_mates/pages/general_purpuse/splash_screen.dart';
import 'package:sport_mates/config/theme.dart';

class Root extends StatelessWidget {
  const Root({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sport Mates',
      theme: createLightTheme(),
      darkTheme: createDarkTheme(),
      home: SplashScreen(),
    );
  }
}
