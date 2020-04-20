import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;


NetworkUtil netUtil = new NetworkUtil();

class NetworkUtil {
  static NetworkUtil _instance = new NetworkUtil.internal();
  NetworkUtil.internal();
  factory NetworkUtil() => _instance;

  final JsonDecoder _decoder = new JsonDecoder();

  Future<dynamic> get(String url, {Map<String, String> inpHeaders}) async {
    Map<String, String> headers = new Map<String, String>();
    headers.addAll(inpHeaders);
    print(" toleds network util get url >>> $url");
    return http.get(url, headers: headers).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return _decoder.convert(res);
    }).catchError((Object error) {
      print(error.toString());
      throw new Exception(error.toString());
    });
  }

  Future<dynamic> post(String url, {Map<String, String> inpHeaders, body, encoding}) async {
    Map<String, String> headers = new Map<String, String>();
    headers.addAll(inpHeaders);
    return http.post(url, body: body, headers: headers, encoding: encoding).then((http.Response response) {
      final int statusCode = response.statusCode;
      final String res = response.body;
      if (statusCode < 200 || statusCode >= 500 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return _decoder.convert(res);
    }).catchError((Object error) {
      print(error.toString());
      throw new Exception(error.toString());
    });
  }

  Future<dynamic> put(String url, {Map<String, String> inpHeaders, body, encoding}) async {
    Map<String, String> headers = new Map<String, String>();
    headers.addAll(inpHeaders);
    return http.put(url, body: body, headers: headers, encoding: encoding).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 500 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return _decoder.convert(res);
    }).catchError((Object error) {
      print(error.toString());
      throw new Exception(error.toString());
    });
  }

  Future<dynamic> delete(String url, {Map<String, String> inpHeaders}) async {
    Map<String, String> headers = new Map<String, String>();
    headers.addAll(inpHeaders);
    return http.delete(url, headers: headers).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 500 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return _decoder.convert(res);
    }).catchError((Object error) {
      print(error.toString());
      throw new Exception(error.toString());
    });
  }

  Future<dynamic> patch(String url, {Map<String, String> inpHeaders}) async {
    Map<String, String> headers = new Map<String, String>();
    headers.addAll(inpHeaders);
    return http.patch(url, headers: headers).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 500 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return _decoder.convert(res);
    }).catchError((Object error) {
      print(error.toString());
      throw new Exception(error.toString());
    });
  }
}
