import 'package:flutter/material.dart';
import '/Login-Register-Page/LoginPage.dart';
import '/Screen-Size/Get-Device-Details.dart';

/// Show Custom message
void showMessage(
  String title,
  String? subtitle,
  DeviceDetails _deviceDetails,
  BuildContext context,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 10,
        scrollable: true,
        title: title != ''
            ? Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: _deviceDetails.getNormalFontSize(),
                ),
              )
            : null,
        content: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: _deviceDetails.getNormalFontSize(),
                ),
              )
            : null,
        actions: [
          TextButton(
            child: Text(
              "Ok",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: _deviceDetails.getNormalFontSize(),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}

/// Show Login message
void showLoginMessage(
  int returnIndexNo,
  double fontSize,
  BuildContext context,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 10,
        scrollable: true,
        title: Text(
          'Please login or register an account',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: fontSize,
          ),
        ),
        actions: [
          /// Ok
          TextButton(
            child: Text(
              "Ok",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
          ),

          /// Cancel
          TextButton(
            child: Text(
              "Cancel",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
              ),
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      );
    },
  ).then((result) async {
    if (result == null)
      return null;
    else {
      if (result == true) {
        bool? successful = await Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (BuildContext context) {
              return LoginScreen(
                returnIndex: returnIndexNo,
                singlePage: false,
              );
            },
          ),
        );

        if (successful != null) {
          return successful;
        }
      } else {
        print("Cancelled");
      }
    }
  });
}

/// Show Snackbar below
void showSnackBar(String textData, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(textData),
      duration: const Duration(seconds: 1),
    ),
  );
}

/// Show Not Available Yet message
void showTempMessage(
  DeviceDetails _deviceDetails,
  BuildContext context,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 10,
        scrollable: true,
        title: Text(
          'Not Available Yet!',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: _deviceDetails.getNormalFontSize(),
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              "Ok",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: _deviceDetails.getNormalFontSize(),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}
