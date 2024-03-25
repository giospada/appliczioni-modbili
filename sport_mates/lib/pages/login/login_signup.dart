import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sport_mates/pages/login/action_state_login.dart';
import 'package:sport_mates/pages/login/login_signup_widget.dart';

class LoginSignupPage extends StatefulWidget {
  @override
  _LoginSignupPageState createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage>
    with TickerProviderStateMixin {
  ActionStateLogin current_action = ActionStateLogin.login;

  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Login',
              icon: Icon(Icons.login),
            ),
            Tab(
              text: 'Sign Up',
              icon: Icon(Icons.person_add),
            ),
          ],
        ),
        body: SafeArea(
          child: TabBarView(controller: _tabController, children: [
            LoginSignUpWidget(
              action: ActionStateLogin.login,
            ),
            LoginSignUpWidget(
              action: ActionStateLogin.signUp,
            ),
          ]),
        ));
  }
}
