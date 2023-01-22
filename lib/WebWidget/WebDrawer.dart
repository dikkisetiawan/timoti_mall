import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:timoti_project/Functions/Messager.dart';
import 'package:timoti_project/Home/HomePage.dart';
import 'package:timoti_project/Nav.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';
import 'package:timoti_project/Screen-Size/ui-utils.dart';
import 'package:timoti_project/enums/device-screen-type.dart';

class WebDrawer extends StatelessWidget {
  final BottomAppBarState bottomAppBarState;

  const WebDrawer({Key? key, required this.bottomAppBarState})
      : super(key: key);

  Widget getNavigationUI(
    BuildContext context,
    DeviceDetails _deviceDetails,
  ) {
    return Row(
      children: [
        /// Home
        Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: HomePage(
                    bottomAppBarState: bottomAppBarState,
                  ),
                ),
              );
            },
            child: Text(
              'Home'.toUpperCase(),
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize() - 3,
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
                fontSize: _deviceDetails.getNormalFontSize() - 3,
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
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: HomePage(
                    bottomAppBarState: bottomAppBarState,
                  ),
                ),
              );
            },
            child: Text(
              'Product'.toUpperCase(),
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize() - 3,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),

        /// News & Event
        Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: InkWell(
            onTap: () {
              showLoginMessage(0, 15, context);
            },
            child: Text(
              'News & Event'.toUpperCase(),
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize() - 3,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),

        /// Context
        Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: InkWell(
            onTap: () {
              showLoginMessage(0, 15, context);
            },
            child: Text(
              'Contact'.toUpperCase(),
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize() - 3,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Theme.of(context).cardColor,
        //other styles
      ),
      child: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              // Container(
              //   color: Theme.of(context).highlightColor,
              //   child: DrawerHeader(
              //     child: Align(
              //       alignment: Alignment.centerLeft,
              //       child: Text(
              //         "Timoti",
              //         style: TextStyle(
              //           fontSize: 30,
              //           color: Theme.of(context).backgroundColor,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              Column(
                children: <Widget>[
                  /// Home
                  ListTile(
                    title: Text(
                      'Home',
                      style: TextStyle(
                        fontSize: _deviceDetails.getNormalFontSize() - 3,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),

                  /// Product
                  ListTile(
                    title: Text(
                      'Product',
                      style: TextStyle(
                        fontSize: _deviceDetails.getNormalFontSize() - 3,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onTap: () async {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: HomePage(
                            bottomAppBarState: bottomAppBarState,
                          ),
                        ),
                      );
                    },
                  ),

                  /// Help
                  ListTile(
                    title: Text(
                      'Help',
                      style: TextStyle(
                        fontSize: _deviceDetails.getNormalFontSize() - 3,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                    },
                  ),

                  /// Our Store
                  ListTile(
                    title: Text(
                      'Our Store',
                      style: TextStyle(
                        fontSize: _deviceDetails.getNormalFontSize() - 3,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ), // Populate the Drawer in the next step.
      ),
    );
  }
}
