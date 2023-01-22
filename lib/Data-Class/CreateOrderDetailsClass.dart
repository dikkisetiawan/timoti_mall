import 'package:json_annotation/json_annotation.dart';

part 'CreateOrderDetailsClass.g.dart';

@JsonSerializable(explicitToJson: true)

class CreateOrderDetailsClass {
  String productId;
  int quantity;

  CreateOrderDetailsClass({
    this.productId = "",
    this.quantity = -1,
  });

  /// Factory method
  factory CreateOrderDetailsClass.fromJson(Map<String, dynamic> json) => _$CreateOrderDetailsClassFromJson(json);
  Map<String, dynamic> toJson() => _$CreateOrderDetailsClassToJson(this);
}