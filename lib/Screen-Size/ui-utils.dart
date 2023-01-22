import 'package:flutter/widgets.dart';
import '/enums/device-screen-type.dart';

DeviceScreenType getDeviceType(MediaQueryData mediaQuery) {
  var orientation = mediaQuery.orientation;

  double deviceWidth = 0;
  deviceWidth = mediaQuery.size.width;

  // if (orientation == Orientation.landscape) {
  //   deviceWidth = mediaQuery.size.height;
  // } else {
  //   // print(mediaQuery.size.width.toString());
  //   deviceWidth = mediaQuery.size.width;
  // }

  if (deviceWidth > 950) {
    // print("Desktop Size");
    return DeviceScreenType.Desktop;
  }

  // if (deviceWidth >= 600) {
  if (deviceWidth >= 800) {
    // print("Tablet Size");
    return DeviceScreenType.Tablet;
  }
  // print("Mobile Size");
  return DeviceScreenType.Mobile;
}
