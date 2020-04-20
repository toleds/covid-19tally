
class CovidWorld {
    int active;
    int affectedCountries;
    int cases;
    double casesPerOneMillion;
    int critical;
    int deaths;
    double deathsPerOneMillion;
    int recovered;
    int tests;
    double testsPerOneMillion;
    int todayCases;
    int todayDeaths;
    int updated;

    CovidWorld({this.active, this.affectedCountries, this.cases, this.casesPerOneMillion, this.critical, this.deaths, this.deathsPerOneMillion, this.recovered, this.tests, this.testsPerOneMillion, this.todayCases, this.todayDeaths, this.updated});

    factory CovidWorld.fromJson(Map<String, dynamic> json) {
        return CovidWorld(
            active: json['active'], 
            affectedCountries: json['affectedCountries'], 
            cases: json['cases'], 
            casesPerOneMillion: double.parse(json['casesPerOneMillion'] == null ? "0.0" : json['casesPerOneMillion'].toString()),
            critical: json['critical'], 
            deaths: json['deaths'], 
            deathsPerOneMillion: double.parse(json['deathsPerOneMillion'] == null ? "0.0" : json['deathsPerOneMillion'].toString()),
            recovered: json['recovered'], 
            tests: json['tests'], 
            testsPerOneMillion: double.parse(json['testsPerOneMillion'] == null ? "0.0" : json['testsPerOneMillion'].toString()),
            todayCases: json['todayCases'], 
            todayDeaths: json['todayDeaths'], 
            updated: json['updated'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['active'] = this.active;
        data['affectedCountries'] = this.affectedCountries;
        data['cases'] = this.cases;
        data['casesPerOneMillion'] = this.casesPerOneMillion;
        data['critical'] = this.critical;
        data['deaths'] = this.deaths;
        data['deathsPerOneMillion'] = this.deathsPerOneMillion;
        data['recovered'] = this.recovered;
        data['tests'] = this.tests;
        data['testsPerOneMillion'] = this.testsPerOneMillion;
        data['todayCases'] = this.todayCases;
        data['todayDeaths'] = this.todayDeaths;
        data['updated'] = this.updated;
        return data;
    }
}