import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:groceryapp/Classes/User.dart';

class UserGreetingBar extends StatefulWidget {
  @override
  _UserGreetingBarState createState() => _UserGreetingBarState();
}

class _UserGreetingBarState extends State<UserGreetingBar> {
  FirebaseAuth mAuth = FirebaseAuth.instance;

  User userData = User();

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
      });
    });
  }

  @override
  void initState() {
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage("images/User.jpg"),
          ),
          title: Text("Hello,"),
          subtitle: userData.name == null
              ? Text(
                  'Anonymous',
                  style: TextStyle(
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
          trailing: IconButton(
            onPressed: () {
              print("Location Pressed");
            },
            icon: Icon(
              Icons.location_on,
              size: 30,
            ),
            color: Color(0xffF26016),
          )),
    );
  }
}
