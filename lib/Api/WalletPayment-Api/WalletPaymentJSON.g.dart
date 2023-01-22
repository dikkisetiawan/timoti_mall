// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'WalletPaymentJSON.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletPaymentJSON _$WalletPaymentJSONFromJson(Map<String, dynamic> json) =>
    WalletPaymentJSON(
      isSuccess: json['isSuccess'] as bool?,
      errorMessage: json['errorMessage'] as String?,
      paymentId: json['paymentId'] as String?,
    );

Map<String, dynamic> _$WalletPaymentJSONToJson(WalletPaymentJSON instance) =>
    <String, dynamic>{
      'isSuccess': instance.isSuccess,
      'errorMessage': instance.errorMessage,
      'paymentId': instance.paymentId,
    };
