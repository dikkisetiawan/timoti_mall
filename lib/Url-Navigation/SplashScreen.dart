import 'package:flutter/material.dart';
import '/Url-Navigation/Routes.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 1000), () {
      Navigator.pushNamed(context, MyFluroRouterClass.baseURL + '/home');
    });
    return Scaffold(
      body: Container(
        child: Text(
          'Splash Screen...',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
        ),
      ),
    );
  }
}
