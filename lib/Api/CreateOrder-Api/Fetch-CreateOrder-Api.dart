import 'dart:io';

import 'package:http/http.dart' as http;
import '/Api/CreateOrder-Api/Create-Order-JSON.dart';
import '/Data-Class/CreateOrderClass.dart';
import 'dart:convert';

import '/Data-Class/ListCreateOrderClass.dart';
import '/main.dart';

Future<CreateOrderJSON> fetchCreateOrderApi(
  String token,
  ListCreateOrderClass
      listCreateOrderClass, // this wont be use unless there is field
  List<CreateOrderClass> createOrderClassList,
) async {
  final String apiEndpoint = App.apiURL + '/storeapi/Orders/CreateOrder';

  final Uri url = Uri.parse(apiEndpoint);

  final http.Response response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      // 'Content-type': 'application/json',
      HttpHeaders.authorizationHeader: "Bearer $token",
      // 'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
    body: jsonEncode(createOrderClassList),
    // body: order,
  );

  if (response.statusCode == 200) {
    return CreateOrderJSON.fromJson(json.decode(response.body));
  } else {
    print("**************************");
    print("Http Error Status Code: " + response.statusCode.toString());
    return CreateOrderJSON.fromJson(json.decode(response.body));
    // throw Exception('Failed to get Create Order API JSON');
  }
}
