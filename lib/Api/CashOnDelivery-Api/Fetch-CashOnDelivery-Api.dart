import 'dart:io';

import 'package:http/http.dart' as http;
import '/Api/CashOnDelivery-Api/CashOnDeliveryJSON.dart';
import 'dart:convert';

import '/main.dart';

Future<CashOnDeliveryJSON> fetchCashOnDeliveryApi(
  String token,
  List<String> orderIDs,
  String clientIP,
  String paymentFor,
) async {
  final String apiEndpoint = App.apiURL + '/storeapi/Wallet/CashOnDelivery';

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
      "source": "mobile",
      'clientIP': clientIP,
      'paymentFor': "",
    }),
  );

  if (response.statusCode == 200) {
    return CashOnDeliveryJSON.fromJson(json.decode(response.body));
  } else {
    print("**************************");
    print("Http Error Status Code: " + response.statusCode.toString());
    return CashOnDeliveryJSON.fromJson(json.decode(response.body));
  }
}
