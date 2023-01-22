import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:timoti_project/Functions/Messager.dart';
import 'package:timoti_project/Home/HomePage.dart';
import 'package:timoti_project/Home/Search/SearchingPage.dart';
import 'package:timoti_project/Nav.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';
import 'package:timoti_project/Screen-Size/ui-utils.dart';
import 'package:timoti_project/WebWidget/WebDrawer.dart';
import 'package:timoti_project/enums/device-screen-type.dart';

class WebAppbar extends StatelessWidget with PreferredSizeWidget {
  final BottomAppBarState bottomAppBarState;

  const WebAppbar({Key? key, required this.bottomAppBarState})
      : super(key: key);

  Widget getNavigationUI(
    BuildContext context,
    DeviceDetails _deviceDetails,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        /// Home
        Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: InkWell(
            onTap: () {
              //showLoginMessage(0, 15, context);

              Navigator.popUntil(context, ModalRoute.withName('/'));

              // Navigator.push(
              //   context,
              //   PageTransition(
              //     type: PageTransitionType.rightToLeft,
              //     child: HomePage(
              //       bottomAppBarState: bottomAppBarState,
              //     ),
              //   ),
              // );
            },
            child: Text(
              'Home'.toUpperCase(),
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize() - 5,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),

        /// About
        Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: InkWell(
            onTap: () {
              showLoginMessage(0, 15, context);
            },
            child: Text(
              'About'.toUpperCase(),
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize() - 5,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),

        /// Product
        Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: InkWell(
            onTap: () {
              showLoginMessage(0, 15, context);

              // Navigator.push(
              //   context,
              //   PageTransition(
              //     type: PageTransitionType.rightToLeft,
              //     child: HomePage(
              //       bottomAppBarState: bottomAppBarState,
              //     ),
              //   ),
              // );
            },
            child: Text(
              'Product'.toUpperCase(),
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize() - 5,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),

        /// News & Events
        Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: InkWell(
            onTap: () {
              showLoginMessage(0, 15, context);
            },
            child: Text(
              'News & Events'.toUpperCase(),
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize() - 5,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),

        /// Contact
        InkWell(
          onTap: () {
            showLoginMessage(0, 15, context);
          },
          child: Text(
            'Contact'.toUpperCase(),
            style: TextStyle(
              fontSize: _deviceDetails.getNormalFontSize() - 5,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget getSearchLoginSignUpUI(
    BuildContext context,
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        /// Search Box
        Container(
          width: _widgetSize.getResponsiveWidth(0.3, 0.2, 0.2),
          height: 30,
          color: Theme.of(context).cardColor,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: SearchingPage(
                    userPosition: null,
                    bottomAppBarState: bottomAppBarState,
                  ),
                ),
              );
            },

            /// Search bar
            child: Container(
              // width: _widgetSize.getResponsiveWidth(0.90, 0.90, 0.90),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight,
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              padding: EdgeInsets.only(left: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AutoSizeText(
                  "Search your products here",
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: 20),

        /// Login /Sign Up
        loginSignUpUI(context, _deviceDetails, _widgetSize),
      ],
    );
  }

  Widget loginSignUpUI(
    BuildContext context,
    DeviceDetails deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return Row(
      children: [
        /// Sign In or Register
        Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: InkWell(
            onTap: () {
              print("Sign In or Register");
            },
            child: Text(
              'Login / Sign Up'.toUpperCase(),
              style: TextStyle(
                fontSize: deviceDetails.getNormalFontSize() - 5,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),

        /// Profile
        Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: InkWell(
            onTap: () {
              print("Profile");
            },
            child: Icon(
              Icons.account_circle_outlined,
              color: Colors.black,
              size: _widgetSize.getResponsiveWidth(
                0.02,
                0.02,
                0.02,
              ),
            ),
          ),
        ),

        /// Favourite
        Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: InkWell(
              onTap: () {
                print("Favourite");
              },
              child: Icon(
                Icons.favorite_border_outlined,
                color: Colors.black,
                size: _widgetSize.getResponsiveWidth(
                  0.02,
                  0.02,
                  0.02,
                ),
              )),
        ),

        /// Cart
        InkWell(
          onTap: () {
            print("Cart");
          },
          child: Icon(
            Icons.shopping_bag_outlined,
            color: Colors.black,
            size: _widgetSize.getResponsiveWidth(
              0.02,
              0.02,
              0.02,
            ),
          ),
        ),
        // cartUI(
        //   context,
        //   deviceDetails,
        //   _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
        //   0,
        // ),
      ],
    );
  }

  Widget cartUI(
    BuildContext context,
    DeviceDetails deviceDetails,
    double iconValue,
    int cartQuantity,
  ) {
    return InkWell(
      onTap: () {
        print("Cart");
      },
      child: Container(
        width: iconValue + 30,
        height: iconValue + 12,
        child: Stack(
          children: <Widget>[
            Align(
              // alignment: Alignment.bottomCenter,
              child: Icon(
                Icons.shopping_bag_outlined,
                color: Colors.black,
                size: iconValue,
              ),
            ),

            /// Cart Quantity
            if (cartQuantity > 0 && cartQuantity < 100)
              Positioned(
                right: 0,
                // bottom: 5,
                child: Material(
                  elevation: 20,
                  shadowColor: Colors.black,
                  borderRadius: BorderRadius.circular(6),
                  child: new Container(
                    padding: EdgeInsets.all(1),
                    decoration: new BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 1.2,
                      ),
                      color: Theme.of(context).backgroundColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(2.0, 0, 2, 0),
                      child: Text(
                        '${cartQuantity.toString()}',
                        // '${cartQuantity.toString()}',
                        style: new TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: deviceDetails.getNormalFontSize(),
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            if (cartQuantity >= 100)
              Positioned(
                right: 0,
                // bottom: 5,
                child: Material(
                  elevation: 20,
                  shadowColor: Colors.black,
                  borderRadius: BorderRadius.circular(6),
                  child: new Container(
                    padding: EdgeInsets.all(1),
                    decoration: new BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 1.2,
                      ),
                      color: Theme.of(context).backgroundColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(2.0, 0, 2, 0),
                      child: Text(
                        "99+",
                        style: new TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: deviceDetails.getNormalFontSize(),
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    var mediaQuery = MediaQuery.of(context);

    return SafeArea(
      child: Container(
        color: getDeviceType(mediaQuery) != DeviceScreenType.Desktop ? Theme.of(context).cardColor : Colors.white,
        height: _widgetSize.getResponsiveHeight(0.1, 0.12, 0.12),
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          _widgetSize.getResponsiveWidth(0.02, 0.05, 0.05),
          20,
          _widgetSize.getResponsiveWidth(0.02, 0.05, 0.05),
          20,
        ),
        child: getDeviceType(mediaQuery) == DeviceScreenType.Desktop
            ?

            /// Desktop
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Title
                  SizedBox(
                    width: _widgetSize.getResponsiveWidth(0.15, 0.15, 0.15),
                    child: Center(
                      child: InkWell(
                        onTap: () {
                          Navigator.popUntil(context, ModalRoute.withName('/'));
                        },
                        child:Image.asset('assets/icon/logo.png'),
                      ),
                    ),
                  ),

                  /// Search Box + Navigation
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      /// Search box + Login Sign Up
                      Expanded(
                        child: getSearchLoginSignUpUI(
                          context,
                          _deviceDetails,
                          _widgetSize,
                        ),
                      ),
                      SizedBox(height: 10),

                      /// Navigation Menu
                      Expanded(
                        child: getNavigationUI(
                          context,
                          _deviceDetails,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            :

            /// Mobile + Tablet
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Menu
                  Container(
                    child: IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: Colors.black,
                        size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                      ),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      tooltip: MaterialLocalizations.of(context)
                          .openAppDrawerTooltip,
                    ),
                  ),

                  /// Login Sign Up UI
                  loginSignUpUI(context, _deviceDetails, _widgetSize),
                ],
              ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
