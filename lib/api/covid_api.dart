import 'dart:io';

import 'network_util.dart';

class CovidAPI {
  NetworkUtil _netUtil = new NetworkUtil();

  Future<Map<String, dynamic>> getCountry(String country) {
    String url = "https://corona.lmao.ninja/v2/countries/$country";
    Map<String, String> _inpHeaders = {
      HttpHeaders.contentTypeHeader: "application/json"
    };

    return _netUtil.get(url, inpHeaders: _inpHeaders).then((response) {
      return response as Map<String, dynamic>;
    }).catchError((error) {
      print(error.toString());
    });
  }

  Future<Map<String, dynamic>> getWorld() {
    String url = "https://corona.lmao.ninja/v2/all";
    Map<String, String> _inpHeaders = {
      HttpHeaders.contentTypeHeader: "application/json"
    };

    return _netUtil.get(url, inpHeaders: _inpHeaders).then((response) {
      return response as Map<String, dynamic>;
    }).catchError((error) {
      print(error.toString());
    });
  }

  Future<Map<String, dynamic>> getHistory(String country, {int filter:0}) {
    String url = "https://corona.lmao.ninja/v2/historical/$country?lastdays=${filter > 0 ? filter : 'all'}";
    Map<String, String> _inpHeaders = {
      HttpHeaders.contentTypeHeader: "application/json"
    };

    return _netUtil.get(url, inpHeaders: _inpHeaders).then((response) {
      return response as Map<String, dynamic>;
    }).catchError((error) {
      print(error.toString());
    });
  }

  Future<Iterable> getCountries() {
    String url = "https://corona.lmao.ninja/v2/countries?sort=cases";
    Map<String, String> _inpHeaders = {
      HttpHeaders.contentTypeHeader: "application/json"
    };

    return _netUtil.get(url, inpHeaders: _inpHeaders).then((response) {
      return response as Iterable;
    }).catchError((error) {
      print(error.toString());
    });
  }



}