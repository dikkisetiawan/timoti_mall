import 'dart:io';

import 'package:http/http.dart' as http;
import '/Api/SendWallet-Api/Send-Wallet-JSON.dart';
import 'dart:convert';

import '/main.dart';

Future<SendWalletJSON> fetchSendWalletApi(
  String token,
  String senderID,
  String receiverID,
  String amount,
  String note,
) async {
  final String apiEndpoint = App.apiURL + '/storeapi/wallet/send';

  final Uri url = Uri.parse(apiEndpoint);

  final http.Response response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      // 'Authorization': 'Bearer $token',
      HttpHeaders.authorizationHeader: "Bearer $token",
      // 'Accept': 'application/json',
    },
    body: jsonEncode(<String, dynamic>{
      "from": senderID,
      "to": receiverID,
      "amount": amount,
      "senderNote": note,
    }),
  );

  if (response.statusCode == 200) {
    return SendWalletJSON.fromJson(json.decode(response.body));
  } else {
    print("**************************");
    print("Http Error Status Code: " + response.statusCode.toString());
    print(response.body);
    if (response.body.isNotEmpty) {
      print("Its not empty");
      return SendWalletJSON.fromJson(json.decode(response.body));
    }
  }
  return SendWalletJSON.fromJson(json.decode(response.body));
}
