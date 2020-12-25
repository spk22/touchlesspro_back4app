import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:touchlesspro_back4app/models/library_rules.dart';
import 'package:touchlesspro_back4app/models/library_timings.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/models/subscriber.dart';
import 'package:touchlesspro_back4app/models/subscription.dart';
import 'package:touchlesspro_back4app/services/image_picker_service.dart';
import 'package:touchlesspro_back4app/services/parse_auth_service.dart';
import 'package:touchlesspro_back4app/ui/regenerative_qrimage.dart';
import 'package:touchlesspro_back4app/ui/subscriber_info.dart';
import 'package:touchlesspro_back4app/ui/custom_switch.dart';

class ServiceControlPanel extends StatefulWidget {
  final ServicePoint servicePoint;
  final ValueChanged<String> setImage;
  ServiceControlPanel({Key key, this.servicePoint, this.setImage})
      : super(key: key);

  @override
  _ServiceControlPanelState createState() => _ServiceControlPanelState();
}

class _ServiceControlPanelState extends State<ServiceControlPanel> {
  String imageUrl;
  final GlobalKey<FormBuilderState> _fbKey1 = GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _fbKey2 = GlobalKey<FormBuilderState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  List<Subscriber> paidSubscribers;
  List<Subscriber> unpaidSubscribers;
  TimeOfDay selectedTime24Hour;
  Map<String, TimeOfDay> pickedTimesMap = {};
  Map<String, dynamic> savedMap;
  final _format = DateFormat("HH:mm");
  Map<String, dynamic> defaultMap = {
    "sunday": {
      "clopen": "closed",
      "opening": {"hr": 8, "min": 30},
      "closing": {"hr": 20, "min": 30}
    },
    "monday": {
      "clopen": "open",
      "opening": {"hr": 8, "min": 30},
      "closing": {"hr": 20, "min": 30}
    },
    "tuesday": {
      "clopen": "open",
      "opening": {"hr": 8, "min": 30},
      "closing": {"hr": 20, "min": 30}
    },
    "wednesday": {
      "clopen": "open",
      "opening": {"hr": 8, "min": 30},
      "closing": {"hr": 20, "min": 30}
    },
    "thursday": {
      "clopen": "open",
      "opening": {"hr": 8, "min": 30},
      "closing": {"hr": 20, "min": 30}
    },
    "friday": {
      "clopen": "open",
      "opening": {"hr": 8, "min": 30},
      "closing": {"hr": 20, "min": 30}
    },
    "saturday": {
      "clopen": "open",
      "opening": {"hr": 8, "min": 30},
      "closing": {"hr": 20, "min": 30}
    }
  };

  Future<void> _getSubscribers() async {
    SubscriberGroup subscriberGroup =
        await ParseAuthService.getSubscribers(widget.servicePoint);
    setState(() {
      paidSubscribers = subscriberGroup.paidSubscribers;
      unpaidSubscribers = subscriberGroup.unpaidSubscribers;
    });
  }

  @override
  void initState() {
    _getSubscribers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.servicePoint.serviceType == ServiceType.library)
      return _buildLibrary(context);
    else
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text('${widget.servicePoint.name}'),
          centerTitle: true,
        ),
      );
  }

  Widget _viewSwitcher() {
    Widget widget;
    switch (_selectedIndex) {
      case 0:
        widget = _settingsView();
        break;
      case 1:
        widget = _qrCodeView();
        break;
      case 2:
        widget = _usersView();
        break;
      default:
        widget = _settingsView();
    }
    return widget;
  }

  Widget _buildLibrary(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: _viewSwitcher(),
        appBar: (_selectedIndex == 2)
            ? AppBar(
                backgroundColor: Colors.teal,
                bottom: _tabBar(),
              )
            : null,
        bottomNavigationBar: _bottomNavigationBar(),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (widget.servicePoint.imageUrl != null) {
      return Image.network(widget.servicePoint.imageUrl, fit: BoxFit.cover);
    } else {
      return Icon(
        Icons.camera_alt,
        size: 80.0,
        color: Colors.teal,
      );
    }
  }

  Future<void> _chooseCoverPic(BuildContext context) async {
    final picker = Provider.of<ImagePickerService>(context, listen: false);
    final url = await picker.uploadParseImage(
      context,
      widget.servicePoint,
    );
    setState(() {
      imageUrl = url;
      if (url != null) {
        widget.setImage(imageUrl);
      }
    });
    print('upload response: $url');
  }

  Widget _feeTableWithInitialValue(Map<String, dynamic> savedMap) {
    return FormBuilder(
      key: _fbKey1,
      initialValue: savedMap,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: DataTable(
          columnSpacing: 4.0,
          dataRowHeight: 48.0,
          showBottomBorder: true,
          horizontalMargin: 4.0,
          dataTextStyle: TextStyle(color: Colors.black, fontSize: 12.0),
          columns: const <DataColumn>[
            DataColumn(
              label: Text(
                'Hours',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            DataColumn(
              label: Text(
                'Monthly',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'Quarterly',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'Half-Yearly',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'Annually',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              numeric: true,
            ),
          ],
          rows: <DataRow>[
            DataRow(
              cells: <DataCell>[
                DataCell(Text('6')),
                DataCell(
                  FormBuilderTextField(
                    attribute: 'sixone',
                    maxLines: 1,
                    keyboardType: TextInputType.phone,
                    validators: [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(),
                    ],
                  ),
                  showEditIcon: true,
                  placeholder: true,
                ),
                DataCell(
                  FormBuilderTextField(
                    attribute: 'sixthree',
                    maxLines: 1,
                    keyboardType: TextInputType.phone,
                    validators: [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(),
                    ],
                  ),
                  showEditIcon: true,
                  placeholder: true,
                ),
                DataCell(
                  FormBuilderTextField(
                    attribute: 'sixsix',
                    maxLines: 1,
                    keyboardType: TextInputType.phone,
                    validators: [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(),
                    ],
                  ),
                  showEditIcon: true,
                  placeholder: true,
                ),
                DataCell(
                  FormBuilderTextField(
                    attribute: 'sixtwelve',
                    maxLines: 1,
                    keyboardType: TextInputType.phone,
                    validators: [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(),
                    ],
                  ),
                  showEditIcon: true,
                  placeholder: true,
                ),
              ],
            ),
            DataRow(
              cells: <DataCell>[
                DataCell(Text('9')),
                DataCell(
                  FormBuilderTextField(
                    attribute: 'nineone',
                    maxLines: 1,
                    keyboardType: TextInputType.phone,
                    validators: [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(),
                    ],
                  ),
                  showEditIcon: true,
                  placeholder: true,
                ),
                DataCell(
                  FormBuilderTextField(
                    attribute: 'ninethree',
                    maxLines: 1,
                    keyboardType: TextInputType.phone,
                    validators: [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(),
                    ],
                  ),
                  showEditIcon: true,
                  placeholder: true,
                ),
                DataCell(
                  FormBuilderTextField(
                    attribute: 'ninesix',
                    maxLines: 1,
                    keyboardType: TextInputType.phone,
                    validators: [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(),
                    ],
                  ),
                  showEditIcon: true,
                  placeholder: true,
                ),
                DataCell(
                  FormBuilderTextField(
                    attribute: 'ninetwelve',
                    maxLines: 1,
                    keyboardType: TextInputType.phone,
                    validators: [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(),
                    ],
                  ),
                  showEditIcon: true,
                  placeholder: true,
                ),
              ],
            ),
            DataRow(
              cells: <DataCell>[
                DataCell(Text('12')),
                DataCell(
                  FormBuilderTextField(
                    attribute: 'twelveone',
                    maxLines: 1,
                    keyboardType: TextInputType.phone,
                    validators: [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(),
                    ],
                  ),
                  showEditIcon: true,
                  placeholder: true,
                ),
                DataCell(
                  FormBuilderTextField(
                    attribute: 'twelvethree',
                    maxLines: 1,
                    keyboardType: TextInputType.phone,
                    validators: [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(),
                    ],
                  ),
                  showEditIcon: true,
                  placeholder: true,
                ),
                DataCell(
                  FormBuilderTextField(
                    attribute: 'twelvesix',
                    maxLines: 1,
                    keyboardType: TextInputType.phone,
                    validators: [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(),
                    ],
                  ),
                  showEditIcon: true,
                  placeholder: true,
                ),
                DataCell(
                  FormBuilderTextField(
                    attribute: 'twelvetwelve',
                    maxLines: 1,
                    keyboardType: TextInputType.phone,
                    validators: [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(),
                    ],
                  ),
                  showEditIcon: true,
                  placeholder: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _rulesWithInitialValue(Map<String, dynamic> savedMap) {
    return FormBuilder(
      key: _fbKey2,
      initialValue: savedMap,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilderTextField(
          attribute: 'rules',
          maxLines: null,
          maxLength: null,
          minLines: 4,
          keyboardType: TextInputType.multiline,
          validators: [FormBuilderValidators.required()],
          decoration: InputDecoration(
            hintText: 'Write Rules here',
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.teal),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  Widget _timePicker(
      BuildContext context, int hr, int min, String key1, String key2) {
    return DateTimeField(
      format: _format,
      initialValue: DateTime(2020, 12, 31, hr, min),
      onShowPicker: (context, currentValue) async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
        );
        return (time != null) ? DateTimeField.convert(time) : currentValue;
      },
      onChanged: (dateTime) {
        var pickedTime = TimeOfDay.fromDateTime(dateTime);
        savedMap[key1][key2]['hr'] = pickedTime.hour;
        savedMap[key1][key2]['min'] = pickedTime.minute;
      },
    );
  }

  Widget _timingsWithInitialValue(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: DataTable(
        columnSpacing: 4.0,
        dataRowHeight: 48.0,
        showBottomBorder: true,
        horizontalMargin: 4.0,
        dataTextStyle: TextStyle(fontSize: 12.0, color: Colors.black),
        columns: <DataColumn>[
          DataColumn(
            label: Text(
              'Days',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          DataColumn(
            label: Text(
              'Status',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          DataColumn(
            label: Text(
              'Opening Time',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          DataColumn(
            label: Text(
              'Closing Time',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ],
        rows: <DataRow>[
          DataRow(
            cells: <DataCell>[
              DataCell(
                Text('Sunday'),
              ),
              DataCell(
                // Text(savedMap['sunday']['clopen']),
                CustomSwitch(
                  initialName: savedMap['sunday']['clopen'],
                  onAltered: (value) {
                    print(value);
                    savedMap['sunday']['clopen'] = value;
                  },
                ),
              ),
              DataCell(
                _timePicker(
                  context,
                  savedMap['sunday']['opening']['hr'],
                  savedMap['sunday']['opening']['min'],
                  'sunday',
                  'opening',
                ),
              ),
              DataCell(
                _timePicker(
                  context,
                  savedMap['sunday']['closing']['hr'],
                  savedMap['sunday']['closing']['min'],
                  'sunday',
                  'closing',
                ),
              ),
            ],
          ),
          DataRow(
            cells: <DataCell>[
              DataCell(
                Text('Monday'),
              ),
              DataCell(
                CustomSwitch(
                  initialName: savedMap['monday']['clopen'],
                  onAltered: (value) {
                    print(value);
                    savedMap['monday']['clopen'] = value;
                  },
                ),
              ),
              DataCell(
                _timePicker(
                  context,
                  savedMap['monday']['opening']['hr'],
                  savedMap['monday']['opening']['min'],
                  'monday',
                  'opening',
                ),
              ),
              DataCell(
                _timePicker(
                  context,
                  savedMap['monday']['closing']['hr'],
                  savedMap['monday']['closing']['min'],
                  'monday',
                  'closing',
                ),
              ),
            ],
          ),
          DataRow(
            cells: <DataCell>[
              DataCell(
                Text('Tuesday'),
              ),
              DataCell(
                CustomSwitch(
                  initialName: savedMap['tuesday']['clopen'],
                  onAltered: (value) {
                    print(value);
                    savedMap['tuesday']['clopen'] = value;
                  },
                ),
              ),
              DataCell(
                _timePicker(
                  context,
                  savedMap['tuesday']['opening']['hr'],
                  savedMap['tuesday']['opening']['min'],
                  'tuesday',
                  'opening',
                ),
              ),
              DataCell(
                _timePicker(
                  context,
                  savedMap['tuesday']['closing']['hr'],
                  savedMap['tuesday']['closing']['min'],
                  'tuesday',
                  'closing',
                ),
              ),
            ],
          ),
          DataRow(
            cells: <DataCell>[
              DataCell(
                Text('Wednesday'),
              ),
              DataCell(
                CustomSwitch(
                  initialName: savedMap['wednesday']['clopen'],
                  onAltered: (value) {
                    print(value);
                    savedMap['wednesday']['clopen'] = value;
                  },
                ),
              ),
              DataCell(
                _timePicker(
                  context,
                  savedMap['wednesday']['opening']['hr'],
                  savedMap['wednesday']['opening']['min'],
                  'wednesday',
                  'opening',
                ),
              ),
              DataCell(
                _timePicker(
                  context,
                  savedMap['wednesday']['closing']['hr'],
                  savedMap['wednesday']['closing']['min'],
                  'wednesday',
                  'closing',
                ),
              ),
            ],
          ),
          DataRow(
            cells: <DataCell>[
              DataCell(
                Text('Thursday'),
              ),
              DataCell(
                CustomSwitch(
                  initialName: savedMap['thursday']['clopen'],
                  onAltered: (value) {
                    print(value);
                    savedMap['thursday']['clopen'] = value;
                  },
                ),
              ),
              DataCell(
                _timePicker(
                  context,
                  savedMap['thursday']['opening']['hr'],
                  savedMap['thursday']['opening']['min'],
                  'thursday',
                  'opening',
                ),
              ),
              DataCell(
                _timePicker(
                  context,
                  savedMap['thursday']['closing']['hr'],
                  savedMap['thursday']['closing']['min'],
                  'thursday',
                  'closing',
                ),
              ),
            ],
          ),
          DataRow(
            cells: <DataCell>[
              DataCell(
                Text('Friday'),
              ),
              DataCell(
                CustomSwitch(
                  initialName: savedMap['friday']['clopen'],
                  onAltered: (value) {
                    print(value);
                    savedMap['friday']['clopen'] = value;
                  },
                ),
              ),
              DataCell(
                _timePicker(
                  context,
                  savedMap['friday']['opening']['hr'],
                  savedMap['friday']['opening']['min'],
                  'friday',
                  'opening',
                ),
              ),
              DataCell(
                _timePicker(
                  context,
                  savedMap['friday']['closing']['hr'],
                  savedMap['friday']['closing']['min'],
                  'friday',
                  'closing',
                ),
              ),
            ],
          ),
          DataRow(
            cells: <DataCell>[
              DataCell(
                Text('Saturday'),
              ),
              DataCell(
                CustomSwitch(
                  initialName: savedMap['saturday']['clopen'],
                  onAltered: (value) {
                    print(value);
                    savedMap['saturday']['clopen'] = value;
                  },
                ),
              ),
              DataCell(
                _timePicker(
                  context,
                  savedMap['saturday']['opening']['hr'],
                  savedMap['saturday']['opening']['min'],
                  'saturday',
                  'opening',
                ),
              ),
              DataCell(
                _timePicker(
                  context,
                  savedMap['saturday']['closing']['hr'],
                  savedMap['saturday']['closing']['min'],
                  'saturday',
                  'closing',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _settingsView() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Colors.teal,
          stretch: true,
          expandedHeight: 200.0,
          flexibleSpace: FlexibleSpaceBar(
            background: GestureDetector(
              onLongPress: () {},
              onTap: () => _chooseCoverPic(context),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[_buildImage(context)],
              ),
            ),
            title: Text(widget.servicePoint.name),
            centerTitle: true,
            stretchModes: <StretchMode>[
              StretchMode.zoomBackground,
              StretchMode.blurBackground,
              StretchMode.fadeTitle,
            ],
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            <Widget>[
              SizedBox(height: 8.0),
              Center(
                child: Text(
                  'Subscription Plan:',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    FutureBuilder<SubscriptionPlan>(
                      future: ParseAuthService.getSubscriptionPlan(
                          widget.servicePoint),
                      builder: (BuildContext context,
                          AsyncSnapshot<SubscriptionPlan> snapshot) {
                        Map<String, dynamic> _savedMap;
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else {
                          if (snapshot.hasData) {
                            _savedMap = snapshot.data.toJson();
                            return _feeTableWithInitialValue(_savedMap);
                          } else {
                            // initialize _savedMap with zeros
                            _savedMap = {
                              "sixone": '0',
                              "sixthree": '0',
                              "sixsix": '0',
                              "sixtwelve": '0',
                              "nineone": '0',
                              "ninethree": '0',
                              "ninesix": '0',
                              "ninetwelve": '0',
                              "twelveone": '0',
                              "twelvethree": '0',
                              "twelvesix": '0',
                              "twelvetwelve": '0',
                            };
                            return _feeTableWithInitialValue(_savedMap);
                          }
                        }
                      },
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        MaterialButton(
                          color: Colors.teal,
                          onPressed: () async {
                            final auth = Provider.of<ParseAuthService>(context,
                                listen: false);
                            if (_fbKey1.currentState.saveAndValidate()) {
                              print(_fbKey1.currentState.value);
                              // save map to servicepoint on backend
                              final jsonString =
                                  json.encode(_fbKey1.currentState.value);
                              await auth.saveSubscriptionPlan(
                                  widget.servicePoint, jsonString);
                            }
                          },
                          child: const Text(
                            'Submit',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        MaterialButton(
                          color: Colors.teal,
                          onPressed: () {
                            _fbKey1.currentState.reset();
                          },
                          child: const Text(
                            'Reset',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Center(
                      child: Text(
                        'Library Rules:',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    FutureBuilder<LibraryRules>(
                      future:
                          ParseAuthService.getLibraryRules(widget.servicePoint),
                      builder: (BuildContext context,
                          AsyncSnapshot<LibraryRules> snapshot) {
                        Map<String, dynamic> _savedMap;
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else {
                          if (snapshot.hasData) {
                            _savedMap = snapshot.data.toJson();
                            return _rulesWithInitialValue(_savedMap);
                          } else {
                            _savedMap = {'rules': ''};
                            return _rulesWithInitialValue(_savedMap);
                          }
                        }
                      },
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        MaterialButton(
                          color: Colors.teal,
                          onPressed: () async {
                            final auth = Provider.of<ParseAuthService>(context,
                                listen: false);
                            if (_fbKey2.currentState.saveAndValidate()) {
                              print(_fbKey2.currentState.value);
                              // save map to servicepoint on backend
                              final jsonString =
                                  json.encode(_fbKey2.currentState.value);
                              await auth.saveLibraryRules(
                                  widget.servicePoint, jsonString);
                            }
                          },
                          child: const Text(
                            'Submit',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        MaterialButton(
                          color: Colors.teal,
                          onPressed: () {
                            _fbKey2.currentState.reset();
                          },
                          child: const Text(
                            'Reset',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Center(
                      child: Text(
                        'Library Timings:',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    FutureBuilder<LibraryTimings>(
                      future: ParseAuthService.getLibraryTimings(
                          widget.servicePoint),
                      builder: (BuildContext context,
                          AsyncSnapshot<LibraryTimings> snapshot) {
                        // Map<String, dynamic> _savedMap;
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else {
                          if (snapshot.hasData) {
                            savedMap = snapshot.data.toJson();
                            defaultMap = savedMap;
                          } else {
                            savedMap = defaultMap;
                          }
                          return _timingsWithInitialValue(context);
                        }
                      },
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        MaterialButton(
                          color: Colors.teal,
                          onPressed: () async {
                            final auth = Provider.of<ParseAuthService>(context,
                                listen: false);
                            print(savedMap);
                            // save map to servicepoint on backend
                            final jsonString = json.encode(savedMap);
                            await auth.saveLibraryTimings(
                                widget.servicePoint, jsonString);
                          },
                          child: const Text(
                            'Submit',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        MaterialButton(
                          color: Colors.teal,
                          onPressed: () {
                            setState(() {
                              savedMap = defaultMap;
                            });
                          },
                          child: const Text(
                            'Reset',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _qrCodeView() {
    if (widget.servicePoint.imageUrl == null) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Set image of service, before using its QR Code',
            style: TextStyle(color: Colors.teal, fontSize: 24.0),
          ),
        ),
      );
    } else {
      return Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: RegenerativeQRImage(
            periodInSeconds: 5,
            servicePoint: widget.servicePoint,
          ),
        ),
      );
    }
  }

  Widget _usersView() {
    return TabBarView(
      children: <Widget>[
        _paidView(PaymentStatus.Paid),
        _unpaidView(PaymentStatus.Unpaid),
      ],
    );
  }

  Widget _unpaidView(PaymentStatus paymentStatus) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      itemCount: unpaidSubscribers.length,
      itemBuilder: (context, index) {
        final subscriber = unpaidSubscribers[index];
        return Dismissible(
          key: UniqueKey(),
          onDismissed: (direction) async {
            setState(() {
              unpaidSubscribers.removeAt(index);
            });
            await ParseAuthService.removeSubscriber(
                widget.servicePoint, subscriber.uid);
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    "User ${subscriber.name} with phone: ${subscriber.phone.number} removed!"),
              ),
            );
          },
          background: Container(color: Colors.red),
          child: Card(
            child: ListTile(
              title: Text('${subscriber.name}'),
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => SubscriberInfo(
                    subscriber: subscriber,
                    paymentStatus: paymentStatus,
                    servicePoint: widget.servicePoint,
                    delegateListUpdate: (_) {
                      setState(() {
                        _getSubscribers();
                      });
                    },
                  ),
                  fullscreenDialog: true,
                ));
              },
            ),
            elevation: 2.0,
          ),
        );
      },
    );
  }

  Widget _paidView(PaymentStatus paymentStatus) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      itemCount: paidSubscribers.length,
      itemBuilder: (context, index) {
        final subscriber = paidSubscribers[index];
        return Dismissible(
          key: UniqueKey(),
          onDismissed: (direction) async {
            setState(() {
              paidSubscribers.removeAt(index);
            });
            await ParseAuthService.removeSubscriber(
                widget.servicePoint, subscriber.uid);
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    "User ${subscriber.name} with phone: ${subscriber.phone.number} removed!"),
              ),
            );
          },
          background: Container(color: Colors.red),
          child: Card(
            child: ListTile(
              title: Text('${subscriber.name}'),
              trailing: Text('${subscriber.phone.number}'),
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => SubscriberInfo(
                    subscriber: subscriber,
                    paymentStatus: paymentStatus,
                    servicePoint: widget.servicePoint,
                    delegateListUpdate: (_) {
                      setState(() {
                        _getSubscribers();
                      });
                    },
                  ),
                  fullscreenDialog: true,
                ));
              },
            ),
            elevation: 2.0,
          ),
        );
      },
    );
  }

  Widget _tabBar() {
    return TabBar(
      tabs: <Tab>[
        Tab(
          icon: Text(
            'PAID',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        Tab(
          icon: (unpaidSubscribers.length > 0)
              ? Badge(
                  shape: BadgeShape.circle,
                  padding: EdgeInsets.all(4),
                  position: BadgePosition.topEnd(top: -10, end: -16),
                  badgeContent: Text(
                    '${unpaidSubscribers.length}',
                    style: TextStyle(color: Colors.white),
                  ),
                  child: Text(
                    'UNPAID',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                )
              : Text(
                  'UNPAID',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }

  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code),
          label: 'QR Code',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Users',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.teal[800],
      onTap: _onOptionTapped,
    );
  }

  void _onOptionTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
