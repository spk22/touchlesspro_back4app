import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:touchlesspro_back4app/models/service_point.dart';
import 'package:touchlesspro_back4app/models/subscription.dart';

class LibraryUserForm extends StatelessWidget {
  final ServicePoint servicePoint;
  final Map<String, String> authObject;
  LibraryUserForm({Key key, this.servicePoint, this.authObject})
      : super(key: key);

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    List<String> options = [];
    Subscription.values.forEach((e) => options.add(subscriptionToName[e]));
    final cost = Provider.of<ValueNotifier<int>>(context, listen: false);
    int localSlot;
    int localDuration = 1;
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
                'date': DateTime.now(),
                'accept_terms': false,
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
                        onChanged: (value) {
                          localSlot = value;
                          // estimate cost via a function
                          cost.value = localSlot + localDuration;
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
                                onSelectedItemChanged: (index) {
                                  localDuration = durationMap[options[index]];
                                  field.didChange(options[index]);
                                  // estimate cost via a function
                                  cost.value = localSlot + localDuration;
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
                    SizedBox(height: 10.0),
                    ListTile(
                      leading: Text(
                        'Total Cost:',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      title: Consumer<ValueNotifier<int>>(
                        builder: (_, cost, __) => Text(
                          '${cost.value}',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                MaterialButton(
                  color: Colors.teal,
                  onPressed: () {
                    if (_fbKey.currentState.saveAndValidate()) {
                      print(_fbKey.currentState.value);
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
                    cost.value = 0;
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
    );
  }
}
