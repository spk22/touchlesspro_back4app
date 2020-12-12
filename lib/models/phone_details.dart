import 'dart:convert';

// To parse this JSON data, do
//
//     final phone = phoneFromJson(jsonString);
//

PhoneDetails phoneFromJson(String str) =>
    PhoneDetails.fromJson(json.decode(str));

String phoneToJson(PhoneDetails data) => json.encode(data.toJson());

class PhoneDetails {
  String number;
  String countryCode;
  PhoneDetails({this.number, this.countryCode});

  factory PhoneDetails.fromJson(Map<String, dynamic> jsonMap) => PhoneDetails(
        number: jsonMap['number'],
        countryCode: jsonMap['countryCode'],
      );

  Map<String, dynamic> toJson() => {
        "number": number,
        "countryCode": countryCode,
      };
}
