import 'package:flutter/material.dart';
import 'package:timoti_project/Core/DateTime-Calculator.dart';
import 'package:timoti_project/Custom-UI/Custom-ListTile.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';
import 'package:timoti_project/Screen-Size/ui-utils.dart';
import 'package:timoti_project/enums/device-screen-type.dart';

class CustomEventListTile extends StatelessWidget {
  final CustomSubListTile? customsubListTile;
  final String contentTitle;
  final Widget? customButton;

  final int year;
  final int month;
  final int date;
  final int hours;
  final int minutes;

  const CustomEventListTile({
    Key? key,
    this.customsubListTile,
    this.contentTitle = '',
    this.customButton,
    this.year = 0,
    this.month = 0,
    this.date = 0,
    this.hours = 0,
    this.minutes = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return eventWidget(context);
  }

  String getTime() {
    DateTimeCalculator _dateTimeCalculator = new DateTimeCalculator();
    String formattedDate = _dateTimeCalculator.getDateStringFormat(
        year, month, date, hours, minutes, 'h:mm a');

    return formattedDate;
  }

  DateTime getStartTime() {
    DateTimeCalculator _dateTimeCalculator = new DateTimeCalculator();
    var targetDate =
        _dateTimeCalculator.getDate(year, month, date, hours, minutes);
    return targetDate;
  }

  Widget eventWidget(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);
    var mediaQuery = MediaQuery.of(context);

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          /// Content Title
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              /// Time + Content Title
              getTime() + " " + contentTitle,
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize() - 2,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          /// Spacing
          SizedBox(
            height: 3,
          ),

          /// Custom SubList Tile
          SizedBox(
            height:
                getDeviceType(mediaQuery) == DeviceScreenType.Mobile ? 65 : 90,
            child: customsubListTile,
          ),

          /// Custom Button
          if (customButton != null)
            Align(
              alignment: Alignment.centerLeft,
              child: customButton,
            ),

          /// Draw Line
          Divider(
            height: _widgetSize.getResponsiveHeight(0.05, 0.05, 0.05),
            thickness: 2,
          ),
        ],
      ),
    );
  }
}
