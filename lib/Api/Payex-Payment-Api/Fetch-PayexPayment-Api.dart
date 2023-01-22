import 'dart:io';

import 'package:http/http.dart' as http;
import '/Api/Payex-Payment-Api/PayexPayment-JSON.dart';
import 'dart:convert';

import '/main.dart';

Future<PayexPaymentJSON> fetchPayexPaymentApi(
  String token,
  List<String> orderIDs,
  String firstName,
  String lastName,
  String email,
  String clientIP,
  String paymentFor,
) async {
  final String apiEndpoint = App.apiURL + '/storeapi/Payex/PaymentFormV2';

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
      "clientIP": clientIP,
      "paymentFor": paymentFor,
      "v_currency": "MYR",
      "returnurl": "",
      "v_firstname": firstName,
      "v_lastname": lastName,
      "v_billemail": email,
      "v_billstreet": "",
      "v_billpost": "",
      "v_billcity": "",
      "v_billstate": "",
      "v_billcountry": "",
      "v_billphone": "",
      "v_shipstreet": "",
      "v_shippost": "",
      "v_shipcity": "",
      "v_shipstate": "",
      "v_shipcountry": "",
      "v_productdesc": "",
      "preselection": "",
    }),
  );

  if (response.statusCode == 200) {
    return PayexPaymentJSON.fromJson(json.decode(response.body));
  } else {
    print("**************************");
    print("Http Error Status Code: " + response.statusCode.toString());
    return PayexPaymentJSON.fromJson(json.decode(response.body));
  }
}
