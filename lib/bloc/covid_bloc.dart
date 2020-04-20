import 'package:covid19/api/covid_api.dart';
import 'package:covid19/bloc/base_bloc.dart';
import 'package:covid19/model/covid_country.dart';
import 'package:covid19/model/covid_historical_data.dart';
import 'package:covid19/model/covid_world.dart';
import 'package:covid19/model/key_value.dart';
import 'package:rxdart/rxdart.dart';

class CovidBloc implements Bloc {
  final CovidAPI api = new CovidAPI();
  final countriesController = BehaviorSubject<List<CovidCountry>>();
  final worldController = BehaviorSubject<CovidWorld>();
  final countryController = BehaviorSubject<CovidCountry>();
  final historyController = BehaviorSubject<CovidHistoricalData>();
  final colorController = BehaviorSubject<bool>();
  final daysController = BehaviorSubject<KeyValuePair>();

  Observable<List<CovidCountry>> get countries => countriesController.stream;
  Observable<CovidWorld> get world => worldController.stream;
  Observable<CovidCountry> get country => countryController.stream;
  Observable<CovidHistoricalData> get history => historyController.stream;
  Observable<bool> get color => colorController.stream;
  Observable<KeyValuePair> get days => daysController.stream;

  Future<void> fetchCountries() async {
    return await api.getCountries().then((json) {
      countriesController.sink.add(json.map((model) => CovidCountry.fromJson(model)).toList());
    }).catchError((onError) => print(onError));
  }

  Future<void>  fetchCountry(String country) async {
    return await api.getCountry(country).then((json) {
      countryController.sink.add(CovidCountry.fromJson(json));
    }).catchError((onError) => print(onError));
  }

  Future<void>  fetchWorld() async {
    return await api.getWorld().then((json) {
      worldController.sink.add(CovidWorld.fromJson(json));
    }).catchError((onError) => print(onError));
  }

  Future<void>  fetchHistory(String country, int lastDays) async {
    return await api.getHistory(country, filter:lastDays).then((json) {
      historyController.sink.add(CovidHistoricalData.fromJson(json));
    }).catchError((onError) => print(onError));
  }

  @override
  void dispose() {
    countriesController.close();
    countryController.close();
    colorController.close();
    historyController.close();
    colorController.close();
    worldController.close();
    daysController.close();
  }


}
