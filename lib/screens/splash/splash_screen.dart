import 'package:flutter/material.dart';

import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = "/splash";
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    gotoHome();
  }

  gotoHome() {
    Future.delayed(Duration.zero, () {
      Navigator.pushNamedAndRemoveUntil(
          context, HomeScreen.routeName, (Route route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: 120,
          height: 120,
        ),
      ),
    );
  }
}
