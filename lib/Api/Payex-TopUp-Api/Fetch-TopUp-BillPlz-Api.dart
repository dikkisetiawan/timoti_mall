import 'dart:io';

import 'package:http/http.dart' as http;
import '/Api/TopUp-JSON.dart';
import 'dart:convert';

import '/main.dart';

Future<TopUpJSON> fetchTopUpPayexApi(
  String token,
  String amount,
  String firstName,
  String email,
) async {
  final String apiEndpoint = App.apiURL + '/storeapi/Payex/TopUp';

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
      "v_currency": "MYR",
      "v_amount": amount,
      "source": "mobile",
      "returnurl": App.testing == false ? '' : "http://localhost:7353",
      "v_firstname": firstName,
      "v_lastname": '',
      "v_billemail": email,
      "preselection": "",
    }),
  );

  if (response.statusCode == 200) {
    return TopUpJSON.fromJson(json.decode(response.body));
  } else {
    print("**************************");
    print("Http Error Status Code: " + response.statusCode.toString());
    return TopUpJSON.fromJson(json.decode(response.body));
  }
}
