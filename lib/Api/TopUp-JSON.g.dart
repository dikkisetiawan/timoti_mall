// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TopUp-JSON.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopUpJSON _$TopUpJSONFromJson(Map<String, dynamic> json) => TopUpJSON(
      paymentForm: json['paymentForm'] == null
          ? null
          : PaymentResult.fromJson(json['paymentForm'] as Map<String, dynamic>),
      isSuccess: json['isSuccess'] as bool?,
      topupId: json['topupId'] as String?,
    );

Map<String, dynamic> _$TopUpJSONToJson(TopUpJSON instance) => <String, dynamic>{
      'paymentForm': instance.paymentForm?.toJson(),
      'isSuccess': instance.isSuccess,
      'topupId': instance.topupId,
    };
