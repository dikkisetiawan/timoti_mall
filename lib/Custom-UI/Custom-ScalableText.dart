import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomScalableText extends StatelessWidget {
  final int maxCharacters;
  final String textString;
  final TextStyle textStyle;
  final int maxLines;
  final bool enforceScale;

  const CustomScalableText({
    Key? key,
    required this.maxCharacters,
    required this.textString,
    required this.textStyle,
    required this.maxLines,
    required this.enforceScale,
  }) : super(key: key);

  Widget textUI() {
    if (kIsWeb == true) {
      return SelectableText(
        textString,
        maxLines: maxLines,
        style: textStyle,
      );
    } else {
      return Text(
        textString,
        overflow: TextOverflow.ellipsis,
        maxLines: maxLines,
        style: textStyle,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (enforceScale == true) {
      return FittedBox(fit: BoxFit.fitWidth, child: textUI());
    } else {
      /// if textLength > max Characters
      /// No need Scale
      return textString.length > maxCharacters
          ? textUI()
          : FittedBox(fit: BoxFit.fitWidth, child: textUI());
    }
  }
}
