import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/models/subscription.dart';
import 'package:touchlesspro_back4app/services/parse_auth_service.dart';
import 'package:touchlesspro_back4app/ui/checkout_page.dart';

class LibraryUserForm extends StatelessWidget {
  final ServicePoint servicePoint;
  final Map<String, String> authObject;
  LibraryUserForm({Key key, this.servicePoint, this.authObject})
      : super(key: key);

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final priceTextStyle = TextStyle(
    color: Colors.black54,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    List<String> options = [];
    Subscription.values.forEach((e) => options.add(subscriptionToName[e]));
    final cost = Provider.of<ValueNotifier<int>>(context, listen: false);
    int localSlot;
    int localDuration = 1;
    SubscriptionPlan plan;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Membership Form'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            FormBuilder(
              key: _fbKey,
              initialValue: {
                'phone': authObject['number'],
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Text(
                        'Name:',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      title: FormBuilderTextField(
                        attribute: 'name',
                        maxLines: 1,
                        obscureText: false,
                        valueTransformer: (value) => value.toString().trim(),
                        validators: [FormBuilderValidators.required()],
                      ),
                    ),
                    SizedBox(height: 10.0),
                    ListTile(
                      leading: Text(
                        'Mobile No:',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      title: FormBuilderTextField(
                        attribute: 'phone',
                        maxLines: 1,
                        obscureText: false,
                        readOnly: true,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    ListTile(
                      leading: Text(
                        'Preparing For:',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      title: FormBuilderTextField(
                        attribute: 'prep',
                        maxLines: 1,
                        obscureText: false,
                        valueTransformer: (value) => value.toString().trim(),
                        validators: [FormBuilderValidators.required()],
                      ),
                    ),
                    SizedBox(height: 10.0),
                    ListTile(
                      title: Text(
                        'Slot (hours/day):',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      subtitle: FormBuilderSegmentedControl(
                        attribute: 'slot',
                        options: List.generate(3, (i) => 6 + 3 * i)
                            .map((e) => FormBuilderFieldOption(value: e))
                            .toList(),
                        validators: [FormBuilderValidators.required()],
                        pressedColor: Colors.teal,
                        selectedColor: Colors.teal,
                        borderColor: Colors.teal,
                        onChanged: (value) async {
                          localSlot = value;
                          // estimate cost via a function
                          plan ??= await ParseAuthService.getSubscriptionPlan(
                              servicePoint);
                          cost.value = servicePoint.estimateCost(
                              localSlot, localDuration, plan);
                        },
                      ),
                    ),
                    SizedBox(height: 10.0),
                    FormBuilderCustomField(
                      attribute: 'duration',
                      formField: FormField(
                        builder: (FormFieldState<dynamic> field) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Select Subscription:',
                              labelStyle:
                                  TextStyle(fontSize: 30, color: Colors.black),
                              contentPadding:
                                  EdgeInsets.only(top: 10.0, bottom: 0.0),
                              errorText: field.errorText,
                            ),
                            child: Container(
                              height: 150.0,
                              child: CupertinoPicker(
                                itemExtent: 30.0,
                                onSelectedItemChanged: (index) async {
                                  localDuration = durationMap[options[index]];
                                  field.didChange(options[index]);
                                  // estimate cost via a function
                                  plan ??= await ParseAuthService
                                      .getSubscriptionPlan(servicePoint);
                                  cost.value = servicePoint.estimateCost(
                                      localSlot, localDuration, plan);
                                },
                                children: options.map((e) => Text(e)).toList(),
                                magnification: 1.2,
                                useMagnifier: true,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20.0),
                    _buildDivider(),
                    SizedBox(height: 10.0),
                    Row(
                      children: <Widget>[
                        Text(
                          'Fee:',
                          style: priceTextStyle.copyWith(color: Colors.black),
                        ),
                        Spacer(),
                        Consumer<ValueNotifier<int>>(
                          builder: (_, cost, __) => Text(
                            '\u{20B9} ${cost.value}',
                            style: priceTextStyle,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    _buildDivider(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: RaisedButton(
                    padding: const EdgeInsets.all(16.0),
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    color: Colors.teal,
                    onPressed: () {
                      if (_fbKey.currentState.saveAndValidate()) {
                        print(_fbKey.currentState.value);
                        // navigate to checkout page with fee
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Checkout(
                              servicePoint: servicePoint,
                              authObject: authObject,
                              fee: cost.value,
                              formMap: _fbKey.currentState.value,
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: RaisedButton(
                    padding: const EdgeInsets.all(16.0),
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    color: Colors.teal,
                    onPressed: () {
                      _fbKey.currentState.reset();
                      cost.value = 0;
                      localSlot = null;
                      localDuration = 1;
                    },
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container _buildDivider() {
    return Container(
      height: 2.0,
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: Colors.teal.shade300,
        borderRadius: BorderRadius.circular(5.0),
      ),
    );
  }
}
