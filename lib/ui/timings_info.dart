import 'package:flutter/material.dart';
import 'package:touchlesspro_back4app/models/library_timings.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/services/parse_auth_service.dart';

class TimingsInfo extends StatefulWidget {
  final ServicePoint servicePoint;
  TimingsInfo({Key key, this.servicePoint}) : super(key: key);

  @override
  _TimingsInfoState createState() => _TimingsInfoState();
}

class _TimingsInfoState extends State<TimingsInfo> {
  LibraryTimings timings;
  Map<String, dynamic> obtainedMap;
  Map<String, dynamic> savedMap;

  Future<void> _getLibraryTimings() async {
    timings = await ParseAuthService.getLibraryTimings(widget.servicePoint);
    obtainedMap = timings.toJson();
    print(obtainedMap);
  }

  @override
  void initState() {
    _getLibraryTimings();
    setState(() {
      savedMap = obtainedMap;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Library Timings'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 30.0),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: _table(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _table() {
    return FutureBuilder<LibraryTimings>(
      future: ParseAuthService.getLibraryTimings(widget.servicePoint),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          savedMap = snapshot.data.toJson();
          if (snapshot.hasData) {
            return Table(
              border: TableBorder.all(width: 2.0, color: Colors.teal),
              columnWidths: {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(5),
              },
              children: [
                TableRow(
                  children: [
                    TableCell(
                      child: SizedBox(
                        height: 30.0,
                        child: Center(child: Text('Sunday')),
                      ),
                      verticalAlignment: TableCellVerticalAlignment.middle,
                    ),
                    TableCell(
                      child: SizedBox(
                        height: 30.0,
                        child: Center(
                          child: Text(savedMap['sunday']['clopen']),
                        ),
                      ),
                      verticalAlignment: TableCellVerticalAlignment.middle,
                    ),
                    TableCell(
                      child: SizedBox(
                        height: 30.0,
                        child: Center(
                          child: (_isOpenOn('sunday'))
                              ? _timeText('sunday')
                              : Text('-'),
                        ),
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
                        child: Center(child: Text('Monday')),
                      ),
                      verticalAlignment: TableCellVerticalAlignment.middle,
                    ),
                    TableCell(
                      child: SizedBox(
                        height: 30.0,
                        child: Center(
                          child: Text(savedMap['monday']['clopen']),
                        ),
                      ),
                      verticalAlignment: TableCellVerticalAlignment.middle,
                    ),
                    TableCell(
                      child: SizedBox(
                        height: 30.0,
                        child: Center(
                          child: (_isOpenOn('monday'))
                              ? _timeText('monday')
                              : Text('-'),
                        ),
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
                        child: Center(child: Text('Tuesday')),
                      ),
                      verticalAlignment: TableCellVerticalAlignment.middle,
                    ),
                    TableCell(
                      child: SizedBox(
                        height: 30.0,
                        child: Center(
                          child: Text(savedMap['tuesday']['clopen']),
                        ),
                      ),
                      verticalAlignment: TableCellVerticalAlignment.middle,
                    ),
                    TableCell(
                      child: SizedBox(
                        height: 30.0,
                        child: Center(
                          child: (_isOpenOn('tuesday'))
                              ? _timeText('tuesday')
                              : Text('-'),
                        ),
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
                        child: Center(child: Text('Wednesday')),
                      ),
                      verticalAlignment: TableCellVerticalAlignment.middle,
                    ),
                    TableCell(
                      child: SizedBox(
                        height: 30.0,
                        child: Center(
                          child: Text(savedMap['wednesday']['clopen']),
                        ),
                      ),
                      verticalAlignment: TableCellVerticalAlignment.middle,
                    ),
                    TableCell(
                      child: SizedBox(
                        height: 30.0,
                        child: Center(
                          child: (_isOpenOn('wednesday'))
                              ? _timeText('wednesday')
                              : Text('-'),
                        ),
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
                        child: Center(child: Text('Thursday')),
                      ),
                      verticalAlignment: TableCellVerticalAlignment.middle,
                    ),
                    TableCell(
                      child: SizedBox(
                        height: 30.0,
                        child: Center(
                          child: Text(savedMap['thursday']['clopen']),
                        ),
                      ),
                      verticalAlignment: TableCellVerticalAlignment.middle,
                    ),
                    TableCell(
                      child: SizedBox(
                        height: 30.0,
                        child: Center(
                          child: (_isOpenOn('thursday'))
                              ? _timeText('thursday')
                              : Text('-'),
                        ),
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
                        child: Center(child: Text('Friday')),
                      ),
                      verticalAlignment: TableCellVerticalAlignment.middle,
                    ),
                    TableCell(
                      child: SizedBox(
                        height: 30.0,
                        child: Center(
                          child: Text(savedMap['friday']['clopen']),
                        ),
                      ),
                      verticalAlignment: TableCellVerticalAlignment.middle,
                    ),
                    TableCell(
                      child: SizedBox(
                        height: 30.0,
                        child: Center(
                          child: (_isOpenOn('friday'))
                              ? _timeText('friday')
                              : Text('-'),
                        ),
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
                        child: Center(child: Text('Saturday')),
                      ),
                      verticalAlignment: TableCellVerticalAlignment.middle,
                    ),
                    TableCell(
                      child: SizedBox(
                        height: 30.0,
                        child: Center(
                          child: Text(savedMap['saturday']['clopen']),
                        ),
                      ),
                      verticalAlignment: TableCellVerticalAlignment.middle,
                    ),
                    TableCell(
                      child: SizedBox(
                        height: 30.0,
                        child: Center(
                          child: (_isOpenOn('saturday'))
                              ? _timeText('saturday')
                              : Text('-'),
                        ),
                      ),
                      verticalAlignment: TableCellVerticalAlignment.middle,
                    ),
                  ],
                ),
              ],
            );
          } else
            return CircularProgressIndicator();
        }
      },
    );
  }

  Widget _timeText(String key) {
    int hr = savedMap[key]['opening']['hr'];
    int min = savedMap[key]['opening']['min'];
    final openingTime = TimeOfDay(hour: hr, minute: min);
    hr = savedMap[key]['closing']['hr'];
    min = savedMap[key]['closing']['min'];
    final closingTime = TimeOfDay(hour: hr, minute: min);
    return Text(
        openingTime.format(context) + ' to ' + closingTime.format(context));
  }

  bool _isOpenOn(String key) {
    if (savedMap[key]['clopen'] == 'closed')
      return false;
    else
      return true;
  }
}
