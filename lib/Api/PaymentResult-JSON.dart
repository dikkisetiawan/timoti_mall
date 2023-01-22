import 'package:json_annotation/json_annotation.dart';

part 'PaymentResult-JSON.g.dart';

@JsonSerializable(explicitToJson: true)

/// Create sub class
class PaymentResult {
  String? url;

  PaymentResult({
    this.url,
  });

  /// Factory method
  factory PaymentResult.fromJson(Map<String, dynamic> json) => _$PaymentResultFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentResultToJson(this);
}



