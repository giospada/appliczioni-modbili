import 'package:flutter/material.dart';
import 'package:sport_mates/pages/home.dart';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class SpringCurve extends Curve {
  const SpringCurve({
    this.a = 0.15,
    this.w = 19.4,
  });
  final double a;
  final double w;

  @override
  double transformInternal(double t) {
    return -(pow(e, -t / a) * cos(t * w)) + 1;
  }
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..forward();
    _animation =
        CurvedAnimation(parent: _controller!, curve: const SpringCurve());

    _navigateToHome();
  }

  _navigateToHome() async {
    // Wait for the animation to finish
    await Future.delayed(const Duration(seconds: 2));
    // Navigate to the next page

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Home()),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ScaleTransition(
          scale: _animation!,
          child: Image.asset(
            'assets/images/logo.png',
            height: 100,
            width: 100,
          ), // Your logo here
        ),
      ),
    );
  }
}
