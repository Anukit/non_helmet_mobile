import 'dart:convert';

import 'package:dio/dio.dart';
import "package:http/http.dart" as http;
import 'package:non_helmet_mobile/modules/constant.dart';

class RequestResult {
  bool pass;
  dynamic data;
  RequestResult(this.pass, this.data);
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

Future<RequestResult> postLogin([dynamic data]) async {
  try {
    var url = "${Constant().domain}/Login/PostLogin";
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

Future<RequestResult> getDataUser(user_id) async {
  //Login
  try {
    print(user_id);
    var url = "${Constant().domain}/GetDataUser/$user_id";
    var result = await http.get(Uri.parse(url));
    //print(result.body);
    return RequestResult(true, jsonDecode(result.body));
  } catch (e) {
    print(e);
    return RequestResult(true, "");
  }
}

