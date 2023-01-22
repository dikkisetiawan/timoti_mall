import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '/Custom-UI/Custom-DefaultAppBar.dart';
import '/Data-Class/ComingSoon.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';

class ComingSoonPage extends StatefulWidget {
  static const routeName = '/Coming-Soon-Page';

  @override
  _ComingSoonPageState createState() => _ComingSoonPageState();
}

class _ComingSoonPageState extends State<ComingSoonPage> {
  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    final ComingSoonArgument data =
        ModalRoute.of(context)?.settings.arguments as ComingSoonArgument;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomDefaultAppBar(
        widgetSize: _widgetSize,
        appbarTitle: data.appbarTitle,
        onTapFunction: () => Navigator.pop(context),
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
              data,
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
    ComingSoonArgument argument,
  ) {
    List<Widget> pageContent = <Widget>[];

    pageContent.add(
      Text(
        'Coming Soon !',
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
        'Please Stay Tuned !',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: _deviceDetails.getNormalFontSize(),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
    return pageContent;
  }
}
