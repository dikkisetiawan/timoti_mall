import 'package:json_annotation/json_annotation.dart';

part 'CheckPhoneResultJSON.g.dart'; // Same as File Name

@JsonSerializable(explicitToJson: true)

/// Create class
class CheckPhoneResultJSON{
  String? customerId;
  bool? isExist;

  CheckPhoneResultJSON({
     this.customerId,
     this.isExist,
  });

  /// Factory method
  factory CheckPhoneResultJSON.fromJson(Map<String, dynamic> json) => _$CheckPhoneResultJSONFromJson(json);
  Map<String, dynamic> toJson() => _$CheckPhoneResultJSONToJson(this);
}
