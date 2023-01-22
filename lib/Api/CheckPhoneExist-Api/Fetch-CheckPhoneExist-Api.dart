import 'package:http/http.dart' as http;
import 'package:timoti_project/Api/CheckPhoneExist-Api/CheckPhoneResultJSON.dart';
import 'dart:convert';
import 'package:timoti_project/main.dart';

Future<CheckPhoneResultJSON> fetchCheckPhoneApi(
  String phoneNumber,
) async {
  final String apiEndpoint =
      App.apiURL + '/storeapi/Customers/CheckPhoneExistence';

  final Uri url = Uri.parse(apiEndpoint);

  final http.Response response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      // 'Authorization': 'Bearer $token',
      // HttpHeaders.authorizationHeader: "Bearer $token",
      // 'Accept': 'application/json',
    },
    body: jsonEncode(<String, dynamic>{
      "phone": phoneNumber,
    }),
  );

  if (response.statusCode == 200) {
    return CheckPhoneResultJSON.fromJson(json.decode(response.body));
  } else {
    print("**************************");
    print("Http Error Status Code: " + response.statusCode.toString());
    return CheckPhoneResultJSON.fromJson(json.decode(response.body));
  }
}
