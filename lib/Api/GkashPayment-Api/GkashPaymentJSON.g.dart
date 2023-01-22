// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GkashPaymentJSON.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GkashPaymentJSON _$GkashPaymentJSONFromJson(Map<String, dynamic> json) =>
    GkashPaymentJSON(
      paymentForm: json['paymentForm'] == null
          ? null
          : GkashPaymentResult.fromJson(
              json['paymentForm'] as Map<String, dynamic>),
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$GkashPaymentJSONToJson(GkashPaymentJSON instance) =>
    <String, dynamic>{
      'paymentForm': instance.paymentForm?.toJson(),
      'errorMessage': instance.errorMessage,
    };
