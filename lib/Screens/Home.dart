import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:groceryapp/Classes/Categories.dart';
import 'package:groceryapp/Classes/Constants.dart';
import 'package:groceryapp/Classes/Shops.dart';
import 'package:groceryapp/Widgets/SearchBar.dart';
import 'package:groceryapp/Widgets/UserGreetingBar.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import '../Classes/Categories.dart';
import 'ShopScreens/ShopMainScreen.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Shops> shops = [];
  List<String> shopNames = [];
  Color selectedcolor;
  int selectedcategory = 0;

  bool isFetching = false;

  @override
  // ignore: must_call_super
  void initState() {
    getShops();
  }

  void getShops() {
    print('Retrieving ${categorylist[selectedcategory].name}');
    if (this.mounted) {
      setState(() {
        isFetching = true;
      });
    }
    shops.clear();
    shopNames.clear();
    var dbRef = FirebaseDatabase.instance
        .reference()
        .child(categorylist[selectedcategory].name);
    dbRef.once().then((DataSnapshot snap) {
      Map<dynamic, dynamic> values = snap.value;
      values.forEach((key, value) async {
        Shops newShop = Shops();
        newShop.key = key;
        newShop.name = await value['name'];
        newShop.address = await value['address'];
        newShop.desc = await value['desc'];
        newShop.contactnum = await value['phoneNo'].toString();
        newShop.imageUrl = await value['imageUrl'];
        newShop.category = await categorylist[selectedcategory].name;
        shops.add(newShop);
        shopNames.add(value['name']);
      });
      if (this.mounted) {
        setState(() {
          isFetching = false;
          print(shops.length);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xFFf0f5f9),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: <Widget>[
          SizedBox(
            height: pHeight * 0.02,
          ),
          UserGreetingBar(),
          Container(
              margin: EdgeInsets.all(10),
              // color: Colors.blue,
              child: SearchBar(shops, shopNames, this)),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 20, 0, 0),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Categories",
                  style: GoogleFonts.openSans(
                      fontWeight: FontWeight.bold, fontSize: 22),
                )),
          ),
          Container(
            height: 120,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categorylist.length,
                itemBuilder: (BuildContext context, int categoryindex) {
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            selectedcategory = categoryindex;
                            print(selectedcategory);
                            setState(() {
                              getShops();
                            });
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                                color: selectedcategory == categoryindex
                                    ? Color(0xffFFD6BC)
                                    : Color(0xffcff9e1),
                                height: 70,
                                width: 70,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(25, 10, 0, 0),
                                  child: Image(
                                    image: AssetImage(
                                        categorylist[categoryindex].imageUrl),
                                  ),
                                )),
                          ),
                        ),
                        Text(categorylist[categoryindex].name)
                      ],
                    ),
                  );
                }),
          ),
          isFetching
              ? Center(
                  child: SpinKitFadingFour(
                    color: kSecondaryColor,
                  ),
                )
              : (shops.length == 0
                  ? Center(
                      child: Text(
                        'No shops to display',
                        style: GoogleFonts.openSans(
                            color: kSecondaryColor, fontSize: pHeight * 0.03),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: shops.length,
                        itemBuilder: (context, index) {
                          var item = shops[index];
                          return GestureDetector(
                            onTap: () {
                              pushNewScreen(context,
                                  screen: ShopMainScreen(
                                    shop: item,
                                    category:
                                        categorylist[selectedcategory].name,
                                  ),
                                  withNavBar: false);
                            },
                            child: Stack(children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(25),
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          offset: Offset.lerp(
                                              Offset.fromDirection(10),
                                              Offset.fromDirection(10),
                                              -10),
                                          color: Colors.grey[300],
                                          blurRadius: 10,
                                          spreadRadius: 10)
                                    ],
                                  ),
                                  height: 200,
                                  width: MediaQuery.of(context).size.width,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image(
                                      colorBlendMode: BlendMode.screen,
                                      image: NetworkImage(item.imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(25, 155, 25, 0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Container(
                                    color: Color(0xffF0F5F9),
                                    child: ListTile(
                                        title: Text(item.name,
                                            style: GoogleFonts.openSans(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blueGrey[600])),
                                        subtitle: Text("📍" + item.address,
                                            style: GoogleFonts.openSans(
                                                color: Colors.blueGrey[600])),
                                        trailing: Icon(
                                          (Icons.chevron_right),
                                          color: Color(0xffF26016),
                                          size: 40,
                                        )),
                                  ),
                                ),
                              )
                            ]),
                          );
                        },
                      ),
                    )),
        ],
      ),
    );
  }
}
