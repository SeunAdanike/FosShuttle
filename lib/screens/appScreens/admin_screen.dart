import 'dart:collection';
import 'package:fluttershuttle/screens/MapScreens/user_Map_Screen.dart';
import 'package:fluttershuttle/screens/appScreens/admin_editing.dart';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershuttle/providers/database.dart';

class Administrator extends StatefulWidget {
  final String username;

  Administrator({this.username});
  @override
  _AdministratorState createState() => _AdministratorState(username);
}

class _AdministratorState extends State<Administrator> {
  final _messageController = TextEditingController();
  DatabaseMethods databaseMethods = DatabaseMethods();
  final GlobalKey<FormState> _formKey = GlobalKey();
  LinkedHashMap<String, dynamic> adminMessages =
      LinkedHashMap<String, dynamic>();
  String message;
  List driverIds = List();
  String _username;

  _AdministratorState(this._username);

  _getLocationsDetails() async {
    Firestore.instance.collection('trackData').snapshots().listen((event) {
      for (int i = 0; i < event.documents.length; i++) {
        driverIds.insert(i, event.documents[i].documentID);
      }
      print(driverIds);
    });
  }

  List sentTime = List();
  List sentMessage = List();

  _getMessage(uid) async {
    Firestore.instance
        .collection('messaging')
        .document(uid)
        .snapshots()
        .listen((event) async {
      if (event.exists) {
        setState(() {
          print(uid);
          sentTime = event.data.keys.toList();
          sentMessage = event.data.values.toList();
        });
      }
    });
  }

  _onSendMessage(uid) async {
    DateTime now = DateTime.now();
    var newFormat = DateFormat("E, d MMM yyyy HH:mm:ss");
    String currentTime = newFormat.format(now);
    if (_messageController.text.isNotEmpty) {
      adminMessages.update(
        'Admin Message $currentTime',
        (value) => _messageController.text,
        ifAbsent: () => _messageController.text,
      );
      await databaseMethods.sendMessage(adminMessages, uid);
    } else {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                scrollable: true,
                title: Text('No message entered'),
                content: Column(
                  children: <Widget>[
                    Center(child: Text('Please enter a message')),
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Close'),
                    )
                  ],
                ),
              ));
    }
  }

  void _showMessageDialog(uid) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              scrollable: true,
              title: Text('Send driver message'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(height: 7),
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            labelText: 'Enter Message',
                            border: OutlineInputBorder(),
                          ),
                          controller: _messageController,
                          onSaved: (newValue) {
                            message = newValue;
                          },
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 15),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        RaisedButton(
                          color: Colors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.green)),
                          onPressed: () {
                            _onSendMessage(uid);
                            _messageController.clear();
                            Navigator.of(context).pop();
                          },
                          child: Text('Send'),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              side: BorderSide(color: Colors.green)),
                          onPressed: () {
                            _messageController.clear();
                            Navigator.of(ctx).pop();
                          },
                          child: Text('Cancel'),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  FlatButton(
                    onPressed: () {
                      _getMessage(uid).then((_) {
                        _replyDialog(uid);
                      });
                    },
                    child: Text('View all messages'),
                  )
                ],
              ),
            ));
  }

  void _replyDialog(uid) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              scrollable: true,
              title: Text('Reply Driver'),
              content: Container(
                height: 250.0,
                width: double.maxFinite,
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListView.builder(
                            physics: ClampingScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: sentMessage.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(7.0),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.15,
                                          child: Text(
                                            sentTime[index],
                                            style: TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04,
                                        ),
                                        Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.35,
                                            child: Text(
                                              sentMessage[index],
                                              style: TextStyle(
                                                fontSize: 17,
                                              ),
                                            )),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                  ],
                                ),
                              );
                            }),
                        if (onReply)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(
                                        color: Colors.green, width: 0.5),
                                    bottom: BorderSide(
                                        color: Colors.green, width: 0.5)),
                                color: Colors.white,
                              ),
                              child: TextField(
                                maxLines: null,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15.0),
                                controller: _messageController,
                                decoration: InputDecoration.collapsed(
                                  hintText: 'Type your message...',
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                RaisedButton(
                                    onPressed: () {
                                      onReply
                                          ? setState(() {
                                              onReply = false;
                                              _onSendMessage(uid);
                                            })
                                          : setState(() {
                                              onReply = true;
                                            });
                                    },
                                    child: Text(onReply ? 'Send' : 'Reply')),
                                SizedBox(
                                  width: 30,
                                ),
                                FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      setState(() {
                                        // isMessageRead = false;
                                        // print(isMessageRead);
                                      });
                                    },
                                    child: Text('Close')),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ));
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
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          SizedBox(
            width: 20,
          ),
          FlatButton(
            child: Text('Send Message'),
            onPressed: () {
              Navigator.of(context).pop();
              _showMessageDialog(documentSnapshot.documentID);
            },
          ),
          SizedBox(
            width: 25,
          )
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
                Icons.message,
              ),
              onPressed: () {
                _showMessageDialog(document.documentID);
              }),
        )
      ],
    );
  }

  bool onReply = false;

  @override
  void initState() {
    _getLocationsDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Screen'),
        backgroundColor: Colors.green,
        actions: <Widget>[
          FlatButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdministratorEdit()),
                );
              },
              child: Text('View all Drivers'))
        ],
      ),
      body: Stack(children: <Widget>[
        StreamBuilder(
            stream: Firestore.instance.collection('drivers').snapshots(),
            builder: (context, snapshot) {
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdministratorEdit()),
                          );
                        },
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
                                'View All Drivers',
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
                                Navigator.of(context).pop();
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MapsReceiver(
                                      userName: _username,
                                    ),
                                  ),
                                );
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
      ]),
    );
  }
}
