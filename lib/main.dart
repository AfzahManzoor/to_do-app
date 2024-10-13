import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:todo_rem/routes.dart';
import 'package:todo_rem/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        title: 'My Todos App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.purple),
        initialRoute: SplashScreen.routeName,
        routes: routes,
      ),
    );
  }
}
