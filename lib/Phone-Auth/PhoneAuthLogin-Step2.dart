import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timoti_project/Core/auth.dart';
import 'package:timoti_project/Data-Class/PhoneAuthStepTwoArgument.dart';
import 'package:timoti_project/Introduction-Page/Introduction-Page.dart';
import 'package:timoti_project/Functions/Messager.dart';
import 'package:timoti_project/Nav.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';
import 'package:timoti_project/enums/Sign-In-Type.dart';
import 'package:timoti_project/enums/User-Sign-In-Method.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class PhoneAuthLoginStepTwoScreen extends StatefulWidget {
  static const routeName = "/PhoneAuthLoginStep2";

  @override
  _PhoneAuthLoginStepTwoScreenState createState() =>
      _PhoneAuthLoginStepTwoScreenState();
}

class _PhoneAuthLoginStepTwoScreenState
    extends State<PhoneAuthLoginStepTwoScreen> {
  String countryNo = '';


  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();
  String _verificationId = '1';
  String status = '';

  bool phoneNoError = false;
  bool otpError = false;
  String cacheSignInMethod = "CacheSignInMethod";

  Future<void> createCacheData(
    String fileName,
    String data,
  ) async {
    /// Cache Directory
    var cacheDir = await getTemporaryDirectory();

    /// If Cache data NOT exist
    if (await File(cacheDir.path + "/" + fileName).exists() == false) {
      print("Creating cache data (" + fileName + ")" + ": " + data);

      // CacheUser cacheUser = File(cacheDir.path + "/" + fileName);

      File file = new File(cacheDir.path + "/" + fileName);
      file.writeAsString(data, flush: true, mode: FileMode.write);
    }

    /// Overwrite existing cache data
    else {
      print("AGAIN Creating cache data (" + fileName + ")" + ": " + data);
      File file = new File(cacheDir.path + "/" + fileName);
      file.writeAsString(data, flush: true, mode: FileMode.write);
    }
  }

  Future<void> deleteCacheData(
    String fileName,
  ) async {
    if (!mounted) {
      return;
    }

    /// Cache Directory
    var cacheDir = await getTemporaryDirectory();

    /// If Cache data exist
    if (await File(cacheDir.path + "/" + fileName).exists()) {
      print("Deleting cache data " + fileName);

      // CacheUser cacheUser = File(cacheDir.path + "/" + fileName);
      cacheDir.delete(recursive: true);
      print("Deleted cache data");
    }

    /// Else Not exist
    else {
      print("No Cache data");
    }
  }

  Future<void> loginPath() async {
    /// Cache Directory
    var cacheDir = await getTemporaryDirectory();

    /// If Cache data exist
    if (await File(cacheDir.path + "/" + cacheSignInMethod).exists()) {
      print("Cache File Exist: " + cacheSignInMethod);
      Navigator.pop(context);
      Navigator.pushReplacementNamed (
        context,
        Nav.routeName,
        // arguments: navBarGlobalKey,
      );
    }

    /// Else Not exist
    else {
      print("No Cache data");
      Navigator.pop(context);
      Navigator.pushReplacementNamed (
        context,
        IntroductionPage.routeName,
        // arguments: navBarGlobalKey,
      );
    }
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

  void verifyPhoneNumber(String phoneNo) async {
    // void _verifyPhoneNumber() async {
    if (mounted)
      setState(() {
        status = '';
      });
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      // _firebaseUser.updatePhoneNumberCredential(phoneAuthCredential);
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
      _verificationId = verificationId;
      setState(() {});
      // Navigator.of(context).pushReplacement(new MaterialPageRoute(
      //     builder: (BuildContext context) =>
      //     new VerifyOtp(_firebaseUser, verificationId)));
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
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
      String _verificationId, DeviceDetails _deviceDetails) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _smsController.text,
      );

      final User user =
          (await firebaseAuth.signInWithCredential(credential)).user as User;
      // firebaseUser.linkWithCredential(credential).then((user) {
      //   print(user.uid);
      // }).catchError((error) {
      //   print(error.toString());
      // });
      setState(() {
        status = "Successfully signed in UID: ${user.uid}";
        showSnackbar("Successfully signed in ");
      });
      authService.updateUserData(user);
      // SignInMethod signInMethod = Provider.of(context, listen: false);
      // signInMethod.updateSignInMethod(SignInType.Email);

      /// Save Cache Data
      // createCacheData("CacheUsername", _emailController.text);
      // createCacheData("CachePassword", _passwordController.text);
      // createCacheData(cacheSignInMethod, SignInType.Email.toString());

      loginPath();
      // showSnackbar("Successfully signed in UID: ${user.uid}");
    } on PlatformException catch (error) {
      showMessage('', error.message, _deviceDetails,  context,);
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);
    final data = ModalRoute.of(context)?.settings.arguments;

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
        title: Text(
          "Phone Authentication",
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
     backgroundColor: Theme.of(context).backgroundColor,
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
                  children: getPageContent(
                    _deviceDetails,
                    _widgetSize,
                    data as PhoneAuthStepTwoArg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> getPageContent(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    PhoneAuthStepTwoArg data,
  ) {
    List<Widget> pageContent = [];

    pageContent.add(SizedBox(
      height: _widgetSize.getResponsiveHeight(0.05, 0.05, 0.05),
    ));

    /// Icon
    pageContent.add(Icon(
      Icons.phone_android_rounded,
      color: Theme.of(context).primaryColor,
      size: _widgetSize.getResponsiveWidth(0.25, 0.25, 0.25),
    ));

    pageContent.add(
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
    );

    /// Text
    pageContent.add(
      Padding(
        padding: EdgeInsets.fromLTRB(
            _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
            _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
            0),
        child: Text(
          "You will get OTP via SMS (${data.phoneNumber})",
          style: TextStyle(
            fontSize: _deviceDetails.getNormalFontSize(),
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );

    /// Spacing
    pageContent.add(SizedBox(
      height: _widgetSize.getResponsiveHeight(0.08, 0.08, 0.08),
    ));

    /// Verification code
    pageContent.add(
      Padding(
        padding: EdgeInsets.fromLTRB(
          _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
          0,
        ),
        child: customBorder(
          _smsController,
          "Please Enter OTP",
          otpError,
          "Please Enter OTP",
          false,
          _deviceDetails,
        ),
      ),
    );

    /// Verify
    pageContent.add(
      Padding(
        padding: EdgeInsets.fromLTRB(
          0,
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          0,
          0,
        ),
        child: InkWell(
          onTap: () async {
            FocusScope.of(context).unfocus();
            // print('working');
            if (validate() == true) {
              _signInWithPhoneNumber(data.verificationId, _deviceDetails);
            }

            print("Old VID: " + data.verificationId);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).highlightColor,
            ),
            width: _widgetSize.getResponsiveWidth(0.8, 0.8, 0.8),
            height: _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
            alignment: Alignment.center,
            child: Text(
              "Login",
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize(),
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );

    /// Resend Code
    pageContent.add(
      Padding(
        padding: EdgeInsets.fromLTRB(
            _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
            _widgetSize.getResponsiveWidth(0.08, 0.08, 0.08),
            _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
            0),
        child: InkWell(
          onTap: () {
            FocusScope.of(context).unfocus();
            if (validate() == true) {
              verifyPhoneNumber(data.phoneNumber);
              data.verificationId = _verificationId;
              print("New VID: " + data.verificationId);
            }
          },
          child: FittedBox(
            child: Row(
              children: [
                Text(
                  "Didn't receive the verification OTP? ",
                  style: TextStyle(
                    fontSize: _deviceDetails.getNormalFontSize(),
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                Container(
                  // decoration: BoxDecoration(
                  //     border: Border.all(color: Theme.of(context).primaryColor)),
                  alignment: Alignment.center,
                  child: Text(
                    "Resend Again",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: _deviceDetails.getNormalFontSize(),
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
    );

    return pageContent;
  }
}
