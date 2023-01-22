import '/Custom-UI/Custom-ListTilePrice.dart';
import '/Data-Class/ProductVariant.dart';
import '/Data-Class/ShippingDataClass.dart';
import '/Data-Class/VoucherDataClass.dart';

class ToggleableItemClass {
  CustomListTilePrice? itemUI;
  CustomListTilePrice? actual;
  String? branchCartID;
  String? image;
  String productName;
  String productId;
  String providerId;
  String? variantId;
  bool isDisable;
  bool boolValue;
  int quantity;
  double? price;
  double? totalPrice;
  ShippingData? shippingData;
  VoucherData? voucherData;
  double priceAfterDiscount;
  bool hasItemChecked;

  // Product Variant
  ProductVariantType? productVariantFinal;
  ProductVariant? selectedProductVariant;

  ToggleableItemClass({
    this.itemUI,
    this.image,
    this.branchCartID,
    this.isDisable = false,
    this.productName = '',
    this.variantId,
    this.providerId = '',
    this.actual,
    this.productId = '',
    this.boolValue = false,
    this.quantity = 0,
    this.price,
    this.totalPrice,
    this.shippingData,
    this.voucherData,
    this.priceAfterDiscount = 0,
    this.hasItemChecked = false,
    this.productVariantFinal,
    this.selectedProductVariant,
  });
}
