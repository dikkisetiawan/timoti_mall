import 'package:json_annotation/json_annotation.dart';

part 'CheckEmailResultJSON.g.dart'; // Same as File Name

@JsonSerializable(explicitToJson: true)

/// Create class
class CheckEmailResultJSON{
  List<String>? provider;
  bool? isExist;

  CheckEmailResultJSON({
     this.provider,
     this.isExist,
  });

  /// Factory method
  factory CheckEmailResultJSON.fromJson(Map<String, dynamic> json) => _$CheckEmailResultJSONFromJson(json);
  Map<String, dynamic> toJson() => _$CheckEmailResultJSONToJson(this);
}
