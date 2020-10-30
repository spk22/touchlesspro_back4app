import 'package:flutter/material.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';

class LibraryService extends StatefulWidget {
  final ServicePoint servicePoint;
  LibraryService({Key key, this.servicePoint}) : super(key: key);

  @override
  _LibraryServiceState createState() => _LibraryServiceState();
}

class _LibraryServiceState extends State<LibraryService> {
  bool detailsFilled;

  @override
  void initState() {
    super.initState();
    // check (from backend) here if detailsFilled is true
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            stretch: true,
            onStretchTrigger: () {
              // Function callback for stretch
              return;
            },
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: <StretchMode>[
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
                StretchMode.fadeTitle,
              ],
              title: Text(widget.servicePoint.name),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.network(
                    widget.servicePoint.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  // Icon(
                  //   Icons.camera_alt,
                  //   size: 100.0,
                  //   color: Colors.teal,
                  // ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              <Widget>[
                ListTile(
                  leading: Icon(Icons.wb_sunny),
                  title: Text('Sunday'),
                  subtitle: Text('sunny, h: 80, l: 65'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
