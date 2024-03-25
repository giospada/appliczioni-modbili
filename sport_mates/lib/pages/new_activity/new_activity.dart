import 'package:sport_mates/pages/new_activity/layout_widget.dart';
import 'package:sport_mates/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sport_mates/config/auth_provider.dart';
import 'package:sport_mates/config/config.dart';
import 'package:sport_mates/pages/general_purpuse/loader.dart';
import 'package:sport_mates/pages/general_purpuse/place_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

class CreateActivityWidget extends StatefulWidget {
  @override
  _CreateActivityWidgetState createState() => _CreateActivityWidgetState();
}

class _CreateActivityWidgetState extends State<CreateActivityWidget> {
  final PageController _pageController = PageController();
  // Change this to false if you want to initially disable swiping
  final bool _isSwipeEnabled = true;

  // Dummy function to illustrate enabling navigation to next page
  final int _pageNumber = 2;
  int _currentPage = 0;

  TextEditingController descriptionController = TextEditingController();
  int numberOfPeople = 0;
  String _selectedSport = Config().sports[0];
  final List<String> _allSports = Config().sports;

  bool _isFree = true;
  double _price = 0;
  DateTime? selectedDate;
  double long = 0, lati = 0;
  String? address;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2025));
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final DateTime pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          selectedDate = pickedDateTime;
        });
      }
    }
  }

  bool _validatePage() {
    if (_currentPage == 0) {
      if (lati == 0 || long == 0) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Please pick a location')));
        return true;
      }
    } else if (_currentPage == 1) {
      if (selectedDate == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Please pick a date')));
        return true;
      }
    } else if (_currentPage == 2) {
      bool allFilled = !descriptionController.text.isEmpty;
      if (!allFilled) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter a description')));
        return true;
      }
    }
    return false;
  }

  void requestActivity() async {
    if (_currentPage == _pageNumber) {
      final data = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AsyncLoaderPage(
              asyncOperation: () async => await _request(context))));

      if (data is http.Response) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Activity created')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to create activity')));
      }
    }
  }

  void nextPageFunction() {
    if (_validatePage()) return;

    requestActivity();

    if (_pageController.page!.round() < _pageNumber) {
      _currentPage++;
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }

  void previusPageFunciton() {
    if (_pageController.page!.round() > 0) {
      _currentPage--;
      _pageController.previousPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }

  Future<http.Response> _request(BuildContext context) async {
    Config config = Config();
    final token = Provider.of<AuthProvider>(context).token;
    final response = await http.post(
      Uri.https(config.host, '/activities'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "description": descriptionController.text,
        "time": selectedDate?.toIso8601String(),
        "position": {
          "long": long,
          "lat": lati,
        },
        "attributes": {
          "level": 'Easy',
          "price": _isFree ? 0 : _price,
          "sport": _selectedSport,
        },
        "numberOfPeople": numberOfPeople,
      }),
    );

    if (response.statusCode == 200) {
      // Handle successful submission
      return response;
    } else {
      throw Exception('Failed to submit activity, ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: PageView(
          controller: _pageController,
          physics: _isSwipeEnabled
              ? AlwaysScrollableScrollPhysics()
              : NeverScrollableScrollPhysics(),
          children: [
            LayoutWidget(
                svgPath: 'assets/svg/best_place.svg',
                title: 'Pick Location',
                description: 'Pick the location of the activity',
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlacePickerWidget(),
                      ),
                    );
                    if (result != null) {
                      long = result['long'];
                      lati = result['lat'];
                      address = result['address'];
                    }
                  },
                  child: Column(
                    children: [Text('Pick Location'), Text(address ?? ' ')],
                  ),
                )),
            LayoutWidget(
                svgPath: 'assets/svg/online_calendar.svg',
                title: 'Pick Date',
                description: 'Pick the date of the activity',
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _selectDate(context),
                      child: Text('Select Date'),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(selectedDate == null
                            ? 'No date selected'
                            : 'Selected date: ${displayFormattedDate(selectedDate!)}'))
                  ],
                )),
            LayoutWidget(
              svgWidget: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(child: child, scale: animation);
                },
                child: SvgPicture.asset(
                  'assets/svg/${_selectedSport}.svg',
                  height: 100,
                  width: 100,
                  key: ValueKey<String>(_selectedSport),
                ),
              ),
              title: 'Activity Details',
              description: 'Enter the details of the activity',
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Description'),
                    controller: descriptionController,
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedSport,
                    decoration: InputDecoration(labelText: 'Sport'),
                    items: List<String>.from(_allSports).map((String value) {
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
                            onChanged: (value) {
                              value = value == '' ? '0' : value;
                              _price = double.parse(value ?? '0');
                            },
                          )
                        : null,
                  ),
                  TextFormField(
                      decoration:
                          InputDecoration(labelText: 'Number of People'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        value = value == '' ? '0' : value;
                        numberOfPeople = int.parse(value ?? '0');
                      })
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: previusPageFunciton,
              child: Icon(Icons.navigate_before),
              //make it little and gray
              backgroundColor: Theme.of(context).colorScheme.secondary,
              mini: true,
              heroTag: 'back',
            ),
            FloatingActionButton(
                onPressed: nextPageFunction,
                child: Icon(
                  Icons.navigate_next,
                ),
                heroTag: 'next'),
          ],
        ));
  }
}
