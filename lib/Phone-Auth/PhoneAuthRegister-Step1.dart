import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/Custom-UI/Custom-LoadingUI.dart';
import '/Introduction-Page/Introduction-Page.dart';
import '/Phone-Auth/PhoneAuthRegister-Step2.dart';
import '/Screen-Size/Get-Device-Details.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';
import '/enums/Sign-In-Type.dart';

class PhoneAuthRegisterStepOneScreen extends StatelessWidget {
  static const routeName = "/PhoneAuthRegisterStep1";
  final bool singlePage;

  PhoneAuthRegisterStepOneScreen({
    required this.singlePage,
  });

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
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
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w400,
                            fontSize: _deviceDetails.getNormalFontSize(),
                          ),
                        ),
                        content: Text(
                          'This process is to link your account with your phone number, some function may not be able to use\n\n*You can link your phone number to your account later: \nAccount -> Settings -> Link Phone Number',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w400,
                            fontSize: _deviceDetails.getNormalFontSize(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
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
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w400,
                                fontSize: _deviceDetails.getNormalFontSize(),
                              ),
                            ),
                            onPressed: () {
                              int count = 0;
                              Navigator.popUntil(context, (route) {
                                return count++ == 1;
                                // if(type == SignInType.Email){
                                //   return count++ == 2;
                                // }else{
                                //   return count++ == 1;
                                // }
                              });

                              Navigator.pushReplacementNamed(
                                context,
                                IntroductionPage.routeName,
                                // arguments: navBarGlobalKey,
                              );
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
        automaticallyImplyLeading: false,
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
              /// Background
              Container(
                color: Theme.of(context).backgroundColor,
                // decoration: BoxDecoration(
                //   image: DecorationImage(
                //     image: AssetImage("assets/icon/homebg.jpg"),
                //     fit: BoxFit.cover,
                //   ),
                // ),
              ),

              /// Content
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                        height:
                            _widgetSize.getResponsiveHeight(0.05, 0.05, 0.05)),
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
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                          _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                          0),
                      child: Text(
                        "We will send you a One Time Password on your phone number",
                        style: TextStyle(
                          fontSize: _deviceDetails.getNormalFontSize(),
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: _widgetSize.getResponsiveHeight(0.08, 0.08, 0.08),
                    ),
                    PhoneInputUI(
                      deviceDetails: _deviceDetails,
                      widgetSize: _widgetSize,
                      singlePage: singlePage,
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

class PhoneInputUI extends StatefulWidget {
  final WidgetSizeCalculation widgetSize;
  final DeviceDetails deviceDetails;
  final bool singlePage;

  PhoneInputUI({
    required this.widgetSize,
    required this.deviceDetails,
    required this.singlePage,
  });
  @override
  _PhoneInputUIState createState() => _PhoneInputUIState();
}

class _PhoneInputUIState extends State<PhoneInputUI> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final TextEditingController _phoneNumberController = TextEditingController();

  String countryNo = '';
  String _verificationId = '';
  String status = '';

  bool phoneNoError = false;
  bool otpError = false;

  bool _loading = false;

  @override
  void initState() {
    _loading = false;
    super.initState();
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
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
    if (_phoneNumberController.text.isEmpty) {
      phoneNoError = true;
    } else {
      phoneNoError = false;
      temp = true;
    }
    return temp;
  }

  void verifyPhoneNumber() async {
    if (this.mounted) {
      _loading = true;
      setState(() {});
    }

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

      if (this.mounted) {
        _loading = false;
        setState(() {});
      }
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      if (mounted)
        setState(() {
          status =
              'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}';
        });

      if (this.mounted) {
        _loading = false;
        setState(() {});
      }
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int? forceResendingToken]) async {
      _verificationId = verificationId;

      if (this.mounted) {
        _loading = false;
        setState(() {});
      }

      // /// Go to Step 2
      // PhoneAuthStepTwoArg arg = new PhoneAuthStepTwoArg(
      //   phoneNumber: countryNo + _phoneNumberController.text,
      //   verificationId: _verificationId,
      // );
      Navigator.pushReplacement(
        context,
        new MaterialPageRoute(
          builder: (BuildContext context) => PhoneAuthRegisterStepTwoScreen(
            phoneNumber: countryNo + _phoneNumberController.text,
            verificationId: _verificationId,
            singlePage: widget.singlePage,
          ),
          fullscreenDialog: true,
        ),
      );
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;

      if (this.mounted) {
        _loading = false;
        setState(() {});
      }
    };

    await firebaseAuth.verifyPhoneNumber(
        phoneNumber: countryNo + _phoneNumberController.text,
        timeout: const Duration(minutes: 1),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
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
        /// Pick Country & Phone No
        Padding(
          padding: EdgeInsets.fromLTRB(
            widget.widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
            widget.widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
            widget.widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
            0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Pick Country
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                      border:
                          Border.all(color: Theme.of(context).primaryColor)),
                  child: CountryCodePicker(
                      backgroundColor: Theme.of(context).highlightColor,
                      textStyle: TextStyle(
                        fontSize: widget.deviceDetails.getNormalFontSize(),
                        color: Theme.of(context).primaryColor,
                      ),
                      onChanged: (code) {
                        countryNo = code.dialCode as String;
                        print(countryNo);
                      },
                      // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                      initialSelection: 'MY',
                      favorite: ['+60', 'MY'],
                      // countryFilter: ['IT', 'FR'],
                      showFlagDialog: true,
                      comparator: (a, b) => b.name!.compareTo(a.name as String),
                      //Get the country information relevant to the initial selection
                      onInit: (code) {
                        countryNo = code!.dialCode as String;
                        print(countryNo);
                        // print("on init: ${code.name} - ${code.dialCode} - ${code.name}");
                      }),
                ),
              ),

              /// Spacing
              Expanded(flex: 1, child: SizedBox()),

              /// Phone No
              Expanded(
                flex: 7,
                child: customBorder(
                  _phoneNumberController,
                  "Please Enter Phone No",
                  phoneNoError,
                  "Field Cannot be Empty",
                  false,
                  widget.deviceDetails,
                ),
              ),
            ],
          ),
        ),

        /// OTP
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
                      verifyPhoneNumber();
                    }
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
                      "GET OTP",
                      style: TextStyle(
                        fontSize: widget.deviceDetails.getNormalFontSize(),
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
