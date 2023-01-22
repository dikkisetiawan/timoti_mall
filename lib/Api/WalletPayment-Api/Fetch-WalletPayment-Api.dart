import 'dart:io';
import 'package:http/http.dart' as http;
import '/Api/WalletPayment-Api/WalletPaymentJSON.dart';
import 'dart:convert';
import '/main.dart';

Future<WalletPaymentJSON> fetchWalletPaymentApi(
  String token,
  List<String> orderIDs,
) async {
  final String apiEndpoint = App.apiURL + '/storeapi/Wallet/Pay';

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
    }),
  );

  if (response.statusCode == 200) {
    return WalletPaymentJSON.fromJson(json.decode(response.body));
  } else {
    print("**************************");
    print("Http Error Status Code: " + response.statusCode.toString());
    return WalletPaymentJSON.fromJson(json.decode(response.body));
  }
}
