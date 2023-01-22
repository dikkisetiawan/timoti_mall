import 'package:json_annotation/json_annotation.dart';
import '/Data-Class/CreateOrderClass.dart';

part 'ListCreateOrderClass.g.dart';

@JsonSerializable(explicitToJson: true)
class ListCreateOrderClass {
  List<CreateOrderClass> orders;

  ListCreateOrderClass({required this.orders});

  /// Factory method
  factory ListCreateOrderClass.fromJson(Map<String, dynamic> json) =>
      _$ListCreateOrderClassFromJson(json);
  Map<String, dynamic> toJson() => _$ListCreateOrderClassToJson(this);
}
