import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/Account/ChangeEmailPage.dart';
import '/Account/ChangePasswordPage.dart';
import '/Account/ChangePhoneNo/ChangePhoneNumber-Step1.dart';
import '/Account/LinkEmail.dart';
import '/Account/LinkPhone/LinkPhone-Step1.dart';
import '/Core/auth.dart';
import '/Custom-UI/Custom-LoadingUI.dart';
import '/Functions/Messager.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';
import '/Screen-Size/ui-utils.dart';
import '/enums/device-screen-type.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = '/SettingsPage';

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String cacheSignInMethod = "CacheSignInMethod";

  User firebaseUser = FirebaseAuth.instance.currentUser as User;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool hasPasswordLogin = false;
  bool hasPhoneLogin = false;
  bool hasGoogleLogin = false;
  bool hasFacebookLogin = false;
  bool googleLoading = false;
  bool facebookLoading = false;

  @override
  void initState() {
    googleLoading = false;
    facebookLoading = false;

    print(firebaseUser.displayName);

    hasPasswordLogin = authService.userUsePassword(firebaseUser);
    hasPhoneLogin = authService.userUsePhone(firebaseUser);
    hasGoogleLogin = authService.userUseGoogle(firebaseUser);
    hasFacebookLogin = authService.userUseFacebook(firebaseUser);

    if (this.mounted) {
      setState(() {});
    }

    super.initState();
  }

  /// Show Snackbar below
  void showSnackBar(String textData) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(textData),
      duration: const Duration(seconds: 1),
    ));
  }

  // region UI
  /// Link, Change Email, Password, Phone Number
  Widget getContentUI(
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
    BuildContext context,
  ) {
    var mediaQuery = MediaQuery.of(context);

    /// List View Content
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        /// Show Link Phone if false
        if (hasPhoneLogin == false)
          Container(
            // height: _widgetSize.getResponsiveHeight(0.08),
            // width: _widgetSize.getResponsiveWidth(1),
            decoration: BoxDecoration(
              color: Theme.of(context).shadowColor,
              border: Border(
                bottom: BorderSide(
                  width: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                      ? 0.6
                      : 3.0,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.fromLTRB(
                _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                0,
                _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                0,
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColor,
                size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
              ),
              title: Text(
                "Link Phone Number",
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onTap: () {
                // Navigator.pushNamed(context, ChangeEmail.routeName);
                Navigator.pushNamed(context, LinkPhoneStepOne.routeName);
              },
            ),
          ),

        /// Show Change Phone No if true
        if (hasPhoneLogin == true)
          Container(
            // height: _widgetSize.getResponsiveHeight(0.08),
            // width: _widgetSize.getResponsiveWidth(1),
            decoration: BoxDecoration(
              color: Theme.of(context).shadowColor,
              border: Border(
                bottom: BorderSide(
                  width: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                      ? 0.6
                      : 3.0,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.fromLTRB(
                _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                0,
                _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                0,
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColor,
                size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
              ),
              title: Text(
                "Change Phone Number",
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onTap: () {
                showTempMessage(_deviceDetails, context);
                // Navigator.pushNamed(
                //     context, ChangePhoneNumberStepOne.routeName);
              },
            ),
          ),

        /// Change Email Button
        if (hasPasswordLogin == true)
          Container(
            // height: _widgetSize.getResponsiveHeight(0.08),
            // width: _widgetSize.getResponsiveWidth(1),
            decoration: BoxDecoration(
              color: Theme.of(context).shadowColor,
              border: Border(
                bottom: BorderSide(
                  width: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                      ? 0.6
                      : 3.0,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.fromLTRB(
                _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                0,
                _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                0,
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColor,
                size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
              ),
              title: Text(
                "Change Email",
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, ChangeEmail.routeName);
              },
            ),
          ),

        /// Change Password Button
        if (hasPasswordLogin == true)
          Container(
            // height: _widgetSize.getResponsiveHeight(0.08),
            // width: _widgetSize.getResponsiveWidth(1),
            decoration: BoxDecoration(
              color: Theme.of(context).shadowColor,
              border: Border(
                bottom: BorderSide(
                  width: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                      ? 0.6
                      : 3.0,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.fromLTRB(
                _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                0,
                _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                0,
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColor,
                size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
              ),
              title: Text(
                "Change Password",
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, ChangePassword.routeName);
              },
            ),
          ),

        /// Check use has password login or not
        if (hasPasswordLogin == false)
          Container(
            // height: _widgetSize.getResponsiveHeight(0.08),
            // width: _widgetSize.getResponsiveWidth(1),
            decoration: BoxDecoration(
              color: Theme.of(context).shadowColor,
              border: Border(
                bottom: BorderSide(
                  width: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                      ? 0.6
                      : 3.0,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.fromLTRB(
                _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                0,
                _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                0,
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColor,
                size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
              ),
              title: Text(
                "Link Account With Password",
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, LinkEmail.routeName);
              },
            ),
          ),

        /// Check use has Google login or not
        if (hasGoogleLogin == false)
          Container(
            // height: _widgetSize.getResponsiveHeight(0.08),
            // width: _widgetSize.getResponsiveWidth(1),
            decoration: BoxDecoration(
              color: Theme.of(context).shadowColor,
              border: Border(
                bottom: BorderSide(
                  width: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                      ? 0.6
                      : 3.0,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.fromLTRB(
                _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                0,
                _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                0,
              ),
              trailing: googleLoading == true
                  ? CustomLoading()
                  : Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).primaryColor,
                      size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    ),
              title: Text(
                "Link Account With Google",
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onTap: googleLoading == true
                  ? null
                  : () {
                      if (firebaseUser != null) {
                        if (this.mounted) {
                          googleLoading = true;
                          setState(() {});
                        }
                        authService
                            .linkGoogleAccount(firebaseUser)
                            .then((value) {
                          if (this.mounted) {
                            googleLoading = false;
                            setState(() {});
                          }

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor:
                                    Theme.of(context).highlightColor,
                                content: Text(
                                  "Successfully Linked Account with Google \nYou can now sign in with Google",
                                  style: TextStyle(
                                    color: Theme.of(context).backgroundColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: Text("Ok",
                                        style: TextStyle(
                                          color:
                                              Theme.of(context).backgroundColor,
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
                            googleLoading = false;
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
                    },
            ),
          ),

        /// Check use has Facebook login or not
        if (hasFacebookLogin == false)
          Container(
            // height: _widgetSize.getResponsiveHeight(0.08),
            // width: _widgetSize.getResponsiveWidth(1),
            decoration: BoxDecoration(
              color: Theme.of(context).shadowColor,
              border: Border(
                bottom: BorderSide(
                  width: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                      ? 0.6
                      : 3.0,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.fromLTRB(
                _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                0,
                _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                0,
              ),
              trailing: facebookLoading == true
                  ? CustomLoading()
                  : Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).primaryColor,
                      size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    ),
              title: Text(
                "Link Account With Facebook",
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onTap: () {},

              //  facebookLoading == true
              //     ? null
              //     : () {
              //         if (firebaseUser != null) {
              //           if (this.mounted) {
              //             facebookLoading = true;
              //             setState(() {});
              //           }
              //           authService
              //               .linkFacebookAccount(firebaseUser)
              //               .then((value) {
              //             if (this.mounted) {
              //               facebookLoading = false;
              //               setState(() {});
              //             }

              //             showDialog(
              //               context: context,
              //               builder: (BuildContext context) {
              //                 return AlertDialog(
              //                   backgroundColor:
              //                       Theme.of(context).highlightColor,
              //                   content: Text(
              //                     "Successfully Linked Account with Facebook \nYou can now sign in with Facebook",
              //                     style: TextStyle(
              //                       color: Theme.of(context).backgroundColor,
              //                       fontWeight: FontWeight.w600,
              //                     ),
              //                   ),
              //                   actions: [
              //                     TextButton(
              //                       child: Text("Ok",
              //                           style: TextStyle(
              //                             color:
              //                                 Theme.of(context).backgroundColor,
              //                             fontWeight: FontWeight.w600,
              //                           )),
              //                       onPressed: () {
              //                         int count = 0;
              //                         Navigator.popUntil(context, (route) {
              //                           return count++ == 2;
              //                         });
              //                       },
              //                     ),
              //                   ],
              //                 );
              //               },
              //             );
              //           }).catchError((error) {
              //             if (this.mounted) {
              //               facebookLoading = false;
              //               setState(() {});
              //             }
              //             showMessage(
              //               '',
              //               error.message,
              //               _deviceDetails,
              //               context,
              //             );
              //           });
              //         }
              //       },
            ),
          ),

        /// Show All Provider
        // Container(
        //   height: _widgetSize.getResponsiveHeight(0.08, 0.08, 0.08),
        //   width: _widgetSize.getResponsiveWidth(1, 1, 1),
        //   decoration: BoxDecoration(
        //     color: Theme.of(context).shadowColor,
        //     border: Border(
        //       bottom: BorderSide(
        //         width: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
        //             ? 1.5
        //             : 3.0,
        //         color: Theme.of(context).dividerColor,
        //       ),
        //     ),
        //   ),
        //   child: ListTile(
        //     trailing: Icon(
        //       Icons.arrow_forward_ios,
        //       color: Theme.of(context).primaryColor,
        //       size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        //     ),
        //     title: Text(
        //       "Check All Provider",
        //       style: TextStyle(
        //         fontSize: _deviceDetails.getNormalFontSize(),
        //         fontWeight: FontWeight.w600,
        //         color: Theme.of(context).primaryColor,
        //       ),
        //     ),
        //     onTap: () {
        //       List<UserInfo> userInfo = firebaseUser.providerData;
        //       print(userInfo.length.toString());
        //       StringBuffer buffer = new StringBuffer();
        //       for (int i = 0; i < userInfo.length; ++i) {
        //         buffer.write("\n" + userInfo[i].providerId);
        //       }
        //       showMessage('', buffer.toString(), _deviceDetails,  context,);
        //     },
        //   ),
        // ),
      ],
    );
  }

  PreferredSize _getCustomAppBar(
    String title,
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
  ) {
    var mediaQuery = MediaQuery.of(context);

    return PreferredSize(
      preferredSize: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
          ? Size.fromHeight(55.0)
          : Size.fromHeight(80.0),
      child: Material(
        elevation: 8,
        shadowColor: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  decoration:
                      BoxDecoration(color: Theme.of(context).backgroundColor),
                ),
                SafeArea(
                  minimum: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                      ? EdgeInsets.fromLTRB(
                          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                          0,
                          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                          0,
                        )
                      : EdgeInsets.fromLTRB(
                          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                          0,
                          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                          0,
                        ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Empty Box
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back_ios_sharp,
                          color: Theme.of(context).primaryColor,
                          size:
                              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                        ),
                      ),

                      /// Title
                      SizedBox(
                        width:
                            getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                                ? _widgetSize.getResponsiveWidth(0.6, 0.6, 0.6)
                                : _widgetSize.getResponsiveWidth(0.5, 0.5, 0.5),
                        child: Center(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: _deviceDetails.getTitleFontSize(),
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      /// Empty
                      SizedBox(
                        width: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Scaffold(
      appBar: _getCustomAppBar("Settings", _widgetSize, _deviceDetails),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: getPageContent(
                context,
                _deviceDetails,
                _widgetSize,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getPageContent(
    BuildContext context,
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    List<Widget> pageContent = [];

    /// Spacing
    SizedBox _spacing = SizedBox(
      height: _widgetSize.getResponsiveHeight(0.025, 0.025, 0.025),
    );
    pageContent.add(_spacing);
    pageContent.add(Padding(
      padding: EdgeInsets.fromLTRB(
        _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        0,
        0,
        _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
      ),
      child: Text(
        "Security",
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w600,
          fontSize: _deviceDetails.getNormalFontSize(),
        ),
      ),
    ));

    pageContent.add(getContentUI(_widgetSize, _deviceDetails, context));
    pageContent.add(SizedBox(
      height: _widgetSize.getResponsiveHeight(0.05, 0.05, 0.05),
    ));

    return pageContent;
  }
}
