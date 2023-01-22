// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BillPlzPayment-JSON.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillPlzPaymentJSON _$BillPlzPaymentJSONFromJson(Map<String, dynamic> json) =>
    BillPlzPaymentJSON(
      paymentId: json['paymentId'] as String?,
      paymentForm: json['paymentForm'] == null
          ? null
          : PaymentResult.fromJson(json['paymentForm'] as Map<String, dynamic>),
      isSuccess: json['isSuccess'] as bool?,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$BillPlzPaymentJSONToJson(BillPlzPaymentJSON instance) =>
    <String, dynamic>{
      'paymentId': instance.paymentId,
      'paymentForm': instance.paymentForm?.toJson(),
      'isSuccess': instance.isSuccess,
      'errorMessage': instance.errorMessage,
    };
