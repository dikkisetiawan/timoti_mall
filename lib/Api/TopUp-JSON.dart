import 'package:json_annotation/json_annotation.dart';
import 'package:timoti_project/Api/PaymentResult-JSON.dart';

part 'TopUp-JSON.g.dart';

@JsonSerializable(explicitToJson: true)

/// Create class
class TopUpJSON{
  PaymentResult? paymentForm;
  bool? isSuccess;
  String? topupId;

  TopUpJSON({
    this.paymentForm,
    this.isSuccess,
    this.topupId,
  });

  /// Factory method
  factory TopUpJSON.fromJson(Map<String, dynamic> json) => _$TopUpJSONFromJson(json);
  Map<String, dynamic> toJson() => _$TopUpJSONToJson(this);
}



