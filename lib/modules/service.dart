import 'dart:convert';

import 'package:dio/dio.dart';
import "package:http/http.dart" as http;
import 'package:non_helmet_mobile/modules/constant.dart';

class RequestResult {
  bool ok;
  dynamic data;
  RequestResult(this.ok, this.data);
}

Future<RequestResult> registerUser([dynamic data]) async {
  try {
    var url = "${Constant().domain}/Register/PostRegister";
    var dataStr = jsonEncode(data);
    var result = await http.post(Uri.parse(url), body: dataStr, headers: {
      "Content-Type": "application/json",
    });
    return RequestResult(true, jsonDecode(result.body));
  } catch (e) {
    print(e);
    return RequestResult(true, "");
  }
}
