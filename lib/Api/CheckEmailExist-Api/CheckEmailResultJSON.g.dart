// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CheckEmailResultJSON.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckEmailResultJSON _$CheckEmailResultJSONFromJson(
        Map<String, dynamic> json) =>
    CheckEmailResultJSON(
      provider: (json['provider'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isExist: json['isExist'] as bool?,
    );

Map<String, dynamic> _$CheckEmailResultJSONToJson(
        CheckEmailResultJSON instance) =>
    <String, dynamic>{
      'provider': instance.provider,
      'isExist': instance.isExist,
    };
