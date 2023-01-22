import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:timoti_project/Nav.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';
import 'package:timoti_project/Screen-Size/ui-utils.dart';
import 'package:timoti_project/enums/device-screen-type.dart';

class IntroductionPage extends StatefulWidget {
  static const routeName = '/Introduction-Page';

  @override
  _IntroductionPageState createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  // final introKey = GlobalKey<IntroductionScreenState>();

  @override
  void initState() {
    super.initState();
  }

  // region UI
  Widget getMainIcon(
    WidgetSizeCalculation _widgetSize,
    double logoSize,
    double paddingTopValue,
    double paddingDownValue,
    String path,
  ) {
    var mediaQuery = MediaQuery.of(context);

    var paddingTop = _widgetSize.getResponsiveHeight(
        paddingTopValue, paddingTopValue, paddingTopValue);
    var paddingDown = _widgetSize.getResponsiveHeight(
        paddingDownValue, paddingDownValue, paddingDownValue);

    return Center(
      child: Padding(
        padding: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
            ? EdgeInsets.fromLTRB(
                0,
                paddingTop,
                0,
                paddingDown,
              )
            : EdgeInsets.fromLTRB(
                0,
                paddingTop,
                0,
                paddingDown,
              ),
        child: SizedBox(
          width: _widgetSize.getResponsiveWidth(logoSize, logoSize, logoSize),
          child: Image.asset(path),
        ),
      ),
    );
  }

  Widget getSpecialIcon(
    WidgetSizeCalculation _widgetSize,
    double logoSize,
    double paddingTopValue,
    double paddingDownValue,
    String path,
  ) {
    var mediaQuery = MediaQuery.of(context);

    var paddingTop = _widgetSize.getResponsiveHeight(
        paddingTopValue, paddingTopValue, paddingTopValue);
    var paddingDown = _widgetSize.getResponsiveHeight(
        paddingDownValue, paddingDownValue, paddingDownValue);

    return Center(
      child: Padding(
        padding: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
            ? EdgeInsets.fromLTRB(
                0,
                paddingTop,
                0,
                paddingDown,
              )
            : EdgeInsets.fromLTRB(
                0,
                paddingTop,
                0,
                paddingDown,
              ),
        child: SizedBox(
          width: _widgetSize.getResponsiveWidth(logoSize, logoSize, logoSize),
          child: Image.asset(path),
        ),
      ),
    );
  }
  // endregion

  // region Functions

  void _onIntroEnd(context) {
    Navigator.popAndPushNamed(
      context,
      Nav.routeName,
      // arguments: navBarGlobalKey,
    );
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    TextStyle bodyStyle = TextStyle(
      fontSize: _deviceDetails.getNormalFontSize(),
      color: Theme.of(context).primaryColor,
    );
    PageDecoration pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: _deviceDetails.getTitleFontSize(),
        fontWeight: FontWeight.w700,
        color: Theme.of(context).primaryColor,
      ),
      bodyTextStyle: bodyStyle,

      /// Primary Color
      pageColor: Theme.of(context).backgroundColor,
      imagePadding: EdgeInsets.zero,
    );

    return SafeArea(
      child: IntroductionScreen(
        // key: introKey,
        pages: [
          /// Intro 1
          PageViewModel(
            title: "",
            bodyWidget: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                getMainIcon(
                    _widgetSize, 0.5, 0.15, 0.1, "assets/icon/logo.png"),
                Text(
                  "Welcome to our whole new app!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w400,
                    fontSize: _deviceDetails.getTitleFontSize() + 5,
                  ),
                ),
              ],
            ),
            decoration: pageDecoration,
          ),

          /// Intro 2
          PageViewModel(
            title: "",
            bodyWidget: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Easy Navigation",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w400,
                    fontSize: _deviceDetails.getTitleFontSize() + 5,
                  ),
                ),
                getSpecialIcon(
                  _widgetSize,
                  0.6,
                  0.1,
                  0,
                  "assets/icon/intro2.png",
                ),
              ],
            ),
            decoration: pageDecoration,
          ),

          /// Intro 3
          PageViewModel(
            title: "",
            bodyWidget: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Experience the E-Wallet transactions safely and securely",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w400,
                    fontSize: _deviceDetails.getTitleFontSize() + 5,
                  ),
                ),
                getSpecialIcon(
                  _widgetSize,
                  0.6,
                  0.1,
                  0,
                  "assets/icon/intro3.png",
                ),
              ],
            ),
            decoration: pageDecoration,
          ),
        ],
        onDone: () => _onIntroEnd(context),
        //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
        showSkipButton: true,

        nextFlex: 0,
        globalBackgroundColor: Theme.of(context).highlightColor,
        skip: Text(
          'Skip',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: _deviceDetails.getNormalFontSize(),
            decoration: TextDecoration.underline,
          ),
        ),
        next: Icon(
          Icons.arrow_forward,
          color: Theme.of(context).primaryColor,
          size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        ),
        done: Text(
          'Done',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: _deviceDetails.getNormalFontSize(),
            decoration: TextDecoration.underline,
          ),
        ),
        dotsDecorator: DotsDecorator(
          size: Size(_widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
              _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03)),
          color: Colors.white,
          activeSize: Size(_widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
              _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03)),
          activeColor: Colors.black,
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
      ),
    );
  }
}
