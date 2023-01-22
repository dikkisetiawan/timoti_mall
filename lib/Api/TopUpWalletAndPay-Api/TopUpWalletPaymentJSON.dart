import 'package:json_annotation/json_annotation.dart';
import 'package:timoti_project/Api/TopUpWalletAndPay-Api/TopUpWalletPaymentSubJSON.dart';

part 'TopUpWalletPaymentJSON.g.dart';

@JsonSerializable(explicitToJson: true)

/// Create class
class TopUpWalletPaymentJSON{
  bool? isSuccess;
  TopUpWalletPaymentResult? paymentForm;
  String? errorMessage;
  String? paymentId;

  TopUpWalletPaymentJSON({
    this.isSuccess,
    this.paymentForm,
    this.errorMessage,
    this.paymentId,
  });

  /// Factory method
  factory TopUpWalletPaymentJSON.fromJson(Map<String, dynamic> json) => _$TopUpWalletPaymentJSONFromJson(json);
  Map<String, dynamic> toJson() => _$TopUpWalletPaymentJSONToJson(this);
}



