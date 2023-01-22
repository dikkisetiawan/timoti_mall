import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:timoti_project/Api/GkashPayment-Api/GkashPaymentJSON.dart';
import 'dart:convert';

import 'package:timoti_project/main.dart';

Future<GkashPaymentJSON> fetchGkashPaymentApi(
  String token,
  String paymentID,
  String preselection,
) async {
  final String apiEndpoint = App.apiURL + '/storeapi/Gkash/PaymentFormV2';

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
      "v_cartid": paymentID,
      "v_currency": "MYR",
      "source": "mobile",
      "preselection": preselection,
    }),
  );

  if (response.statusCode == 200) {
    return GkashPaymentJSON.fromJson(json.decode(response.body));
  } else {
    print("**************************");
    print("Http Error Status Code: " + response.statusCode.toString());
    return GkashPaymentJSON.fromJson(json.decode(response.body));
  }
}
