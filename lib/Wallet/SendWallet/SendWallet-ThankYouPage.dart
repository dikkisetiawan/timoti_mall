import 'package:flutter/material.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';

class SendThankYouPage extends StatelessWidget {
  static const routeName = '/SendThankYouPage-Page';

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Thank You',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
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
        backgroundColor: Theme.of(context).backgroundColor,
        shadowColor: Colors.grey,
        elevation: 3,
      ),
      body: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: getPageContent(
              _deviceDetails,
              _widgetSize,
              context,
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  List<Widget> getPageContent(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    BuildContext context,
  ) {
    List<Widget> pageContent = <Widget>[];

    pageContent.add(
      SizedBox(
        width: _widgetSize.getResponsiveWidth(0.4, 0.4, 0.4),
        child: Image.asset('assets/icon/logo.png'),
      ),
    );

    pageContent.add(SizedBox(
      height: _widgetSize.getResponsiveHeight(0.05, 0.05, 0.05),
    ));

    pageContent.add(
      Text(
        'Thank You',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: _deviceDetails.getTitleFontSize() + 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    pageContent.add(SizedBox(
      height: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
    ));

    pageContent.add(
      Text(
        'You have Successful Send Money.',
        style: TextStyle(
          color: Colors.black,
          fontSize: _deviceDetails.getNormalFontSize(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    return pageContent;
  }
}
