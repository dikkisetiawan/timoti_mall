import 'package:json_annotation/json_annotation.dart';

part 'Top-Up-Sub-JSON.g.dart';

@JsonSerializable(explicitToJson: true)

/// Create sub class
class TopUpResult {
  String? url;

  TopUpResult({
     this.url,
  });

  /// Factory method
  factory TopUpResult.fromJson(Map<String, dynamic> json) => _$TopUpResultFromJson(json);
  Map<String, dynamic> toJson() => _$TopUpResultToJson(this);
}



