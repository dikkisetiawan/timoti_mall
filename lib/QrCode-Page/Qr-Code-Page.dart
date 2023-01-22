import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';
import 'package:timoti_project/Screen-Size/ui-utils.dart';
import 'package:timoti_project/enums/device-screen-type.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodePage extends StatefulWidget {
  static const routeName = '/QrCode';
  @override
  State<StatefulWidget> createState() {
    return _QrCodePageState();
  }
}

class _QrCodePageState extends State<QrCodePage> {
  int currentSite = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // region UI
  /// Custom App bar
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
        elevation: 4,
        shadowColor: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  color: Theme.of(context).backgroundColor,
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
                    children: <Widget>[
                      /// Back Button
                      SizedBox(
                        width: getDeviceType(mediaQuery) ==
                                DeviceScreenType.Mobile
                            ? _widgetSize.getResponsiveWidth(0.06, 0.06, 0.06)
                            : _widgetSize.getResponsiveWidth(0.04, 0.04, 0.04),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                              onTap: () {
                                setState(() {
                                  Navigator.pop(context);
                                });
                              },
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: Theme.of(context).primaryColor,
                                ),
                              )),
                        ),
                      ),

                      /// Title Text
                      SizedBox(
                        width:
                            getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                                ? _widgetSize.getResponsiveWidth(0.6, 0.6, 0.6)
                                : _widgetSize.getResponsiveWidth(0.5, 0.5, 0.5),
                        height: 200,
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

                      /// Spacing
                      SizedBox(
                        width: getDeviceType(mediaQuery) ==
                                DeviceScreenType.Mobile
                            ? _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)
                            : _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
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

  Widget getQrCode(
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
    QrCodePageArgument details,
  ) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          color: Colors.white,
          width: _widgetSize.getResponsiveWidth(0.8, 0.8, 0.8),
          height: _widgetSize.getResponsiveWidth(0.8, 0.8, 0.8),
          padding: EdgeInsets.fromLTRB(
            _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
            _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
            _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
            _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Title
              Text(
                "This is your eWallet QR code",
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).backgroundColor,
                  fontWeight: FontWeight.bold,
                ),
              ),

              /// Spacing
              SizedBox(
                height: _widgetSize.getResponsiveHeight(0.01, 0.01, 0.01),
              ),

              /// Qr Code
              if (details.link != null)
                QrImage(
                  data: details.link,
                  version: QrVersions.auto,
                  size: _widgetSize.getResponsiveWidth(0.4, 0.4, 0.4),
                  // gapless: false,
                  embeddedImage: AssetImage('assets/icon/logo.png'),
                  embeddedImageStyle: QrEmbeddedImageStyle(
                    size: Size(
                      _widgetSize.getResponsiveHeight(0.05, 0.05, 0.05),
                      _widgetSize.getResponsiveHeight(0.05, 0.05, 0.05),
                    ),
                  ),
                ),

              /// Spacing
              SizedBox(
                height: _widgetSize.getResponsiveHeight(0.01, 0.01, 0.01),
              ),

              if (details.link != null)
                FittedBox(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    direction: Axis.horizontal,
                    children: [
                      /// The link
                      InkWell(
                        onTap: () {
                          Clipboard.setData(
                                  new ClipboardData(text: details.link))
                              .then((value) => showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                          "Success",
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .highlightColor,
                                          ),
                                        ),
                                        content: Text(
                                          'Link has been copied to clipboard',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .highlightColor,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            child: Text(
                                              "Ok",
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .accentColor,
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                Navigator.pop(context);
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ));
                        },
                        child: Text(
                          "eWallet Balance: RM 0.00",
                          // overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: _deviceDetails.getNormalFontSize() - 2,
                            color: Theme.of(context).backgroundColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    var paddingLeftRight = _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05);
    final QrCodePageArgument details =
        ModalRoute.of(context)?.settings.arguments as QrCodePageArgument;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      // resizeToAvoidBottomPadding: false,
      appBar: _getCustomAppBar(
        "QR Code",
        _widgetSize,
        _deviceDetails,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green,
              Colors.green,
              Theme.of(context).accentColor,
              // Theme.of(context).accentColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: getPageContent(
                context,
                _deviceDetails,
                _widgetSize,
                details,
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
    QrCodePageArgument details,
  ) {
    List<Widget> pageContent = [];

    pageContent.add(getQrCode(_widgetSize, _deviceDetails, details));

    return pageContent;
  }
}

class QrCodePageArgument {
  String link;

  QrCodePageArgument({required this.link});
}
