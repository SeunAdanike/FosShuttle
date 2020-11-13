import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileUpdate extends StatefulWidget {
  @override
  _ProfileUpdateState createState() => _ProfileUpdateState();
}

class _ProfileUpdateState extends State<ProfileUpdate> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription _listener;
  Map<String, dynamic> userDetails = Map<String, dynamic>();
  List _fieldToEdit = List();
  String _dataToEdit;
  String _userId;
  bool _nextEdit = false;
  TextEditingController _editingController = TextEditingController();

  _onSubmitted() async {
    _nextEdit = false;
    _showMaterialDialog(_dataToEdit);
    await Firestore.instance
        .collection('users')
        .document(_userId)
        .updateData({'$_dataToEdit': _editingController.text});
  }

  _showMaterialDialog(String field) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text("Field Changed"),
              content: Text(
                  "$field, has been changed. You can select another data to update"),
              actions: <Widget>[
                Row(
                  children: <Widget>[
                    FlatButton(
                      child: Text('Okay'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _dataToEdit = null;
                          _editingController.clear();
                        });
                      },
                    ),
                    FlatButton(
                      child: Text('Close!'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _dataToEdit = null;
                          _editingController.clear();
                        });
                      },
                    ),
                  ],
                )
              ],
            ));
  }

  _fieldToUpdate() async {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    if (_listener != null) {
      _listener.cancel();
    }
    _listener = Firestore.instance
        .collection('users')
        .document(uid)
        .snapshots()
        .listen((event) {
      userDetails = Map.fromIterables(
        event.data.keys,
        event.data.values,
      );

      _fieldToEdit = userDetails.keys.toList();
      _fieldToEdit.remove('Email');
      setState(() {});
    });
  }

  @override
  void initState() {
    _nextEdit = false;
    _fieldToUpdate();
    super.initState();
  }

  @override
  void dispose() {
    _listener.cancel(); // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Update Profile',
          ),
          backgroundColor: Colors.green,
        ),
        body: _fieldToEdit.isEmpty
            ? Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Center(
                child: SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Card(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Center(
                              child: DropdownButton(
                                items: _fieldToEdit.map((editField) {
                                  return DropdownMenuItem(
                                    child: Center(
                                      child: Text(
                                        editField,
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                    value: editField,
                                  );
                                }).toList(),
                                onChanged: (newCategory) {
                                  setState(() {
                                    _dataToEdit = newCategory;
                                    _nextEdit = true;
                                  });
                                },
                                hint: Text(
                                  'Please Select the data to be edited',
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                ),
                                value: _dataToEdit,
                              ),
                            ),
                            if (_nextEdit)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      hintText: '$_dataToEdit',
                                      hintStyle: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                      labelText: '$_dataToEdit',
                                      labelStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    obscureText: false,
                                    keyboardType: _dataToEdit == 'PhoneNumber'
                                        ? TextInputType.number
                                        : TextInputType.text,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please enter a valid Field!';
                                      }
                                    },
                                    controller: _editingController,
                                  ),
                                ),
                              ),
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: _onSubmitted,
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    height: MediaQuery.of(context).size.height *
                                        0.057,
                                    child: Material(
                                      borderRadius: BorderRadius.circular(20.0),
                                      shadowColor: Colors.greenAccent,
                                      color: Colors.green,
                                      elevation: 7.0,
                                      child: Center(
                                        child: Text(
                                          'Submit Change',
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
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  height: MediaQuery.of(context).size.height *
                                      0.057,
                                  color: Colors.transparent,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black,
                                            style: BorderStyle.solid,
                                            width: 1.0),
                                        color: Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(20.0)),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) => MapsReceiver(
                                        //       userName: _userName,
                                        //     ),
                                        //   ),
                                        // );
                                      },
                                      child: Center(
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Montserrat'),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ));
  }
}
