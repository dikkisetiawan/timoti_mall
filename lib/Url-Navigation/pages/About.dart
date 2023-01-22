import 'package:flutter/material.dart';

class About extends StatefulWidget {
  static final String routeName = '/About-Page';

  final String urlParam;
  const About(this.urlParam);

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  // Use for routeNamed pass parameter
  AboutDetailsArgument? aboutDetailsArgument;

  @override
  Widget build(BuildContext context) {
    aboutDetailsArgument =
    ModalRoute.of(context)?.settings.arguments as AboutDetailsArgument?;

    return Scaffold(
      body: Container(
        color: Colors.green,
        child: Center(
          child: Text(
            'About Page ... :D and here is the URL Parameter passed.... ${widget.urlParam}'
                '\nThe Details is ${aboutDetailsArgument?.details ?? 'No Details'}'
                '\nThe ID is ${aboutDetailsArgument?.id ?? 'No ID'}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
          ),
        ),
      ),
    );
  }
}

class AboutDetailsArgument {
  final String details;
  final String id;

  AboutDetailsArgument({
    required this.details,
    required this.id,
  });
}
