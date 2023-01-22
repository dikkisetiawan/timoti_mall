import 'package:geolocator/geolocator.dart';
import '/Data-Class/CategoriesDataClass.dart';
import '/Nav.dart';

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
