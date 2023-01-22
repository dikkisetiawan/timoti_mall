import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timoti_project/Custom-UI/Custom-LoadingUI.dart';
import 'package:timoti_project/Custom-UI/Custom-RoundedInputField.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';

class ForgetPasswordPage extends StatefulWidget {
  static const routeName = '/ForgetPassword-Page';
  @override
  State<StatefulWidget> createState() {
    return _ForgetPasswordPageState();
  }
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  TextEditingController _fEmailController = TextEditingController();
  String? emailErrorMessage;
  String emailMessage =
      "*We will send you a reset password email\nPlease also check your spam mail";

  bool emailError = true;
  Color? emailMessageColor;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _fEmailController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // region Function
  bool validateEmail() {
    bool temp = false;
    if (_fEmailController.text == '') {
      emailError = true;
      emailErrorMessage = "Please Enter Your Email";
    } else if (EmailValidator.validate(_fEmailController.text) == false) {
      emailError = true;
      _fEmailController.clear();
      emailErrorMessage = "Invalid Email Format";
    } else {
      emailError = false;
      temp = true;
    }
    return temp;
  }

  /// Forget Password
  void forgetPassword(String email) async {
    if (this.mounted) {
      _loading = true;
      setState(() {});
    }

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email)
          .then((value) {
        emailMessage = "We've send you a reset password email to $email";
        emailMessageColor = Colors.green;
        if (this.mounted) {
          _loading = false;
          setState(() {});
        }
      }).catchError((error) {
        emailMessage = error.message as String;
        emailMessageColor = Colors.red;
        if (this.mounted) {
          _loading = false;
          setState(() {});
        }
      });
    } on PlatformException catch (error) {
      emailMessage = error.message as String;
      emailMessageColor = Colors.red;
      if (this.mounted) {
        _loading = false;
        setState(() {});
      }
    }
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);
    double paddingTopBottom = _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        leading: InkWell(
          highlightColor: Colors.transparent,
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).primaryColor,
            size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          ),
        ),
        title: Text(
          "Forget Password",
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        shadowColor: Colors.grey,
        elevation: 3,
      ),
      body: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: Padding(
            padding: EdgeInsets.only(top: paddingTopBottom),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Field
                Center(
                  child: SizedBox(
                    width: _widgetSize.getResponsiveWidth(0.9, 0.9, 0.9),
                    child: customRoundedBorder(
                      _fEmailController,
                      'Please Type Your Email',
                      emailError,
                      emailErrorMessage,
                      false,
                      _deviceDetails,
                      _widgetSize,
                      null,
                      null,
                    ),
                  ),
                ),

                /// Message
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
                    _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                  ),
                  child: Text(
                    emailMessage,
                    style: TextStyle(
                      color: emailMessageColor,
                    ),
                  ),
                ),

                /// Submit Button
                Center(
                  child: SizedBox(
                    width: _widgetSize.getResponsiveWidth(0.5, 0.5, 0.5),
                    height: _widgetSize.getResponsiveHeight(0.07, 0.07, 0.07),
                    child: TextButton(
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).highlightColor),
                        elevation: MaterialStateProperty.all(5),
                        shadowColor: MaterialStateProperty.all(Colors.grey),
                      ),
                      onPressed: _loading == true
                          ? null
                          : () {
                              if (this.mounted) {
                                setState(() {
                                  if (validateEmail() == true) {
                                    forgetPassword(_fEmailController.text);
                                  }
                                });
                              }
                            },
                      child: _loading == true
                          ? CustomLoading()
                          : Text(
                              "Confirm".toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _deviceDetails.getNormalFontSize(),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
