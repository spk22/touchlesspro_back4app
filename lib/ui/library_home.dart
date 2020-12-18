import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:touchlesspro_back4app/constants/popupmenu_constants.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/models/subscriber.dart';
import 'package:touchlesspro_back4app/ui/blinking_text.dart';

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
  CountdownTimerController controller;

  void _setSubscriptionEndTime() {
    DateTime endDateTime = widget.subscriber.approvedAt.toLocal().add(Duration(
        days:
            (widget.subscriber.planMonths * 30) + widget.subscriber.extension));
    int endTime = endDateTime.millisecondsSinceEpoch;
    controller = CountdownTimerController(endTime: endTime, onEnd: onEnd);
  }

  @override
  void initState() {
    _setSubscriptionEndTime();
    super.initState();
  }

  void onEnd() {
    print('onEnd');
  }

  @override
  void dispose() {
    controller.disposeTimer();
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
          onPressed: () {},
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
                    controller: controller,
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
                      child: Text(
                        'You subscribed at',
                        style: TextStyle(color: Colors.white),
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

  void choiceAction(PopupOption choice) {
    switch (choice) {
      case PopupOption.openingTimes:
        {}
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
