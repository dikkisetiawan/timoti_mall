import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:timoti_project/Api/TopUp-Api/Top-Up-JSON.dart';
import 'dart:convert';

import 'package:timoti_project/main.dart';

Future<TopUpJSON> fetchTopUpApi(
  String token,
  String amount,
  String preselection,
) async {
  final String apiEndpoint = App.apiURL + '/storeapi/gkash/topup';

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
      "preselection": preselection,
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