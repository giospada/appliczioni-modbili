import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sport_mates/provider/auth_provider.dart';
import 'package:sport_mates/config/config.dart';
import 'package:sport_mates/pages/login/action_state_login.dart';

class LoginSignUpWidget extends StatefulWidget {
  final ActionStateLogin action;

  const LoginSignUpWidget({super.key, required this.action});

  @override
  State<LoginSignUpWidget> createState() => _LoginSignUpWidgetState(
        action: action,
      );
}

class _LoginSignUpWidgetState extends State<LoginSignUpWidget> {
  final ActionStateLogin action;
  _LoginSignUpWidgetState({required this.action});

  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '';
  bool loading = false;

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate();
    Config config = Config();
    if (!isValid!) return;
    setState(
      () {
        loading = true;
      },
    );

    _formKey.currentState?.save();
    final response = await http.post(
      Uri.https(config.host,
          '/${ActionStateLogin.login == action ? 'login' : 'signup'}'),
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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(json.decode(response.body)['detail'])));
    }
    setState(
      () {
        loading = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Column(children: [
            const SizedBox(
              height: 20,
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(child: child, scale: animation);
              },
              child: SvgPicture.asset(
                action != ActionStateLogin.login
                    ? 'assets/svg/sign_up.svg'
                    : 'assets/svg/login.svg',
                height: 150,
                width: 150,
                key: ValueKey<String>(action.toString()),
              ),
            ),
            const SizedBox(height: 20),
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
                          onChanged: (value) => _password = value ?? '',
                          onSaved: (value) => _password = value ?? '',
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter a password' : null,
                        ),
                      ),
                    ),
                    (action == ActionStateLogin.signUp)
                        ? Flexible(
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  8.0), // Change the value as needed
                              child: TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Confirm Password'),
                                obscureText: true,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (value != _password) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          )
                        : const SizedBox(height: 0),
                    const SizedBox(height: 10),
                    (loading)
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () => _submit(),
                            child: Text(action == ActionStateLogin.login
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
    );
  }
}
