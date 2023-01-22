import 'package:json_annotation/json_annotation.dart';

part 'GkashPaymentSubJSON.g.dart';

@JsonSerializable(explicitToJson: true)

/// Create sub class
class GkashPaymentResult {
  String? url;

  GkashPaymentResult({
     this.url,
  });

  /// Factory method
  factory GkashPaymentResult.fromJson(Map<String, dynamic> json) => _$GkashPaymentResultFromJson(json);
  Map<String, dynamic> toJson() => _$GkashPaymentResultToJson(this);
}



