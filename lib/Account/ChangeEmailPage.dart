import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timoti_project/Custom-UI/Custom-RoundedInputField.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:timoti_project/Functions/Messager.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';
import 'package:timoti_project/Screen-Size/ui-utils.dart';
import 'package:timoti_project/enums/device-screen-type.dart';

class ChangeEmail extends StatefulWidget {
  static const routeName = '/ChangeEmail';
  @override
  State<StatefulWidget> createState() {
    return _ChangeEmailState();
  }
}

class _ChangeEmailState extends State<ChangeEmail> {
  bool _loading = false;
  String previousEmail = '';
  TextEditingController _emailController = TextEditingController();
  bool _emailError = false;
  String _emailErrorMessage = '';

  User firebaseUser = FirebaseAuth.instance.currentUser as User;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    print(firebaseUser.displayName);
    if (this.mounted) {
      _loading = false;
      setState(() {});
    }

    getUserData();

    // FirebaseAuth.instance.currentUser().then((value) {
    //   if (this.mounted) {
    //     _loading = false;
    //     setState(() {});
    //   }
    //   // print(value.displayName);
    //   print(value.uid);
    //   firebaseUser = value;
    //   getUserData();
    // });

    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
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
          /// Spacing
          SizedBox(
            height: _widgetSize.getResponsiveHeight(0.05, 0.05, 0.05),
          ),

          Wrap(
            crossAxisAlignment: WrapCrossAlignment.start,
            direction: Axis.horizontal,
            children: [
              Text(
                "Your current email address:  ",
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                previousEmail,
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).highlightColor,
                ),
              )
            ],
          ),

          /// Spacing
          SizedBox(
            height: _widgetSize.getResponsiveHeight(0.03, 0.03, 0.03),
          ),

          /// Change Email
          customRoundedBorder(
            _emailController,
            "New Email",
            _emailError,
            _emailErrorMessage,
            false,
            _deviceDetails,
            _widgetSize,
            null,
            null,

          ),

          /// Old Password
          SizedBox(
            height: 15,
          ),

          Text(
            "* Please ensure your email is correct",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
              fontSize: _deviceDetails.getNormalFontSize() - 2,
            ),
          ),

          Text(
            "* Your Google and Facebook Email would not be change",
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
                      print("Validate Success");
                      hasInternet().then((value) {
                        if (value == true) {
                          changeEmail(_deviceDetails, _emailController.text);
                        } else {
                          showSnackBar('No Internet Connection');
                        }
                      });
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
  Future<void> getUserData() async {
    if (this.mounted) {
      _loading = true;
      setState(() {});
    }

    DocumentSnapshot data =
        await firestore.collection('Customers').doc(firebaseUser.uid).get();

    if (this.mounted) {
      /// Define Map Data
      Map<String, dynamic> cusData = Map<String, dynamic>();

      /// Assign Data
      cusData = data.data() as Map<String, dynamic>;

      previousEmail = cusData["Email"];
      _loading = false;
      setState(() {});
    }
  }

  Future<void> changeEmail(
    DeviceDetails _deviceDetails,
    String newEmail,
  ) async {
    if (this.mounted) {
      _loading = true;
      setState(() {});
    }

    await firebaseUser.updateEmail(newEmail).then(
      (value) async {
        await firestore.collection('Customers').doc(firebaseUser.uid).update({
          "Email": newEmail,
        }).then((value) {
          _loading = false;
          previousEmail = newEmail;
          setState(() {});
          showMessage(
            '',
            "Successfully updated your email",
            _deviceDetails,
             context,
                );
        }).catchError((error) {
          _loading = false;
          setState(() {});
          showMessage(
            '',
            error.message,
            _deviceDetails,
             context,
                );
        });
      },
    ).catchError((error) {
      _loading = false;
      setState(() {});
      showMessage(
        '',
        error.message,
        _deviceDetails,
         context,
      );
    });
  }

  /// Validate the form
  bool validate() {
    bool temp = false;
    if (_emailController.text.isEmpty) {
      _emailError = true;
      _emailErrorMessage = "Field cannot be empty";
    } else if (EmailValidator.validate(_emailController.text) == false) {
      _emailError = true;
      _emailController.clear();
      _emailErrorMessage = "Invalid Email Format";
    } else if (_emailController.text == previousEmail) {
      _emailError = true;
      _emailController.clear();
      _emailErrorMessage = "Same Email Address";
    } else {
      _emailError = false;
      temp = true;
    }
    return temp;
  }

  /// Check Internet Status
  Future<bool> hasInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      // Neither mobile data or WIFI detected, not internet connection found.
      return false;
    }
  }

  /// Show Snackbar below
  void showSnackBar(String textData) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(textData),
      duration: const Duration(seconds: 1),
      // action: SnackBarAction(
      //   label: 'ACTION',
      //   onPressed: () { },
      // ),
    ));
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
          "Change Email",
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
