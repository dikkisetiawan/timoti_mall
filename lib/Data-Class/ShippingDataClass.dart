import 'package:timoti_project/enums/Shipping-Method-Type.dart';

class ShippingData {
  String shippingName;
  ShippingMethodType type;
  double shippingPrice;
  bool isActive;
  String description;
  String startTime;
  String endTime;
  bool isNULL;

  ShippingData({
    this.isNULL = false,
    this.shippingName = '',
    this.type = ShippingMethodType.StandardDelivery,
    this.shippingPrice = 0.00,
    this.isActive = true,
    this.description = '',
    this.endTime = '',
    this.startTime = '',
  });
}