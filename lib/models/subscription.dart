import 'dart:convert';

enum Subscription { Monthly, Quarterly, HalfYearly, Annually }

Map<Subscription, String> subscriptionToName = {
  Subscription.Monthly: 'Monthly',
  Subscription.Quarterly: 'Quarterly',
  Subscription.HalfYearly: 'Half-Yearly',
  Subscription.Annually: 'Annually',
};

Map<String, Subscription> nameToSubscription = {
  'Monthly': Subscription.Monthly,
  'Quarterly': Subscription.Quarterly,
  'Half-Yearly': Subscription.HalfYearly,
  'Annually': Subscription.Annually,
};

Map<String, int> durationMap = {
  'Monthly': 1,
  'Quarterly': 3,
  'Half-Yearly': 6,
  'Annually': 12,
};

// To parse this JSON data, do
//
//     final plan = planFromJson(jsonString);

SubscriptionPlan planFromJson(String str) =>
    SubscriptionPlan.fromJson(json.decode(str));

String planToJson(SubscriptionPlan data) => json.encode(data.toJson());

class SubscriptionPlan {
  SubscriptionPlan({
    this.sixone,
    this.sixthree,
    this.sixsix,
    this.sixtwelve,
    this.nineone,
    this.ninethree,
    this.ninesix,
    this.ninetwelve,
    this.twelveone,
    this.twelvethree,
    this.twelvesix,
    this.twelvetwelve,
  });

  String sixone;
  String sixthree;
  String sixsix;
  String sixtwelve;
  String nineone;
  String ninethree;
  String ninesix;
  String ninetwelve;
  String twelveone;
  String twelvethree;
  String twelvesix;
  String twelvetwelve;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) =>
      SubscriptionPlan(
        sixone: json["sixone"],
        sixthree: json["sixthree"],
        sixsix: json["sixsix"],
        sixtwelve: json["sixtwelve"],
        nineone: json["nineone"],
        ninethree: json["ninethree"],
        ninesix: json["ninesix"],
        ninetwelve: json["ninetwelve"],
        twelveone: json["twelveone"],
        twelvethree: json["twelvethree"],
        twelvesix: json["twelvesix"],
        twelvetwelve: json["twelvetwelve"],
      );

  Map<String, dynamic> toJson() => {
        "sixone": sixone,
        "sixthree": sixthree,
        "sixsix": sixsix,
        "sixtwelve": sixtwelve,
        "nineone": nineone,
        "ninethree": ninethree,
        "ninesix": ninesix,
        "ninetwelve": ninetwelve,
        "twelveone": twelveone,
        "twelvethree": twelvethree,
        "twelvesix": twelvesix,
        "twelvetwelve": twelvetwelve,
      };
}
