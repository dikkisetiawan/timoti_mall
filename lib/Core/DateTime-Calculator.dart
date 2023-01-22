import 'package:intl/intl.dart';

class DateTimeCalculator{
  /// Get DateTime by passing int variables
  DateTime getDate(int year, int month, int date, int hour , int minute){
    var targetDate = DateTime(year, month, date, hour, minute);
    return targetDate;
  }

  // region Get Day / Date String
  /// Get Date String directly with customized format
  String getDateStringFormat (int day, int month, int year, hour, minute, String targetFormat) {
    var targetDate = DateTime(year, month, day, hour, minute);
    String formattedDate = DateFormat(targetFormat).format(targetDate);

    return formattedDate;
  }
  // endregion
}