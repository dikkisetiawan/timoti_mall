import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  static final String routeName = '/Profile-Page';
  final String urlName;
  const Profile(this.urlName);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue[400],
      child: Center(
        child: Text(
          'Profile Page.....URL Parameter is ${urlName}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30.0,
          ),
        ),
      ),
    );
  }
}
