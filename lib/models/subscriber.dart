import 'package:touchlesspro_back4app/models/phone_details.dart';

class Subscriber {
  String uid;
  String name;
  String preparingFor;
  int slot;
  int planMonths;
  int planFee;
  PhoneDetails phone;
  int otp;
  Subscriber(
      {this.name,
      this.preparingFor,
      this.slot,
      this.planMonths,
      this.planFee,
      this.phone});
  Subscriber.withUid(
      {this.uid,
      this.name,
      this.preparingFor,
      this.slot,
      this.planMonths,
      this.planFee,
      this.phone,
      this.otp});
}

class SubscriberGroup {
  List<Subscriber> paidSubscribers;
  List<Subscriber> unpaidSubscribers;
  SubscriberGroup({this.paidSubscribers, this.unpaidSubscribers});
}

class Status {
  Subscriber subscriber;
  bool isSubscribed;
  bool isApproved;
  Status(this.isSubscribed, this.isApproved);
}
