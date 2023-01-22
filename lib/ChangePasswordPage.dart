import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '/Custom-UI/Custom-RoundedInputField.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '/Functions/Messager.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';
import '/Screen-Size/ui-utils.dart';
import '/enums/device-screen-type.dart';

class ChangePassword extends StatefulWidget {
  static const routeName = '/ChangePassword';
  @override
  State<StatefulWidget> createState() {
    return _ChangePasswordState();
  }
}

class _ChangePasswordState extends State<ChangePassword> {
  bool _loading = false;
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  String confirmPasswordErrorString = "Field Cannot be empty";
  String newPasswordErrorString = 'Field Cannot be empty';

  bool _newPasswordError = false;
  bool _confirmPasswordError = false;

  User firebaseUser = FirebaseAuth.instance.currentUser as User;

  @override
  void initState() {
    /// Get User Data
    print(firebaseUser.displayName);
    if (this.mounted) {
      _loading = false;
      setState(() {});
    }

    super.initState();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // region UI
  /// Show passcode UI
  Widget showUpdatePasswordUI(
    BuildContext context,
  ) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    var mediaQuery = MediaQuery.of(context);

    return SizedBox(
      width: _widgetSize.getResponsiveWidth(0.9, 0.9, 0.9),
      height: _widgetSize.getResponsiveHeight(0.60, 0.60, 0.60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Old Password
          SizedBox(
            height: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                ? _widgetSize.getResponsiveHeight(0.05, 0.05, 0.05)
                : _widgetSize.getResponsiveHeight(0.08, 0.08, 0.08),
          ),

          /// New Password
          customRoundedBorder(
            _newPasswordController,
            "New Password",
            _newPasswordError,
            newPasswordErrorString,
            true,
            _deviceDetails,
            _widgetSize,
            'New Password',
            null,
          ),

          SizedBox(height: _widgetSize.getResponsiveHeight(0.05, 0.05, 0.05)),

          /// Confirm Password
          customRoundedBorder(
            _confirmPasswordController,
            "Confirm Password",
            _confirmPasswordError,
            confirmPasswordErrorString,
            true,
            _deviceDetails,
            _widgetSize,
            'Confirm Password',
            null,
          ),

          /// Spacing
          SizedBox(
            height: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                ? _widgetSize.getResponsiveHeight(0.03, 0.03, 0.03)
                : _widgetSize.getResponsiveHeight(0.05, 0.05, 0.05),
          ),

          Text(
            "* Your password must have at least 6 characters",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
              fontSize: _deviceDetails.getNormalFontSize() - 2,
            ),
          ),

          /// Spacing
          SizedBox(
            height: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                ? _widgetSize.getResponsiveHeight(0.03, 0.03, 0.03)
                : _widgetSize.getResponsiveHeight(0.05, 0.05, 0.05),
          ),

          /// Submit Button
          Center(
            child: SizedBox(
              width: _widgetSize.getResponsiveWidth(0.4, 0.4, 0.4),
              height: _widgetSize.getResponsiveHeight(0.07, 0.07, 0.07),
              child: TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).highlightColor),
                  elevation: MaterialStateProperty.all(5),
                  shadowColor: MaterialStateProperty.all(Colors.grey),
                ),
                onPressed: () {
                  setState(() {
                    if (validate() == true) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Theme.of(context).highlightColor,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Confirmation",
                                  style: TextStyle(
                                    color: Theme.of(context).backgroundColor,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Icon(
                                    Icons.clear,
                                    color: Theme.of(context).backgroundColor,
                                    size: _widgetSize.getResponsiveHeight(
                                        0.05, 0.05, 0.05),
                                  ),
                                )
                              ],
                            ),
                            content: SizedBox(
                              height: _widgetSize.getResponsiveHeight(
                                  0.3, 0.3, 0.3),
                              child: Column(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Please enter your new password again to proceed",
                                    style: TextStyle(
                                      color: Theme.of(context).backgroundColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                    height: _widgetSize.getResponsiveHeight(
                                        0.05, 0.05, 0.05),
                                  ),
                                  Center(
                                    child: TextField(
                                      onChanged: (text) {
                                        if (text ==
                                            _confirmPasswordController.text) {
                                          Navigator.of(context).pop();
                                          updatePassword(_deviceDetails);
                                        }
                                      },
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).backgroundColor,
                                        fontSize:
                                            _deviceDetails.getNormalFontSize(),
                                        fontWeight: FontWeight.w600,
                                      ),
                                      cursorColor:
                                          Theme.of(context).backgroundColor,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      decoration: InputDecoration(
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .backgroundColor),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .backgroundColor),
                                        ),
                                        hintText: "Please enter password",
                                        hintStyle: TextStyle(
                                            color: Theme.of(context)
                                                .backgroundColor),
                                      ),
                                      obscureText: true,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  });
                },
                child: Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _deviceDetails.getNormalFontSize(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  // endregion

  // region Function
  /// Validate the form
  bool validate() {
    bool temp = false;
    if (_newPasswordController.text.isEmpty) {
      _newPasswordError = true;
      newPasswordErrorString = "Field cannot be empty";
    } else if (_newPasswordController.text.length < 6) {
      _newPasswordError = true;
      newPasswordErrorString =
          "Your password must be at least have 6 characters";
    } else if (_confirmPasswordController.text.isEmpty) {
      _confirmPasswordError = true;
      confirmPasswordErrorString = "Field cannot be empty";
    } else if (_newPasswordController.text != _confirmPasswordController.text) {
//        _confirmPasswordController.clear();
      _confirmPasswordError = true;
      confirmPasswordErrorString = "Password doesn't match !";
    } else {
      _newPasswordError = false;
      _confirmPasswordError = false;
      temp = true;
    }
    return temp;
  }

  Future<void> updatePassword(DeviceDetails _deviceDetails) async {
    if (this.mounted) {
      _loading = true;
      setState(() {});
    }

    try {
      await firebaseUser
          .updatePassword(_newPasswordController.text)
          .then((value) {
        if (this.mounted) {
          _loading = false;
          setState(() {});
        }
        showMessage(
          '',
          "Password Updated",
          _deviceDetails,
          context,
        );
      });
    } on PlatformException catch (error) {
      if (this.mounted) {
        _loading = false;
        setState(() {});
      }
      showMessage(
        '',
        'Please login again to change password',
        _deviceDetails,
        context,
      );
    }
  }

// endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    var paddingLeftRight = _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      // resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_sharp,
            color: Theme.of(context).primaryColor,
            size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          ),
        ),
        title: Text(
          "Change Password",
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        shadowColor: Colors.grey,
        elevation: 3,
      ),
      body: ModalProgressHUD(
        opacity: 0.50,
        color: Theme.of(context).primaryColor,
        inAsyncCall: _loading,
        progressIndicator: SpinKitWave(
          color: Colors.white,
          duration: Duration(milliseconds: 350),
        ),
        child: SafeArea(
          minimum: EdgeInsets.fromLTRB(
            paddingLeftRight,
            0,
            paddingLeftRight,
            0,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
              maxWidth: MediaQuery.of(context).size.width,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: getPageContent(context, _deviceDetails, _widgetSize),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  List<Widget> getPageContent(
    BuildContext context,
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    List<Widget> pageContent = [];

    pageContent.add(showUpdatePasswordUI(context));

    return pageContent;
  }
}
