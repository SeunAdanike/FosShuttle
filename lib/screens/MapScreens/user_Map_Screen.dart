import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:fluttershuttle/providers/authenticate.dart';
import 'package:fluttershuttle/providers/database.dart';
import 'package:fluttershuttle/screens/AuthScreens/login_Screen.dart';
import 'package:fluttershuttle/screens/appScreens/admin_screen.dart';
import 'package:fluttershuttle/screens/appScreens/order_Request_Screen.dart';
import 'package:fluttershuttle/screens/appScreens/schedule_Screen.dart';
import 'package:fluttershuttle/widgets/main_drawer.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapsReceiver extends StatefulWidget {
  final String userName;

  MapsReceiver({@required this.userName});

  static const routeName = '/userMap';

  @override
  State createState() => MapsReceiverState(userName);
}

class MapsReceiverState extends State<MapsReceiver> {
  String _userName;

  MapsReceiverState(this._userName);


  static GoogleMapController mapController;

  Map<String, double> currentLocation = Map();

  Location location = Location();
  String error;
  Set<Polygon> _polygons = HashSet<Polygon>();
  DatabaseMethods _databaseMethods = DatabaseMethods();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String userCat;
  bool _isAdmin;

  _getUserCategory() async {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    _databaseMethods.getUsersById('users', uid).then((result) {
      userCat = result['studentCategory'];
      result['userCategory'] == 'Administrator' ? _isAdmin = true : _isAdmin = false;
    });
  }

  void _setPolygons() {
    List<LatLng> polygonLatLongs = List<LatLng>();
    polygonLatLongs.add(LatLng(6.672595, 3.151276));
    polygonLatLongs.add(LatLng(6.667549, 3.153160));
    polygonLatLongs.add(LatLng(6.667208, 3.155820));
    polygonLatLongs.add(LatLng(6.665162, 3.155605));
    polygonLatLongs.add(LatLng(6.663712, 3.161869));
    polygonLatLongs.add(LatLng(6.664480, 3.166031));
    polygonLatLongs.add(LatLng(6.665247, 3.166014));
    polygonLatLongs.add(LatLng(6.666099, 3.164973));
    polygonLatLongs.add(LatLng(6.667346, 3.163118));
    polygonLatLongs.add(LatLng(6.670984, 3.163353));
    polygonLatLongs.add(LatLng(6.678610, 3.162515));
    polygonLatLongs.add(LatLng(6.678418, 3.160263));
    polygonLatLongs.add(LatLng(6.675093, 3.160177));
    polygonLatLongs.add(LatLng(6.674624, 3.157898));

    _polygons.add(
      Polygon(
        polygonId: PolygonId("Covenant Map"),
        points: polygonLatLongs,
        fillColor: Colors.transparent,
        strokeColor: Colors.purple,
        strokeWidth: 1,
        visible: true,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  DatabaseMethods databaseMethods = DatabaseMethods();

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  void initMarker(request, requestId) {
    var markerIdVal = requestId;
    final MarkerId markerId = MarkerId(markerIdVal);
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        request['latitude'],
        request['longitude'],
      ),
    );

    markers[markerId] = marker;
  }

  @override
  void initState() {
    _isAdmin = false;
    super.initState();
    _setPolygons();
    _getUserCategory();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(
        userName: _userName,
      ),
      appBar: AppBar(
        title: Text('Overview'),
        backgroundColor: Colors.green,
        actions: <Widget>[
          if (_isAdmin)
            FlatButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Administrator(),
                    ),
                  );
                },
                child: Text('Admin Screen'))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(0),
        child: Stack(
          children: <Widget>[
            StreamBuilder<Object>(
                stream: Firestore.instance.collection('trackData').snapshots(),
                builder: (context, value) {
                  if (!value.hasData)
                    return Container(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  QuerySnapshot dataValue = value.data;

                  if (dataValue.documents.isNotEmpty) {
                    for (int i = 0; i < dataValue.documents.length; ++i) {
                      initMarker(
                        dataValue.documents[i].data,
                        dataValue.documents[i].documentID,
                      );
                    }
                  }
                  return GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        6.671206,
                        3.158301,
                      ),
                      zoom: 15.5,
                    ),
                    onMapCreated: _onMapCreated,
                    zoomGesturesEnabled: true,
                    zoomControlsEnabled: false,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    polygons: _polygons,
                    markers: Set<Marker>.of(markers.values),
                  );
                }),
            Align(
              alignment: Alignment.bottomCenter,
              child: FlatButton(
                onPressed: () {
                  AuthService().signOut();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                },
                child: Text(
                  'Log out',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            if (userCat != 'Undergraduate' &&
                (userCat == null || userCat == 'Post-graduate'))
              Align(
                alignment: Alignment.bottomRight,
                child: FlatButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderRequest(),
                      ),
                    );
                  },
                  child: Text(
                    'Place Orders',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FloatingActionButton(
                  heroTag: null,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScheduleTable(
                          userName: _userName,
                        ),
                      ),
                    );
                  },
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.green,
                  child: const Icon(
                    Icons.table_chart,
                    size: 35,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
