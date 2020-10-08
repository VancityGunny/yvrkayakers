import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  static String route = 'splash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.asset('graphics/logo.png')),
    );
  }
}
