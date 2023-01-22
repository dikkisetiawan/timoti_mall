import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/Core/auth.dart';
import '/Functions/Messager.dart';
import '/Phone-Auth/PhoneAuthRegister-Step1.dart';
import '/Screen-Size/Get-Device-Details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';

class ChangePhoneNumberStepTwo extends StatefulWidget {
  static const routeName = "/ChangePhoneNumberStepTwo";
  String phoneNumber;
  String verificationId;

  ChangePhoneNumberStepTwo({
    this.phoneNumber = '',
    this.verificationId = '',
  });
  @override
  _ChangePhoneNumberStepTwoState createState() =>
      _ChangePhoneNumberStepTwoState(
        phoneNumber,
        verificationId,
      );
}

class _ChangePhoneNumberStepTwoState extends State<ChangePhoneNumberStepTwo> {
  String phoneNumber = '';
  String verificationId = '';
  bool hasReturn = false;

  _ChangePhoneNumberStepTwoState(
    String phoneNumberValue,
    String verifyIDValue,
  ) {
    this.phoneNumber = phoneNumberValue;
    this.verificationId = verifyIDValue;
  }

  String countryNo = '';

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final TextEditingController _smsController = TextEditingController();
  String _verificationId = '1';
  String status = '';

  bool phoneNoError = false;
  bool otpError = false;
  String cacheSignInMethod = "CacheSignInMethod";

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
    String _verificationId,
    String phoneNo,
    DeviceDetails _deviceDetails,
  ) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _smsController.text,
      );

      /// Get Current User
      // User firebaseUser = await firebaseAuth.currentUser();
      User firebaseUser = FirebaseAuth.instance.currentUser as User;

      /// Update Phone Number (in Firebase Auth)
      await firebaseUser.updatePhoneNumber(credential).then((value) {
        /// Update Phone Number (in Cloud Firestore)
        authService.updatePhone(firebaseUser, phoneNo);

        /// Message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).highlightColor,
              content: Text(
                "Updated Phone Number",
                style: TextStyle(
                  color: Theme.of(context).backgroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                TextButton(
                  child: Text("Ok",
                      style: TextStyle(
                        color: Theme.of(context).backgroundColor,
                        fontWeight: FontWeight.w600,
                      )),
                  onPressed: () {
                    int count = 0;
                    Navigator.popUntil(context, (route) {
                      return count++ == 2;
                    });
                  },
                ),
              ],
            );
          },
        );
      }).catchError((error) {
        showMessage(
          '',
          error.message,
          _deviceDetails,
          context,
        );
      });
    } on PlatformException catch (error) {
      showMessage(
        '',
        error.message,
        _deviceDetails,
        context,
      );
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              new MaterialPageRoute(
                builder: (BuildContext context) =>
                    PhoneAuthRegisterStepOneScreen(
                  singlePage: false,
                ),
                fullscreenDialog: true,
              ),
            );
          },
          child: Icon(
            Icons.arrow_back_ios_sharp,
            color: Theme.of(context).primaryColor,
            size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          ),
        ),
        automaticallyImplyLeading: false,
        title: Text(
          "Change Phone Number",
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                Colors.green,
                Colors.green,
                Colors.green,
              ])),
        ),
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
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/icon/homebg.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: getPageContent(
                    _deviceDetails,
                    _widgetSize,
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
          0,
        ),
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
          "Field Cannot be Empty",
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
              _signInWithPhoneNumber(
                  verificationId, phoneNumber, _deviceDetails);
            }

            print("Old VID: " + verificationId);
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
              "VERIFY",
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize(),
                color: Theme.of(context).backgroundColor,
                fontWeight: FontWeight.w700,
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
          0,
        ),
        child: InkWell(
          onTap: () {
            FocusScope.of(context).unfocus();
            if (validate() == true) {
              verifyPhoneNumber(phoneNumber);
              verificationId = _verificationId;
              print("New VID: " + verificationId);
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
