// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Top-Up-JSON.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopUpJSON _$TopUpJSONFromJson(Map<String, dynamic> json) => TopUpJSON(
      paymentId: json['paymentId'] as String?,
      paymentForm: json['paymentForm'] == null
          ? null
          : TopUpResult.fromJson(json['paymentForm'] as Map<String, dynamic>),
      isSuccess: json['isSuccess'] as bool?,
    );

Map<String, dynamic> _$TopUpJSONToJson(TopUpJSON instance) => <String, dynamic>{
      'paymentId': instance.paymentId,
      'paymentForm': instance.paymentForm?.toJson(),
      'isSuccess': instance.isSuccess,
    };
