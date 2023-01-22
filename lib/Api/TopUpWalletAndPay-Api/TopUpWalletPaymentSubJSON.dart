import 'package:json_annotation/json_annotation.dart';

part 'TopUpWalletPaymentSubJSON.g.dart';

@JsonSerializable(explicitToJson: true)

/// Create sub class
class TopUpWalletPaymentResult {
  String? url;

  TopUpWalletPaymentResult({
     this.url,
  });

  /// Factory method
  factory TopUpWalletPaymentResult.fromJson(Map<String, dynamic> json) => _$TopUpWalletPaymentResultFromJson(json);
  Map<String, dynamic> toJson() => _$TopUpWalletPaymentResultToJson(this);
}



