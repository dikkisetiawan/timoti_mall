import 'package:json_annotation/json_annotation.dart';
import '/Api/GkashPayment-Api/GkashPaymentSubJSON.dart';

part 'GkashPaymentJSON.g.dart';

@JsonSerializable(explicitToJson: true)

/// Create class
class GkashPaymentJSON {
  GkashPaymentResult? paymentForm;
  String? errorMessage;

  GkashPaymentJSON({
    this.paymentForm,
    this.errorMessage,
  });

  /// Factory method
  factory GkashPaymentJSON.fromJson(Map<String, dynamic> json) =>
      _$GkashPaymentJSONFromJson(json);
  Map<String, dynamic> toJson() => _$GkashPaymentJSONToJson(this);
}
