import 'package:flutter/material.dart';
import 'package:timoti_project/Url-Navigation/Routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    MyFluroRouterClass.setupRouter(); // 1. Set Up Router
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/', // 2. Define initial route
      onGenerateRoute: MyFluroRouterClass.router.generator, // 3. Call Flurorouter generator
    );
  }
}