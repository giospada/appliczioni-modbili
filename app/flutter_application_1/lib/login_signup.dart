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

enum ActionState {
  login,
  signUp,
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  ActionState current_action = ActionState.login;
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '';

  void _submit() async {
    final isValid = _formKey.currentState?.validate();
    if (!isValid!) return;

    _formKey.currentState?.save();
    try {
      final response = await http.post(
        Uri.parse(
            '${HOST}/${ActionState.login == current_action ? 'login' : 'sign up'}'),
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
                title: const Text('An error occurred'),
                content: Text(e.toString() ?? 'Unknown error occurred'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Okay'),
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
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: SegmentedButton<ActionState>(
                  segments: const [
                    ButtonSegment<ActionState>(
                        value: ActionState.login,
                        label: Text('Login'),
                        icon: Icon(Icons.login)),
                    ButtonSegment<ActionState>(
                        value: ActionState.signUp,
                        label: Text('Signup'),
                        icon: Icon(Icons.person_add)),
                  ],
                  selected: <ActionState>{current_action},
                  onSelectionChanged: (Set<ActionState> selection) =>
                      setState(() {
                    current_action = selection.first;
                  }),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding:
                    const EdgeInsets.all(8.0), // Change the value as needed
                child: Image.asset('assets/images/logo.png',
                    height: 100, width: 100),
              ),
              const SizedBox(height: 10),
            ]),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(
                              8.0), // Change the value as needed
                          child: TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'username'),
                            onSaved: (value) => _email = value ?? '',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(
                              8.0), // Change the value as needed
                          child: TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            onSaved: (value) => _password = value ?? '',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _submit,
                        child: Text(current_action == ActionState.login
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
