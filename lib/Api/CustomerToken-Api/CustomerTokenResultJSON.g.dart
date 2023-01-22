// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CustomerTokenResultJSON.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerTokenResultJSON _$CustomerTokenResultJSONFromJson(
        Map<String, dynamic> json) =>
    CustomerTokenResultJSON(
      accessToken: json['accessToken'] as String?,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$CustomerTokenResultJSONToJson(
        CustomerTokenResultJSON instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'errorMessage': instance.errorMessage,
    };
