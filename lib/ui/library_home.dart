import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:provider/provider.dart';
import 'package:touchlesspro_back4app/constants/popupmenu_constants.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/models/subscriber.dart';
import 'package:touchlesspro_back4app/services/parse_auth_service.dart';
import 'package:touchlesspro_back4app/ui/blinking_text.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:touchlesspro_back4app/models/session_booking.dart';
import 'package:touchlesspro_back4app/ui/timings_info.dart';

class LibraryHome extends StatefulWidget {
  final ServicePoint servicePoint;
  final Map<String, String> authObject;
  final Subscriber subscriber;
  const LibraryHome(
      {Key key, this.servicePoint, this.authObject, this.subscriber})
      : super(key: key);

  @override
  _LibraryHomeState createState() => _LibraryHomeState();
}

class _LibraryHomeState extends State<LibraryHome> {
  CountdownTimerController subscriptionDaysController;
  CountdownTimerController sessionHoursController;
  String qrCode;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  SessionBooking booking;

  void _setSessionEndTime(SessionBooking booking) {
    if (widget.subscriber.sessionStatus == SessionStatus.inside) {
      DateTime endDateTime = booking.timing.toLocal().add(
            Duration(hours: widget.subscriber.slot + booking.extension),
          );
      int endTime = endDateTime.millisecondsSinceEpoch;
      sessionHoursController =
          CountdownTimerController(endTime: endTime, onEnd: onEnd);
    }
  }

  void _setSubscriptionEndTime() {
    DateTime endDateTime = widget.subscriber.approvedAt.toLocal().add(Duration(
        days:
            (widget.subscriber.planMonths * 30) + widget.subscriber.extension));
    int endTime = endDateTime.millisecondsSinceEpoch;
    subscriptionDaysController =
        CountdownTimerController(endTime: endTime, onEnd: onEnd);
  }

  @override
  void initState() {
    _setSubscriptionEndTime();
    // getBooking if booking is null
    // _setSessionEndTime(booking);
    super.initState();
  }

  void onEnd() {
    print('onEnd');
  }

  @override
  void dispose() {
    // controller.disposeTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   elevation: 0,
        //   leading: Builder(
        //     builder: (BuildContext context) => IconButton(
        //       icon: const Icon(
        //         Icons.menu,
        //         color: Colors.teal,
        //       ),
        //       onPressed: () {
        //         Scaffold.of(context).openDrawer();
        //       },
        //     ),
        //   ),
        // ),
        drawer: DrawerMenu(
          servicePoint: widget.servicePoint,
          subscriber: widget.subscriber,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.teal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          child: (widget.subscriber.sessionStatus == SessionStatus.outside)
              ? Text('Scan')
              : Text('End'),
          onPressed: (widget.subscriber.sessionStatus == SessionStatus.outside)
              ? _onScanPressed
              : _onEndPressed,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Stack(
          children: <Widget>[
            // Main Body
            Container(
              margin: EdgeInsets.fromLTRB(4.0, 30.0, 4.0, 60.0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // timer showing days left in subscription
                  CountdownTimer(
                    controller: subscriptionDaysController,
                    widgetBuilder: (context, remainingTime) => Center(
                      child: (remainingTime.days >= 5)
                          ? Text(
                              '${remainingTime.days} days left!',
                              style:
                                  TextStyle(color: Colors.teal, fontSize: 24.0),
                            )
                          : BlinkingText(
                              'Only ${remainingTime.days} days left!',
                              TextStyle(color: Colors.red, fontSize: 24.0),
                            ),
                    ),
                  ),
                  Card(
                    elevation: 5.0,
                    shadowColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    color: Colors.teal,
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(8.0),
                      height: MediaQuery.of(context).size.height * 0.25,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${statusToName[widget.subscriber.sessionStatus]}',
                            style:
                                TextStyle(color: Colors.white, fontSize: 24.0),
                          ),
                          if (widget.subscriber.sessionStatus ==
                              SessionStatus.inside)
                            FutureBuilder<SessionBooking>(
                              future: ParseAuthService.getSessionBooking(
                                  widget.servicePoint, widget.subscriber.token),
                              builder: (BuildContext context,
                                  AsyncSnapshot<SessionBooking> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else {
                                  if (snapshot.hasData) {
                                    _setSessionEndTime(snapshot.data);
                                    return CountdownTimer(
                                        controller: sessionHoursController,
                                        widgetBuilder:
                                            (context, remainingTime) {
                                          print(
                                              'remaining hours: ${remainingTime.hours}');
                                          return (remainingTime.hours >= 1)
                                              ? Text(
                                                  '${remainingTime.hours} hours left!',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24.0),
                                                )
                                              : BlinkingText(
                                                  'Only ${remainingTime.min} mins left!',
                                                  TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 24.0),
                                                );
                                        });
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                }
                              },
                            )
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: 5.0,
                    shadowColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    color: Colors.teal,
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(8.0),
                      height: MediaQuery.of(context).size.height * 0.25,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Text(
                        '${widget.subscriber.approvedAt.toLocal()}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6.0, 6.0, 6.0, 0.0),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Builder(
                    builder: (BuildContext context) => IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.teal,
                        size: 32.0,
                      ),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                  actions: <Widget>[
                    IconButton(
                      color: Colors.teal,
                      icon: Icon(Icons.notifications),
                      onPressed: () {},
                    ),
                    SizedBox(
                      width: 2.0,
                    ),
                    PopupMenuButton<PopupOption>(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.teal,
                      ),
                      itemBuilder: (BuildContext context) {
                        return PopupMenuConstants.choices
                            .map((PopupOption choice) =>
                                PopupMenuItem<PopupOption>(
                                  child: Text(
                                    PopupMenuConstants.optionsToString[choice],
                                  ),
                                  value: choice,
                                ))
                            .toList();
                      },
                      onSelected: choiceAction,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void choiceAction(PopupOption choice) async {
    switch (choice) {
      case PopupOption.openingTimes:
        {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => TimingsInfo(servicePoint: widget.servicePoint),
            fullscreenDialog: true,
          ));
        }
        break;
      case PopupOption.location:
        {}
        break;
      case PopupOption.nearestLibraries:
        {}
        break;
      case PopupOption.feedback:
        {}
        break;
    }
  }

  void _callSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _onScanPressed() async {
    // when sessionStatus is outside
    qrCode = await scanner.scan();
    if (qrCode == null)
      _callSnackBar('code not found, scanning failed');
    else {
      print(qrCode);
      SessionBooking newBooking = SessionBooking(
        token: qrCode,
        timing: DateTime.now(),
        status: SessionStatus.inside,
        extension: 0,
      );
      // create user session
      final auth = Provider.of<ParseAuthService>(context, listen: false);
      newBooking = await auth.startBooking(
          widget.servicePoint, widget.subscriber, newBooking);
      if (newBooking.success) {
        // update user session
        setState(() {
          widget.subscriber.sessionStatus = SessionStatus.inside;
          booking = newBooking;
          _setSessionEndTime(newBooking);
        });
      } else {
        _callSnackBar('Could not capture session. Try again!');
      }
    }
  }

  void _onEndPressed() async {
    // when sessionStatus is inside
    // end user session
    SessionBooking booking = SessionBooking(
      token: '',
      timing: DateTime.now(),
      status: SessionStatus.outside,
      extension: 0,
    );
    final auth = Provider.of<ParseAuthService>(context, listen: false);
    booking =
        await auth.endBooking(widget.servicePoint, widget.subscriber, booking);
    if (booking.success) {
      // update user session
      setState(() {
        widget.subscriber.sessionStatus = SessionStatus.outside;
      });
      // navigate out of library home
      Navigator.of(context).pop();
    } else {
      _callSnackBar('Could not end session. Try again!');
    }
  }
}

class DrawerMenu extends StatefulWidget {
  final ServicePoint servicePoint;
  final Subscriber subscriber;
  DrawerMenu({Key key, this.servicePoint, this.subscriber}) : super(key: key);

  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  int _selectedIndex;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.teal),
            currentAccountPicture: CircleAvatar(
              radius: 32.0,
              backgroundColor: Colors.teal[200],
              backgroundImage: null,
              child: Icon(
                Icons.camera_alt,
                size: 30.0,
                color: Colors.teal[800],
              ),
            ),
            accountName: Text(
              widget.subscriber.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              '(${widget.subscriber.phone.number})',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          // 1. Sessions History
          // 2. Renew Subscription
          // 3. User Settings
          // 4. About App
          // 5. Rate App
          // 6. Share App
          ListTile(),
        ],
      ),
    );
  }
}
