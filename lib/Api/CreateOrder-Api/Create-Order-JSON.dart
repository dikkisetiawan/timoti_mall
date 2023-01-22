import 'package:json_annotation/json_annotation.dart';

part 'Create-Order-JSON.g.dart';

@JsonSerializable(explicitToJson: true)

/// Create class
class CreateOrderJSON {
  List<String>? orderIds;
  bool? isSuccess;
  String? errorMessage;

  CreateOrderJSON({
     this.orderIds,
     this.isSuccess,
     this.errorMessage,
  });

  /// Factory method
  factory CreateOrderJSON.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderJSONFromJson(json);
  Map<String, dynamic> toJson() => _$CreateOrderJSONToJson(this);
}
