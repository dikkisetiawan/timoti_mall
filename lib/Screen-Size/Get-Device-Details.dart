import 'package:flutter/cupertino.dart';
import '/Screen-Size/ui-utils.dart';
import '/enums/device-screen-type.dart';

class DeviceDetails {
  final BuildContext context;
  DeviceDetails(this.context);

  double normalFontSize = 15;
  double titleFontSize = 17;
  var mediaQuery;

  double getNormalFontSize() {
    mediaQuery = MediaQuery.of(context);
    DeviceScreenType _deviceScreenType = getDeviceType(mediaQuery);

    if (_deviceScreenType != null) {
      if (_deviceScreenType == DeviceScreenType.Mobile) {
        //print("It works on mobile");
        return normalFontSize = 15;
      } else if (_deviceScreenType == DeviceScreenType.Tablet) {
        //print("It works on tablet");
        return normalFontSize = 18;
      } else if (_deviceScreenType == DeviceScreenType.Desktop) {
        //print("It works on tablet");
        return normalFontSize = 21;
      }
    } else if (_deviceScreenType == null) {
      print("Device Screen Type is Null");
    }
    return normalFontSize;
  }

  double getTitleFontSize() {
    mediaQuery = MediaQuery.of(context);
    DeviceScreenType _deviceScreenType = getDeviceType(mediaQuery);

    if (_deviceScreenType != null) {
      if (_deviceScreenType == DeviceScreenType.Mobile) {
        return titleFontSize = 17;
      } else if (_deviceScreenType == DeviceScreenType.Tablet) {
        return titleFontSize = 20;
      } else if (_deviceScreenType == DeviceScreenType.Desktop) {
        return titleFontSize = 24;
      }
    } else {
      print("Device Screen Type is Null");
    }
    return titleFontSize;
  }
}
