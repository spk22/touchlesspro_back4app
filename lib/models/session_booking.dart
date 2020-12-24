enum SessionStatus { inside, outside }

class SessionBooking {
  String token;
  bool success; // result of booking operation
  DateTime timing;
  int extension; // in hours
  SessionStatus status; // desired status
  SessionBooking({this.token, this.timing, this.status, this.extension});
}

Map<String, SessionStatus> nameToStatus = {
  'inside': SessionStatus.inside,
  'outside': SessionStatus.outside,
};

Map<SessionStatus, String> statusToName = {
  SessionStatus.inside: 'inside',
  SessionStatus.outside: 'outside',
};
