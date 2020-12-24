import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/models/subscriber.dart';
import 'package:touchlesspro_back4app/services/parse_auth_service.dart';
import 'package:provider/provider.dart';
import 'package:touchlesspro_back4app/models/session_booking.dart';

class SubscriberInfo extends StatefulWidget {
  final Subscriber subscriber;
  final PaymentStatus paymentStatus;
  final ServicePoint servicePoint;
  final ValueChanged<int> delegateListUpdate;
  const SubscriberInfo(
      {Key key,
      this.subscriber,
      this.paymentStatus,
      this.servicePoint,
      this.delegateListUpdate})
      : super(key: key);

  @override
  _SubscriberInfoState createState() => _SubscriberInfoState();
}

class _SubscriberInfoState extends State<SubscriberInfo> {
  bool isChanged = false;
  double incrementByAdmin = 0;
  CountdownTimerController controller;

  void _setSubscriptionEndTime() {
    DateTime endDateTime = widget.subscriber.approvedAt.toLocal().add(Duration(
        days:
            (widget.subscriber.planMonths * 30) + widget.subscriber.extension));
    int endTime = endDateTime.millisecondsSinceEpoch;
    controller = CountdownTimerController(endTime: endTime, onEnd: onEnd);
  }

  void onEnd() {
    print('onEnd');
  }

  @override
  void initState() {
    if (widget.paymentStatus == PaymentStatus.Paid) _setSubscriptionEndTime();
    super.initState();
  }

  @override
  void dispose() {
    controller.disposeTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscriber Info'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 30.0),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _table(),
              ),
              SizedBox(height: 20.0),
              if (widget.paymentStatus == PaymentStatus.Paid)
                // integral touch spinner here
                Slider(
                  value: incrementByAdmin,
                  min: 0,
                  max: 30,
                  divisions: 30,
                  label: incrementByAdmin.floor().toString(),
                  activeColor: Colors.teal,
                  onChanged: (double value) {
                    setState(() {
                      incrementByAdmin = value;
                      isChanged = true;
                    });
                  },
                ),
              // TouchSpin(
              //   min: 0,
              //   max: 29,
              //   step: 1,
              //   value: 0,
              //   textStyle: TextStyle(fontSize: 36),
              //   iconSize: 48.0,
              //   addIcon: Icon(Icons.add_circle_outline, color: Colors.teal),
              //   subtractIcon:
              //       Icon(Icons.remove_circle_outline, color: Colors.teal),
              //   iconPadding: EdgeInsets.all(20),
              //   onChanged: (val) {
              //     setState(() {
              //       incrementByAdmin = val;
              //       isChanged = true;
              //     });
              //   },
              // ),
              SizedBox(height: 40.0),
              if (isChanged)
                MaterialButton(
                  color: Colors.teal,
                  onPressed: () async {
                    final auth =
                        Provider.of<ParseAuthService>(context, listen: false);
                    await auth.incrementDaysBy(incrementByAdmin.floor(),
                        widget.servicePoint, widget.subscriber);
                    widget.delegateListUpdate(
                        incrementByAdmin.floor() + widget.subscriber.extension);
                  },
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _table() {
    return Table(
      border: TableBorder.all(width: 2.0, color: Colors.teal),
      children: <TableRow>[
        TableRow(
          children: [
            TableCell(
              child: SizedBox(
                height: 30.0,
                child: Center(child: Text('Name')),
              ),
              verticalAlignment: TableCellVerticalAlignment.middle,
            ),
            TableCell(
              child: SizedBox(
                height: 30.0,
                child: Center(child: Text(widget.subscriber.name)),
              ),
              verticalAlignment: TableCellVerticalAlignment.middle,
            ),
          ],
        ),
        TableRow(
          children: <TableCell>[
            TableCell(
              child: SizedBox(
                height: 30.0,
                child: Center(child: Text('Phone')),
              ),
              verticalAlignment: TableCellVerticalAlignment.middle,
            ),
            TableCell(
              child: SizedBox(
                height: 30.0,
                child: Center(child: Text(widget.subscriber.phone.number)),
              ),
              verticalAlignment: TableCellVerticalAlignment.middle,
            ),
          ],
        ),
        TableRow(
          children: [
            TableCell(
              child: SizedBox(
                height: 30.0,
                child: Center(child: Text('Preparing For')),
              ),
              verticalAlignment: TableCellVerticalAlignment.middle,
            ),
            TableCell(
              child: SizedBox(
                height: 30.0,
                child: Center(child: Text(widget.subscriber.preparingFor)),
              ),
              verticalAlignment: TableCellVerticalAlignment.middle,
            ),
          ],
        ),
        TableRow(
          children: [
            TableCell(
              child: SizedBox(
                height: 30.0,
                child: Center(child: Text('Slot (hours)')),
              ),
              verticalAlignment: TableCellVerticalAlignment.middle,
            ),
            TableCell(
              child: SizedBox(
                height: 30.0,
                child: Center(child: Text(widget.subscriber.slot.toString())),
              ),
              verticalAlignment: TableCellVerticalAlignment.middle,
            ),
          ],
        ),
        TableRow(
          children: [
            TableCell(
              child: SizedBox(
                height: 30.0,
                child: Center(child: Text('Duration (months)')),
              ),
              verticalAlignment: TableCellVerticalAlignment.middle,
            ),
            TableCell(
              child: SizedBox(
                height: 30.0,
                child: Center(
                    child: Text(widget.subscriber.planMonths.toString())),
              ),
              verticalAlignment: TableCellVerticalAlignment.middle,
            ),
          ],
        ),
        TableRow(
          children: [
            TableCell(
              child: SizedBox(
                height: 30.0,
                child: Center(child: Text('Subscription Fee')),
              ),
              verticalAlignment: TableCellVerticalAlignment.middle,
            ),
            TableCell(
              child: SizedBox(
                height: 30.0,
                child: Center(
                    child: Text(
                        '\u{20B9} ' + widget.subscriber.planFee.toString())),
              ),
              verticalAlignment: TableCellVerticalAlignment.middle,
            ),
          ],
        ),
        TableRow(
          children: [
            TableCell(
              child: SizedBox(
                height: 30.0,
                child: Center(child: Text('OTP')),
              ),
              verticalAlignment: TableCellVerticalAlignment.middle,
            ),
            TableCell(
              child: SizedBox(
                height: 50.0,
                child: Center(
                    child: Container(
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    border: Border.all(),
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.subscriber.otp.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                  ),
                )),
              ),
              verticalAlignment: TableCellVerticalAlignment.middle,
            ),
          ],
        ),
        if (widget.paymentStatus == PaymentStatus.Paid)
          TableRow(
            children: [
              TableCell(
                child: SizedBox(
                  height: 30.0,
                  child: Center(child: Text('Days Left')),
                ),
                verticalAlignment: TableCellVerticalAlignment.middle,
              ),
              TableCell(
                child: SizedBox(
                  height: 30.0,
                  child: Center(child: _daysLeftText(context)),
                ),
                verticalAlignment: TableCellVerticalAlignment.middle,
              ),
            ],
          ),
        if (widget.paymentStatus == PaymentStatus.Paid)
          TableRow(
            children: [
              TableCell(
                child: SizedBox(
                  height: 30.0,
                  child: Center(child: Text('Status')),
                ),
                verticalAlignment: TableCellVerticalAlignment.middle,
              ),
              TableCell(
                child: SizedBox(
                  height: 30.0,
                  child: Center(
                      child:
                          Text(statusToName[widget.subscriber.sessionStatus])),
                ),
                verticalAlignment: TableCellVerticalAlignment.middle,
              ),
            ],
          ),
      ],
    );
  }

  _daysLeftText(BuildContext context) {
    return CountdownTimer(
      controller: controller,
      widgetBuilder: (context, remainingTime) =>
          Text('${remainingTime.days + incrementByAdmin}'),
    );
  }
}
