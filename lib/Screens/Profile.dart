import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:groceryapp/Classes/Constants.dart';
import 'package:groceryapp/Classes/User.dart';
import 'package:groceryapp/Screens/LoginScreen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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
    final pHeight = MediaQuery.of(context).size.height;
    final pWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24.0, top: 8),
              child: Text(
                'Profile',
                style: GoogleFonts.openSans(
                    color: kSecondaryColor,
                    fontSize: pHeight * 0.035,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: pWidth,
              child: Divider(
                color: Colors.black.withOpacity(
                  0.5,
                ),
                thickness: 1,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            userData.name != null
                ? Container(
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundImage: ExactAssetImage('images/User.jpg'),
                            radius: 30,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(userData.name,
                                  style: GoogleFonts.openSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  )),
                              Text('Delivery Address',
                                  style: GoogleFonts.openSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: kSecondaryColor,
                                  )),
                              Container(
                                  width: pWidth * 0.7,
                                  child: Text(userData.address)),
                              Text('Pin- ${userData.zip}'),
                              Text('Phone- ${userData.phoneNo}')
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: Center(
                      child: SpinKitFadingFour(
                        color: kSecondaryColor,
                      ),
                    ),
                  ),
            SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                _launchURL('https://www.google.com/');
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: pHeight * 0.01),
                child: Row(
                  children: [
                    Spacer(),
                    Icon(
                      Icons.info_outline,
                      size: pWidth * 0.06,
                    ),
                    Spacer(),
                    Text(
                      'About',
                      style: GoogleFonts.openSans(
                          fontSize: pWidth * 0.055,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    ),
                    Spacer(
                      flex: 3,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: pWidth,
              child: Divider(
                color: Colors.black.withOpacity(
                  0.3,
                ),
                thickness: 0.5,
              ),
            ),
            InkWell(
              onTap: () {
                _launchURL('https://www.google.com/');
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: pHeight * 0.01),
                child: Row(
                  children: [
                    Spacer(
                      flex: 2,
                    ),
                    Icon(
                      Icons.warning,
                      size: pWidth * 0.06,
                    ),
                    Spacer(flex: 2),
                    Text(
                      'Send Feedback',
                      style: GoogleFonts.openSans(
                          fontSize: pWidth * 0.055,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    ),
                    Spacer(
                      flex: 3,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: pWidth,
              child: Divider(
                color: Colors.black.withOpacity(
                  0.3,
                ),
                thickness: 0.5,
              ),
            ),
            InkWell(
              onTap: () {
                FirebaseAuth.instance.signOut();
                pushNewScreen(context, screen: LoginPage(), withNavBar: false);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: pHeight * 0.01),
                child: Row(
                  children: [
                    Spacer(),
                    Icon(
                      Icons.exit_to_app,
                      size: pWidth * 0.06,
                    ),
                    Spacer(),
                    Text(
                      'Log Out',
                      style: GoogleFonts.openSans(
                          fontSize: pWidth * 0.055,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    ),
                    Spacer(flex: 3),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: pWidth,
              child: Divider(
                color: Colors.black.withOpacity(
                  0.3,
                ),
                thickness: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _launchURL(String launchUrl) async {
    String url = launchUrl;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
