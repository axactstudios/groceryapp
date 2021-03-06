import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gps/gps.dart';
import 'package:groceryapp/Classes/Constants.dart';
import 'package:groceryapp/Screens/NavBar.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  var latlng;

  TextEditingController name = new TextEditingController(text: '');
  TextEditingController phone = new TextEditingController(text: '+91');
  TextEditingController address = new TextEditingController(text: '');
  TextEditingController zip = new TextEditingController(text: '');

  @override
  // ignore: must_call_super
  void initState() {
    getGps();
  }

  final _formKey = GlobalKey<FormState>();

  final controller = MapController(
    location: LatLng(0.0, 0.0),
  );

  double lat, lng;

  void getGps() async {
    latlng = await Gps.currentGps();
    lat = double.parse(latlng.lat);
    lng = double.parse(latlng.lng);
    setState(() {
      controller.location = LatLng(lat, lng);
      getLocation();
      print(latlng);
    });
  }

  getLocation() async {
    final coordinates = new Coordinates(lat, lng);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    print(first.subAdminArea);
    setState(() {
      address.text = first.addressLine;
      zip.text = first.postalCode;
    });
  }

  void writeData() async {
    // ignore: deprecated_member_use
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    var dbRef =
        FirebaseDatabase.instance.reference().child('Users').child(user.uid);
    dbRef.set({
      'uid': user.uid,
      'name': name.text,
      'phoneNo': phone.text,
      'address': address.text,
      'zip': zip.text,
      'lat': lat.toString(),
      'lng': lng.toString()
    });
  }

  @override
  Widget build(BuildContext context) {
    final pHeight = MediaQuery.of(context).size.height;
    final pWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kPrimaryColor,
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: pHeight * 0.05,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(pHeight * 0.15),
                  child: Container(
                    color: Colors.white,
                    height: pHeight * 0.13,
                    width: pHeight * 0.13,
                    child: Icon(
                      Icons.person,
                      color: Color(0xFF11263C),
                      size: pHeight * 0.1,
                    ),
                  ),
                ),
                SizedBox(
                  height: pHeight * 0.04,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: TextFormField(
                            controller: name,
                            validator: (value) {
                              if (value.length == 0) {
                                return 'Invalid name';
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              icon: Icon(
                                Icons.perm_contact_calendar,
                                size: pHeight * 0.03,
                                color: Color(0xFF11263C),
                              ),
                              hintText: 'Name',
                              hintStyle: GoogleFonts.openSans(
                                  color: Color(0xFF11263C),
                                  fontSize: pHeight * 0.02),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: pHeight * 0.001,
                          width: double.infinity,
                          child: Divider(
                            thickness: 1.5,
                            color: Color(0xFFC8CDD2),
                          ),
                        ),
                        // SizedBox(
                        //   height: pHeight * 0.008,
                        // ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: TextFormField(
                            controller: phone,
                            validator: (value) {
                              if (value.length < 13) {
                                return 'Invalid phone number';
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              icon: Icon(
                                Icons.phone,
                                size: pHeight * 0.03,
                                color: Color(0xFF11263C),
                              ),
                              hintText: 'Mobile',
                              hintStyle: GoogleFonts.openSans(
                                  color: Color(0xFF11263C),
                                  fontSize: pHeight * 0.02),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        SizedBox(
                          height: pHeight * 0.001,
                          width: double.infinity,
                          child: Divider(
                            thickness: 1.5,
                            color: Color(0xFFC8CDD2),
                          ),
                        ),
                        // SizedBox(
                        //   height: pHeight * 0.008,
                        // ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: TextFormField(
                            controller: address,
                            validator: (value) {
                              if (value.length == 0) {
                                return 'Invalid address';
                              } else {
                                return null;
                              }
                            },
                            maxLines: 2,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              prefixIcon: Icon(
                                Icons.mail,
                                size: pHeight * 0.03,
                                color: Color(0xFF11263C),
                              ),
                              hintText: ' Delivery Address',
                              hintStyle: GoogleFonts.openSans(
                                  color: Color(0xFF11263C),
                                  fontSize: pHeight * 0.02),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: pHeight * 0.00001,
                          width: double.infinity,
                          child: Divider(
                            thickness: 1.5,
                            color: Color(0xFFC8CDD2),
                          ),
                        ),
                        // SizedBox(
                        //   height: pHeight * 0.008,
                        // ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: TextFormField(
                            controller: zip,
                            validator: (value) {
                              if (value.length < 6) {
                                return 'Invalid PIN Code';
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              icon: Icon(
                                Icons.location_on,
                                size: pHeight * 0.03,
                                color: Color(0xFF11263C),
                              ),
                              hintText: 'PIN Code',
                              hintStyle: GoogleFonts.openSans(
                                  color: Color(0xFF11263C),
                                  fontSize: pHeight * 0.02),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        SizedBox(
                          height: pHeight * 0.00000001,
                          width: double.infinity,
                          child: Divider(
                            thickness: 1.5,
                            color: Color(0xFFC8CDD2),
                          ),
                        ),
                        // SizedBox(
                        //   height: pHeight * 0.008,
                        // ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.location_on,
                                color: Color(0xFF11263C),
                                size: pHeight * 0.03,
                              ),
                              SizedBox(
                                width: pWidth * 0.05,
                              ),
                              Text(
                                'Delivery Location',
                                style: GoogleFonts.openSans(
                                  fontSize: pHeight * 0.02,
                                  color: Color(0xFF11263C),
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                icon: Icon(
                                  Icons.gps_fixed,
                                  color: Color(0xFF11263C),
                                ),
                                onPressed: () {
                                  getGps();
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(6),
                              bottomRight: Radius.circular(6),
                            ),
                          ),
                          height: pHeight * 0.2,
                          child: Map(
                            controller: controller,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FloatingActionButton(
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              await writeData();
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => HomePage(),
                                ),
                              );
                            }
                          },
                          backgroundColor: kAccentColor,
                          child: Icon(
                            Icons.chevron_right,
                            size: 40,
//                                color: Color.fromARGB(255, 242, 96, 22),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
