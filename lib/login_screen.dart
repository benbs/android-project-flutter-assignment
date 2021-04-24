import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/auth_repository.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            SizedBox(height: 24.0),
            Text('Welcome to Startup Name Generator, please login below',
                style: TextStyle(fontSize: 16.0)),
            SizedBox(height: 48.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            Padding(
                padding: EdgeInsets.only(top: 20),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                        width: double.maxFinite,
                        child: Consumer<AuthRepository>(
                            builder: (context, authRepository, _) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).primaryColor,
                                onPrimary: Colors.white,
                                shape: StadiumBorder()),
                            child: Text('Login'),
                            onPressed:
                                authRepository.status == Status.Authenticating
                                    ? null
                                    : _onLoginPressed,
                          );
                        })),
                    SizedBox(
                        width: double.maxFinite,
                        child: Consumer<AuthRepository>(
                            builder: (context, authRepository, _) {
                          return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Theme.of(context).accentColor,
                                  onPrimary: Colors.white,
                                  shape: StadiumBorder()),
                              child: Text('New user? Click to sign up'),
                              onPressed: () {
                                showModalBottomSheet(
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (context) => _showSignupModal());
                              });
                        })),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _showSignupModal() {
    return Padding(
      padding: EdgeInsets.only(
          left: 16,
          right: 16),
          child: Form(key: _formKey, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                  child: Padding(
                      padding: EdgeInsets.only(top: 12, bottom: 5),
                      child: Text(
                        "Please confirm your password below:",
                        style: Theme.of(context).textTheme.bodyText2,
                      ))),
              Divider(),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords must match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Center(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).accentColor),
                      onPressed: _onSignupPressed,
                      child: Text("Confirm",
                          style: (Theme.of(context).textTheme.bodyText1
                                  as TextStyle)
                              .merge(TextStyle(color: Colors.white)))))
            ],
          )),
    );
  }

  void _displaySnackbar(final String text) {
    final snackBar =
        SnackBar(content: Text(text), behavior: SnackBarBehavior.floating);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _onSignupPressed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    AuthRepository authRepository =
        Provider.of<AuthRepository>(context, listen: false);
    try {
      await authRepository.signUp(
          _emailController.text, _passwordController.text);
      Navigator.of(context).pushNamed('/');
    } catch (err) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Error"),
            content: new Text(err.toString()),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new ElevatedButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      _displaySnackbar(err.toString());
    }
  }

  void _onLoginPressed() async {
    final bool loggedIn =
        await Provider.of<AuthRepository>(context, listen: false)
            .signIn(_emailController.text, _passwordController.text);
    if (loggedIn) {
      Navigator.of(context).pushNamed('/');
    } else {
      final snackBar = SnackBar(content: Text('Failure'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
