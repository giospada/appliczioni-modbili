import 'package:SportMates/data/activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AddFeedbackScreen extends StatefulWidget {
  final Activity activity;

  AddFeedbackScreen({Key? key, required this.activity}) : super(key: key);

  @override
  _AddFeedbackScreenState createState() => _AddFeedbackScreenState();
}

class _AddFeedbackScreenState extends State<AddFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  String _comment = '';
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Feedback'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: 'Comment'),
              onSaved: (value) {
                setState(() {
                  _comment = value ?? '';
                });
              },
            ),
            Slider(
              value: _rating.toDouble(),
              min: 0,
              max: 5,
              divisions: 5,
              label: _rating.toString(),
              onChanged: (double value) {
                setState(() {
                  _rating = value.round();
                });
              },
            ),
            ElevatedButton(
              child: Text('Submit'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // TODO: Save the feedback
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
