import 'package:geolocator/geolocator.dart';
import 'package:timoti_project/Data-Class/CategoriesDataClass.dart';
import 'package:timoti_project/Nav.dart';

class ProductDetailsArgument {
  Position? userPosition;
  String productBaseID;
  String productName;
  String productDescription;
  String? productDescriptionHTML;
  String priceString;
  List<String> urlList;
  BottomAppBarState bottomAppBarState;

  ProductDetailsArgument({
    this.userPosition,
    required this.productBaseID,
    required this.productName,
    required this.productDescription,
    this.productDescriptionHTML,
    required this.priceString,

    required this.urlList,
    required this.bottomAppBarState,
  });
}
