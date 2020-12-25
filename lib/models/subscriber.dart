import 'package:touchlesspro_back4app/models/phone_details.dart';
import 'package:touchlesspro_back4app/models/session_booking.dart';

class Subscriber {
  String uid;
  String name;
  String preparingFor;
  int slot;
  int planMonths;
  int planFee;
  PhoneDetails phone;
  int otp;
  DateTime approvedAt;
  int extension;
  SessionStatus sessionStatus;
  String token;
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
      this.otp,
      this.approvedAt});
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

enum PaymentStatus { Paid, Unpaid }
