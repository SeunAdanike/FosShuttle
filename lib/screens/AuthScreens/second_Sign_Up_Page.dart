import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttershuttle/providers/authenticate.dart';
import 'package:fluttershuttle/providers/database.dart';

import 'login_Screen.dart';

class SecondSignUpPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  SecondSignUpPage({@required this.userData});

  static const routeName = '/secondSignUp';
  @override
  _SecondSignUpPageState createState() => _SecondSignUpPageState(userData);
}

class _SecondSignUpPageState extends State<SecondSignUpPage> {
  TextEditingController passwordEditingController = new TextEditingController();
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController usernameEditingController = new TextEditingController();

  DatabaseMethods databaseMethods = new DatabaseMethods();

  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Map<String, dynamic> userData;
  _SecondSignUpPageState(this.userData);

  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthService authService = new AuthService();

  _signUp() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      await authService
          .signUpWithEmailAndPassword(
              emailEditingController.text, passwordEditingController.text)
          .then((result) async {
        if (result != null) {
          final FirebaseUser user = await _auth.currentUser();
          final uid = user.uid;
          databaseMethods.addUserInfo(userData, uid);
          userData['userCategory'] == 'Driver'
              ? databaseMethods.addDriverInfo(userData, uid)
              : userData['userCategory'] == 'Faculty/Staff'
                  ? databaseMethods.addStaffandFacultyInfo(userData, uid)
                  : userData['userCategory'] == 'Student'
                      ? databaseMethods.addStudentInfo(userData, uid)
                      : databaseMethods.addAdminInfo(userData, uid);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
        }
      });
    }
  }

  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailEditingController.dispose();
    passwordEditingController.dispose();
    usernameEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(
          'Signup',
        ),
        backgroundColor: Colors.green,
      ),
      resizeToAvoidBottomPadding: true,
      body: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Center(
              child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Form(
                        key: formKey,
                        child: Container(
                          padding: EdgeInsets.only(
                              top: 35.0, left: 20.0, right: 20.0),
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) {
                                  return RegExp(
                                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                          .hasMatch(val)
                                      ? null
                                      : "Enter correct email";
                                },
                                controller: emailEditingController,
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  labelStyle: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                ),
                                controller: usernameEditingController,
                                validator: (val) {
                                  return val.isEmpty || val.length < 3
                                      ? "Enter Username 3+      characters"
                                      : null;
                                },
                              ),
                              SizedBox(height: 10.0),
                              TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'Password ',
                                    labelStyle: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.green))),
                                obscureText: true,
                                controller: passwordEditingController,
                                validator: (val) {
                                  return val.length < 6
                                      ? "Enter Password 6+ characters"
                                      : null;
                                },
                              ),
                              SizedBox(height: 10.0),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password ',
                                  labelStyle: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                ),
                                validator: (val) {
                                  return passwordEditingController.text != val
                                      ? "Enter Password 6+ characters"
                                      : null;
                                },
                                obscureText: true,
                              ),
                              SizedBox(height: 50.0),
                              GestureDetector(
                                  onTap: () {
                                    userData.putIfAbsent('Username',
                                        () => usernameEditingController.text);
                                    userData.putIfAbsent(
                                        'Email',
                                        () => emailEditingController.text
                                            .toLowerCase());
                                    _signUp();
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
                                          'SIGNUP',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Montserrat'),
                                        ),
                                      ),
                                    ),
                                  )),
                              SizedBox(height: 20.0),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  height: 40.0,
                                  color: Colors.transparent,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black,
                                          style: BorderStyle.solid,
                                          width: 1.0),
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Go Back',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'Already a user of FosShuttle?',
                                    style: TextStyle(fontFamily: 'Montserrat'),
                                  ),
                                  SizedBox(width: 5.0),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LoginPage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'LogIn',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              )
                            ],
                          ),
                        ),
                      ),
                    ]),
              ),
            ),
    );
  }
}
