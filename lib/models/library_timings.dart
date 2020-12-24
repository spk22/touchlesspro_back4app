import 'dart:convert';

enum Clopen { closed, open }

Map<Clopen, String> clopenToName = {
  Clopen.closed: 'closed',
  Clopen.open: 'open',
};

Map<String, Clopen> nameToClopen = {
  'closed': Clopen.closed,
  'open': Clopen.open,
};

// To parse this JSON data, do
//
//     final timings = timingsFromJson(jsonString);

LibraryTimings timingsFromJson(String str) =>
    LibraryTimings.fromJson(json.decode(str));

String timingsToJson(LibraryTimings data) => json.encode(data.toJson());

class LibraryTimings {
  LibraryTimings({
    this.sunday,
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
  });

  LibraryDay sunday;
  LibraryDay monday;
  LibraryDay tuesday;
  LibraryDay wednesday;
  LibraryDay thursday;
  LibraryDay friday;
  LibraryDay saturday;

  factory LibraryTimings.fromJson(Map<String, dynamic> json) => LibraryTimings(
        sunday: LibraryDay.fromJson(json["sunday"]),
        monday: LibraryDay.fromJson(json["monday"]),
        tuesday: LibraryDay.fromJson(json["tuesday"]),
        wednesday: LibraryDay.fromJson(json["wednesday"]),
        thursday: LibraryDay.fromJson(json["thursday"]),
        friday: LibraryDay.fromJson(json["friday"]),
        saturday: LibraryDay.fromJson(json["saturday"]),
      );

  Map<String, dynamic> toJson() => {
        "sunday": sunday.toJson(),
        "monday": monday.toJson(),
        "tuesday": tuesday.toJson(),
        "wednesday": wednesday.toJson(),
        "thursday": thursday.toJson(),
        "friday": friday.toJson(),
        "saturday": saturday.toJson(),
      };
}

class LibraryDay {
  LibraryDay({
    this.clopen,
    this.opening,
    this.closing,
  });

  Clopen clopen;
  Moment opening;
  Moment closing;

  factory LibraryDay.fromJson(Map<String, dynamic> json) => LibraryDay(
        clopen: nameToClopen[json["clopen"]],
        opening: Moment.fromJson(json["opening"]),
        closing: Moment.fromJson(json["closing"]),
      );

  Map<String, dynamic> toJson() => {
        "clopen": clopenToName[clopen],
        "opening": opening.toJson(),
        "closing": closing.toJson(),
      };
}

class Moment {
  Moment({
    this.hr,
    this.min,
  });

  int hr;
  int min;

  factory Moment.fromJson(Map<String, dynamic> json) => Moment(
        hr: json["hr"],
        min: json["min"],
      );

  Map<String, dynamic> toJson() => {
        "hr": hr,
        "min": min,
      };
}
