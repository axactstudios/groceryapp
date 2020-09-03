import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:groceryapp/Classes/Constants.dart';
import 'package:groceryapp/Classes/Shops.dart';
import 'package:groceryapp/Screens/ShopScreens/ShopItemsScreens.dart';

// ignore: must_be_immutable
class ShopMainScreen extends StatefulWidget {
  Shops shop = Shops();
  String category;
  State state;
  ShopMainScreen({this.shop, this.category, this.state});

  @override
  _ShopMainScreenState createState() => _ShopMainScreenState();
}

class _ShopMainScreenState extends State<ShopMainScreen> {
  @override
  Widget build(BuildContext context) {
    final pHeight = MediaQuery.of(context).size.height;
    final pWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Column(
        children: <Widget>[
//          SizedBox(
//            height: 50,
//          ),
//          InkWell(
//            onTap: () async {
//              await widget.state.setState(() {
//                print('sfs');
//              });
//              await Navigator.pop(context);
//            },
//            child: Text('Back'),
//          ),
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
            child: Image.network(
              widget.shop.imageUrl,
              height: pHeight * 0.5,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: pHeight * 0.015,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: <Widget>[
                Text(
                  widget.shop.name,
                  style: GoogleFonts.openSans(
                      color: kSecondaryColor,
                      fontSize: pHeight * 0.035,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(
            height: pHeight * 0.01,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.location_on,
                  color: kSecondaryColor,
                  size: pHeight * 0.03,
                ),
                SizedBox(
                  width: pWidth * 0.02,
                ),
                Container(
                  width: pWidth * 0.8,
                  child: Text(
                    widget.shop.address,
                    style: GoogleFonts.openSans(
                      color: kSecondaryColor,
                      fontSize: pHeight * 0.022,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: pHeight * 0.01,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.phone_in_talk,
                  color: kSecondaryColor,
                  size: pHeight * 0.03,
                ),
                SizedBox(
                  width: pWidth * 0.02,
                ),
                Text(
                  widget.shop.contactnum,
                  style: GoogleFonts.openSans(
                    color: kSecondaryColor,
                    fontSize: pHeight * 0.022,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: pHeight * 0.01,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: <Widget>[
                Text(
                  widget.shop.desc,
                  style: GoogleFonts.openSans(
                    color: kSecondaryColor,
                    fontSize: pHeight * 0.018,
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShopItemsScreen(
                    shop: widget.shop,
                    category: widget.category,
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: pHeight * 0.08,
              decoration: BoxDecoration(
                color: kSecondaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Spacer(
                      flex: 3,
                    ),
                    Text(
                      'Shop Now',
                      style: GoogleFonts.openSans(
                          color: Colors.white, fontSize: pHeight * 0.025),
                    ),
                    SizedBox(
                      width: pWidth * 0.04,
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: kAccentColor,
                    ),
                    Spacer(
                      flex: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
