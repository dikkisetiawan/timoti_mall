// import 'dart:developer';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '/Account/AppVersion-Page.dart';
import '/Account/PurchaseHistory/Purchase-History-Main.dart';
import '/Account/SettingsPage.dart';
import '/Account/UpdateProfilePage.dart';
import '/Api/CheckEmailExist-Api/Fetch-CheckEmailExist-Api.dart';
import '/Api/CustomerToken-Api/Fetch-GetToken-Api.dart';
// import '/Api/CustomerToken-Api/Fetch-GetToken-Api.dart';
import '/Coming-Soon-Page.dart';
import '/Core/User-Data.dart';
import '/Core/auth.dart';
import '/Data-Class/ComingSoon.dart';
import '/Data-Class/InitialTabArgument.dart';
import '/Login-Register-Page/LoginPage.dart';
import '/Functions/Messager.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';
import '/Screen-Size/ui-utils.dart';
import '/Voucher-Page/Voucher-Main.dart';
import '/Webview/Webview.dart';
import '/enums/device-screen-type.dart';
// import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  ///  To Enable Testing Function
  bool isTesting = false;

  String cacheSignInMethod = "CacheSignInMethod";

  User? firebaseUser = FirebaseAuth.instance.currentUser;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String name = '';
  String profilePicURL = '';
  bool hasGoogleLogin = false;
  bool hasFacebookLogin = false;

  @override
  void initState() {
    if (firebaseUser != null) {
      if (firebaseUser?.isAnonymous == true) {
        name = "Guest";
        if (this.mounted) {
          setState(() {});
        }
        print("*** User is Guest Login");
      } else {
        print("*** Normal Login");

        /// Get User data
        print(firebaseUser!.displayName);
        hasGoogleLogin = authService.userUseGoogle(firebaseUser!);
        hasFacebookLogin = authService.userUseFacebook(firebaseUser!);
        getUserData();
      }
    } else {
      /// Auto Sign in as Guest
      FirebaseAuth.instance.signInAnonymously().then((value) {
        // Do some stuff after login
        firebaseUser = value.user;
        if (firebaseUser != null) {
          print('*** Guest Auto Login Occur!');
        } else {
          print("*** Somehow firebase user is null");
        }
      });
    }

    super.initState();
  }

  void getUserData() async {
    DocumentSnapshot userData =
        await firestore.collection('Customers').doc(firebaseUser!.uid).get();

    if (this.mounted) {
      Map<String, dynamic> data = Map<String, dynamic>();
      data = userData.data() as Map<String, dynamic>;

      name = data["Full_Name"];
      profilePicURL = data["Profile_Pic"];
      setState(() {});
    }
  }

  // region UI
  /// User Icon + Name
  Widget getUserInformationUI(
    BuildContext context,
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
  ) {
    double frameSize = _widgetSize.getResponsiveWidth(0.23, 0.23, 0.23);
    double photoSize = _widgetSize.getResponsiveWidth(0.20, 0.20, 0.20);

    var mediaQuery = MediaQuery.of(context);
    // User user = Provider.of(context);
    // UserData userData = new UserData(firebaseUser);

    return Padding(
      padding: EdgeInsets.only(
          left: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),
      child: SizedBox(
        height: _widgetSize.getResponsiveHeight(0.13, 0.13, 0.13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            /// Default Profile Picture
            if (profilePicURL == '')
              Container(
                width: _widgetSize.getResponsiveWidth(0.2, 0.2, 0.2),
                decoration: BoxDecoration(
                  // borderRadius: BorderRadius.circular(100),
                  // border: Border.all(width: 4, color: Colors.white),
                  image: DecorationImage(
                    image: AssetImage('assets/icon/defaultPic.png'),
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

            /// Actual Profile Picture
            if (profilePicURL != '')
              SizedBox(
                width: frameSize,
                height: frameSize,
                child: Container(
                  width: photoSize,
                  height: photoSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(width: 4, color: Colors.white),
                  ),
                  child: ClipOval(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: CachedNetworkImage(
                        imageUrl: profilePicURL,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

            /// Spacing
            SizedBox(
                width: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                    ? _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)
                    : 0),

            /// User's name Text + Edit Profile
            SizedBox(
              width: _widgetSize.getResponsiveWidth(0.6, 0.6, 0.6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name != '' ? name : 'User',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: _deviceDetails.getTitleFontSize(),
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).primaryColor),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Ink(
                    color: Colors.transparent,
                    child: InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () async {
                        if (FirebaseAuth.instance.currentUser?.isAnonymous ==
                            false) {
                          Navigator.pushNamed(
                                  context, UpdateProfilePage.routeName)
                              .then((value) {
                            getUserData();
                          });
                        } else {
                          showLoginMessage(0, 15, context);
                        }
                      },
                      child: Text(
                        "Edit Profile >",
                        style: TextStyle(
                          fontSize: _deviceDetails.getNormalFontSize(),
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          decoration: TextDecoration.underline,
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
    );
  }

  /// Purchase UI
  Widget getPurchaseUI(
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
  ) {
    var mediaQuery = MediaQuery.of(context);

    /// List View Content
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        /// Purchase History
        Container(
          // height: _widgetSize.getResponsiveHeight(0.08),
          // width: _widgetSize.getResponsiveWidth(1),
          decoration: BoxDecoration(
            color: Theme.of(context).shadowColor,
            border: Border(
              top: BorderSide(
                width: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                    ? 0.6
                    : 3.0,
                color: Theme.of(context).dividerColor,
              ),
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
              "Purchase History",
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize(),
                fontWeight: FontWeight.w400,
                color: Theme.of(context).primaryColor,
              ),
            ),
            onTap: () {
              InitialTabArgument arg = new InitialTabArgument(tabIndex: 0);
              Navigator.pushNamed(context, PurchaseHistoryMain.routeName,
                  arguments: arg);
            },
          ),
        ),

        /// Spacing
        Container(
          height: _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
          width: _widgetSize.getResponsiveWidth(1, 1, 1),
          color: Theme.of(context).shadowColor,
        ),

        /// To Pay / Ship / Receive / Rate
        Container(
          height: _widgetSize.getResponsiveWidth(0.15, 0.15, 0.15),
          width: _widgetSize.getResponsiveWidth(1, 1, 1),
          color: Theme.of(context).shadowColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// To Pay
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    0,
                    0,
                    0,
                    0,
                  ),
                  child: InkWell(
                    onTap: () {
                      InitialTabArgument arg =
                          new InitialTabArgument(tabIndex: 1);
                      Navigator.pushNamed(
                        context,
                        PurchaseHistoryMain.routeName,
                        arguments: arg,
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// Icon
                        Expanded(
                          child: Image(
                            // height: _widgetSize.getResponsiveHeight(0.25),
                            // width: _widgetSize.getResponsiveHeight(0.25),
                            image: AssetImage('assets/icon/Pay.png'),
                            // color: Theme.of(context).shadowColor,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),

                        /// Text
                        Text(
                          "To Pay",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: _deviceDetails.getNormalFontSize() - 2,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// To Ship
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    0,
                    0,
                    0,
                    0,
                  ),
                  child: InkWell(
                    onTap: () {
                      InitialTabArgument arg =
                          new InitialTabArgument(tabIndex: 2);
                      Navigator.pushNamed(
                        context,
                        PurchaseHistoryMain.routeName,
                        arguments: arg,
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// Icon
                        Expanded(
                          child: Image(
                            // height: _widgetSize.getResponsiveHeight(0.25),
                            // width: _widgetSize.getResponsiveHeight(0.25),
                            image: AssetImage('assets/icon/Ship.png'),
                            // color: Theme.of(context).shadowColor,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),

                        /// Text
                        Text(
                          "To Ship",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: _deviceDetails.getNormalFontSize() - 2,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// To Receive
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    0,
                    0,
                    0,
                    0,
                  ),
                  child: InkWell(
                    onTap: () {
                      InitialTabArgument arg =
                          new InitialTabArgument(tabIndex: 3);
                      Navigator.pushNamed(
                        context,
                        PurchaseHistoryMain.routeName,
                        arguments: arg,
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// Icon
                        Expanded(
                          child: Image(
                            // height: _widgetSize.getResponsiveHeight(0.25),
                            // width: _widgetSize.getResponsiveHeight(0.25),
                            image: AssetImage('assets/icon/ReceiveIcon.png'),
                            // color: Theme.of(context).shadowColor,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),

                        /// Text
                        Text(
                          "To Receive",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: _deviceDetails.getNormalFontSize() - 2,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// Completed
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    0,
                    0,
                    0,
                    0,
                  ),
                  child: InkWell(
                    onTap: () {
                      InitialTabArgument arg =
                          new InitialTabArgument(tabIndex: 4);
                      Navigator.pushNamed(
                        context,
                        PurchaseHistoryMain.routeName,
                        arguments: arg,
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// Icon
                        Expanded(
                          child: Image(
                            // height: _widgetSize.getResponsiveHeight(0.25),
                            // width: _widgetSize.getResponsiveHeight(0.25),
                            image: AssetImage('assets/icon/Rate.png'),
                            // color: Theme.of(context).shadowColor,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),

                        /// Text
                        Text(
                          "Completed",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: _deviceDetails.getNormalFontSize() - 2,
                            fontWeight: FontWeight.w400,
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

        /// Spacing
        Container(
          height: _widgetSize.getResponsiveWidth(0.04, 0.04, 0.04),
          width: _widgetSize.getResponsiveWidth(1, 1, 1),
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
        ),
      ],
    );
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  /// Points, Reward, Referral, Settings, Help Center
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
        /// Voucher Button
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).shadowColor,
            border: Border(
              top: BorderSide(
                width: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                    ? 0.6
                    : 3.0,
                color: Theme.of(context).dividerColor,
              ),
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
              "Voucher",
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize(),
                fontWeight: FontWeight.w400,
                color: Theme.of(context).primaryColor,
              ),
            ),
            onTap: () {
              // showMessage(
              //   "",
              //   "Coming Soon",
              //   _deviceDetails,
              //   context,
              // );
              if (FirebaseAuth.instance.currentUser?.isAnonymous == false) {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: VoucherMain(),
                  ),
                );
              } else {
                showLoginMessage(0, 15, context);
              }
            },
          ),
        ),

        /// Points
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
              "Points",
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize(),
                fontWeight: FontWeight.w400,
                color: Theme.of(context).primaryColor,
              ),
            ),
            onTap: () {
              ComingSoonArgument arg =
                  ComingSoonArgument(appbarTitle: "Points");
              Navigator.pushNamed(context, ComingSoonPage.routeName,
                  arguments: arg);
            },
          ),
        ),

        /// Referral
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
              "Referral",
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize(),
                fontWeight: FontWeight.w400,
                color: Theme.of(context).primaryColor,
              ),
            ),
            onTap: () {
              ComingSoonArgument arg =
                  ComingSoonArgument(appbarTitle: "Referral");
              Navigator.pushNamed(context, ComingSoonPage.routeName,
                  arguments: arg);
            },
          ),
        ),

        /// Settings
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
              "Settings",
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize(),
                fontWeight: FontWeight.w400,
                color: Theme.of(context).primaryColor,
              ),
            ),
            onTap: () => showTempMessage(_deviceDetails, context),
            // onTap: () async {
            //   if (FirebaseAuth.instance.currentUser?.isAnonymous == false) {
            //     Navigator.pushNamed(context, SettingsPage.routeName);
            //   } else {
            //     showLoginMessage(0, 15, context);
            //   }
            // },
          ),
        ),

        /// App Version Button
        Container(
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
              "App Version",
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize(),
                fontWeight: FontWeight.w400,
                color: Theme.of(context).primaryColor,
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, AppVersionPage.routeName);
            },
          ),
        ),

        /// About Us Button
        Container(
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
              "About Us",
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize(),
                fontWeight: FontWeight.w400,
                color: Theme.of(context).primaryColor,
              ),
            ),
            onTap: () =>
                launchURL('http://www.timoti.asia/timoti-story', 'About Us'),
          ),
        ),

        /// Privacy Policy Button
        Container(
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
              "Privacy Policy",
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize(),
                fontWeight: FontWeight.w400,
                color: Theme.of(context).primaryColor,
              ),
            ),
            onTap: () =>
                launchURL('http://www.timoti.asia/privacy', 'Privacy Policy'),
          ),
        ),

        /// Terms of Use Button
        Container(
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
              "Terms of Use",
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize(),
                fontWeight: FontWeight.w400,
                color: Theme.of(context).primaryColor,
              ),
            ),
            onTap: () =>
                launchURL('http://www.timoti.asia/term', 'Terms of Use'),
          ),
        ),

        if (isTesting == true)

          /// Get Token Button
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).shadowColor,
              border: Border(
                bottom: BorderSide(
                  width: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                      ? 1.5
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
                "Get Customer Token Test",
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onTap: () {
                firebaseUser!.getIdTokenResult().then((value) {
                  print('** Customer Firebase Token');
                  printWrapped(value.token as String);
                  // log(value.token as String);
                  fetchGetTokenApi(value.token as String).then((value) {
                    if (value.errorMessage == null) {
                      print("Has token !");
                      printWrapped(value.accessToken as String);
                    } else {
                      print("Error Message: " + (value.errorMessage as String));
                    }
                  });
                });
              },
            ),
          ),

        if (isTesting == true)

          /// Get Token Button
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).shadowColor,
              border: Border(
                bottom: BorderSide(
                  width: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                      ? 1.5
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
                "Check Email Existence Test",
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onTap: () {
                if (firebaseUser != null) {
                  if (firebaseUser!.email != null) {
                    fetchCheckEmailApi(firebaseUser?.email as String)
                        .then((value) {
                      if (value.isExist == true) {
                        StringBuffer buffer = new StringBuffer();
                        if (value.provider != null) {
                          int LENGTH = value.provider!.length;
                          for (int i = 0; i < LENGTH; ++i) {
                            buffer.write("\n" + value.provider![i]);
                            if (i == LENGTH - 1) {
                              showMessage(
                                buffer.toString(),
                                null,
                                _deviceDetails,
                                context,
                              );
                            }
                          }
                        } else {
                          showMessage('Somehow no provider in API', null,
                              _deviceDetails, context);
                        }
                      } else {
                        showMessage('This User has no email exist', null,
                            _deviceDetails, context);
                      }
                    }).catchError((error) {
                      showMessage(error.message, null, _deviceDetails, context);
                    });
                  } else {
                    showMessage('This User has no email', null, _deviceDetails,
                        context);
                  }
                }
              },
            ),
          ),

        /// Empty Space
        SizedBox(
          height: _widgetSize.getResponsiveHeight(0.05, 0.05, 0.05),
          width: _widgetSize.getResponsiveWidth(0.9, 0.9, 0.9),
        ),
      ],
    );
  }

  /// Sign Out button UI
  Widget signOutButton(
    BuildContext context,
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
  ) {
    return Center(
      child: SizedBox(
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
          onPressed: () => signInOutHandler(),
          child: Center(
            child: Text(
              FirebaseAuth.instance.currentUser!.isAnonymous == false
                  ? "Sign Out"
                  : "Sign In / Up",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: _deviceDetails.getNormalFontSize(),
                color: Theme.of(context).focusColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Handle Sign In / Out
  Future<void> signInOutHandler() async {
    // Sign Out
    if (FirebaseAuth.instance.currentUser!.isAnonymous == false) {
      if (hasGoogleLogin == true) {
        print("is Google Login ready to sign out");
        await authService.googleSignOut();
      }
      // if (hasFacebookLogin == true) {
      //   print("is Facebook Login ready to sign out");
      //   await authService.facebookSignOut();
      // }
      await authService.signOut();

      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: LoginScreen(
            singlePage: false,
            returnIndex: 0,
          ),
        ),
      );
    }
    // Sign In
    else {
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: LoginScreen(
            singlePage: false,
            returnIndex: 0,
          ),
        ),
      );
    }
  }

  Future<void> launchURL(
    String url,
    String title,
  ) async {
    if (kIsWeb) {
      if (await canLaunch(url)) {
        await launch(
          url,
          forceSafariVC: true,
          forceWebView: true,
          // webOnlyWindowName: '_self',
          webOnlyWindowName: '_blank',
        );
      } else {
        throw 'Could not launch $url';
      }
    } else {
      await Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: WebViewApp(
            targetURL: url,
            title: title,
          ),
        ),
      );
    }
  }

  // endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Scaffold(
      body: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
            maxWidth: MediaQuery.of(context).size.width,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: getPageContent(context, _deviceDetails, _widgetSize),
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

    /// Spacing
    SizedBox _spacing = SizedBox(
      height: _widgetSize.getResponsiveHeight(0.025, 0.025, 0.025),
    );
    SizedBox _spacing2 = SizedBox(
      height: _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
    );
    pageContent.add(SizedBox(
      height: _widgetSize.getResponsiveHeight(0.05, 0.05, 0.05),
    ));
    pageContent.add(getUserInformationUI(context, _widgetSize, _deviceDetails));
    pageContent.add(_spacing);
    pageContent.add(getPurchaseUI(_widgetSize, _deviceDetails));
    pageContent.add(_spacing2);
    pageContent.add(getContentUI(_widgetSize, _deviceDetails, context));

    /// Sign Out
    if (FirebaseAuth.instance.currentUser != null) {
      pageContent.add(signOutButton(context, _widgetSize, _deviceDetails));
    }

    pageContent.add(SizedBox(
      height: _widgetSize.getResponsiveHeight(0.05, 0.05, 0.05),
    ));

    return pageContent;
  }
}
