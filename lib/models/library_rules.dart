import 'dart:convert';

// To parse this JSON data, do
//
//     final rules = rulesFromJson(jsonString);
//
// {"rules":"1. abcde\n\n2. qwert\n\n3. lmnop"}

LibraryRules rulesFromJson(String str) =>
    LibraryRules.fromJson(json.decode(str));
String rulesToJson(LibraryRules data) => json.encode(data.toJson());

class LibraryRules {
  LibraryRules({this.rules});
  String rules;

  factory LibraryRules.fromJson(Map<String, dynamic> jsonMap) => LibraryRules(
        rules: jsonMap["rules"],
      );

  Map<String, dynamic> toJson() => {
        "rules": rules,
      };
}
