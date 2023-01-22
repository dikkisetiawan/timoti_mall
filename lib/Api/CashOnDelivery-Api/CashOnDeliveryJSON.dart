import 'package:json_annotation/json_annotation.dart';

part 'CashOnDeliveryJSON.g.dart';

@JsonSerializable(explicitToJson: true)

/// Create class
class CashOnDeliveryJSON{
  String? paymentId;
  String? errorMessage;
  bool? isSuccess;

  CashOnDeliveryJSON({
    this.paymentId,
     this.errorMessage,
    this.isSuccess,
  });

  /// Factory method
  factory CashOnDeliveryJSON.fromJson(Map<String, dynamic> json) => _$CashOnDeliveryJSONFromJson(json);
  Map<String, dynamic> toJson() => _$CashOnDeliveryJSONToJson(this);
}



