import 'dart:convert';

LibraryAnnouncement announcementFromJson(String str) =>
    LibraryAnnouncement.fromJson(json.decode(str));
String announcementToJson(LibraryAnnouncement data) =>
    json.encode(data.toJson());

class LibraryAnnouncement {
  String message;
  LibraryAnnouncement({this.message});

  factory LibraryAnnouncement.fromJson(Map<String, dynamic> jsonMap) =>
      LibraryAnnouncement(
        message: jsonMap['message'],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
      };
}
