import 'package:json_annotation/json_annotation.dart';
import '/Api/PaymentResult-JSON.dart';

part 'PayexPayment-JSON.g.dart';

@JsonSerializable(explicitToJson: true)

/// Create class
class PayexPaymentJSON {
  String? paymentId;
  PaymentResult? paymentForm;
  bool? isSuccess;
  String? errorMessage;

  PayexPaymentJSON({
    this.paymentId,
    this.paymentForm,
    this.isSuccess,
    this.errorMessage,
  });

  /// Factory method
  factory PayexPaymentJSON.fromJson(Map<String, dynamic> json) =>
      _$PayexPaymentJSONFromJson(json);
  Map<String, dynamic> toJson() => _$PayexPaymentJSONToJson(this);
}
