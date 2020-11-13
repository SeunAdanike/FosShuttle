import 'package:flutter/material.dart';
import 'package:fluttershuttle/providers/authenticate.dart';
import 'package:fluttershuttle/providers/database.dart';
import 'package:fluttershuttle/screens/AuthScreens/change_password.dart';
import 'package:fluttershuttle/screens/AuthScreens/login_Screen.dart';
import 'package:fluttershuttle/screens/appScreens/admin_screen.dart';
import 'package:fluttershuttle/screens/appScreens/order_Request_Screen.dart';
import 'package:fluttershuttle/screens/appScreens/update_Profile.dart';

class MainDrawer extends StatefulWidget {
  final String userName;

  MainDrawer({@required this.userName});

  @override
  _MainDrawerState createState() => _MainDrawerState(userName);
}

class _MainDrawerState extends State<MainDrawer> {
  String _userName;

  _MainDrawerState(this._userName);
  DatabaseMethods _databaseMethods = DatabaseMethods();
  
  _getUserType() async {
    await _databaseMethods
        .getUserInfo('Name', _userName)
        .then((snapshot) async {
      await snapshot.documents.forEach((result) {
     setState(() {   result.data['studentCategory'] == 'Undergraduate'
            ? _isUndergraduate = true
            : _isUndergraduate = false;
        result.data['userCategory'] == 'Administrator'
            ? _isAdmin == true
            : _isAdmin == false;
        });
      });
    });
  }

  bool _isUndergraduate;
  bool _isAdmin;

  Widget buildListTile(
    String title,
    IconData icon,
    Function tapHandler,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        size: 26,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: tapHandler,
    );
  }

  @override
  void initState() {
    _isUndergraduate = true;
    _isAdmin = false;
    _getUserType();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Container(
        child: Drawer(
          child: Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.164,
                width: double.infinity * 0.2, //deviceWidth * 0.3,
                padding: EdgeInsets.all(20),
                alignment: Alignment.centerLeft,
                color: Colors.green,
                child: Center(
                  child: Text(
                    'Welcome, \n${_userName.toUpperCase()}!',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              buildListTile('Update Profile', Icons.settings_applications, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileUpdate(),
                  ),
                );
              }),
              SizedBox(
                height: 20,
              ),
              buildListTile('School News', Icons.new_releases, () {
                //Navigator.of(context).pushReplacementNamed('/');
              }),
              SizedBox(
                height: 20,
              ),
              if (!_isUndergraduate)
                buildListTile('Pick Up Request', Icons.directions_transit, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderRequest(),
                    ),
                  );
                }),
              SizedBox(
                height: 20,
              ),
              buildListTile('Change Password', Icons.exit_to_app, () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePassword(),
                  ),
                );
              }),
              if(_isAdmin)
                buildListTile('Admin Screen', Icons.security, () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Administrator(),
                  ),
                );
              }),
              buildListTile('Log out', Icons.exit_to_app, () {
                AuthService().signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              }),
            ],
          ),
        ),
      ),
    );
  }
}
