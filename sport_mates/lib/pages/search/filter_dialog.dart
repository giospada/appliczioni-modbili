import 'package:flutter/material.dart';
import 'package:sport_mates/config/config.dart';
import 'package:sport_mates/pages/search/filter_data.dart';

class DialogFilter extends StatefulWidget {
  final FilterData filterData;

  DialogFilter({required this.filterData});

  @override
  _DialogFilterState createState() =>
      _DialogFilterState(filterData: filterData);
}

class _DialogFilterState extends State<DialogFilter> {
  FilterData filterData;

  _DialogFilterState({required this.filterData});

  @override
  Widget build(BuildContext context) {
    List<String> allSports = Config().sports + [Config().nullSport];
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Filtri', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Seleziona uno sport'),
                  DropdownButton<String>(
                    value: filterData.selectedSport,
                    onChanged: (String? value) {
                      setState(() {
                        filterData.selectedSport = value ?? Config().nullSport;
                      });
                    },
                    items:
                        allSports.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SwitchListTile(
                title: const Text('Prezzo massimo'),
                value: filterData.price,
                onChanged: (bool value) {
                  setState(() {
                    filterData.price = value;
                  });
                },
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: filterData.price
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Column(
                          children: [
                            Text(
                                'Prezzo Massimo: ${filterData.maxPrice.toStringAsFixed(2)}'),
                            Slider(
                              value: filterData.maxPrice,
                              min: 0,
                              max: 50,
                              divisions: 10,
                              onChanged: (value) {
                                setState(() {
                                  filterData.maxPrice = value;
                                });
                              },
                            ),
                          ],
                        ),
                      )
                    : Container(),
              ),
              const SizedBox(
                height: 10,
              ),
              _buildDateSelector(
                context: context,
                title: 'Seleziona la data di partenza',
                selectedDate: filterData.startDate,
                onDateSelected: (DateTime date) {
                  setState(() {
                    filterData.startDate = date;
                  });
                },
              ),
              const SizedBox(
                height: 10,
              ),
              _buildDateSelector(
                context: context,
                title: 'Seleziona la data di fine',
                selectedDate: filterData.endDate,
                onDateSelected: (DateTime date) {
                  setState(() {
                    filterData.endDate = date;
                  });
                },
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                child: const Text('Applica i filtri'),
                onPressed: () => Navigator.of(context).pop(filterData),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(
      {required BuildContext context,
      required String title,
      DateTime? selectedDate,
      required Function(DateTime) onDateSelected}) {
    return Wrap(
      direction: Axis.horizontal,
      children: [
        ElevatedButton(
          child: Text(title),
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              onDateSelected(date);
            }
          },
        ),
        if (selectedDate != null)
          const SizedBox(
            height: 5,
            width: 5,
          ),
        if (selectedDate != null)
          Chip(
            label: Text(
              '${selectedDate.day}/${selectedDate.month}',
            ),
            onDeleted: () => setState(() {
              if (title.contains('start')) {
                filterData.startDate = null;
              } else {
                filterData.endDate = null;
              }
            }),
          ),
      ],
    );
  }
}
