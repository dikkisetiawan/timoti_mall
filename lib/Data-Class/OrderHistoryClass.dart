import '/Address-Page/AddressClass.dart';
import '/Data-Class/OrderDetailClass.dart';
import '/enums/OrderHistoryType.dart';

class OrderHistoryClass {
  /// Customer Details
  String customer_ID;
  String customer_Name;

  /// Order
  String order_ID;
  String orderCreatedTime;
  String orderUpdatedTime;
  OrderHistoryType type;
  bool payStatus;
  String? receivedDate;

  /// Order Address
  AddressClass? addressData;

  /// Order Price
  String total_Shipping;
  String total_Price;
  String total_Amount;
  String order_total_discount;
  String order_subtotal_price;
  String paymentMethod;

  /// Branch Data
  String provider_ID;
  String branchName;

  String deliveryType;

  /// Order Details (Products)
  List<OrderDetailsClass> orderDetailsList;

  bool hasTrackingData;

  OrderHistoryClass({
    this.type = OrderHistoryType.NONE,
    required this.deliveryType,
    required this.order_ID,
    required this.customer_ID,
    required this.customer_Name,
    required this.payStatus,
    required this.orderCreatedTime,
    required this.orderUpdatedTime,
    this.receivedDate,
    required this.provider_ID,
    required this.branchName,
    required this.total_Shipping,
    required this.total_Price,
    required this.total_Amount,
    required this.order_total_discount,
    required this.order_subtotal_price,
    required this.paymentMethod,
    required this.orderDetailsList,
    this.addressData,
    this.hasTrackingData = true,
  });
}
