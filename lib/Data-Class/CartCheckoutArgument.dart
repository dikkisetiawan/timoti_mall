import '/Data-Class/ToggleableItemClass.dart';

class CartCheckoutArgument {
  double totalPrice;
  int totalItem;
  Map<String, List<ToggleableItemClass>> productsMap;

  CartCheckoutArgument({
    required this.totalPrice,
    required this.totalItem,
    required this.productsMap,
  });
}
