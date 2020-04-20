import 'key_value.dart';

class Timeline {
    List<KeyValuePair> cases;
    List<KeyValuePair> deaths;
    List<KeyValuePair> recovered;

    Timeline({this.cases, this.deaths, this.recovered});

    factory Timeline.fromJson(Map<String, dynamic> json) {
        List<KeyValuePair> cases = [];
        List<KeyValuePair> deaths = [];
        List<KeyValuePair> recovered = [];

        if (json['cases'] != null)
            json['cases'].entries.forEach((e) => cases.add(KeyValuePair(name:e.key, value:e.value)));
        if (json['deaths'] != null)
            json['deaths'].entries.forEach((e) => deaths.add(KeyValuePair(name:e.key, value:e.value)));
        if (json['recovered'] != null)
            json['recovered'].entries.forEach((e) => recovered.add(KeyValuePair(name:e.key, value:e.value)));

        return Timeline(
            cases: cases,
            deaths: deaths,
            recovered: recovered
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        if (this.cases != null) {
            data['cases'] = Map.fromIterable(this.cases, key: (e) => e.key, value: (e) => e.value);
        }
        if (this.deaths != null) {
            data['deaths'] = Map.fromIterable(this.deaths, key: (e) => e.key, value: (e) => e.value);
        }
        if (this.recovered != null) {
            data['recovered'] = Map.fromIterable(this.recovered, key: (e) => e.key, value: (e) => e.value);
        }
        return data;
    }
}