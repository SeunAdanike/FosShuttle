import 'package:flutter/material.dart';

enum Mode { ConfirmOldPassword, ChangePassword }

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController passwordEditingController = TextEditingController();
  Mode _authMode = Mode.ConfirmOldPassword;

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

  onConfirmOldPassword() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _authMode = Mode.ChangePassword;
    });
    _showErrorDialog('Old password correct');
  }

  onSubmitChange() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    _showErrorDialog('Password Changed successfully');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Container(
          //alignment: AlignmentGeometry.,
          height: MediaQuery.of(context).size.height * .7,
          child: Form(
            key: _formKey,
            child: Center(
              child: Container(
                  padding: EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: _authMode == Mode.ConfirmOldPassword
                                ? 'Please enter your old password'
                                : 'Please Enter Your New Password',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.green))),
                        validator: (val) {
                          return val.length >= 6 ? null : 'Incorrect Password';
                        },
                        controller: passwordEditingController,
                      ),
                      SizedBox(height: 20.0),
                      if (_authMode == Mode.ChangePassword)
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Confirm Your New Password',
                              labelStyle: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green))),
                          obscureText: true,
                          validator: (val) {
                            return passwordEditingController.text != val
                                ? "Enter Password 6+ characters"
                                : null;
                          },
                        ),
                      SizedBox(
                        height: 5.0,
                      ),
                      if (_authMode == Mode.ConfirmOldPassword)
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
                          _authMode == Mode.ConfirmOldPassword
                              ? onConfirmOldPassword()
                              : onSubmitChange();
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
                                _authMode == Mode.ConfirmOldPassword
                                    ? 'Confirm Password'
                                    : 'Submit Change',
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
          ),
        ),
      ),
    );
  }
}
