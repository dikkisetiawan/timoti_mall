import 'package:geolocator/geolocator.dart';

class CategoryArgument{
  Position userPosition;
  String appbarTitle;
  String categoryString;

  CategoryArgument({
    required this.userPosition,
    required this.appbarTitle,
    required this.categoryString,
  });
}
