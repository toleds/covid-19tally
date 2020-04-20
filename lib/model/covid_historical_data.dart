import 'package:covid19/model/Timeline.dart';

class CovidHistoricalData {
    String country;
    List<String> provinces;
    Timeline timeline;

    CovidHistoricalData({this.country, this.provinces, this.timeline});

    factory CovidHistoricalData.fromJson(Map<String, dynamic> json) {
        return CovidHistoricalData(
            country: json['country'], 
            provinces: json['provinces'] != null ? new List<String>.from(json['provinces']) : null, 
            timeline: json['timeline'] != null ? Timeline.fromJson(json['timeline']) : null, 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['country'] = this.country;
        if (this.provinces != null) {
            data['provinces'] = this.provinces;
        }
        if (this.timeline != null) {
            data['timeline'] = this.timeline.toJson();
        }
        return data;
    }
}