class KeyValuePair {
    String name;
    int value;

    KeyValuePair({this.name, this.value});

    factory KeyValuePair.fromJson(Map<String, dynamic> json) {
        return KeyValuePair(
            name: json['name'], 
            value: json['value'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['name'] = this.name;
        data['value'] = this.value;
        return data;
    }

    @override
    String toString() {
        return 'KeyValuePair{name: $name, value: $value}';
    }


}