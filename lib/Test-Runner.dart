import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TestRunner extends StatelessWidget {
  final Widget targetWidget;
  const TestRunner({Key? key, required this.targetWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.lexendDecaTextTheme(
          Theme.of(context).textTheme,
        ),

        /// Box Color
        shadowColor: Color(0XFFFFFFFF),
        dividerColor: Colors.grey,
        // accentColor: Color(0xFF6BD82F),

        /// Other Primary Text Color
        primaryColor: Colors.black,

        /// Login page text color
        primaryColorLight: Colors.white,

        /// Yellow
        highlightColor: Color(0xFFE1AE31),

        /// Home App Bar Color
        cardColor: Colors.white,

        /// Home Background Color
        backgroundColor: Color(0xFFF0F0F0),

        /// Login Background Color
        focusColor: Color(0xFF161616),
      ),
      home: targetWidget,
    );
  }
}
