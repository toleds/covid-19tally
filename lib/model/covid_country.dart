
import 'country_info.dart';

class CovidCountry {
    int active;
    int cases;
    double casesPerOneMillion;
    String country;
    CountryInfo countryInfo;
    int critical;
    int deaths;
    double deathsPerOneMillion;
    int recovered;
    int todayCases;
    int todayDeaths;
    int updated;
    int tests;
    double testsPerOneMillion;

    CovidCountry({this.active, this.cases, this.casesPerOneMillion, this.country, this.countryInfo, this.critical, this.deaths, this.deathsPerOneMillion, this.recovered, this.todayCases, this.todayDeaths, this.updated, this.tests, this.testsPerOneMillion});

    factory CovidCountry.fromJson(Map<String, dynamic> json) {
        return CovidCountry(
            active: json['active'], 
            cases: json['cases'], 
            casesPerOneMillion: double.parse(json['casesPerOneMillion'] == null ? "0.0" : json['casesPerOneMillion'].toString()),
            country: json['country'],
            countryInfo: json['countryInfo'] != null ? CountryInfo.fromJson(json['countryInfo']) : null,
            critical: json['critical'], 
            deaths: json['deaths'], 
            deathsPerOneMillion: double.parse(json['deathsPerOneMillion'] == null ? "0.0" : json['deathsPerOneMillion'].toString()),
            recovered: json['recovered'], 
            todayCases: json['todayCases'], 
            todayDeaths: json['todayDeaths'], 
            updated: json['updated'],
            tests: json['tests'],
            testsPerOneMillion: double.parse(json['testsPerOneMillion'] == null ? "0.0" : json['testsPerOneMillion'].toString()),
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['active'] = this.active;
        data['cases'] = this.cases;
        data['casesPerOneMillion'] = this.casesPerOneMillion;
        data['country'] = this.country;
        data['critical'] = this.critical;
        data['deaths'] = this.deaths;
        data['deathsPerOneMillion'] = this.deathsPerOneMillion;
        data['recovered'] = this.recovered;
        data['todayCases'] = this.todayCases;
        data['todayDeaths'] = this.todayDeaths;
        data['updated'] = this.updated;
        data['tests'] = this.tests;
        data['testsPerOneMillion'] = this.testsPerOneMillion;
        if (this.countryInfo != null) {
            data['countryInfo'] = this.countryInfo.toJson();
        }
        return data;
    }
}