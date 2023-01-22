import 'package:json_annotation/json_annotation.dart';
part 'WalletPaymentJSON.g.dart';

@JsonSerializable(explicitToJson: true)

/// Create class
class WalletPaymentJSON{
  bool? isSuccess;
  String? errorMessage;
  String? paymentId;

  WalletPaymentJSON({
    this.isSuccess,
    this.errorMessage,
    this.paymentId,
  });

  /// Factory method
  factory WalletPaymentJSON.fromJson(Map<String, dynamic> json) => _$WalletPaymentJSONFromJson(json);
  Map<String, dynamic> toJson() => _$WalletPaymentJSONToJson(this);
}



