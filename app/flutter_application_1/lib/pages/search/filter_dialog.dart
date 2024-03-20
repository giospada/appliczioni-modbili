import 'package:SportMates/config/config.dart';
import 'package:flutter/material.dart';

class DialogFilter extends StatefulWidget {
  const DialogFilter({super.key});

  @override
  State<DialogFilter> createState() => _DialogFilterState();
}

class _DialogFilterState extends State<DialogFilter> {
  double maxPrice = 0;
  bool price = false;
  String selectedSport = Config().nullSport;

  @override
  Widget build(BuildContext context) {
    List<String> allSports = Config().sports + [Config().nullSport];
    return AlertDialog(
      title: Text('Select Sport and Max Price'),
      content: Column(
        children: <Widget>[
          DropdownButton<String>(
            hint: Text('Select Sport'),
            value: selectedSport,
            onChanged: (String? value) {
              setState(() {
                selectedSport = value ?? Config().nullSport;
              });
            },
            items: allSports.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          SwitchListTile(
            title: Text('Is the activity free?'),
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
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.of(context).pop({price, selectedSport, maxPrice});
          },
        ),
      ],
    );
  }
}
