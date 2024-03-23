import 'package:sport_mates/config/config.dart';
import 'package:flutter/material.dart';

class Filters extends StatefulWidget {
  const Filters({super.key});

  @override
  State<Filters> createState() => _FiltersState();
}

final String _nullSport = 'Nessuno';

class _FiltersState extends State<Filters> {
  final ScrollController _scrollController = ScrollController();
  Map<String, (String, dynamic)> filters = {};

  List<String> _allSports = Config().sports + [_nullSport];

  String _selectedSport = _nullSport;

  double _radius = 10;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget filterToChip(String filterName, String filterValue) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: Chip(
        label: Text(filterValue),
        onDeleted: () {
          setState(() {
            filters.remove(filterName);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> filterChips = [];
    filterChips.add(ActionChip(
      label: Text('Filter'),
      avatar: Icon(Icons.filter),
      onPressed: () {
        showDialog(
            context: context,
            builder: (BuildContext build) {
              return Dialog(
                child: Container(
                  height: 200,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      ListTile(
                        title: Text('Radius'),
                        trailing: Container(
                            width: 200,
                            child: Slider(
                              value: _radius,
                              min: 1,
                              max: 100,
                              divisions: 100,
                              label: "${_radius.round()} km",
                              onChanged: (double value) {
                                setState(() {
                                  _radius = value;
                                  filters['radius'] =
                                      ('${_radius.round()} km', _radius);
                                });
                              },
                            )),
                      ),
                      ListTile(
                        title: Text('Sport'),
                        trailing: Container(
                          width: 200,
                          child: DropdownButtonFormField<String>(
                            value: _selectedSport,
                            decoration: InputDecoration(labelText: 'Sport'),
                            items: List<String>.from(_allSports)
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedSport = newValue!;
                                if (_selectedSport == _nullSport) {
                                  filters.remove('sport');
                                } else {
                                  filters['sport'] =
                                      (_selectedSport, _selectedSport);
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
      },
    ));
    for (var filter in filters.entries) {
      filterChips.add(filterToChip(filter.key, filter.value.$1));
    }
    return Container(
      height: 50,
      width: double.infinity,
      child: Scrollbar(
        thumbVisibility: true,
        controller: _scrollController,
        child: ListView(
          controller: _scrollController,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          // add gap between children
          children: filterChips,
        ),
      ),
    );
  }
}
