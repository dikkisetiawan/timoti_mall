import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/Account/LinkPhone/LinkPhone-Step2.dart';
import '/Data-Class/PhoneAuthStepTwoArgument.dart';
import '/Phone-Auth/PhoneAuthLogin-Step2.dart';
import '/Screen-Size/Get-Device-Details.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';

class LinkPhoneStepOne extends StatefulWidget {
  static const routeName = "/LinkPhoneStepOne";

  @override
  _LinkPhoneStepOneState createState() => _LinkPhoneStepOneState();
}

class _LinkPhoneStepOneState extends State<LinkPhoneStepOne> {
  String countryNo = '';

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final TextEditingController _phoneNumberController = TextEditingController();
  String _verificationId = '';
  String status = '';

  bool phoneNoError = false;
  bool otpError = false;

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
      setState(() {
        Navigator.pushReplacement(
          context,
          new MaterialPageRoute(
            builder: (BuildContext context) => LinkPhoneStepTwo(
              phoneNumber: countryNo + _phoneNumberController.text,
              verificationId: _verificationId,
            ),
            fullscreenDialog: true,
          ),
        );
      });
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
    };

    await firebaseAuth.verifyPhoneNumber(
        phoneNumber: countryNo + _phoneNumberController.text,
        timeout: const Duration(minutes: 1),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget goToPhonePage(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return Container(
      height: _widgetSize.getResponsiveHeight(0.07, 0.07, 0.07),
      width: _widgetSize.getResponsiveWidth(0.7, 0.7, 0.7),
      color: Colors.white,
      child: InkWell(
        onTap: () => setState(() {
          /// Go to Step 2
          PhoneAuthStepTwoArg arg = new PhoneAuthStepTwoArg(
            phoneNumber: '+601122334455',
            verificationId: "11111111",
          );

          Navigator.popAndPushNamed(
            context,
            PhoneAuthLoginStepTwoScreen.routeName,
            arguments: arg,
          );
        }),
        child: Center(
            child: Text(
          "Go To Step 2",
          style: TextStyle(fontWeight: FontWeight.w900),
        )),
      ),
    );
  }

  // endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
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
        title: Text(
          "Linked Phone Number",
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
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
                  children: getPageContent(_deviceDetails, _widgetSize),
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
    pageContent.add(
      Padding(
        padding: EdgeInsets.fromLTRB(
          _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
          0,
        ),
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
    );

    pageContent.add(SizedBox(
      height: _widgetSize.getResponsiveHeight(0.08, 0.08, 0.08),
    ));

    /// Pick Country & Phone No
    pageContent.add(Padding(
      padding: EdgeInsets.fromLTRB(
        _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
        _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
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
                  border: Border.all(color: Theme.of(context).primaryColor)),
              child: CountryCodePicker(
                  backgroundColor: Theme.of(context).highlightColor,
                  textStyle: TextStyle(
                    fontSize: _deviceDetails.getNormalFontSize(),
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
                    countryNo = code?.dialCode as String;
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
              _deviceDetails,
            ),
          ),
        ],
      ),
    ));

    /// OTP
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
            if (validate() == true) {
              verifyPhoneNumber();
            }
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
              "GET OTP",
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

    // pageContent.add(goToPhonePage(_deviceDetails, _widgetSize));
    // /// Verification code
    // pageContent.add(
    //   Padding(
    //     padding: EdgeInsets.fromLTRB(
    //       _widgetSize.getResponsiveWidth(0.1),
    //       _widgetSize.getResponsiveWidth(0.05),
    //       _widgetSize.getResponsiveWidth(0.1),
    //       0,
    //     ),
    //     child: customBorder(
    //       _smsController,
    //       "Please Enter OTP",
    //       otpError,
    //       "Field Cannot be Empty",
    //       false,
    //       _deviceDetails,
    //     ),
    //   ),
    // );
    //
    // /// Sign In
    // pageContent.add(Container(
    //   padding: const EdgeInsets.only(top: 16.0),
    //   alignment: Alignment.center,
    //   child: RaisedButton(
    //       color: Colors.greenAccent[200],
    //       onPressed: () async {
    //         _signInWithPhoneNumber();
    //       },
    //       child: Text("Sign in")),
    // ));

    // pageContent.add(Text("Status: $status"));

    return pageContent;
  }
}
