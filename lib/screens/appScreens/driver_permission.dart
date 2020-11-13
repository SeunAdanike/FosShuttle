import 'package:flutter/material.dart';
import 'package:fluttershuttle/providers/database.dart';
import 'package:fluttershuttle/screens/AuthScreens/login_Screen.dart';
import 'package:fluttershuttle/widgets/main_drawer.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../MapScreens/driver_Map_Screen.dart';

class DriverPermission extends StatefulWidget {
  final String driverName;
  final String iD;
  static const routeName = '/showOnMap';
  DriverPermission({this.driverName, this.iD});
  @override
  _DriverPermissionState createState() =>
      _DriverPermissionState(driverName, iD);
}

class _DriverPermissionState extends State<DriverPermission> {
  LatLng presentPosition;
  DatabaseMethods databaseMethods = new DatabaseMethods();
  String _driverName;
  String _iD;

  _DriverPermissionState(this._driverName, this._iD);

  Future<LatLng> getCurrentLocation() async {
    final currentPosition = await Geolocator().getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    presentPosition = LatLng(
      currentPosition.latitude,
      currentPosition.longitude,
    );
    print(presentPosition);
    return presentPosition;
  }

  bool isSwitched = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(
        userName: _driverName,
      ),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Drivers Screen'),
        //actions: <Widget>[],
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              child: Text(
                '${_driverName.toUpperCase()} Welcome',
                style: TextStyle(
                  fontSize: 30,
                  // fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  alignment: Alignment.center,
                  child: Card(
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0),
                    ),
                    color: Colors.lightGreen,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text('Switch on before driving',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                        Switch(
                          value: isSwitched,
                          onChanged: (value) {
                            setState(
                              () {
                                isSwitched = value;
                                print(isSwitched);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            FlatButton(
              onPressed: () async {
                print(isSwitched);
                isSwitched
                    ? Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DriverMapScreen(
                            driverName: _driverName,
                          ),
                        ),
                      )
                    : null;
              },
              child: Text('Submit'),
              color: Colors.lightGreen,
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
              child: Container(
                height: 40.0,
                //color: Colors.deepOrange,
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
                          fontFamily: 'Montserrat'),
                    ),
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
