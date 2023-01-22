// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CreateOrderClass.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateOrderClass _$CreateOrderClassFromJson(Map<String, dynamic> json) =>
    CreateOrderClass(
      customerFirstName:
          json['customerFirstName'] as String? ?? "DIDNT INSERT Name",
      customerId: json['customerId'] as String? ?? "DIDNT INSERT CustomerID",
      deliveryType:
          json['deliveryType'] as String? ?? "DIDNT INSERT DeliveryType",
      orderBillingAddress:
          json['orderBillingAddress'] as String? ?? "DIDNT INSERT Address",
      orderBillingAddressCity:
          json['orderBillingAddressCity'] as String? ?? "DIDNT INSERT City",
      orderBillingAddressEmail:
          json['orderBillingAddressEmail'] as String? ?? "DIDNT INSERT Email",
      orderBillingAddressFirstName:
          json['orderBillingAddressFirstName'] as String? ??
              "DIDNT INSERT FirstName",
      orderBillingAddressPhone:
          json['orderBillingAddressPhone'] as String? ?? "DIDNT INSERT Phone",
      orderBillingAddressProvince:
          json['orderBillingAddressProvince'] as String? ??
              "DIDNT INSERT Province",
      orderBillingAddressZip:
          json['orderBillingAddressZip'] as String? ?? "DIDNT INSERT Zip",
      orderCreatedAt:
          json['orderCreatedAt'] as String? ?? "DIDNT INSERT CreatedDate",
      orderCustomerFirstName: json['orderCustomerFirstName'] as String? ??
          "DIDNT INSERT First Name",
      orderCustomerId:
          json['orderCustomerId'] as String? ?? "DIDNT INSERT CustomerID",
      orderCustomerPhone:
          json['orderCustomerPhone'] as String? ?? "DIDNT INSERT Phone",
      orderShippingAddress:
          json['orderShippingAddress'] as String? ?? "DIDNT INSERT Address",
      orderShippingAddressCity:
          json['orderShippingAddressCity'] as String? ?? "DIDNT INSERT City",
      orderShippingAddressEmail:
          json['orderShippingAddressEmail'] as String? ?? "DIDNT INSERT Email",
      orderShippingAddressFirstName:
          json['orderShippingAddressFirstName'] as String? ?? "DIDNT INSERT",
      orderShippingAddressPhone:
          json['orderShippingAddressPhone'] as String? ?? "DIDNT INSERT Phone",
      orderShippingAddressProvince:
          json['orderShippingAddressProvince'] as String? ??
              "DIDNT INSERT State",
      orderShippingAddressZip:
          json['orderShippingAddressZip'] as String? ?? "DIDNT INSERT zip",
      providerId: json['providerId'] as String? ?? "DIDNT INSERT ProviderID",
      VoucherID: json['VoucherID'] as String? ?? '',
      orderDetails: (json['orderDetails'] as List<dynamic>?)
          ?.map((e) =>
              CreateOrderDetailsClass.fromJson(e as Map<String, dynamic>))
          .toList(),
      customerLastName: json['customerLastName'] as String? ?? '',
      orderBillingAddressCountry:
          json['orderBillingAddressCountry'] as String? ?? 'Indonesia',
      orderBillingAddressCountryCode:
          json['orderBillingAddressCountryCode'] as String? ?? "ID",
      orderBillingAddressLastName:
          json['orderBillingAddressLastName'] as String? ?? "",
      orderBillingAddressProvinceCode:
          json['orderBillingAddressProvinceCode'] as String? ?? "",
      orderCustomerCountryCode:
          json['orderCustomerCountryCode'] as String? ?? "ID",
      orderRemark: json['orderRemark'] as String? ?? "",
      orderShippingAddressCountry:
          json['orderShippingAddressCountry'] as String? ?? 'Indonesia',
      orderShippingAddressCountryCode:
          json['orderShippingAddressCountryCode'] as String? ?? "ID",
      orderShippingAddressLastName:
          json['orderShippingAddressLastName'] as String? ?? "",
      orderShippingAddressProvinceCode:
          json['orderShippingAddressProvinceCode'] as String? ?? "",
      orderSourceType: json['orderSourceType'] as String? ?? "mobile",
    );

Map<String, dynamic> _$CreateOrderClassToJson(CreateOrderClass instance) =>
    <String, dynamic>{
      'customerFirstName': instance.customerFirstName,
      'customerId': instance.customerId,
      'customerLastName': instance.customerLastName,
      'deliveryType': instance.deliveryType,
      'orderBillingAddress': instance.orderBillingAddress,
      'orderBillingAddressCity': instance.orderBillingAddressCity,
      'orderBillingAddressCountry': instance.orderBillingAddressCountry,
      'orderBillingAddressCountryCode': instance.orderBillingAddressCountryCode,
      'orderBillingAddressEmail': instance.orderBillingAddressEmail,
      'orderBillingAddressFirstName': instance.orderBillingAddressFirstName,
      'orderBillingAddressLastName': instance.orderBillingAddressLastName,
      'orderBillingAddressPhone': instance.orderBillingAddressPhone,
      'orderBillingAddressProvince': instance.orderBillingAddressProvince,
      'orderBillingAddressProvinceCode':
          instance.orderBillingAddressProvinceCode,
      'orderBillingAddressZip': instance.orderBillingAddressZip,
      'orderCreatedAt': instance.orderCreatedAt,
      'orderCustomerCountryCode': instance.orderCustomerCountryCode,
      'orderCustomerFirstName': instance.orderCustomerFirstName,
      'orderCustomerId': instance.orderCustomerId,
      'orderCustomerPhone': instance.orderCustomerPhone,
      'orderDetails': instance.orderDetails?.map((e) => e.toJson()).toList(),
      'orderRemark': instance.orderRemark,
      'orderShippingAddress': instance.orderShippingAddress,
      'orderShippingAddressCity': instance.orderShippingAddressCity,
      'orderShippingAddressCountry': instance.orderShippingAddressCountry,
      'orderShippingAddressCountryCode':
          instance.orderShippingAddressCountryCode,
      'orderShippingAddressEmail': instance.orderShippingAddressEmail,
      'orderShippingAddressFirstName': instance.orderShippingAddressFirstName,
      'orderShippingAddressLastName': instance.orderShippingAddressLastName,
      'orderShippingAddressPhone': instance.orderShippingAddressPhone,
      'orderShippingAddressProvince': instance.orderShippingAddressProvince,
      'orderShippingAddressProvinceCode':
          instance.orderShippingAddressProvinceCode,
      'orderShippingAddressZip': instance.orderShippingAddressZip,
      'orderSourceType': instance.orderSourceType,
      'providerId': instance.providerId,
      'VoucherID': instance.VoucherID,
    };
