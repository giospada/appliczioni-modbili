import 'package:latlong2/latlong.dart';
import 'package:sport_mates/data/activity_data.dart';
import 'package:sport_mates/pages/new_activity/pos_selector.dart';
import 'package:sport_mates/pages/new_activity/layout_widget.dart';
import 'package:sport_mates/utils.dart';
import 'package:flutter/material.dart';
import 'package:sport_mates/provider/auth_provider.dart';
import 'package:sport_mates/config/config.dart';
import 'package:sport_mates/pages/general_purpuse/loader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sport_mates/provider/data_provider.dart';
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

  Future<void> _selectDate() async {
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
            .showSnackBar(const SnackBar(content: Text('Scegli la posizione')));
        return true;
      }
    } else if (_currentPage == 1) {
      if (selectedDate == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Scegli il giorno')));
        return true;
      }
    } else if (_currentPage == 2) {
      bool allFilled = descriptionController.text.isNotEmpty;
      if (!allFilled) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inserisci la descrizione')));
        return true;
      }
    }
    return false;
  }

  void requestActivity() async {
    if (_currentPage == _pageNumber) {
      final data = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              AsyncLoaderPage(asyncOperation: () async => await _request())));

      if (data is http.Response && data.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Attività creata')));
        Activity activity = Activity.fromJson(jsonDecode(data.body));
        Navigator.pop(context, activity);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible creare attività')));
      }
    }
  }

  void nextPageFunction() {
    if (_validatePage()) return;

    requestActivity();

    if (_pageController.page!.round() < _pageNumber) {
      _currentPage++;
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }

  void previusPageFunciton() {
    if (_pageController.page!.round() > 0) {
      _currentPage--;
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }

  Future<http.Response> _request() async {
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
      Provider.of<DataProvider>(context, listen: false).load(token);
      return response;
    } else {
      throw Exception('Impossibile salvare l\'attività ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: PageView(
          controller: _pageController,
          physics: _isSwipeEnabled
              ? const AlwaysScrollableScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          children: [
            LayoutWidget(
                svgPath: 'assets/svg/best_place.svg',
                title: 'Scegli un luogo',
                description: 'Scegli il luogo dell\'attività',
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final pos = await determinePosition();
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PosSelectorWidget(pos),
                          ),
                        ) as LatLng?;
                        setState(() {
                          if (result != null) {
                            long = result.longitude;
                            lati = result.latitude;
                          }
                        });
                      },
                      child: const Text('Scegli una posizione'),
                    ),
                    if (lati != 0 && long != 0)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Posizione selezionata'),
                      )
                  ],
                )),
            LayoutWidget(
                svgPath: 'assets/svg/online_calendar.svg',
                title: 'Scegli la data',
                description: 'Scegli la data e l\'ora dell\'attività',
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _selectDate(),
                      child: const Text('Select Date'),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(selectedDate == null
                            ? 'Nessuna data selezionata'
                            : 'Data selezionata: ${displayFormattedDate(selectedDate!)}'))
                  ],
                )),
            LayoutWidget(
              svgWidget: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: SvgPicture.asset(
                  'assets/svg/${_selectedSport}.svg',
                  height: 100,
                  width: 100,
                  key: ValueKey<String>(_selectedSport),
                ),
              ),
              title: 'Aggiungi i dettagli',
              description: 'Aggiungi i dettagli dell\'attività',
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Descrizione'),
                    controller: descriptionController,
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedSport,
                    decoration: const InputDecoration(labelText: 'Sport'),
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
                    title: const Text('È gratis?'),
                    value: _isFree,
                    onChanged: (bool value) {
                      setState(() {
                        _isFree = value;
                      });
                    },
                  ),
                  AnimatedContainer(
                    height: _isFree ? 0 : 60,
                    duration: const Duration(milliseconds: 200),
                    child: !_isFree
                        ? TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Prezzo'),
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
                          const InputDecoration(labelText: "Numero di persone"),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        value = value == '' ? '0' : value;
                        numberOfPeople = int.parse(value);
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
              //make it little and gray
              backgroundColor: Theme.of(context).colorScheme.secondary,
              mini: true,
              heroTag: 'indietro',
              child: const Icon(Icons.navigate_before),
            ),
            FloatingActionButton(
                onPressed: nextPageFunction,
                heroTag: 'prossimo',
                child: const Icon(
                  Icons.navigate_next,
                )),
          ],
        ));
  }
}
