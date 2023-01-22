import 'package:json_annotation/json_annotation.dart';
import '/Api/TopUp-Api/Top-Up-Sub-JSON.dart';

part 'Top-Up-JSON.g.dart';

@JsonSerializable(explicitToJson: true)

/// Create class
class TopUpJSON {
  String? paymentId;
  TopUpResult? paymentForm;
  bool? isSuccess;

  TopUpJSON({
    this.paymentId,
    this.paymentForm,
    this.isSuccess,
  });

  /// Factory method
  factory TopUpJSON.fromJson(Map<String, dynamic> json) =>
      _$TopUpJSONFromJson(json);
  Map<String, dynamic> toJson() => _$TopUpJSONToJson(this);
}
