class CountryInfo {
    int id;
    String flag;
    String iso2;
    String iso3;
    double lat;
    double long;

    CountryInfo({this.id, this.flag, this.iso2, this.iso3, this.lat, this.long});

    factory CountryInfo.fromJson(Map<String, dynamic> json) {
        return CountryInfo(
            id: json['_id'],
            flag: json['flag'], 
            iso2: json['iso2'], 
            iso3: json['iso3'], 
            lat: double.parse(json['lat'] == null ? "0.0" : json['lat'].toString()),
            long: double.parse(json['long'] == null ? "0.0" : json['long'].toString()),
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['_id'] = this.id;
        data['flag'] = this.flag;
        data['iso2'] = this.iso2;
        data['iso3'] = this.iso3;
        data['lat'] = this.lat;
        data['long'] = this.long;
        return data;
    }
}