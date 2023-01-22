// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Create-Order-JSON.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateOrderJSON _$CreateOrderJSONFromJson(Map<String, dynamic> json) =>
    CreateOrderJSON(
      orderIds: (json['orderIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isSuccess: json['isSuccess'] as bool?,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$CreateOrderJSONToJson(CreateOrderJSON instance) =>
    <String, dynamic>{
      'orderIds': instance.orderIds,
      'isSuccess': instance.isSuccess,
      'errorMessage': instance.errorMessage,
    };
