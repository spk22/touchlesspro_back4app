import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class ServiceUser {
  @HiveField(0)
  Map<String, String> phone;

  ServiceUser(this.phone);

  @override
  String toString() {
    return phone.toString();
  }

  String getValue(String key) {
    return phone[key];
  }
}

class UserAdapter extends TypeAdapter<ServiceUser> {
  @override
  final typeId = 0;

  @override
  ServiceUser read(BinaryReader reader) {
    return ServiceUser(reader.read());
  }

  @override
  void write(BinaryWriter writer, ServiceUser obj) {
    writer.write(obj.phone);
  }
}
