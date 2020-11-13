import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttershuttle/providers/database.dart';
import 'package:fluttershuttle/screens/MapScreens/user_Map_Screen.dart';
import 'package:fluttershuttle/screens/MapScreens/track_Driver.dart';
import 'package:fluttershuttle/widgets/main_drawer.dart';
import 'package:geolocator/geolocator.dart';

class OrderRequest extends StatefulWidget {
  @override
  _OrderRequestState createState() => _OrderRequestState();
}

class _OrderRequestState extends State<OrderRequest> {
  final _formKey = GlobalKey<FormState>();
  String _destLocation;

  String _userName;
  String _displayName;
  String _currentAddress;
  String _userPhoneNumber;
  String userId;

  Position _currentPosition;

  List _places = List();
  List _placesCoordinates = List();

  DatabaseMethods databaseMethods = DatabaseMethods();

  Map<String, dynamic> forDrivers = Map<String, dynamic>();

  TextEditingController placeEditingController = new TextEditingController();

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool placed = false;
  bool onSubmitNotification = false;

  getCurrentName() async {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    userId = uid;

    databaseMethods.getUsersById('users',uid).then((result) async {
      _userName = result['Name'];
      forDrivers.update(
        'Name',
        (value) => result['Name'],
        ifAbsent: () => result['Name'],
      );
      _displayName = _userName.toUpperCase();

      _userPhoneNumber = result['PhoneNumber'];
      forDrivers.update(
        'Phone Number',
        (value) => _userPhoneNumber,
        ifAbsent: () => _userPhoneNumber,
      );
    });
    forDrivers.update(
      'Status',
      (value) => placed,
      ifAbsent: () => placed,
    );
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];
      setState(() {
        _currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
        forDrivers.update(
          'Locality',
          (value) => _currentAddress,
          ifAbsent: () => _currentAddress,
        );
      });
    } catch (e) {
      print(e);
    }
  }

  _getCurrentLocation() async {
    await geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        GeoPoint _userCurrentLocation = GeoPoint(
          position.latitude,
          position.longitude,
        );
        forDrivers.update(
          'Location',
          (value) => _userCurrentLocation,
          ifAbsent: () => _userCurrentLocation,
        );
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _sendOrderRequestToDatabase() async {
    forDrivers.update(
      'Current Location',
      (value) => placeEditingController.text,
      ifAbsent: () => placeEditingController.text,
    );
    await databaseMethods.addSetAndOrders(forDrivers, userId).then((_) {
      setState(() {
        onSubmitNotification = true;
        placeEditingController.clear();
      });
    });
  }

  @override
  void initState() {
    placed = false;
    getCurrentName();
    _getCurrentLocation();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Pick-Up'),
        backgroundColor: Colors.green,
      ),
      drawer: MainDrawer(userName: _userName),
      body: Form(
        key: _formKey,
        autovalidate: true,
        child: Align(
          alignment: Alignment.center,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            child: SingleChildScrollView(
              child: StreamBuilder(
                  stream: Firestore.instance.collection('busStops').snapshots(),
                  builder: (context, snapshot) {
                    Map<String, GeoPoint> busStops = Map<String, GeoPoint>();
                    if (!snapshot.hasData)
                      return Container(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    QuerySnapshot fireBusStop = snapshot.data;
                    for (int i = 0; i < fireBusStop.documents.length; i++) {
                      busStops.update(
                        fireBusStop.documents[i].data['busStop'],
                        (value) => fireBusStop.documents[i].data['coordinates'],
                        ifAbsent: () =>
                            fireBusStop.documents[i].data['coordinates'],
                      );
                    }
                    _places = busStops.keys.toList();
                    _placesCoordinates = busStops.values.toList();

                    // Map placesAndCoordinates =
                    //     Map.fromIterables(_places, _placesCoordinates);

                    return Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: <Widget>[
                          Center(
                            child: FittedBox(
                              child: _displayName == null
                                  ? Container(
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : FittedBox(
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            'Welcome',
                                            style: TextStyle(fontSize: 25),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Text(
                                            '$_displayName',
                                            style: TextStyle(
                                              fontSize: 55,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                                labelText: 'Place Enter your current location',
                                labelStyle: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.green))),
                            validator: (val) {
                              return val.length >= 3
                                  ? null
                                  : 'Invalid location';
                            },
                            controller: placeEditingController,
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.green,
                                      style: BorderStyle.solid,
                                      width: 1.0),
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20.0)),
                              child: Center(
                                child: DropdownButton(
                                  items: _places.map((busStopName) {
                                    return DropdownMenuItem(
                                      child: Text(
                                        busStopName,
                                        style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      value: busStopName,
                                    );
                                  }).toList(),
                                  onChanged: (destinationLocation) {
                                    setState(() {
                                      _destLocation = destinationLocation;
                                      forDrivers.update(
                                        'Destination',
                                        (value) => _destLocation,
                                        ifAbsent: () => _destLocation,
                                      );
                                    });
                                  },
                                  hint: Center(
                                    child: Text(
                                      'Please select your location',
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54),
                                    ),
                                  ),
                                  value: _destLocation,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: _sendOrderRequestToDatabase,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.057,
                                      child: Material(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        shadowColor: Colors.greenAccent,
                                        color: Colors.green,
                                        elevation: 7.0,
                                        child: Center(
                                          child: Text(
                                            'Place Request',
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
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MapsReceiver(
                                                userName: _userName,
                                              ),
                                            ),
                                          );
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
                                  ),
                                ],
                              ),
                              if (onSubmitNotification)
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
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
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MapsReceiver(
                                                userName: _userName,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.057,
                                          child: Center(
                                            child: StreamBuilder(
                                                stream: Firestore.instance
                                                    .collection('pickUpRequest')
                                                    .document(userId)
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  if (!snapshot.hasData)
                                                    return Container(
                                                      child: Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                    );

                                                  bool status =
                                                      snapshot.data['Status'];
                                                  return status
                                                      ? FlatButton(
                                                          onPressed: () {
                                                            Navigator
                                                                .pushReplacement(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        TrackDriver(
                                                                  pickUpLocation:
                                                                      GeoPoint(
                                                                    _currentPosition
                                                                        .latitude,
                                                                    _currentPosition
                                                                        .longitude,
                                                                  ),
                                                                  userId:
                                                                      userId,
                                                                  userName:
                                                                      _userName,
                                                                ),
                                                              ),
                                                            );
                                                            databaseMethods
                                                                .deleteRequest(
                                                              'pickUpRequest',
                                                              userId,
                                                            );
                                                          },
                                                          child: Row(
                                                            children: <Widget>[
                                                              Flexible(
                                                                child: Text(
                                                                    'PickUp Received, Tap to \n\t\t\t\t\t\t\tTrack driver',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontFamily:
                                                                            'Montserrat')),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : Text(
                                                          'Please wait.........',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Montserrat'),
                                                        );
                                                }),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
            ),
          ),
        ),
      ),
    );
  }
}
