import 'package:flutter/material.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';

/// Underline
Widget customUnderlineBorder(
  TextEditingController controller,
  String hintText,
  bool verification,
  String errorText,
  bool hiddenInput,
  DeviceDetails _deviceDetails,
) {
  return TextField(
    controller: controller,
    style: TextStyle(
        fontSize: _deviceDetails.getNormalFontSize(),
        height: 2.0,
        color: Colors.white),
    cursorColor: Colors.white,
    textAlignVertical: TextAlignVertical.center,
    decoration: InputDecoration(
      labelText: verification ? null : hintText,
      labelStyle: TextStyle(
        color: Colors.white,
        fontSize: _deviceDetails.getNormalFontSize(),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: new BorderSide(color: Colors.white),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: new BorderSide(color: Colors.white),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: new BorderSide(color: Colors.white),
      ),
      errorText: verification ? errorText : null,
      errorStyle: TextStyle(
          color: Colors.red,
          fontSize: _deviceDetails.getNormalFontSize(),
          fontWeight: FontWeight.w800),
    ),
    obscureText: hiddenInput,
  );
}

/// Rounded
Widget customRoundedBorder(
  TextEditingController controller,
  String hintText,
  bool verification,
  String? errorText,
  bool hiddenInput,
  DeviceDetails _deviceDetails,
  WidgetSizeCalculation _widgetSize,
  String? labelString,
  Color? textColor,
) {
  return TextField(
    controller: controller,
    cursorColor: textColor == null ? Colors.black : textColor,
    textAlignVertical: TextAlignVertical.center,
    style: TextStyle(
      color: textColor == null ? Colors.black : textColor,
    ),
    decoration: InputDecoration(
      label: labelString != null
          ? Padding(
              padding: EdgeInsets.only(
                  bottom: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),
              child: Text(
                labelString,
                style: TextStyle(
                  color: textColor == null ? Colors.black : textColor,
                ),
              ),
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: new BorderSide(
          width: 0,
          color: Colors.red,
        ),
      ),
      contentPadding: EdgeInsets.only(
        left: _widgetSize.getResponsiveWidth(
          0.05,
          0.05,
          0.05,
        ),
      ),
      // filled: true,
      // fillColor: Color(0xFF161616),
      hintText: hintText,
      hintStyle: TextStyle(
        color: textColor == null ? Colors.black : textColor,
        fontSize: _deviceDetails.getNormalFontSize(),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: new BorderSide(
          width: 1,
          color: Colors.red,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          width: textColor == null ? 1.5 : 0.5,
          style: BorderStyle.solid,
          color: Color(0xFFE1AE31),
        ),
        borderRadius: BorderRadius.circular(30.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          width: textColor == null ? 1.5 : 0.5,
          style: BorderStyle.solid,
          color: Color(0xFFE1AE31),
        ),
        borderRadius: BorderRadius.circular(30.0),
      ),
      errorText: verification ? errorText : null,
      errorStyle: TextStyle(
          color: Colors.red,
          fontSize: _deviceDetails.getNormalFontSize(),
          fontWeight: FontWeight.w800),
    ),
    obscureText: hiddenInput,
  );
}
