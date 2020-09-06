import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:groceryapp/Classes/Constants.dart';
import 'package:groceryapp/Classes/User.dart';

class UserGreetingBar extends StatefulWidget {
  @override
  _UserGreetingBarState createState() => _UserGreetingBarState();
}

class _UserGreetingBarState extends State<UserGreetingBar> {
  FirebaseAuth mAuth = FirebaseAuth.instance;

  User userData = User();
  String city = '';

  getUser() async {
    FirebaseUser user = await mAuth.currentUser();
    final dbRef =
        FirebaseDatabase.instance.reference().child('Users').child(user.uid);
    dbRef.once().then((DataSnapshot snapshot) async {
      userData.uid = await snapshot.value['uid'];
      userData.phoneNo = await snapshot.value['phoneNo'];
      userData.zip = await snapshot.value['zip'];
      userData.lat = await snapshot.value['lat'];
      userData.lng = await snapshot.value['lng'];
      userData.name = await snapshot.value['name'];
      userData.address = await snapshot.value['address'];
      setState(() {
        print('User fetched');
        getLocation();
      });
    });
  }

  getLocation() async {
    double lat, lng;
    lat = await double.parse(userData.lat);
    lng = await double.parse(userData.lng);
    final coordinates = new Coordinates(lat, lng);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    print(first.subAdminArea);
    setState(() {
      city = first.subAdminArea;
    });
  }

  @override
  void initState() {
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage("images/User.jpg"),
            ),
            title: userData.name == null
                ? Text(
                    'Anonymous',
                    style: GoogleFonts.openSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  )
                : Text(
                    userData.name,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
            trailing: city == null
                ? IconButton(
                    onPressed: () {
                      print("Location Pressed");
                    },
                    icon: Icon(
                      Icons.location_on,
                      size: 30,
                    ),
                    color: Color(0xffF26016),
                  )
                : Text(
                    city,
                    style: TextStyle(
                        color: kAccentColor,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold),
                  )),
      ),
    );
  }
}
