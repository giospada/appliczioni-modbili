import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/place_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

class CreateActivityWidget extends StatefulWidget {
  @override
  _CreateActivityWidgetState createState() => _CreateActivityWidgetState();
}

class _CreateActivityWidgetState extends State<CreateActivityWidget> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController descriptionController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController levelController = TextEditingController();
  TextEditingController numberOfPeopleController = TextEditingController();
  bool _isFree = true;
  double _price = 0;
  double long = 0, lati = 0;

  String _selectedSport = 'running';
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2025));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Future<void> submitActivity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final response = await http.post(
      Uri.parse('https://yourhost/actvicity'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "description": descriptionController.text,
        "time": selectedDate.toIso8601String(),
        "position": {
          "long": double.parse(longitudeController.text),
          "lat": double.parse(latitudeController.text),
        },
        "attributes": {
          "level": levelController.text,
          "price": _isFree ? 0 : _price,
          "sport": _selectedSport,
        },
        "numberOfPeople": int.parse(numberOfPeopleController.text),
      }),
    );

    if (response.statusCode == 200) {
      // Handle successful submission
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Activity Created Successfully!')));
    } else {
      // Handle error
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to Create Activity')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Activity')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: numberOfPeopleController,
                decoration: InputDecoration(labelText: 'Number of People'),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ], // Only numbers can be entered
              ),
              SwitchListTile(
                title: Text('Is the activity free?'),
                value: _isFree,
                onChanged: (bool value) {
                  setState(() {
                    _isFree = value;
                  });
                },
              ),
              AnimatedContainer(
                height: _isFree ? 0 : 60,
                duration: Duration(milliseconds: 200),
                child: !_isFree
                    ? TextFormField(
                        decoration: InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                        onSaved: (value) => _price = double.parse(value ?? '0'),
                      )
                    : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedSport,
                decoration: InputDecoration(labelText: 'Sport'),
                items: <String>['running', 'basket', 'football']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSport = newValue!;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: Text('Select Date'),
              ),
              ElevatedButton(
                onPressed: submitActivity,
                child: Text('Submit Activity'),
              ),
              ElevatedButton(
                child: Text('Pick Location'),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlacePickerWidget(),
                    ),
                  );
                  print(result);
                  if (result != null) {
                    long = result['longitude'];
                    lati = result['latitude'];
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
