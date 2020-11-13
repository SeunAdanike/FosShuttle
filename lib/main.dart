import 'package:flutter/material.dart';
import 'package:fluttershuttle/screens/AuthScreens/change_password.dart';
import 'package:fluttershuttle/screens/MapScreens/driver_Map_Screen.dart';
import 'package:fluttershuttle/screens/MapScreens/user_Map_Screen.dart';
import 'package:fluttershuttle/screens/appScreens/admin_screen.dart';
import 'package:fluttershuttle/screens/appScreens/order_Request_Screen.dart';
import 'package:fluttershuttle/screens/appScreens/schedule_Screen.dart';

//import 'package:fluttershuttle/screens/appScreens/schedule.dart';
import 'package:provider/provider.dart';

import 'screens/AuthScreens/first_Sign_Up_Page.dart';
import 'screens/appScreens/driver_permission.dart';
import 'package:fluttershuttle/providers/authenticate.dart';
import 'package:fluttershuttle/screens/AuthScreens/login_Screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: AuthService(),
        ),
      ],
      child: Consumer<AuthService>(
        builder: (ctx, auth, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Fluttershuttle',
            home: LoginPage(), //OrderRequest(),//ChangePassword(),
            routes: {
              FirstSignUpPage.routeName: (ctx) => FirstSignUpPage(),
              DriverPermission.routeName: (ctx) => DriverPermission(),
            }),
      ),
    );
  }
}
