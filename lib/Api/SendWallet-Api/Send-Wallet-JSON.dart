import 'package:json_annotation/json_annotation.dart';

part 'Send-Wallet-JSON.g.dart';

@JsonSerializable(explicitToJson: true)

/// Create class
class SendWalletJSON{
  bool? isSuccess;
  String? errorMessage;

  SendWalletJSON({
     this.isSuccess,
     this.errorMessage,
  });

  /// Factory method
  factory SendWalletJSON.fromJson(Map<String, dynamic> json) => _$SendWalletJSONFromJson(json);
  Map<String, dynamic> toJson() => _$SendWalletJSONToJson(this);
}



