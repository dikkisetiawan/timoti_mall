// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TopUpWalletPaymentJSON.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopUpWalletPaymentJSON _$TopUpWalletPaymentJSONFromJson(
        Map<String, dynamic> json) =>
    TopUpWalletPaymentJSON(
      isSuccess: json['isSuccess'] as bool?,
      paymentForm: json['paymentForm'] == null
          ? null
          : TopUpWalletPaymentResult.fromJson(
              json['paymentForm'] as Map<String, dynamic>),
      errorMessage: json['errorMessage'] as String?,
      paymentId: json['paymentId'] as String?,
    );

Map<String, dynamic> _$TopUpWalletPaymentJSONToJson(
        TopUpWalletPaymentJSON instance) =>
    <String, dynamic>{
      'isSuccess': instance.isSuccess,
      'paymentForm': instance.paymentForm?.toJson(),
      'errorMessage': instance.errorMessage,
      'paymentId': instance.paymentId,
    };
