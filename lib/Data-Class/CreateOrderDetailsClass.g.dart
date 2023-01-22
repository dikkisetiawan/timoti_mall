// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CreateOrderDetailsClass.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateOrderDetailsClass _$CreateOrderDetailsClassFromJson(
        Map<String, dynamic> json) =>
    CreateOrderDetailsClass(
      productId: json['productId'] as String? ?? "",
      quantity: json['quantity'] as int? ?? -1,
    );

Map<String, dynamic> _$CreateOrderDetailsClassToJson(
        CreateOrderDetailsClass instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'quantity': instance.quantity,
    };
