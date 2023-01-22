import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:page_transition/page_transition.dart';
import 'package:timoti_project/Core/auth.dart';
import 'package:timoti_project/Custom-UI/Custom-DefaultAppBar.dart';
import 'package:timoti_project/Custom-UI/Custom-LoadingUI.dart';
import 'package:timoti_project/Custom-UI/Custom-RoundedInputField.dart';
import 'package:timoti_project/ForgetPassword-Page/ForgetPassword-Page.dart';
import 'package:timoti_project/Introduction-Page/Introduction-Page.dart';
import 'package:timoti_project/Login-Register-Page/RegisterPage.dart';
import 'package:timoti_project/Functions/Messager.dart';
import 'package:timoti_project/Nav.dart';
import 'package:timoti_project/Phone-Auth/PhoneAuthLogin-Step1.dart';
import 'package:timoti_project/Phone-Auth/PhoneAuthRegister-Step1.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';
import 'package:timoti_project/Screen-Size/ui-utils.dart';
import 'package:timoti_project/enums/Sign-In-Type.dart';
import 'package:timoti_project/enums/User-Sign-In-Method.dart';
import 'package:timoti_project/enums/device-screen-type.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:timoti_project/Cache-Data/Cache-User.dart';
import 'package:path_provider/path_provider.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/Login-Page';
  final int? returnIndex;
  final bool singlePage;

  const LoginScreen({
    Key? key,
    this.returnIndex,
    required this.singlePage,
  }) : super(key: key);

  // region UI
  // region Layout Design
  /// Layout with Background
  Widget layoutBG(
    double paddingTopBottom,
    BuildContext context,
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return Container(
      width: _widgetSize.getResponsiveWidth(1, 1, 1),
      height: _widgetSize.getResponsiveHeight(1, 1, 1),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          /// Background
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/icon/homebg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// Content
          Padding(
            padding: EdgeInsets.only(top: paddingTopBottom),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// Logo
                getMainIcon(_widgetSize, context, 0.3, 0.4),

                /// Spacing

                SizedBox(height: _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1)),

                /// Login
                EmailSignIn(
                  widgetSize: _widgetSize,
                  deviceDetails: _deviceDetails,
                ),

                /// Phone Login & Forgot Password
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                      15,
                      _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                      0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// Phone Login
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              PhoneAuthLoginStepOneScreen.routeName,
                            );
                          },
                          child: Text(
                            "Phone Login",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: _deviceDetails.getNormalFontSize(),
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        /// Forget Password
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              ForgetPasswordPage.routeName,
                            );
                          },
                          child: Text(
                            "Forget Password?",
                            style: TextStyle(
                              fontSize: _deviceDetails.getNormalFontSize(),
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// Spacing
                SizedBox(
                    height: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),

                /// Register
                getRegisterUI(_deviceDetails, _widgetSize, context),

                /// Google + Facebook Sign in
                FacebookGoogleSignIn(
                  singlePage: singlePage,
                  widgetSize: _widgetSize,
                  deviceDetails: _deviceDetails,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Layout NO Background
  Widget layoutNoBG(
    double paddingTopBottom,
    BuildContext context,
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return Container(
      width: _widgetSize.getResponsiveWidth(1, 1, 1),
      height: _widgetSize.getResponsiveHeight(1, 1, 1),
      child: Padding(
        padding: EdgeInsets.only(top: paddingTopBottom),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Logo
            getMainIcon(_widgetSize, context, 0.6, 0.4),

            /// Spacing
            SizedBox(height: _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1)),

            /// Login
            EmailSignIn(
              widgetSize: _widgetSize,
              deviceDetails: _deviceDetails,
            ),

            /// Phone Login & Forgot Password
            Padding(
              padding: EdgeInsets.fromLTRB(
                  _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                  15,
                  _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                  0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// Phone Login
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                            context, PhoneAuthLoginStepOneScreen.routeName);
                      },
                      child: Text(
                        "Phone Login",
                        style: TextStyle(
                          fontSize: _deviceDetails.getNormalFontSize(),
                          color: Theme.of(context).highlightColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    SizedBox(width: 10),

                    Text(" | ", style: TextStyle(color: Colors.white)),

                    SizedBox(width: 10),

                    /// Forget Password
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                            context, ForgetPasswordPage.routeName);
                      },
                      child: Text(
                        "Forget Password?",
                        style: TextStyle(
                          fontSize: _deviceDetails.getNormalFontSize(),
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// Spacing
            SizedBox(height: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),

            /// Register
            getRegisterUI(_deviceDetails, _widgetSize, context),

            /// Google + Facebook Sign in
            FacebookGoogleSignIn(
              singlePage: singlePage,
              widgetSize: _widgetSize,
              deviceDetails: _deviceDetails,
            ),
          ],
        ),
      ),
    );
  }
  // endregion

  /// Icon UI
  Widget getMainIcon(
    WidgetSizeCalculation _widgetSize,
    BuildContext context,
    double mobileLogoSize,
    double otherSize,
  ) {
    var mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Image.asset(
        'assets/icon/logo.png',
        width: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
            ? _widgetSize.getResponsiveWidth(
                mobileLogoSize, mobileLogoSize, mobileLogoSize)
            : _widgetSize.getResponsiveWidth(otherSize, otherSize, otherSize),
        // height: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
        //     ? _widgetSize.getResponsiveHeight(0.3, 0.4, 0.4)
        //     : _widgetSize.getResponsiveHeight(0.3, 0.4, 0.4),
      ),
    );
  }

  /// Register UI
  Widget getRegisterUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    BuildContext context,
  ) {
    return SizedBox(
      width: _widgetSize.getResponsiveWidth(0.8, 0.8, 0.8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          /// Line
          Container(
            color: Theme.of(context).highlightColor,
            width: _widgetSize.getResponsiveWidth(0.2, 0.2, 0.2),
            height: 1,
          ),

          SizedBox(
            height: 20,
          ),

          Text(
            "Not yet a member?",
            style: TextStyle(
              color: Colors.white,
              fontSize: _deviceDetails.getNormalFontSize(),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(
            height: 10,
          ),

          SizedBox(
            width: _widgetSize.getResponsiveWidth(0.9, 0.9, 0.9),
            height: _widgetSize.getResponsiveHeight(0.07, 0.07, 0.07),
            child: TextButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all(Colors.white),
                elevation: MaterialStateProperty.all(5),
                shadowColor:
                    MaterialStateProperty.all(Theme.of(context).highlightColor),
              ),
              onPressed: () async {
                bool? registerSuccessful = await Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.bottomToTop,
                    child: RegisterScreen(),
                  ),
                );

                if (registerSuccessful != null) {
                  /// Register Successful
                  // Go to Phone Register Page One
                  if (registerSuccessful == true) {
                    if (kIsWeb == false) {
                      Navigator.pushReplacement(
                        context,
                        PageTransition(
                          type: PageTransitionType.bottomToTop,
                          child: PhoneAuthRegisterStepOneScreen(
                            singlePage: singlePage,
                          ),
                        ),
                      );
                    } else {
                      showSnackBar('Welcome to Timoti!', context);
                      Navigator.pop(context);
                    }
                  }
                }
              },
              child: Text(
                "Register Now",
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).focusColor,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  // endregion

  // region Functions
  Widget goToPhonePage(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    BuildContext context,
  ) {
    return Container(
      height: _widgetSize.getResponsiveHeight(0.07, 0.07, 0.07),
      width: _widgetSize.getResponsiveWidth(0.7, 0.7, 0.7),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.popAndPushNamed(
              context, PhoneAuthLoginStepOneScreen.routeName);
        },
        child: Center(
            child: Text(
          "Go To Phone Page",
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

    var paddingTopBottom = _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1);

    return Scaffold(
      appBar: singlePage == false
          ? CustomDefaultAppBar(
              widgetSize: _widgetSize,
              appbarTitle: 'Login',
              onTapFunction: () => Navigator.pop(context),
            )
          : null,
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).focusColor,
      body: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: layoutNoBG(
            paddingTopBottom,
            context,
            _deviceDetails,
            _widgetSize,
          ),
        ),
      ),
    );
  }
}

// region Email Sign In
class EmailSignIn extends StatefulWidget {
  final WidgetSizeCalculation widgetSize;
  final DeviceDetails deviceDetails;

  EmailSignIn({
    required this.widgetSize,
    required this.deviceDetails,
  });
  @override
  _EmailSignInState createState() => _EmailSignInState();
}

class _EmailSignInState extends State<EmailSignIn> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _emailError = false;
  bool _passwordError = false;
  bool _loading = false;
  String cacheSignInMethod = "CacheSignInMethod";

  /// Fingerprint
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  List<BiometricType> _availableBiometrics = [];
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _loading = false;
    _passwordError = false;
    _emailError = false;

    /// Check Biometrics
    if (kIsWeb == false) {
      _checkBiometrics();
    }
  }

  // region Function
  /// Login
  Future<void> signIn(
    BuildContext context,
    DeviceDetails _deviceDetails,
  ) async {
    if (this.mounted) {
      _loading = true;
      setState(() {});
    }

    if (_emailError == false && _passwordError == false) {
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text)
            .then((auth) async {
          if (this.mounted) {
            _loading = false;
            setState(() {});
          }

          // Update user to firecloud
          authService.updateUserData(auth.user as User);

          Navigator.pop(context);
          showSnackBar("Welcome Back to Timoti!", context);
          // Navigator.pushReplacementNamed(
          //   context,
          //   Nav.routeName,
          // );
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
  }

  /// Validate the form
  bool successValidate() {
    bool temp = false;
    if (_emailController.text.isEmpty) {
      _emailError = true;
    } else if (_passwordController.text.isEmpty) {
      _passwordError = true;
    } else {
      _emailError = false;
      _passwordError = false;
      temp = true;
    }

    return temp;
  }
  // endregion

  // region Fingerprint Functions
  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics = false;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics = [];
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticate(
      CacheUser user, DeviceDetails _deviceDetails) async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      // authenticated = await auth.authenticateWithBiometrics(
      //     localizedReason: 'Scan your fingerprint to authenticate',
      //     useErrorDialogs: true,
      //     stickyAuth: true);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      // print("Error:" + e.message);
      print(e);
    }
    if (!mounted) return;

    final String message = authenticated ? 'Authorized' : 'Not Authorized';
    setState(() {
      _authorized = message;
      print(_authorized);
      if (_authorized == 'Authorized') {
        // CurrentSiteID siteID = Provider.of(context, listen: false);

        print("Username: " + user.username);
        print("Password: " + user.password);

        _emailController.text = user.username;
        _passwordController.text = user.password;

        // signIn(context, _deviceDetails);
      }
    });
  }

  void _cancelAuthentication() {
    auth.stopAuthentication();
  }
  // endregion

  /// Email, Password, Login UI
  Widget getLoginUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return SizedBox(
      width: _widgetSize.getResponsiveWidth(0.8, 0.8, 0.8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          /// Email
          customRoundedBorder(
            _emailController,
            "Email Address",
            _emailError,
            "Please fill in your email",
            false,
            _deviceDetails,
            _widgetSize,
            null,
            Colors.white,
          ),

          /// Spacing
          SizedBox(
            height: _widgetSize.getResponsiveHeight(0.03, 0.03, 0.03),
          ),

          /// Password
          customRoundedBorder(
            _passwordController,
            "Password",
            _passwordError,
            "Please fill in your password",
            true,
            _deviceDetails,
            _widgetSize,
            null,
            Colors.white,
          ),

          /// Spacing
          SizedBox(
            height: _widgetSize.getResponsiveHeight(0.03, 0.03, 0.03),
          ),

          /// Login Button
          SizedBox(
            width: _widgetSize.getResponsiveWidth(0.9, 0.9, 0.9),
            height: _widgetSize.getResponsiveHeight(0.07, 0.07, 0.07),
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
                            signIn(context, _deviceDetails);
                          }
                        });
                      }
                    },
              child: _loading == true
                  ? CustomLoading()
                  : Text(
                      "Log In",
                      style: TextStyle(
                        fontSize: _deviceDetails.getNormalFontSize(),
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).focusColor,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return getLoginUI(widget.deviceDetails, widget.widgetSize);
  }
}
// endregion

// region Facebook Google Sign In
class FacebookGoogleSignIn extends StatefulWidget {
  final WidgetSizeCalculation widgetSize;
  final DeviceDetails deviceDetails;
  final bool singlePage;

  FacebookGoogleSignIn({
    required this.widgetSize,
    required this.deviceDetails,
    required this.singlePage,
  });

  @override
  _FacebookGoogleSignInState createState() => _FacebookGoogleSignInState();
}

class _FacebookGoogleSignInState extends State<FacebookGoogleSignIn> {
  String cacheSignInMethod = "CacheSignInMethod";
  bool _googleLoading = false;
  bool _fbLoading = false;

  @override
  void initState() {
    _googleLoading = false;
    _fbLoading = false;
    super.initState();
  }

  // For Google
  void googleSignInOutHandler() {
    if (this.mounted) {
      _googleLoading = true;
      setState(() {});
    }

    /// Google Sign In
    authService.googleSignIn(context, true).then((userLoginBefore) {
      if (this.mounted) {
        _googleLoading = false;
        setState(() {});
      }
      if (userLoginBefore == true) {
        showSnackBar('Welcome to Timoti!', context);
      }
      Navigator.pop(context);
    }).onError((error, stackTrace) {
      if (this.mounted) {
        _googleLoading = false;
        setState(() {});
      }
      if (error != null) {
        showMessage(
          'Google Login Error',
          error.toString(),
          widget.deviceDetails,
          context,
        );
      }
    });

    // /// Already Login
    // if (FirebaseAuth.instance.currentUser != null) {
    //   /// Is Guest
    //   if (FirebaseAuth.instance.currentUser?.isAnonymous == true) {
    //     authService
    //         .upgradeWithGoogle(widget.deviceDetails, context)
    //         .then((value) {
    //       if (kIsWeb == false) {
    //         Navigator.pushReplacement(
    //           context,
    //           PageTransition(
    //             type: PageTransitionType.rightToLeft,
    //             child: PhoneAuthRegisterStepOneScreen(
    //                 singlePage: widget.singlePage),
    //           ),
    //         );
    //       } else {
    //         Navigator.pop(context);
    //       }
    //     });
    //   } else {
    //     /// Call Google Login Service
    //     authService.googleSignIn(context, true).then((userLoginBefore) {
    //       if (this.mounted) {
    //         _googleLoading = false;
    //         setState(() {});
    //       }
    //
    //       /// Existing User
    //       if (userLoginBefore == true) {
    //         Navigator.pop(context);
    //         // Navigator.pushReplacementNamed(
    //         //     context, Nav.routeName);
    //       }
    //
    //       /// New User
    //       else {
    //         if (kIsWeb == false) {
    //           Navigator.pushReplacement(
    //             context,
    //             PageTransition(
    //               type: PageTransitionType.rightToLeft,
    //               child: PhoneAuthRegisterStepOneScreen(
    //                   singlePage: widget.singlePage),
    //             ),
    //           );
    //         } else {
    //           Navigator.pop(context);
    //         }
    //       }
    //     }).catchError((error) {
    //       if (this.mounted) {
    //         _googleLoading = false;
    //         setState(() {});
    //       }
    //       showMessage(
    //         '',
    //         error.message,
    //         widget.deviceDetails,
    //         context,
    //       );
    //     });
    //   }
    // } else {
    //   /// Call Google Login Service
    //   authService.googleSignIn(context, true).then((userLoginBefore) {
    //     if (this.mounted) {
    //       _googleLoading = false;
    //       setState(() {});
    //     }
    //
    //     /// Existing User
    //     if (userLoginBefore == true) {
    //       Navigator.pop(context);
    //       // Navigator.pushReplacementNamed(
    //       //     context, Nav.routeName);
    //     }
    //
    //     /// New User
    //     else {
    //       Navigator.pushReplacement(
    //         context,
    //         PageTransition(
    //           type: PageTransitionType.rightToLeft,
    //           child:
    //               PhoneAuthRegisterStepOneScreen(singlePage: widget.singlePage),
    //         ),
    //       );
    //     }
    //   }).catchError((error) {
    //     if (this.mounted) {
    //       _googleLoading = false;
    //       setState(() {});
    //     }
    //     showMessage(
    //       '',
    //       error.message,
    //       widget.deviceDetails,
    //       context,
    //     );
    //   });
    // }
  }

  // For Facebook
  // void facebookSignInOutHandler() {
  //   if (this.mounted) {
  //     _fbLoading = true;
  //     setState(() {});
  //   }

  //   /// Facebook Sign In
  //   authService.signInWithFacebook(context, true).then((userLoginBefore) {
  //     if (this.mounted) {
  //       _fbLoading = false;
  //       setState(() {});
  //     }
  //     if (userLoginBefore == true) {
  //       showSnackBar('Welcome to Timoti!', context);
  //     }
  //     Navigator.pop(context);
  //   }).onError((error, stackTrace) {
  //     if (this.mounted) {
  //       _fbLoading = false;
  //       setState(() {});
  //     }
  //     if (error != null) {
  //       showMessage(
  //         'Facebook Login Error',
  //         error.toString(),
  //         widget.deviceDetails,
  //         context,
  //       );
  //     }
  //   });

  //   // }).catchError((error) {
  //   //   if (this.mounted) {
  //   //     _fbLoading = false;
  //   //     setState(() {});
  //   //   }
  //   //   showMessage(
  //   //     'Facebook Login Error',
  //   //     error,
  //   //     widget.deviceDetails,
  //   //     context,
  //   //   );
  //   // });

  //   // /// Already Login
  //   // if (FirebaseAuth.instance.currentUser != null) {
  //   //   /// Is Guest
  //   //   if (FirebaseAuth.instance.currentUser?.isAnonymous == true) {
  //   //     authService
  //   //         .upgradeWithGoogle(widget.deviceDetails, context)
  //   //         .then((value) {
  //   //       if (kIsWeb == false) {
  //   //         Navigator.pushReplacement(
  //   //           context,
  //   //           PageTransition(
  //   //             type: PageTransitionType.rightToLeft,
  //   //             child: PhoneAuthRegisterStepOneScreen(
  //   //                 singlePage: widget.singlePage),
  //   //           ),
  //   //         );
  //   //       } else {
  //   //         Navigator.pop(context);
  //   //       }
  //   //     });
  //   //   } else {
  //   //     /// Call Google Login Service
  //   //     authService.googleSignIn(context, true).then((userLoginBefore) {
  //   //       if (this.mounted) {
  //   //         _googleLoading = false;
  //   //         setState(() {});
  //   //       }
  //   //
  //   //       /// Existing User
  //   //       if (userLoginBefore == true) {
  //   //         Navigator.pop(context);
  //   //         // Navigator.pushReplacementNamed(
  //   //         //     context, Nav.routeName);
  //   //       }
  //   //
  //   //       /// New User
  //   //       else {
  //   //         if (kIsWeb == false) {
  //   //           Navigator.pushReplacement(
  //   //             context,
  //   //             PageTransition(
  //   //               type: PageTransitionType.rightToLeft,
  //   //               child: PhoneAuthRegisterStepOneScreen(
  //   //                   singlePage: widget.singlePage),
  //   //             ),
  //   //           );
  //   //         } else {
  //   //           Navigator.pop(context);
  //   //         }
  //   //       }
  //   //     }).catchError((error) {
  //   //       if (this.mounted) {
  //   //         _googleLoading = false;
  //   //         setState(() {});
  //   //       }
  //   //       showMessage(
  //   //         '',
  //   //         error.message,
  //   //         widget.deviceDetails,
  //   //         context,
  //   //       );
  //   //     });
  //   //   }
  //   // } else {
  //   //   /// Call Google Login Service
  //   //   authService.googleSignIn(context, true).then((userLoginBefore) {
  //   //     if (this.mounted) {
  //   //       _googleLoading = false;
  //   //       setState(() {});
  //   //     }
  //   //
  //   //     /// Existing User
  //   //     if (userLoginBefore == true) {
  //   //       Navigator.pop(context);
  //   //       // Navigator.pushReplacementNamed(
  //   //       //     context, Nav.routeName);
  //   //     }
  //   //
  //   //     /// New User
  //   //     else {
  //   //       Navigator.pushReplacement(
  //   //         context,
  //   //         PageTransition(
  //   //           type: PageTransitionType.rightToLeft,
  //   //           child:
  //   //               PhoneAuthRegisterStepOneScreen(singlePage: widget.singlePage),
  //   //         ),
  //   //       );
  //   //     }
  //   //   }).catchError((error) {
  //   //     if (this.mounted) {
  //   //       _googleLoading = false;
  //   //       setState(() {});
  //   //     }
  //   //     showMessage(
  //   //       '',
  //   //       error.message,
  //   //       widget.deviceDetails,
  //   //       context,
  //   //     );
  //   //   });
  //   // }
  // }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: FractionalOffset.bottomCenter,
        child: Container(
          width: widget.widgetSize.getResponsiveWidth(1, 1, 1),
          height: widget.widgetSize.getResponsiveWidth(0.25, 0.25, 0.25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Text
              Expanded(
                flex: 3,
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Or continue with social account",
                      style:
                          TextStyle(color: Theme.of(context).primaryColorLight),
                    ),
                  ),
                ),
              ),

              /// FB + Google
              Expanded(
                flex: 7,
                child: Container(
                  width: widget.widgetSize.getResponsiveWidth(1, 1, 1),
                  color: Colors.white,
                  child: FittedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// Facebook
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            0,
                            10,
                            0,
                            10,
                          ),
                          child: Container(
                            width: widget.widgetSize
                                .getResponsiveWidth(0.38, 0.38, 0.38),
                            height: widget.widgetSize
                                .getResponsiveWidth(0.12, 0.12, 0.12),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/icon/f.jpg"),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: InkWell(
                              onTap: _fbLoading == true
                                  ? null
                                  // : () => showTempMessage(
                                  //     widget.deviceDetails, context),
                                  : () {}, //() => facebookSignInOutHandler(),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: widget.widgetSize
                                        .getResponsiveWidth(0.05, 0.05, 0.05),
                                  ),
                                  child: _fbLoading == true
                                      ? CustomLoading()
                                      : Text(
                                          "Facebook",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: widget.deviceDetails
                                                  .getTitleFontSize(),
                                              fontWeight: FontWeight.w500),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 10),

                        /// Google
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            0,
                            10,
                            0,
                            10,
                          ),
                          child: Container(
                            width: widget.widgetSize
                                .getResponsiveWidth(0.38, 0.38, 0.38),
                            height: widget.widgetSize
                                .getResponsiveWidth(0.12, 0.12, 0.12),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/icon/g.jpg"),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: InkWell(
                              // onTap: () => showTempMessage(
                              //     widget.deviceDetails, context),
                              onTap: _googleLoading == true
                                  ? null
                                  // : () => showTempMessage(
                                  //     widget.deviceDetails, context),
                                  : () => googleSignInOutHandler(),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: widget.widgetSize
                                        .getResponsiveWidth(0.05, 0.05, 0.05),
                                  ),
                                  child: _googleLoading == true
                                      ? CustomLoading()
                                      : Text(
                                          "Google",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: widget.deviceDetails
                                                  .getTitleFontSize(),
                                              fontWeight: FontWeight.w500),
                                        ),
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
            ],
          ),
        ),
      ),
    );
  }
}
// endregion
