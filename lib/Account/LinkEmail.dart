import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/Custom-UI/Custom-LoadingUI.dart';
import '/Custom-UI/Custom-RoundedInputField.dart';
import '/Functions/Messager.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';
import '/Screen-Size/ui-utils.dart';
import '/enums/device-screen-type.dart';

class LinkEmail extends StatefulWidget {
  static const routeName = "/LinkEmail";

  @override
  _LinkEmailState createState() => _LinkEmailState();
}

class _LinkEmailState extends State<LinkEmail> {
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _cPasswordController = TextEditingController();
  String _cPasswordString = "";

  bool _passwordError = false;
  bool _confirmPasswordError = false;
  bool _loading = false;
  String previousEmail = '';

  User firebaseUser = FirebaseAuth.instance.currentUser as User;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    print(firebaseUser.displayName);

    if (this.mounted) {
      _loading = false;
      setState(() {});
    }

    getUserData();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
    _cPasswordController.dispose();
  }

  // region UI
  /// First Name, Last name, Email, Password, Confirm Password
  Widget getRegisterUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    var mediaQuery = MediaQuery.of(context);

    return SizedBox(
      width: _widgetSize.getResponsiveWidth(0.8, 0.8, 0.8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.start,
            direction: Axis.horizontal,
            children: [
              Text(
                "Email address:  ",
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

          SizedBox(height: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),

          /// Password
          SizedBox(
            height: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                ? _widgetSize.getResponsiveHeight(0.1, 0.1, 0.1)
                : _widgetSize.getResponsiveHeight(0.08, 0.08, 0.08),
            child: customRoundedBorder(
              _passwordController,
              "Password",
              _passwordError,
              "Please fill in your password",
              true,
              _deviceDetails,
              _widgetSize,
              null,
              null,
            ),
          ),

          /// Confirm Password
          SizedBox(
            height: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                ? _widgetSize.getResponsiveHeight(0.1, 0.1, 0.1)
                : _widgetSize.getResponsiveHeight(0.08, 0.08, 0.08),
            child: customRoundedBorder(
              _cPasswordController,
              "Confirm Password",
              _confirmPasswordError,
              _cPasswordString,
              true,
              _deviceDetails,
              _widgetSize,
              null,
              null,
            ),
          ),
        ],
      ),
    );
  }

  /// Sign up button
  Widget getLinkButtonUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return SizedBox(
      width: _widgetSize.getResponsiveWidth(0.8, 0.8, 0.8),
      height: _widgetSize.getResponsiveWidth(0.12, 0.12, 0.12),
      child: TextButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          backgroundColor:
              MaterialStateProperty.all(Theme.of(context).highlightColor),
          elevation: MaterialStateProperty.all(5),
          shadowColor:
              MaterialStateProperty.all(Theme.of(context).highlightColor),
        ),
        onPressed: _loading == true
            ? null
            : () {
                if (this.mounted) {
                  setState(() {
                    if (successValidate() == true) {
                      linkPassword(context, _deviceDetails);
                    }
                  });
                }
              },
        child: _loading == true
            ? CustomLoading()
            : Text(
                "Link With Password",
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
  // endregion

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

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    var mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
            ? Size.fromHeight(80.0)
            : Size.fromHeight(80.0),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            SizedBox(
              height: _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
              child: Stack(
                children: <Widget>[
                  Container(
                    color: Theme.of(context).backgroundColor,
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: SafeArea(
                      minimum: getDeviceType(mediaQuery) ==
                              DeviceScreenType.Mobile
                          ? EdgeInsets.fromLTRB(
                              0,
                              _widgetSize.getResponsiveHeight(0.05, 0.05, 0.05),
                              _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                              _widgetSize.getResponsiveHeight(0.01, 0.01, 0.01),
                            )
                          : EdgeInsets.fromLTRB(
                              0,
                              _widgetSize.getResponsiveHeight(0.03, 0.03, 0.03),
                              _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                              _widgetSize.getResponsiveHeight(0.01, 0.01, 0.01),
                            ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          0,
                          _widgetSize.getResponsiveHeight(0.01, 0.01, 0.01),
                          0,
                          0,
                        ),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: SizedBox(
                            width:
                                _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(
                                  Icons.close,
                                  color: Theme.of(context).highlightColor,
                                  size: _widgetSize.getResponsiveWidth(
                                      0.1, 0.1, 0.1),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: getPageContent(_deviceDetails, _widgetSize),
            ),
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
    var paddingLeftRight = _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1);

    /// Register UI
    pageContent.add(
      Padding(
        padding: EdgeInsets.fromLTRB(paddingLeftRight, 0, paddingLeftRight, 0),
        child: getRegisterUI(_deviceDetails, _widgetSize),
      ),
    );

    /// Spacing
    pageContent.add(SizedBox(
      height: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
    ));

    /// Link Password
    pageContent.add(
      getLinkButtonUI(_deviceDetails, _widgetSize),
    );

    return pageContent;
  }

  bool successValidate() {
    bool temp = false;

    // region Empty Field
    if (_passwordController.text.isEmpty) {
      _passwordError = true;
    } else if (_cPasswordController.text.isEmpty) {
      _confirmPasswordError = true;
      _cPasswordString = "Please fill in password again";
    }
    // endregion
    // region Confirm Password Checking
    else if (_passwordController.text != _cPasswordController.text) {
      _confirmPasswordError = true;
      _cPasswordString = "Password does not match.";
    }
    // endregion

    else {
      _passwordError = false;
      _confirmPasswordError = false;
      temp = true;
    }
    return temp;
  }

  Future<void> linkPassword(
    BuildContext context,
    DeviceDetails _deviceDetails,
  ) async {
    if (this.mounted) {
      _loading = true;
      setState(() {});
    }

    /// Get Email Credential
    final AuthCredential credential = EmailAuthProvider.credential(
      email: previousEmail,
      password: _passwordController.text,
    );

    /// Link Account
    firebaseUser.linkWithCredential(credential).then((user) {
      if (this.mounted) {
        _loading = false;
        setState(() {});
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).backgroundColor,
            content: Text(
              "Successfully Linked Account with Password \nYou can now sign in with email",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              TextButton(
                child: Text("Ok",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
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
  }
}
