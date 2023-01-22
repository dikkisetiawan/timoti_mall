// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CashOnDeliveryJSON.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CashOnDeliveryJSON _$CashOnDeliveryJSONFromJson(Map<String, dynamic> json) =>
    CashOnDeliveryJSON(
      paymentId: json['paymentId'] as String?,
      errorMessage: json['errorMessage'] as String?,
      isSuccess: json['isSuccess'] as bool?,
    );

Map<String, dynamic> _$CashOnDeliveryJSONToJson(CashOnDeliveryJSON instance) =>
    <String, dynamic>{
      'paymentId': instance.paymentId,
      'errorMessage': instance.errorMessage,
      'isSuccess': instance.isSuccess,
    };
