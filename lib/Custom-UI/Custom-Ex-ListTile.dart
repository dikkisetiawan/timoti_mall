import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timoti_project/Core/DateTime-Calculator.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';

class CustomExListTile extends StatelessWidget {
  final String trailingText;
  final Color trailingTextColor;
  final Widget? trailingIcon;
  final Widget? leadingIcon;

  final String title;
  final String subTitle;
  final int maxLine;

  final int dateDay;
  final int dateMonth;
  final int dateYear;
  final int hour;
  final int minute;
  final int second;
  final String dateFormat;

  final Color dateColor;
  final Color titleColor;
  final Color subTitleColor;
  final Color bgColor;

  final DateTimeCalculator? dateTimeCalculator;
  final bool showDate;
  final double contentPaddingTopBottom;
  final double overallPaddingTop;
  final double overallPaddingBottom;
  final double overallPaddingLeftRight;

  final String dateString;
  final Widget? child;
  final DateTime? dateTime;

  CustomExListTile({
    Key? key,
    this.trailingText = '',
    this.trailingTextColor = Colors.white,
    this.trailingIcon,
    this.leadingIcon,
    this.title = '',
    this.subTitle = '',
    this.maxLine = 1,
    this.dateDay = 0,
    this.dateMonth = 0,
    this.dateYear = 0,
    this.hour = 0,
    this.minute = 0,
    this.second = 0,
    this.dateFormat = "d MMM yyyy",
    this.dateColor = Colors.white,
    this.titleColor = Colors.white,
    this.subTitleColor = const Color(0xffa5a5a5),
    this.bgColor = const Color(0xff262626),
    this.dateTimeCalculator,
    this.showDate = true,
    this.contentPaddingTopBottom = 0,
    this.overallPaddingLeftRight = 0,
    this.overallPaddingTop = 0,
    this.overallPaddingBottom = 0,
    this.dateString = '',
    this.child,
    this.dateTime,
  }) : super(key: key);

  DateTime getStartDate() {
    var targetDate = DateTime.now();
    targetDate =
        dateTimeCalculator?.getDate(dateYear, dateMonth, dateDay, hour, minute) as DateTime;

    return targetDate;
  }

  /// Use this if Date String exist
  DateTime getDate() {
    // String target_date = "2020-09-14 05:47:55 PM";

    String date = dateString.split(" ")[0];
    String time = dateString.split(" ")[1];
    String c = dateString.split(" ")[2];

    // print("Date: " + date);
    // print("time: " + time);
    // print("AM / PM: " + c);
    DateTime currentTime = DateTime.now();

    /// Convert 12 hours to 24 hours
    currentTime = DateFormat.jms().parse(time + " $c");
    date = DateFormat("yyyy-MM-dd").format(DateTime.parse(date));

    String finalDate = date + " " + DateFormat("HH:mm:ss").format(currentTime);
    var targetDate = DateTime.parse(finalDate);
    return targetDate;
  }

  DateTime getStringDate() {
    // String target_date = "2020-09-14 05:47:55 PM";

    String date = dateString.split(" ")[0];

    var targetDate = DateTime.parse(date);
    return targetDate;
  }

  /// Use this if Date Time exist
  DateTime getEXDate() {
    return dateTime as DateTime;
  }

  /// This is used to compare day
  String compareCurrentDay() {
    if (dateTime != null) {
      return DateFormat(dateFormat).format(dateTime as DateTime);
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Date
        if (dateDay != null && dateDay > 0 && showDate == true)
          Padding(
            padding: EdgeInsets.fromLTRB(
              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
              0,
              0,
              0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: Text(
                  dateTimeCalculator!.getDateStringFormat(
                      dateDay, dateMonth, dateYear, 0, 0, dateFormat),
                  style: TextStyle(
                    color: dateColor,
                    fontSize: _deviceDetails.getNormalFontSize() - 3,
                  ),
                ),
              ),
            ),
          ),

        if (dateTime != null && showDate == true)
          Padding(
            padding: EdgeInsets.fromLTRB(
              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
              0,
              0,
              0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: Text(
                  DateFormat(dateFormat).format(dateTime as DateTime).toString(),
                  style: TextStyle(
                    color: dateColor,
                    fontSize: _deviceDetails.getNormalFontSize() - 3,
                  ),
                ),
              ),
            ),
          ),

        // if (dateString != null && showDate == true)
        //   Padding(
        //     padding: EdgeInsets.fromLTRB(
        //       _widgetSize.getResponsiveWidth(0.05),
        //       0,
        //       0,
        //       0,
        //     ),
        //     child: Align(
        //       alignment: Alignment.centerLeft,
        //       child: Padding(
        //         padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        //         child: Text(
        //           DateFormat(dateFormat).format(getStringDate()).toString(),
        //           style: TextStyle(
        //             color: dateColor,
        //             fontSize: _deviceDetails.getNormalFontSize() - 3,
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),

        /// List Tile
        Padding(
          padding: EdgeInsets.fromLTRB(
            _widgetSize.getResponsiveWidth(overallPaddingLeftRight,
                overallPaddingLeftRight, overallPaddingLeftRight),
            _widgetSize.getResponsiveHeight(
                overallPaddingTop, overallPaddingTop, overallPaddingTop),
            _widgetSize.getResponsiveWidth(overallPaddingLeftRight,
                overallPaddingLeftRight, overallPaddingLeftRight),
            _widgetSize.getResponsiveHeight(overallPaddingBottom,
                overallPaddingBottom, overallPaddingBottom),
          ),
          child: Container(
            color: bgColor,
            child: ListTile(
              contentPadding: EdgeInsets.fromLTRB(
                _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                _widgetSize.getResponsiveHeight(contentPaddingTopBottom,
                    contentPaddingTopBottom, contentPaddingTopBottom),
                _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
                _widgetSize.getResponsiveHeight(contentPaddingTopBottom,
                    contentPaddingTopBottom, contentPaddingTopBottom),
              ),
              leading: (leadingIcon != null) ? leadingIcon : null,
              title: title != ''
                  ? Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: titleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: _deviceDetails.getNormalFontSize(),
                      ),
                    )
                  : null,
              subtitle: subTitle != ''
                  ? Text(
                      subTitle,
                      maxLines: maxLine,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: subTitleColor,
                        fontSize: _deviceDetails.getNormalFontSize() - 2,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  : null,
              isThreeLine: maxLine > 2 ? true : false,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  if (trailingText != null || trailingText != '')
                    Text(
                      trailingText,
                      style: TextStyle(
                        color: trailingTextColor,
                        fontSize: _deviceDetails.getNormalFontSize() - 1,
                      ),
                    ),
                  if (trailingIcon != null) trailingIcon as Widget,
                ],
              ),
            ),
          ),
        ),

        /// Child
        if (child != null) child as Widget,
      ],
    );
  }
}
