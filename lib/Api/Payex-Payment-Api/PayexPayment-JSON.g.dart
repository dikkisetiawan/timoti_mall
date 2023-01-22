// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PayexPayment-JSON.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PayexPaymentJSON _$PayexPaymentJSONFromJson(Map<String, dynamic> json) =>
    PayexPaymentJSON(
      paymentId: json['paymentId'] as String?,
      paymentForm: json['paymentForm'] == null
          ? null
          : PaymentResult.fromJson(json['paymentForm'] as Map<String, dynamic>),
      isSuccess: json['isSuccess'] as bool?,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$PayexPaymentJSONToJson(PayexPaymentJSON instance) =>
    <String, dynamic>{
      'paymentId': instance.paymentId,
      'paymentForm': instance.paymentForm?.toJson(),
      'isSuccess': instance.isSuccess,
      'errorMessage': instance.errorMessage,
    };
