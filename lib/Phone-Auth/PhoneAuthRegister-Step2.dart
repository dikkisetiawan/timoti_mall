import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import '/Core/auth.dart';
import '/Custom-UI/Custom-LoadingUI.dart';
import '/Functions/CustomPopNavigator.dart';
import '/Introduction-Page/Introduction-Page.dart';
import '/Functions/Messager.dart';
import '/Phone-Auth/PhoneAuthRegister-Step1.dart';
import '/Screen-Size/Get-Device-Details.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';
import '/enums/Sign-In-Type.dart';
import '/enums/User-Sign-In-Method.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class PhoneAuthRegisterStepTwoScreen extends StatelessWidget {
  static const routeName = "/PhoneAuthRegisterStep2";
  final String phoneNumber;
  final String verificationId;
  final bool singlePage;

  PhoneAuthRegisterStepTwoScreen({
    required this.phoneNumber,
    required this.verificationId,
    required this.singlePage,
  });

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
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
        automaticallyImplyLeading: false,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Theme.of(context).highlightColor,
                        elevation: 10,
                        scrollable: true,
                        title: Text(
                          'Notice',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: _deviceDetails.getNormalFontSize(),
                          ),
                        ),
                        content: Text(
                          'This process is to link your account with your phone number, some function may not be able to use\n\n*You can link your phone number to your account later: \nAccount -> Settings -> Link Phone Number',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: _deviceDetails.getNormalFontSize(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: _deviceDetails.getNormalFontSize(),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: Text(
                              "Confirm",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: _deviceDetails.getNormalFontSize(),
                              ),
                            ),
                            onPressed: () {
                              /// Guest After Upgrade
                              if (singlePage == false) {
                                PopPageUntil(3, context);
                              }

                              /// Non Guest
                              else {
                                /// Close Message and Return to step 1
                                PopPageUntil(2, context);

                                /// Go to Introduction Page
                                Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.bottomToTop,
                                    child: IntroductionPage(),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  "Skip",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    // letterSpacing: 1,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: _deviceDetails.getNormalFontSize() + 2,
                  ),
                ),
              ),
            ),
          ),
        ],
        title: Text(
          "Phone Registration",
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        // flexibleSpace: Container(
        //   decoration: BoxDecoration(
        //       gradient: LinearGradient(
        //           begin: Alignment.topLeft,
        //           end: Alignment.bottomRight,
        //           colors: <Color>[
        //         Colors.green,
        //         Colors.green,
        //         Theme.of(context).accentColor,
        //         Colors.green,
        //       ])),
        // ),
        shadowColor: Colors.grey,
        elevation: 3,
      ),
      body: SafeArea(
        child: Container(
          width: _widgetSize.getResponsiveWidth(1, 1, 1),
          height: _widgetSize.getResponsiveHeight(1, 1, 1),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Container(
                color: Theme.of(context).backgroundColor,

                // decoration: BoxDecoration(
                //   image: DecorationImage(
                //     image: AssetImage("assets/icon/homebg.jpg"),
                //     fit: BoxFit.cover,
                //   ),
                // ),
              ),
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                        height:
                            _widgetSize.getResponsiveHeight(0.05, 0.05, 0.05)),

                    /// Icon
                    Icon(
                      Icons.phone_android_rounded,
                      color: Theme.of(context).primaryColor,
                      size: _widgetSize.getResponsiveWidth(0.25, 0.25, 0.25),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                          _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                          0),
                      child: Text(
                        "Verification",
                        style: TextStyle(
                          fontSize: _deviceDetails.getTitleFontSize() + 5,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    /// Text

                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                          _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                          0),
                      child: Text(
                        "You will get OTP via SMS ($phoneNumber)",
                        style: TextStyle(
                          fontSize: _deviceDetails.getNormalFontSize(),
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    /// Spacing
                    SizedBox(
                        height:
                            _widgetSize.getResponsiveHeight(0.08, 0.08, 0.08)),

                    /// Verification
                    PhoneVerificationUI(
                      widgetSize: _widgetSize,
                      deviceDetails: _deviceDetails,
                      singlePage: singlePage,
                      phoneNumber: phoneNumber,
                      verificationId: verificationId,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PhoneVerificationUI extends StatefulWidget {
  final WidgetSizeCalculation widgetSize;
  final DeviceDetails deviceDetails;
  final String phoneNumber;
  final String verificationId;
  final bool singlePage;

  PhoneVerificationUI({
    required this.widgetSize,
    required this.deviceDetails,
    required this.phoneNumber,
    required this.verificationId,
    required this.singlePage,
  });

  @override
  _PhoneVerificationUIState createState() => _PhoneVerificationUIState();
}

class _PhoneVerificationUIState extends State<PhoneVerificationUI> {
  String cacheSignInMethod = "CacheSignInMethod";
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final TextEditingController _smsController = TextEditingController();

  String _verificationId = '1';
  String status = '';

  bool phoneNoError = false;
  bool otpError = false;
  String newVerificationId = '';

  bool _loading = false;

  @override
  void initState() {
    _loading = false;
    newVerificationId = widget.verificationId;
    super.initState();
  }

  Widget customBorder(
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
        color: Theme.of(context).primaryColor,
      ),
      cursorColor: Theme.of(context).primaryColor,
      // maxLength: 18,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(18),
      ],
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        labelText: verification ? null : hintText,
        labelStyle: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: _deviceDetails.getNormalFontSize(),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: new BorderSide(color: Colors.red),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: new BorderSide(color: Theme.of(context).primaryColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: new BorderSide(color: Theme.of(context).primaryColor),
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

  // region Function
  bool validate() {
    bool temp = false;
    if (_smsController.text.isEmpty) {
      otpError = true;
    } else {
      otpError = false;
      temp = true;
    }
    return temp;
  }

  void verifyPhoneNumberAgain(String phoneNo) async {
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      if (mounted)
        setState(() {
          status = 'Received phone auth credential: $phoneAuthCredential';
        });
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      if (mounted)
        setState(() {
          status =
              'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}';
        });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int? forceResendingToken]) async {
      print('Please check your phone for the verification code.');
      newVerificationId = verificationId;
      setState(() {});
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      newVerificationId = verificationId;
      setState(() {});
    };

    await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNo,
        timeout: const Duration(minutes: 1),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void _signInWithPhoneNumber(
    String _verificationId,
    String phoneNo,
    DeviceDetails _deviceDetails,
  ) async {
    if (this.mounted) {
      _loading = true;
      setState(() {});
    }
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _smsController.text,
      );
      User firebaseUser = firebaseAuth.currentUser as User;
      firebaseUser.linkWithCredential(credential).then((user) {
        if (this.mounted) {
          _loading = false;
          setState(() {});
        }
        // print(user.user.uid);
        setState(() {
          status = "Successfully Linked in UID: ${user.user?.uid}";
          showSnackBar("Successfully Linked Account");
        });

        authService.updateUserData(firebaseUser);
        authService.updatePhone(firebaseUser, phoneNo);

        /// Guest Upgrade Process
        if (widget.singlePage == false) {
          /// Link Phone Successful, Pop 2 times
          PopPageUntil(2, context);
        } else {
          /// Return to step 1
          Navigator.pop(context);

          /// Go to Introduction Page
          Navigator.pushReplacement(
            context,
            PageTransition(
              type: PageTransitionType.bottomToTop,
              child: IntroductionPage(),
            ),
          );
        }
      }).catchError((error) {
        if (this.mounted) {
          _loading = false;
          setState(() {});
        }
        showMessage(
          '',
          error.message,
          _deviceDetails,
          context,
        );
      });

      // showSnackbar("Successfully signed in UID: ${user.uid}");
    } on PlatformException catch (error) {
      if (this.mounted) {
        _loading = false;
        setState(() {});
      }
      showMessage(
        '',
        error.message,
        _deviceDetails,
        context,
      );
    }
  }

  /// Show Snackbar below
  void showSnackBar(String textData) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(textData),
      duration: const Duration(seconds: 1),
    ));
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Verification code
        Padding(
          padding: EdgeInsets.fromLTRB(
            widget.widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
            widget.widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
            widget.widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
            0,
          ),
          child: customBorder(
            _smsController,
            "Please Enter OTP",
            otpError,
            "Please Enter OTP",
            false,
            widget.deviceDetails,
          ),
        ),

        /// Verify
        Padding(
          padding: EdgeInsets.fromLTRB(
            0,
            widget.widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
            0,
            0,
          ),
          child: InkWell(
            onTap: _loading == true
                ? null
                : () async {
                    FocusScope.of(context).unfocus();
                    if (validate() == true) {
                      _signInWithPhoneNumber(
                        newVerificationId,
                        widget.phoneNumber,
                        widget.deviceDetails,
                      );
                    }

                    print("Old VID: " + newVerificationId);
                  },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).highlightColor,
              ),
              width: widget.widgetSize.getResponsiveWidth(0.8, 0.8, 0.8),
              height: widget.widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
              alignment: Alignment.center,
              child: _loading == true
                  ? CustomLoading()
                  : Text(
                      "VERIFY",
                      style: TextStyle(
                        fontSize: widget.deviceDetails.getNormalFontSize(),
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),

        /// Resend Code
        Padding(
          padding: EdgeInsets.fromLTRB(
              widget.widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
              widget.widgetSize.getResponsiveWidth(0.08, 0.08, 0.08),
              widget.widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
              0),
          child: InkWell(
            onTap: _loading == true
                ? null
                : () {
                    FocusScope.of(context).unfocus();
                    if (validate() == true) {
                      verifyPhoneNumberAgain(widget.phoneNumber);
                      print("New VID: " + newVerificationId);
                    }
                  },
            child: FittedBox(
              child: Row(
                children: [
                  Text(
                    "Didn't receive the verification OTP? ",
                    style: TextStyle(
                      fontSize: widget.deviceDetails.getNormalFontSize(),
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: _loading == true
                        ? CustomLoading()
                        : Text(
                            "Resend Again",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize:
                                  widget.deviceDetails.getNormalFontSize(),
                              color: Theme.of(context).highlightColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
