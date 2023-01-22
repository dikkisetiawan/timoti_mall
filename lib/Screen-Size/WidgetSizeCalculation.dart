import 'package:flutter/widgets.dart';
import 'package:timoti_project/Screen-Size/ui-utils.dart';
import 'package:timoti_project/enums/device-screen-type.dart';

class WidgetSizeCalculation {
  final BuildContext context;
  var mediaQuery;

  WidgetSizeCalculation(this.context);

  double getScreenHeight() {
    Size screenSize = MediaQuery.of(context).size;
    return screenSize.height;
  }

  double getScreenWidth() {
    Size screenSize = MediaQuery.of(context).size;
    return screenSize.width;
  }

  // region Based on Screen Size's width and height UI
  double getResponsiveHeight(
    double mobilePercentage,
    double tabletPercentage,
    double desktopPercentage,
  ) {
    double widgetHeight = 0;

    mediaQuery = MediaQuery.of(context);
    DeviceScreenType _deviceScreenType = getDeviceType(mediaQuery);

    if (_deviceScreenType != null) {
      if (_deviceScreenType == DeviceScreenType.Mobile) {
        if (mobilePercentage > 0) {
          return widgetHeight = this.getScreenHeight() * mobilePercentage;
        }
      } else if (_deviceScreenType == DeviceScreenType.Tablet) {
        if (tabletPercentage > 0) {
          return widgetHeight = this.getScreenHeight() * tabletPercentage;
        }
      } else if (_deviceScreenType == DeviceScreenType.Desktop) {
        if (desktopPercentage > 0) {
          return widgetHeight = this.getScreenHeight() * desktopPercentage;
        }
      }
    } else if (_deviceScreenType == null) {
      print("Device Screen Type is Null");
    }

    return widgetHeight;
  }

  double getResponsiveWidth(
    double mobilePercentage,
    double tabletPercentage,
    double desktopPercentage,
  ) {
    double widgetWidth = 0;

    mediaQuery = MediaQuery.of(context);
    DeviceScreenType _deviceScreenType = getDeviceType(mediaQuery);

    if (_deviceScreenType != null) {
      if (_deviceScreenType == DeviceScreenType.Mobile) {
        if (mobilePercentage > 0) {
          return widgetWidth = this.getScreenWidth() * mobilePercentage;
        }
      } else if (_deviceScreenType == DeviceScreenType.Tablet) {
        if (tabletPercentage > 0) {
          return widgetWidth = this.getScreenWidth() * tabletPercentage;
        }
      } else if (_deviceScreenType == DeviceScreenType.Desktop) {
        if (desktopPercentage > 0) {
          return widgetWidth = this.getScreenWidth() * desktopPercentage;
        }
      }
    } else if (_deviceScreenType == null) {
      print("Device Screen Type is Null");
    }
    return widgetWidth;
  }
  // endregion

  // region Old Version
  // double getResponsiveHeight(double percentageValue){
  //   double widgetHeight = 0;
  //
  //   if(percentageValue > 0) {
  //     widgetHeight = this.getScreenHeight() * percentageValue;
  //   }
  //   return widgetHeight;
  // }
  //
  // double getResponsiveWidth(double percentageValue){
  //   double widgetWidth = 0;
  //
  //   if(percentageValue > 0) {
  //     widgetWidth = this.getScreenWidth() * percentageValue;
  //   }
  //   return widgetWidth;
  // }
  // endregion

  // region Based on Parent's width & height UI
  double getResponsiveParentSize(double percentageValue, double parentHeight) {
    if (percentageValue > 0) {
      parentHeight = parentHeight * percentageValue;
    } else {
      // print('Percentage Value cannot be zero or exceed 1');
    }
    //print('Widget Width: $parentHeight');
    return parentHeight;
  }
// endregion

}
