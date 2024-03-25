import 'package:sport_mates/config/config.dart';
import 'package:sport_mates/pages/search/filter_data.dart';
import 'package:sport_mates/utils.dart';
import 'package:flutter/material.dart';

class DialogFilter extends StatefulWidget {
  final FilterData filterData;
  DialogFilter({
    required this.filterData,
  });

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
    return AlertDialog(
      title: Text('Filters'),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Select a sport'),
                DropdownButton<String>(
                  hint: Text('Select Sport'),
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
              title: Text('Max Price'),
              value: filterData.price,
              onChanged: (bool value) {
                setState(() {
                  filterData.price = value;
                });
              },
            ),
            AnimatedContainer(
              height: !filterData.price ? 0 : 60,
              duration: Duration(milliseconds: 200),
              child: filterData.price
                  ? Slider(
                      value: filterData.maxPrice,
                      min: 0,
                      max: 50,
                      divisions: 10,
                      onChanged: (value) {
                        setState(() {
                          filterData.maxPrice = value;
                        });
                      },
                      label: filterData.maxPrice.toString(),
                    )
                  : null,
            ),
            Row(
              children: [
                ElevatedButton(
                  child: Text('Select start date'),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: filterData.startDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        filterData.startDate = date;
                      });
                    }
                  },
                ),
                (filterData.startDate != null)
                    ? Chip(
                        label:
                            Text(displayFormattedDate(filterData.startDate!)),
                        onDeleted: () => setState(() {
                              filterData.startDate = null;
                            }))
                    : Text('No date selected')
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  child: Text('Select end date'),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: filterData.endDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        filterData.startDate = date;
                      });
                    }
                  },
                ),
                (filterData.endDate != null)
                    ? Chip(
                        label: Text(displayFormattedDate(filterData.endDate!)),
                        onDeleted: () => setState(() {
                              filterData.endDate = null;
                            }))
                    : Text('No date selected')
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.of(context).pop(filterData);
          },
        ),
      ],
    );
  }
}
