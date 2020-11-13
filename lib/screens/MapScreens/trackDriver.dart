import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttershuttle/screens/AuthScreens/login.dart';
import 'package:fluttershuttle/widgets/main_drawer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackDriver extends StatefulWidget {
  GeoPoint pickUpLocation;
  String userId;
  String userName;
  TrackDriver({
    @required this.pickUpLocation,
    @required this.userId,
    @required this.userName,
  });
  @override
  _TrackDriverState createState() =>
      _TrackDriverState(pickUpLocation, userId, userName);
}

class _TrackDriverState extends State<TrackDriver> {
  static const api_key = 'AIzaSyCTIRKgbnHsa_nWRcC_-4kPsFqYlSEuzlA';
  GeoPoint pickUpLocation;
  GoogleMapController mapController;
  String userId;
  String _userName;
  _TrackDriverState(this.pickUpLocation, this.userId, this._userName);
  Set<Marker> _markers = {};
  PolylinePoints polylinePoints;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  final FirebaseAuth _auth = FirebaseAuth.instance;

  _addMarkers(driverLocation, requestLocation) {
    _markers.add(Marker(
      markerId: MarkerId('Driver'),
      position: LatLng(
        driverLocation.latitude,
        driverLocation.longitude,
      ),
      infoWindow: InfoWindow(
        title: 'CurrentPlace',
      ),
      icon: BitmapDescriptor.defaultMarker,
    ));
    _markers.add(Marker(
      markerId: MarkerId('PickUp'),
      position: LatLng(
        requestLocation.latitude,
        requestLocation.longitude,
      ),
      infoWindow: InfoWindow(
        title: 'Destination',
        //snippet: place,
      ),
      icon: BitmapDescriptor.defaultMarker,
    ));
  }

  _createPolylines(GeoPoint start, GeoPoint destination) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      api_key, // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.transit,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    PolylineId id = PolylineId('Route');

    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );

    polylines[id] = polyline;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking Driver'),
        backgroundColor: Colors.green,
      ),
      drawer: MainDrawer(
        userName: _userName,
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            StreamBuilder(
                stream: Firestore.instance
                    .collection('pickUpRequest')
                    .document(userId)
                    .snapshots(),
                builder: (context, reply) {
                  if (!reply.hasData)
                    return Container(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  GeoPoint driverLocation = reply.data['DriversLocation'];
                  _addMarkers(driverLocation, pickUpLocation);
                  _createPolylines(pickUpLocation, driverLocation);
                  return GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        pickUpLocation.latitude,
                        pickUpLocation.longitude,
                      ),
                      zoom: 18,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    mapType: MapType.normal,
                    zoomGesturesEnabled: true,
                    zoomControlsEnabled: true,
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                    polylines: Set<Polyline>.of(polylines.values),
                    markers: _markers,
                  );
                }),
            Align(
              alignment: Alignment.bottomCenter,
              child: FlatButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                  );
                  _auth.signOut();
                },
                child: Text('Log Out'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
