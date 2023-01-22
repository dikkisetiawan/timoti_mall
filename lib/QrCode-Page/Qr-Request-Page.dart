import 'package:flutter/material.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrRequestPage extends StatelessWidget {
  static const routeName = '/QrRequest';

  final String uid;
  final String userfullname;

  QrRequestPage({
    this.uid = '',
    this.userfullname = '',
  });

  // region UI
  Widget getQrCode(
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
    BuildContext context,
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
                "Ask sender to scan QR code",
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),

              /// Spacing
              SizedBox(
                height: _widgetSize.getResponsiveHeight(0.01, 0.01, 0.01),
              ),

              /// Qr Code
              QrImage(
                data: '$uid:$userfullname',
                version: QrVersions.auto,
                size: _widgetSize.getResponsiveWidth(0.5, 0.5, 0.5),
                // gapless: false,
                embeddedImage: AssetImage('assets/app_logo.png'),
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
            ],
          ),
        ),
      ),
    );
  }
  // endregion

  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    var paddingLeftRight = _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05);

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
          "Request Money",
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        shadowColor: Colors.grey,
        elevation: 3,
      ),
      body: SafeArea(
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

    pageContent.add(getQrCode(
      _widgetSize,
      _deviceDetails,
      context,
    ));

    return pageContent;
  }
}
