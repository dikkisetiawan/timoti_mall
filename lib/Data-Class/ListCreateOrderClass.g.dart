// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ListCreateOrderClass.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListCreateOrderClass _$ListCreateOrderClassFromJson(
        Map<String, dynamic> json) =>
    ListCreateOrderClass(
      orders: (json['orders'] as List<dynamic>)
          .map((e) => CreateOrderClass.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ListCreateOrderClassToJson(
        ListCreateOrderClass instance) =>
    <String, dynamic>{
      'orders': instance.orders.map((e) => e.toJson()).toList(),
    };
