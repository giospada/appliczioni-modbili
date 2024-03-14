import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

class LoginSignupScreen extends StatefulWidget {
  @override
  _LoginSignupScreenState createState() => _LoginSignupScreenState();
}

const HOST = 'http://localhost:8000';

enum action_state {
  login,
  signup,
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  action_state current_action = action_state.login;
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '';

  void _submit() async {
    final isValid = _formKey.currentState?.validate();
    if (!isValid!) return;

    _formKey.currentState?.save();
    try {
      final response = await http.post(
        Uri.parse(
            '${HOST}/${action_state.login == current_action ? 'login' : 'signup'}'),
        body: json.encode({'username': _email, 'password': _password}),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        Provider.of<AuthProvider>(context, listen: false)
            .login(responseData['access_token']);
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text('An error occurred'),
                content: Text(e.toString() ?? 'Unknown error occurred'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text('Okay'),
                  ),
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Column(children: [
              SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: SegmentedButton<action_state>(
                  segments: const [
                    ButtonSegment<action_state>(
                        value: action_state.login,
                        label: Text('Login'),
                        icon: Icon(Icons.login)),
                    ButtonSegment<action_state>(
                        value: action_state.signup,
                        label: Text('Signup'),
                        icon: Icon(Icons.person_add)),
                  ],
                  selected: <action_state>{current_action},
                  onSelectionChanged: (Set<action_state> selection) =>
                      setState(() {
                    current_action = selection.first;
                  }),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.all(8.0), // Change the value as needed
                child: Image.asset('assets/images/logo.png',
                    height: 100, width: 100),
              ),
              SizedBox(height: 10),
            ]),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Padding(
                        padding:
                            EdgeInsets.all(8.0), // Change the value as needed
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'username'),
                          onSaved: (value) => _email = value ?? '',
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding:
                            EdgeInsets.all(8.0), // Change the value as needed
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          onSaved: (value) => _password = value ?? '',
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _submit,
                        child: Text(current_action == action_state.login
                            ? 'Login'
                            : 'Signup'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
