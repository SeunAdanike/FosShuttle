import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershuttle/providers/database.dart';

class AdministratorEdit extends StatefulWidget {
  @override
  _AdministratorEditState createState() => _AdministratorEditState();
}

class _AdministratorEditState extends State<AdministratorEdit> {
  DatabaseMethods databaseMethods = DatabaseMethods();

  LinkedHashMap<String, dynamic> adminMessages =
      LinkedHashMap<String, dynamic>();
  String message;

  List driverIds = List();

  _getDriversDetails() async {
    Firestore.instance.collection('trackData').snapshots().listen((event) {
      for (int i = 0; i < event.documents.length; i++) {
        driverIds.insert(i, event.documents[i].documentID);
      }
      print(driverIds);
    });
  }

  void _showDetailsDialog(DocumentSnapshot documentSnapshot) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Driver\'s details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text('Name: '),
                SizedBox(
                  width: 30,
                ),
                Text(
                  documentSnapshot['Name'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text('PhoneNumber: '),
                SizedBox(
                  width: 20,
                ),
                Text(
                  documentSnapshot['PhoneNumber'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text('ShuttleType: '),
                SizedBox(
                  width: 25,
                ),
                Text(
                  documentSnapshot['ShuttleType'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text('DriverId: '),
                SizedBox(
                  width: 20,
                ),
                Text(
                  documentSnapshot['DriverId'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Delete driver'),
            onPressed: () {
              databaseMethods.deleteDocument(
                  'drivers', documentSnapshot.documentID);
              databaseMethods.deleteDocument(
                  'users', documentSnapshot.documentID);
              Navigator.of(ctx).pop();
            },
          ),
          SizedBox(
            width: 20,
          ),
          FlatButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          SizedBox(
            width: 25,
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(context, DocumentSnapshot document) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: ListTile(
            leading: Icon(
              Icons.person,
              size: 26,
            ),
            title: Text(
              document['Name'],
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              _showDetailsDialog(document);
            },
          ),
        ),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
                icon: Icon(
                  Icons.settings,
                ),
                onPressed: () {} //_showMessage,
                ))
      ],
    );
  }

  @override
  void initState() {
    _getDriversDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // _getMessage();
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Screen'),
        backgroundColor: Colors.green,
        actions: <Widget>[],
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection('drivers').snapshots(),
          builder: (context, snapshot) {
            // print(snapshot.data.documents[1].documentID);
            if (!snapshot.hasData)
              return Container(
                child: CircularProgressIndicator(),
              );
            return Container(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * .65,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            return _buildListTile(
                                context, snapshot.data.documents[index]);
                          }),
                    ),
                    Divider(),
                    GestureDetector(
                      //onTap: _sendOrderRequestToDatabase,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: MediaQuery.of(context).size.height * 0.057,
                        child: Material(
                          borderRadius: BorderRadius.circular(20.0),
                          shadowColor: Colors.greenAccent,
                          color: Colors.green,
                          elevation: 7.0,
                          child: Center(
                            child: Text(
                              'Add/Remove Driver',
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
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * .3,
                          height: MediaQuery.of(context).size.height * 0.05,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black,
                                  style: BorderStyle.solid,
                                  width: 1.0),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20.0)),
                          child: InkWell(
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) =>
                              //         MapsReceiver(
                              //       userName: _userName,
                              //     ),
                              //   ),
                              // );
                            },
                            child: Center(
                              child: Text(
                                'Go Back',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Montserrat'),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * .3,
                          height: MediaQuery.of(context).size.height * 0.05,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black,
                                  style: BorderStyle.solid,
                                  width: 1.0),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20.0)),
                          child: InkWell(
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) =>
                              //         MapsReceiver(
                              //       userName: _userName,
                              //     ),
                              //   ),
                              // );
                            },
                            child: Center(
                              child: Text(
                                'Return to Map',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Montserrat'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
