import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:fluttershuttle/providers/authenticate.dart';
import 'package:fluttershuttle/providers/database.dart';
import 'package:fluttershuttle/screens/MapScreens/user_Map_Screen.dart';
import 'package:fluttershuttle/screens/appScreens/driver_permission.dart';

import 'first_Sign_Up_Page.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/LoginPage';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();

  TextEditingController passwordEditingController = TextEditingController();
  TextEditingController usernameEditingController = TextEditingController();

  bool isLoading = false;
  String userId;

  AuthService authService = AuthService();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  DatabaseMethods databaseMethods = new DatabaseMethods();
  String getUserCategory;
  String getEmail;
  String userName;

  initiateSearch() async {
    if (usernameEditingController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await databaseMethods
          .getUserInfo('Username', usernameEditingController.text)
          .then((snapshot) async {
        await snapshot.documents.forEach((result) {
          getUserCategory = result.data['userCategory'];
          getEmail = result.data['Email'];
          userName = result.data['Name'];
        });
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  _signIn() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      await initiateSearch();
      await authService
          .signInWithEmailAndPassword(getEmail, passwordEditingController.text)
          .catchError((error) {
        var errorMessage = 'Authentication failed';
        if (error.toString().contains('EMAIL_EXISTS')) {
          errorMessage = 'This email address is already in use.';
        } else if (error.toString().contains('INVALID_EMAIL')) {
          errorMessage = 'This is not a valid email address';
        } else if (error.toString().contains('WEAK_PASSWORD')) {
          errorMessage = 'This password is too weak.';
        } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
          errorMessage = 'Could not find a user with that email.';
        } else if (error.toString().contains('INVALID_PASSWORD')) {
          errorMessage = 'Invalid password.';
        } else {
          const errorMessage =
              'Could not authenticate you. Please try again later.';
        }
        _showErrorDialog(errorMessage);
      }).then((result) async {
        if (result != null) {
          final FirebaseUser user = await _auth.currentUser();
          final uid = user.uid;
          userId = uid;

          getUserCategory == 'Driver'
              ? await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DriverPermission(
                            driverName: userName,
                            iD: userId,
                          )))
              : await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapsReceiver(
                      userName: userName,
                    ),
                  ),
                );
        } else {
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }

  int minute;
  int hour;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DateTime currentTime = DateTime.now();
    hour = currentTime.hour;
    minute = currentTime.minute;
  }

  void dispose() {
    super.dispose();
    usernameEditingController.dispose();
    passwordEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/images/Drone-view.jpg',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomPadding: true,
        body: isLoading
            ? Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Stack(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.fromLTRB(15.0, 110.0, 0.0, 0.0),
                            child: Text('Hello',
                                style: TextStyle(
                                    fontSize: 60.0,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(16.0, 175.0, 0.0, 0.0),
                            child: Text(
                                ((hour >= 0 && hour <= 11) && minute <= 59)
                                    ? 'Good Morning'
                                    : ((hour > 11 && hour <= 16) &&
                                            minute <= 59)
                                        ? 'Good Afternoon'
                                        : 'Good Evening',
                                style: TextStyle(
                                    fontSize: 40.0,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    Form(
                      key: formKey,
                      child: Container(
                          padding: EdgeInsets.only(
                              top: 35.0, left: 20.0, right: 20.0),
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'Username',
                                    labelStyle: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.green))),
                                validator: (val) {
                                  return val.length >= 3
                                      ? null
                                      : 'Invalid Username';
                                },
                                controller: usernameEditingController,
                              ),
                              SizedBox(height: 20.0),
                              TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.green))),
                                obscureText: true,
                                validator: (val) {
                                  return val.length < 6
                                      ? "Enter Password 6+ characters"
                                      : null;
                                },
                                controller: passwordEditingController,
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Container(
                                alignment: Alignment(1.0, 0.0),
                                padding: EdgeInsets.only(top: 15.0, left: 20.0),
                                child: InkWell(
                                  onTap: () {},
                                  child: Text(
                                    'Forgot Password',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat',
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                              ),
                              SizedBox(height: 40.0),
                              GestureDetector(
                                onTap: () {
                                  _signIn();
                                },
                                child: Container(
                                  height: 40.0,
                                  child: Material(
                                    borderRadius: BorderRadius.circular(20.0),
                                    shadowColor: Colors.greenAccent,
                                    color: Colors.green,
                                    elevation: 7.0,
                                    child: Center(
                                      child: Text(
                                        'LOGIN',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Montserrat'),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.0),
                            ],
                          )),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'New to FosShuttle?',
                          style: TextStyle(fontFamily: 'Montserrat'),
                        ),
                        SizedBox(width: 5.0),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FirstSignUpPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Register',
                            style: TextStyle(
                              color: Colors.green,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
