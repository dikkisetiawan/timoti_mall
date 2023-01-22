import 'package:json_annotation/json_annotation.dart';
import '/Data-Class/CreateOrderDetailsClass.dart';

part 'CreateOrderClass.g.dart';

@JsonSerializable(explicitToJson: true)
class CreateOrderClass {
  String customerFirstName;
  String customerId;
  String customerLastName;
  String deliveryType;
  String orderBillingAddress;
  String orderBillingAddressCity;
  String orderBillingAddressCountry;
  String orderBillingAddressCountryCode;
  String orderBillingAddressEmail;
  String orderBillingAddressFirstName;
  String orderBillingAddressLastName;
  String orderBillingAddressPhone;
  String orderBillingAddressProvince;
  String orderBillingAddressProvinceCode;
  String orderBillingAddressZip;
  String orderCreatedAt;
  String orderCustomerCountryCode;
  String orderCustomerFirstName;
  String orderCustomerId;
  String orderCustomerPhone;
  List<CreateOrderDetailsClass>? orderDetails;
  String orderRemark;
  String orderShippingAddress;
  String orderShippingAddressCity;
  String orderShippingAddressCountry;
  String orderShippingAddressCountryCode;
  String orderShippingAddressEmail;
  String orderShippingAddressFirstName;
  String orderShippingAddressLastName;
  String orderShippingAddressPhone;
  String orderShippingAddressProvince;
  String orderShippingAddressProvinceCode;
  String orderShippingAddressZip;
  String orderSourceType;
  String providerId;
  String VoucherID;

  CreateOrderClass({
    this.customerFirstName = "DIDNT INSERT Name",
    this.customerId = "DIDNT INSERT CustomerID",
    this.deliveryType = "DIDNT INSERT DeliveryType",
    this.orderBillingAddress = "DIDNT INSERT Address",
    this.orderBillingAddressCity = "DIDNT INSERT City",
    this.orderBillingAddressEmail = "DIDNT INSERT Email",
    this.orderBillingAddressFirstName = "DIDNT INSERT FirstName",
    this.orderBillingAddressPhone = "DIDNT INSERT Phone",
    this.orderBillingAddressProvince = "DIDNT INSERT Province",
    this.orderBillingAddressZip = "DIDNT INSERT Zip",
    this.orderCreatedAt = "DIDNT INSERT CreatedDate",
    this.orderCustomerFirstName = "DIDNT INSERT First Name",
    this.orderCustomerId = "DIDNT INSERT CustomerID",
    this.orderCustomerPhone = "DIDNT INSERT Phone",
    this.orderShippingAddress = "DIDNT INSERT Address",
    this.orderShippingAddressCity = "DIDNT INSERT City",
    this.orderShippingAddressEmail = "DIDNT INSERT Email",
    this.orderShippingAddressFirstName = "DIDNT INSERT",
    this.orderShippingAddressPhone = "DIDNT INSERT Phone",
    this.orderShippingAddressProvince = "DIDNT INSERT State",
    this.orderShippingAddressZip = "DIDNT INSERT zip",
    this.providerId = "DIDNT INSERT ProviderID",
    this.VoucherID = '',
    this.orderDetails,

    /// These no need fill
    this.customerLastName = '',
    this.orderBillingAddressCountry = 'Indonesia',
    this.orderBillingAddressCountryCode = "ID",
    this.orderBillingAddressLastName = "",
    this.orderBillingAddressProvinceCode = "",
    this.orderCustomerCountryCode = "ID",
    this.orderRemark = "",
    this.orderShippingAddressCountry = 'Indonesia',
    this.orderShippingAddressCountryCode = "ID",
    this.orderShippingAddressLastName = "",
    this.orderShippingAddressProvinceCode = "",
    this.orderSourceType = "mobile",
  });

  /// Factory method
  factory CreateOrderClass.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderClassFromJson(json);
  Map<String, dynamic> toJson() => _$CreateOrderClassToJson(this);
}
