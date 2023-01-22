// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Send-Wallet-JSON.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendWalletJSON _$SendWalletJSONFromJson(Map<String, dynamic> json) =>
    SendWalletJSON(
      isSuccess: json['isSuccess'] as bool?,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$SendWalletJSONToJson(SendWalletJSON instance) =>
    <String, dynamic>{
      'isSuccess': instance.isSuccess,
      'errorMessage': instance.errorMessage,
    };
