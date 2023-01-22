import 'package:http/http.dart' as http;
import '/Api/CheckEmailExist-API/CheckEmailResultJSON.dart';
import 'dart:convert';
import '/main.dart';

Future<CheckEmailResultJSON> fetchCheckEmailApi(
  String email,
) async {
  final String apiEndpoint =
      App.apiURL + '/storeapi/Customers/CheckEmailExistence';

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
      "email": email,
    }),
  );

  if (response.statusCode == 200) {
    return CheckEmailResultJSON.fromJson(json.decode(response.body));
  } else {
    print("**************************");
    print("Http Error Status Code: " + response.statusCode.toString());
    return CheckEmailResultJSON.fromJson(json.decode(response.body));
  }
}
