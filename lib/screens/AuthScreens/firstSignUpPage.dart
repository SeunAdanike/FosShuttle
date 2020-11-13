import 'package:flutter/material.dart';
import 'package:fluttershuttle/providers/database.dart';
import 'package:fluttershuttle/screens/AuthScreens/login.dart';

import 'secondSignUpPage.dart';

class FirstSignUpPage extends StatefulWidget {
  static const routeName = '/firstSignUp';
  @override
  _FirstSignUpPageState createState() => _FirstSignUpPageState();
}

class _FirstSignUpPageState extends State<FirstSignUpPage> {
  final formKey = GlobalKey<FormState>();

  TextEditingController nameEditingController = new TextEditingController();
  TextEditingController usernameEditingController = new TextEditingController();
  TextEditingController matNoEditingController = new TextEditingController();
  TextEditingController staffIdEditingController = new TextEditingController();
  TextEditingController phoneNoEditingController = new TextEditingController();
  TextEditingController driverIdEditingController = new TextEditingController();

  DatabaseMethods databaseMethods = new DatabaseMethods();

  Map<String, dynamic> _authData = {};
  Map<String, dynamic> _newAuthData = {};

  Map<String, dynamic> get items {
    return {..._newAuthData};
  }

  List<String> _userCategory = [
    'Student',
    'Faculty/Staff',
    'Driver',
    'Administrator',
  ];
  List<String> _studentCategory = [
    'Undergraduate',
    'Post-graduate',
  ];

  List<String> _shuttleTypes = [
    'SpaceWagon',
    'Car',
    'Bus(Hiace)',
    'Bus(Coaster)',
  ];

  String _selectUserCategory;
  String _selectStudentCategory;
  String _shuttleType;

  void _sendDataToSecondScreen(BuildContext context) {
    Map<String, dynamic> mapToSend = _authData;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SecondSignUpPage(
          userData: mapToSend,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Signup',
        ),
        backgroundColor: Colors.green,
      ),
      resizeToAvoidBottomPadding: true,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Form(
                key: formKey,
                child: Container(
                  padding: EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Surname first',
                          hintStyle: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                          labelText: 'Name',
                          labelStyle: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        obscureText: false,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a name!';
                          }
                        },
                        controller: nameEditingController,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: DropdownButton(
                          items: _userCategory.map((userCategory) {
                            return DropdownMenuItem(
                              child: Text(
                                userCategory,
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              value: userCategory,
                            );
                          }).toList(),
                          onChanged: (newCategory) {
                            setState(() {
                              _selectUserCategory = newCategory;
                              _authData['userCategory'] = newCategory;
                            });
                          },
                          hint: Text(
                            'Please choose your category',
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          value: _selectUserCategory,
                        ),
                      ),
                      if (_selectUserCategory == 'Student')
                        Align(
                          alignment: Alignment.topLeft,
                          child: DropdownButton(
                            items: _studentCategory.map((studentCategory) {
                              return DropdownMenuItem(
                                child: new Text(
                                  studentCategory,
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                value: studentCategory,
                              );
                            }).toList(),
                            onChanged: (newStudentCategory) {
                              setState(() {
                                _selectStudentCategory = newStudentCategory;
                                _authData['studentCategory'] =
                                    newStudentCategory;
                              });
                              if (_selectStudentCategory == null) {
                                return;
                              }
                            },
                            hint: Text(
                              'Degree of study',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                            value: _selectStudentCategory,
                          ),
                        ),
                      if (_selectUserCategory == 'Driver')
                        Align(
                          alignment: Alignment.topLeft,
                          child: DropdownButton(
                            items: _shuttleTypes.map((shuttleType) {
                              return DropdownMenuItem(
                                child: new Text(
                                  shuttleType,
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                value: shuttleType,
                              );
                            }).toList(),
                            onChanged: (driverShuttle) {
                              setState(() {
                                _shuttleType = driverShuttle;
                                _authData['ShuttleType'] = driverShuttle;
                              });
                              if (_shuttleType == null) {
                                return;
                              }
                            },
                            hint: Text(
                              'Shuttle Types',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                            value: _shuttleType,
                          ),
                        ),
                      if (_selectUserCategory == 'Student')
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Matric Number',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          obscureText: false,
                          validator: (value) {
                            if (value.isEmpty || value.length < 5) {
                              return 'Password is too short!';
                            }
                          },
                          controller: matNoEditingController,
                        ),
                      if (_selectUserCategory == 'Faculty/Staff')
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'StaffId',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          obscureText: false,
                          controller: staffIdEditingController,
                          validator: (value) {
                            if (value.isEmpty || value.length < 5) {
                              return 'Password is too short!';
                            }
                            if (value.contains('CU') || value.contains('cu')) {
                              return 'Invalid StaffId';
                            }
                          },
                        ),
                      if (_selectUserCategory == 'Driver')
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'DriverId',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Invalid DriverId!';
                            }
                          },
                          controller: driverIdEditingController,
                        ),
                      if (_selectUserCategory == 'Faculty/Staff' ||
                          _selectStudentCategory == 'Post-graduate' ||
                          _selectUserCategory == 'Driver' ||
                          _selectUserCategory == 'Administrator')
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Phone number',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value.isEmpty || value.length < 11) {
                              return 'Invalid Phone number!';
                            }
                          },
                          controller: phoneNoEditingController,
                        ),
                      SizedBox(height: 50.0),
                      GestureDetector(
                        onTap: () {
                          if (_selectUserCategory == 'Faculty/Staff' ||
                              _selectStudentCategory == 'Post-graduate' ||
                              _selectUserCategory == 'Driver' ||
                              _selectUserCategory == 'Administrator')
                            _authData['PhoneNumber'] =
                                phoneNoEditingController.text;
                          if (_selectUserCategory == 'Driver')
                            _authData['DriverId'] =
                                driverIdEditingController.text;
                          if (_selectUserCategory == 'Faculty/Staff')
                            _authData['StaffId'] =
                                staffIdEditingController.text;
                          if (_selectUserCategory == 'Student')
                            _authData['Matric Number'] =
                                matNoEditingController.text;
                          _authData['Name'] = nameEditingController.text;
                          _sendDataToSecondScreen(context);
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
                                'NEXT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Container(
                        height: 40.0,
                        color: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black,
                                  style: BorderStyle.solid,
                                  width: 1.0),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20.0)),
                          child: InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(),
                                ),
                              );
                            },
                            child: Center(
                              child: Text('Go Back',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat')),
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
                            'Already a user of CovenantShuttle?',
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
