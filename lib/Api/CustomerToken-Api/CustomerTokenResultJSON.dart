import 'package:json_annotation/json_annotation.dart';

part 'CustomerTokenResultJSON.g.dart'; // Same as File Name

@JsonSerializable(explicitToJson: true)

/// Create class
class CustomerTokenResultJSON{
  String? accessToken;
  String? errorMessage;

  CustomerTokenResultJSON({
     this.accessToken,
     this.errorMessage,
  });

  /// Factory method
  factory CustomerTokenResultJSON.fromJson(Map<String, dynamic> json) => _$CustomerTokenResultJSONFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerTokenResultJSONToJson(this);
}
