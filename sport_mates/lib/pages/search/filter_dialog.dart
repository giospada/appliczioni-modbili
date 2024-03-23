import 'package:sport_mates/config/config.dart';
import 'package:sport_mates/utils.dart';
import 'package:flutter/material.dart';

class DialogFilter extends StatefulWidget {
  final String? selectedSport;
  final bool? price;
  final double? maxPrice;
  final DateTime? startDate;
  final DateTime? endDate;

  DialogFilter({
    this.selectedSport,
    this.price,
    this.maxPrice,
    this.startDate,
    this.endDate,
  });

  @override
  _DialogFilterState createState() => _DialogFilterState();
}

class _DialogFilterState extends State<DialogFilter> {
  late String selectedSport;
  late bool price;
  late double maxPrice;
  late DateTime? startDate;
  late DateTime? endDate;

  @override
  void initState() {
    super.initState();
    selectedSport = widget.selectedSport ?? Config().nullSport;
    price = widget.price ?? false;
    maxPrice = widget.maxPrice ?? 0;
    startDate = widget.startDate;
    endDate = widget.endDate;
  }

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
                  value: selectedSport,
                  onChanged: (String? value) {
                    setState(() {
                      selectedSport = value ?? Config().nullSport;
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
              value: price,
              onChanged: (bool value) {
                setState(() {
                  price = value;
                });
              },
            ),
            AnimatedContainer(
              height: !price ? 0 : 60,
              duration: Duration(milliseconds: 200),
              child: price
                  ? Slider(
                      value: maxPrice,
                      min: 0,
                      max: 50,
                      divisions: 10,
                      onChanged: (value) {
                        setState(() {
                          maxPrice = value;
                        });
                      },
                      label: maxPrice.toString(),
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
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        startDate = date;
                      });
                    }
                  },
                ),
                (startDate != null)
                    ? Chip(
                        label: Text(displayFormattedDate(startDate!)),
                        onDeleted: () => setState(() {
                              startDate = null;
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
                      initialDate: endDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        startDate = date;
                      });
                    }
                  },
                ),
                (endDate != null)
                    ? Chip(
                        label: Text(displayFormattedDate(endDate!)),
                        onDeleted: () => setState(() {
                              endDate = null;
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
            Navigator.of(context)
                .pop([price, selectedSport, maxPrice, startDate, endDate]);
          },
        ),
      ],
    );
  }
}
