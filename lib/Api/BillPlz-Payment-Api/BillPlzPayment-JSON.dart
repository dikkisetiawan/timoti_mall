import 'package:json_annotation/json_annotation.dart';
import '/Api/PaymentResult-JSON.dart';

part 'BillPlzPayment-JSON.g.dart';

@JsonSerializable(explicitToJson: true)

/// Create class
class BillPlzPaymentJSON {
  String? paymentId;
  PaymentResult? paymentForm;
  bool? isSuccess;
  String? errorMessage;

  BillPlzPaymentJSON({
    this.paymentId,
    this.paymentForm,
    this.isSuccess,
    this.errorMessage,
  });

  /// Factory method
  factory BillPlzPaymentJSON.fromJson(Map<String, dynamic> json) =>
      _$BillPlzPaymentJSONFromJson(json);
  Map<String, dynamic> toJson() => _$BillPlzPaymentJSONToJson(this);
}
