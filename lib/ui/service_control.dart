import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/services/image_picker_service.dart';
import 'package:touchlesspro_back4app/services/parse_auth_service.dart';

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
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    setState(() {
      imageUrl = widget.servicePoint.imageUrl;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
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
                  child: FormBuilder(
                    key: _fbKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DataTable(
                        columnSpacing: 8.0,
                        dataRowHeight: 48.0,
                        showBottomBorder: true,
                        horizontalMargin: 8.0,
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
                  ),
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    MaterialButton(
                      color: Colors.teal,
                      onPressed: () async {
                        final auth = Provider.of<ParseAuthService>(context,
                            listen: false);
                        if (_fbKey.currentState.saveAndValidate()) {
                          print(_fbKey.currentState.value);
                          // save map to servicepoint on backend
                          final jsonString =
                              json.encode(_fbKey.currentState.value);
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
                        _fbKey.currentState.reset();
                        // cost.value = 0;
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
    );
  }

  Widget _buildImage(BuildContext context) {
    if (imageUrl != null) {
      return Image.network(imageUrl, fit: BoxFit.cover);
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
      widget.servicePoint.adminId,
      widget.servicePoint.name,
    );
    setState(() {
      imageUrl = url;
      if (url != null) {
        widget.setImage(imageUrl);
      }
    });
    print('upload response: $url');
  }
}
