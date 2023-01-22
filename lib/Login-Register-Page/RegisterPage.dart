import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timoti_project/Custom-UI/Custom-LoadingUI.dart';
import 'package:timoti_project/Custom-UI/Custom-RoundedInputField.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:timoti_project/Core/auth.dart';
import 'package:timoti_project/Functions/CheckEmailProvider.dart';
import 'package:timoti_project/Functions/ConvertToSignInType.dart';
import 'package:timoti_project/Introduction-Page/Introduction-Page.dart';
import 'package:timoti_project/Functions/Messager.dart';
import 'package:timoti_project/Nav.dart';
import 'package:timoti_project/Phone-Auth/PhoneAuthRegister-Step1.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';
import 'package:timoti_project/Screen-Size/ui-utils.dart';
import 'package:timoti_project/enums/Sign-In-Type.dart';
import 'package:timoti_project/enums/User-Sign-In-Method.dart';
import 'package:timoti_project/enums/device-screen-type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = "/Register";

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _cPasswordController = TextEditingController();
  String _emailErrorString = '';
  String _cPasswordString = "";

  bool _fullNameError = false;
  bool _emailError = false;
  bool _passwordError = false;
  bool _confirmPasswordError = false;
  bool _checked = true;
  bool _loading = false;
  String cacheSignInMethod = "CacheSignInMethod";

  @override
  void dispose() {
    super.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cPasswordController.dispose();
  }

  // region UI
  /// First Name, Last name, Email, Password, Confirm Password
  Widget getRegisterUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    SizedBox space = SizedBox(
      height: _widgetSize.getResponsiveWidth(
        0.05,
        0.05,
        0.05,
      ),
    );

    return SizedBox(
      width: _widgetSize.getResponsiveWidth(0.8, 0.8, 0.8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          /// Full Name
          customRoundedBorder(
            _fullNameController,
            "Full Name",
            _fullNameError,
            "Please fill in your full name",
            false,
            _deviceDetails,
            _widgetSize,
            null,
            null,
          ),

          space,

          /// Email
          customRoundedBorder(
            _emailController,
            "Email",
            _emailError,
            _emailErrorString,
            false,
            _deviceDetails,
            _widgetSize,
            null,
            null,
          ),
          space,

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
            null,
          ),
          space,

          /// Confirm Password
          customRoundedBorder(
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
        ],
      ),
    );
  }

  /// Check box
  Widget getCheckBoxUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    FontWeight _fontWeight = FontWeight.normal;

    return Row(
      children: <Widget>[
        /// Checkbox
        Theme(
          data: ThemeData(unselectedWidgetColor: Colors.white),
          child: Checkbox(
            checkColor: Theme.of(context).highlightColor,
            focusColor: Colors.transparent,
            activeColor: Colors.transparent,
            value: _checked,
            onChanged: (value) {
              setState(() {
                _checked = value as bool;

                if (value == true) {
                  _fontWeight = FontWeight.w900;
                } else if (value == false) {
                  _fontWeight = FontWeight.normal;
                }
              });
            },
          ),
        ),

        /// T&C
        SizedBox(
          width: _widgetSize.getResponsiveWidth(0.65, 0.65, 0.65),
          child: Text(
            "By Clicking Sign Up, you agree to our Terms & Conditions and our Privacy Policy.",
            style: TextStyle(
              fontWeight: _fontWeight,
              fontSize: _deviceDetails.getNormalFontSize() - 2,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  /// Sign up button
  Widget getSignUpButtonUI(
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
        onPressed: () => checkEmailProcedure(_deviceDetails),
        child: Text(
          "Sign up".toUpperCase(),
          style: TextStyle(
            fontSize: _deviceDetails.getNormalFontSize(),
            fontWeight: FontWeight.w600,
            color: Theme.of(context).focusColor,
          ),
        ),
      ),
    );
  }
  // endregion

  // region Function
  /// Check Email Exist or not then proceed sign up
  void checkEmailProcedure(DeviceDetails _deviceDetails) {
    setState(() {
      if (validate() == true) {
        /// Checkbox is checked (Agreed T&C)
        if (_checked == true) {
          _loading = true;
          setState(() {});

          checkEmailExistenceResult(
            SignInType.Password,
            _emailController.text,
          ).then((result) {
            _loading = false;
            setState(() {});

            if (result == null) {
              showMessage(
                "Check Email API Error",
                null,
                _deviceDetails,
                context,
              );
            } else {
              /// Email Not Exist
              if (result.emailExist == false) {
                /// Already Login
                if (FirebaseAuth.instance.currentUser != null) {
                  /// Is Guest
                  if (FirebaseAuth.instance.currentUser?.isAnonymous == true) {
                    print("* Guest Sign Up process ...");

                    _loading = true;
                    setState(() {});

                    authService
                        .upgradeWithPassword(
                      _emailController.text,
                      _passwordController.text,
                      _deviceDetails,
                      context,
                      _fullNameController.text,
                    )
                        .then((value) {
                      _loading = false;
                      setState(() {});
                      Navigator.pop(context, true);
                      // if(value == true){
                      //   Navigator.pop(context, true);
                      // }
                      // else{
                      //   print("Register Failed !!");
                      // }
                    });
                  } else {
                    /// Non Guest
                    print("* Non Guest Sign Up process ...");
                    signUp(context, _deviceDetails);
                  }
                }

                /// Non Guest
                else {
                  print("* Non Guest Sign Up process ...");
                  signUp(context, _deviceDetails);
                }
              }

              /// Email Exist (Link Message)
              else {
                /// Ensure result is not phone and no provider error
                if (result.targetProvider != SignInType.Phone &&
                    result.providerExistError == false) {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Theme.of(context).highlightColor,
                        elevation: 10,
                        scrollable: true,
                        title: Text(
                          'We found that you previously logged in with ' +
                              convertSignInTypeToString(result.targetProvider) +
                              "\nDo you want to link your account with password login?",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: _deviceDetails.getNormalFontSize(),
                          ),
                        ),
                        content: Text(
                          'If so, please login your account',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: _deviceDetails.getNormalFontSize(),
                          ),
                        ),
                        actions: [
                          /// Ok
                          TextButton(
                            child: Text(
                              "Ok",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: _deviceDetails.getNormalFontSize(),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context, true),
                          ),

                          /// Cancel
                          TextButton(
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: _deviceDetails.getNormalFontSize(),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context, false),
                          ),
                        ],
                      );
                    },
                  ).then((decision) async {
                    if (decision == null) {
                      return;
                    } else {
                      /// Link Account
                      if (decision == true) {
                        BuildContext dialogContext = context;
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext c_context) {
                            dialogContext = c_context;
                            return Dialog(
                              child: new Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  new CustomLoading(),
                                  new Text("Loading"),
                                ],
                              ),
                            );
                          },
                        );
                        // await authService.loginAndLinkAccount(
                        //   result.targetProvider,
                        //   SignInType.Password,
                        //   _emailController.text,
                        //   _passwordController.text,
                        //   context,
                        // );

                        /// This process pop the loading message
                        Navigator.pop(dialogContext);

                        /// This process return back to login page
                        Navigator.pop(context, true);
                      } else {
                        print('Not Linking');
                      }
                    }
                  });
                }

                /// Account Exist
                else {
                  showMessage(
                    "Account Existed!",
                    null,
                    _deviceDetails,
                    context,
                  );
                }
              }
            }
          });
        }

        /// Checkbox is NOT checked
        else {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                content:
                    Text("Please accept our Terms & Conditions to proceed."),
                actions: [
                  TextButton(
                    child: Text("Ok"),
                    onPressed: () {
                      setState(() {
                        _loading = false;
                        Navigator.of(context).pop();
                      });
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    });
  }

  /// Validate Information
  bool validate() {
    bool temp = false;

    // region Empty Field
    if (_fullNameController.text.isEmpty) {
      _fullNameError = true;
    } else if (_emailController.text.isEmpty) {
      _emailError = true;
      _emailErrorString = "Please fill in your Email";
    } else if (_passwordController.text.isEmpty) {
      _passwordError = true;
    } else if (_cPasswordController.text.isEmpty) {
      _confirmPasswordError = true;
      _cPasswordString = "Please fill in password again";
    }
    // endregion
    else if (EmailValidator.validate(_emailController.text) == false) {
      _emailError = true;
      _emailController.clear();
      _emailErrorString = "Invalid Email Format";
    }
    // region Confirm Password Checking
    else if (_passwordController.text != _cPasswordController.text) {
      _confirmPasswordError = true;
      _cPasswordString = "Password does not match.";
    }
    // endregion

    else {
      _fullNameError = false;
      _emailError = false;
      _passwordError = false;
      _confirmPasswordError = false;
      temp = true;
    }
    return temp;
  }
  // endregion

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
                        padding: EdgeInsets.only(
                          right:
                              _widgetSize.getResponsiveHeight(0.01, 0.01, 0.01),
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
                                child: FittedBox(
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
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: ModalProgressHUD(
        opacity: 0.65,
        color: Theme.of(context).highlightColor,
        child: SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
              minWidth: MediaQuery.of(context).size.width,
            ),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: getPageContent(_deviceDetails, _widgetSize),
              ),
            ),
          ),
        ),
        inAsyncCall: _loading,
        progressIndicator:
            SpinKitFoldingCube(color: Theme.of(context).highlightColor),
      ),
    );
  }

  List<Widget> getPageContent(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    List<Widget> pageContent = [];
    var paddingLeftRight = _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1);
    var mediaQuery = MediaQuery.of(context);

    pageContent.add(
      SizedBox(
        height: _widgetSize.getResponsiveHeight(0.07, 0.07, 0.07),
      ),
    );

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

    /// Check box UI
    pageContent.add(
      Padding(
        padding: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
            ? EdgeInsets.fromLTRB(
                _widgetSize.getResponsiveWidth(0.07, 0.07, 0.07),
                0,
                paddingLeftRight,
                0)
            : EdgeInsets.fromLTRB(
                _widgetSize.getResponsiveWidth(0.08, 0.08, 0.08),
                0,
                paddingLeftRight,
                0),
        child: getCheckBoxUI(_deviceDetails, _widgetSize),
      ),
    );

    /// Spacing
    pageContent.add(SizedBox(
      height: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
    ));

    /// Sign up
    pageContent.add(
      getSignUpButtonUI(_deviceDetails, _widgetSize),
    );

    return pageContent;
  }

  void verification() {
    // region Empty Field
    if (_fullNameController.text.isEmpty) {
      _fullNameError = true;
    } else if (_emailController.text.isEmpty) {
      _emailError = true;
      _emailErrorString = "Please fill in your Email";
    } else if (_passwordController.text.isEmpty) {
      _passwordError = true;
    } else if (_cPasswordController.text.isEmpty) {
      _confirmPasswordError = true;
      _cPasswordString = "Please fill in password again";
    }
    // endregion
    else if (EmailValidator.validate(_emailController.text) == false) {
      _emailError = true;
      _emailController.clear();
      _emailErrorString = "Invalid Email Format";
    }
    // region Confirm Password Checking
    else if (_passwordController.text != _cPasswordController.text) {
      _confirmPasswordError = true;
      _cPasswordString = "Password does not match.";
    }
    // endregion

    else {
      _fullNameError = false;
      _emailError = false;
      _passwordError = false;
      _confirmPasswordError = false;
    }
  }

  /// Login
  Future<void> signIn() async {
    if (this.mounted) {
      _loading = true;
    }

    if (_emailError == false && _passwordError == false) {
      try {
        User user = (await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text))
            .user as User;

        if (this.mounted) {
          _loading = false;
        }

        /// Update user to firestore
        await authService.updateUserData(user);

        /// This process return back to login page
        Navigator.pop(context, true);
      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).highlightColor,
              content: Text(
                "$e",
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
                    if (this.mounted) {
                      _loading = false;
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }

    _loading = false;
  }

  Future<void> signUp(
    BuildContext context,
    DeviceDetails _deviceDetails,
  ) async {
    _loading = true;

    if (_fullNameError == false &&
        _emailError == false &&
        _passwordError == false &&
        _confirmPasswordError == false) {
      if (_checked == false) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text("Please accept our Terms & Conditions to proceed."),
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    setState(() {
                      _loading = false;
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ],
            );
          },
        );
      } else {
        try {
          User user =
              (await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          ))
                  .user as User;

          /// Update user (display name)
          user.updateDisplayName(_fullNameController.text);

          print('Update Successful');

          /// Create User Data
          await authService.createUserDataViaPassword(
              user, _fullNameController.text);
          print('Create Data Successful');

          _loading = false;
          signIn();
        } on PlatformException catch (error) {
          showMessage(
            '',
            error.message,
            _deviceDetails,
            context,
          );
        }
      }
    }

    _loading = false;
  }
}
