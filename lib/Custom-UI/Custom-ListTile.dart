// import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/material.dart';
import 'package:timoti_project/Core/DateTime-Calculator.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import '../Screen-Size/WidgetSizeCalculation.dart';

class CustomListTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  final int startDateDay;
  final int startDateMonth;
  final int startDateYear;

  final int endDateDay;
  final int endDateMonth;
  final int endDateYear;

  final bool spacing;
  final Widget? customButton;

  final color;
  final int maxLine;

  final double circularBorderValue;

  CustomListTile({
    Key? key,
    this.imagePath = "",
    this.title = "",
    this.subtitle = "",
    this.startDateDay = 0,
    this.startDateMonth = 0,
    this.startDateYear = 0,
    this.endDateDay = 0,
    this.endDateMonth = 0,
    this.endDateYear = 0,
    this.spacing = false,
    this.customButton,
    this.color,
    this.maxLine = 0,
    this.circularBorderValue = 0,
  }) : super(key: key);

  DateTimeCalculator _dateTimeCalculator = new DateTimeCalculator();

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Column(
      children: <Widget>[
        /// Date
        if (startDateDay != null &&
            startDateDay > 0 &&
            endDateDay != null &&
            endDateDay > 0)
          Padding(
            padding: EdgeInsets.fromLTRB(
                _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05), 0, 0, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: Text(
                  _dateTimeCalculator.getDateStringFormat(startDateDay,
                          startDateMonth, startDateYear, 0, 0, "d MMM yyyy") +
                      " - " +
                      _dateTimeCalculator.getDateStringFormat(endDateDay,
                          endDateMonth, endDateYear, 0, 0, "d MMM yyyy"),
                  style:
                      TextStyle(fontSize: _deviceDetails.getNormalFontSize()),
                ),
              ),
            ),
          ),

        /// ListTile
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(circularBorderValue),
            color: color,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                _widgetSize.getResponsiveHeight(0.02, 0.02, 0.02),
                _widgetSize.getResponsiveWidth(0.01, 0.01, 0.01),
                _widgetSize.getResponsiveHeight(0.02, 0.02, 0.02)),
            child:

                /// ListTile SIZE
                SizedBox(
              height: needToResize()
                  ? _widgetSize.getResponsiveHeight(0.08, 0.08, 0.08)
                  : _widgetSize.getResponsiveHeight(0.13, 0.13, 0.13),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  /// Image
                  // if (imagePath != null && imagePath != '')
                  //   AspectRatio(
                  //     aspectRatio: 1.0,
                  //     child: Image(
                  //       image: FirebaseImage(
                  //           "gs://travel-app-fc73b.appspot.com/$imagePath",
                  //           shouldCache: true,
                  //           cacheRefreshStrategy: CacheRefreshStrategy.NEVER),
                  //       fit: BoxFit.cover,
                  //     ),
                  //   ),

                  /// Content
                  Expanded(
                    child: Padding(
                      padding: needSpacing()
                          ? const EdgeInsets.fromLTRB(20.0, 0.0, 2.0, 0.0)
                          : const EdgeInsets.fromLTRB(0, 0.0, 2.0, 0.0),
                      child: CustomSubListTile(
                        title: title,
                        subtitle: subtitle,
                        customButton: customButton as Widget,
                        maxLine: maxLine,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool needToResize() {
    bool temp = false;
    if (customButton == null && (imagePath == null || imagePath == '')) {
      temp = true;
    }
    return temp;
  }

  bool needSpacing() {
    bool temp = true;
    if (spacing == null || spacing == false) {
      temp = false;
    }
    return temp;
  }

  DateTime getStartDate() {
    var targetDate = _dateTimeCalculator.getDate(
        startDateYear, startDateMonth, startDateDay, 0, 0);
    return targetDate;
  }
}

class CustomSubListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? customButton;
  final int maxLine;

  CustomSubListTile({
    Key? key,
    required this.title,
    required this.subtitle,
    this.customButton,
    required this.maxLine,
  }) : super(key: key);

  int getMaxLine() {
    int temp = 0;
    if (maxLine == null) {
      temp = 1;
    } else {
      temp = maxLine;
    }
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                /// Title
                Text(
                  '$title',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: _deviceDetails.getNormalFontSize(),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(bottom: 2.0)),

                /// Title
                Text(
                  '$subtitle',
                  maxLines: getMaxLine(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: _deviceDetails.getNormalFontSize(),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (customButton != null)
            Expanded(
              flex: 1,
              child: customButton as Widget,
            ),
        ],
      ),
    );
  }
}
