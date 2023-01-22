import 'dart:io';

import 'package:http/http.dart' as http;
import '/Api/TopUpWalletAndPay-Api/TopUpWalletPaymentJSON.dart';
import 'dart:convert';

import '/main.dart';

Future<TopUpWalletPaymentJSON> fetchTopUpWalletPaymentApi(
  String token,
  List<String> orderIDs,
  String preselection,
) async {
  final String apiEndpoint = App.apiURL + '/storeapi/TopupAndPay';

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
      "order_ids": orderIDs,
      "v_currency": "MYR",
      "source": "mobile",
      "preselection": preselection,
    }),
  );

  if (response.statusCode == 200) {
    return TopUpWalletPaymentJSON.fromJson(json.decode(response.body));
  } else {
    print("**************************");
    print("Http Error Status Code: " + response.statusCode.toString());
    return TopUpWalletPaymentJSON.fromJson(json.decode(response.body));
  }
}
