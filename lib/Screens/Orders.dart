import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:groceryapp/Classes/Constants.dart';
import 'package:groceryapp/Classes/Orders.dart';
import 'package:groceryapp/Classes/Shops.dart';

class Orders extends StatefulWidget {
  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  FirebaseAuth mAuth = FirebaseAuth.instance;
  List<Order> orders = [];

  bool isFetching = false;

  getOrders() async {
    if (this.mounted) {
      setState(() {
        isFetching = true;
      });
    }
    orders.clear();
    FirebaseUser user = await mAuth.currentUser();
    final dbRef = FirebaseDatabase.instance
        .reference()
        .child('Users')
        .child(user.uid)
        .child('Orders');
    dbRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value == null) {
        setState(() {
          isFetching = false;
          print('No orders');
        });
      } else {
        Map<dynamic, dynamic> values = snapshot.value;
        values.forEach((key, value) async {
          Order newOrder = Order();
          newOrder.deliveryDate = await value['deliverDate'];
          newOrder.orderAmount = await value['orderAmount'];
          newOrder.orderDate = await value['orderDate'];
          newOrder.orderKey = await value['orderKey'];
          newOrder.orderTime = await value['orderTime'];
          newOrder.shopCategory = await value['shopCategory'];
          newOrder.shopKey = await value['shopKey'];
          newOrder.itemsName = List<String>.from(await value['itemsName']);
          newOrder.itemsQty = List<int>.from(await value['itemsQty']);
          newOrder.isCompleted = await value['isCompleted'];
          final dbRef2 = FirebaseDatabase.instance
              .reference()
              .child(newOrder.shopCategory)
              .child(newOrder.shopKey);
          await dbRef2.once().then((DataSnapshot snap) async {
            newOrder.shop = Shops();
            newOrder.shop.address = await snap.value['address'];
            newOrder.shop.name = await snap.value['name'];
            newOrder.shop.contactnum = await snap.value['phoneNo'].toString();
            newOrder.shop.desc = await snap.value['desc'];
            newOrder.shop.imageUrl = await snap.value['imageUrl'];
            newOrder.shop.key = newOrder.shopKey;
          });
          if (this.mounted) {
            setState(() {
              isFetching = false;
              print(newOrder.shop);
            });
          }
          orders.add(newOrder);
          print(newOrder.orderDate);
        });
        if (this.mounted) {
          setState(() {
            print(orders.length);
          });
        }
      }
    });
  }

  @override
  void initState() {
    getOrders();
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
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 24.0, top: 8),
              child: Text(
                'Your Orders',
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
            isFetching
                ? Expanded(
                    child: Center(
                      child: SpinKitFadingFour(
                        color: kSecondaryColor,
                      ),
                    ),
                  )
                : (orders.length == 0
                    ? Expanded(
                        child: Center(
                          child: Text(
                            'No orders to display',
                            style: GoogleFonts.openSans(
                                color: kSecondaryColor,
                                fontSize: pHeight * 0.03),
                          ),
                        ),
                      )
                    : Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: ListView.builder(
                              itemCount: orders.length,
                              itemBuilder: (context, index) {
                                var item = orders[index];
                                return Card(
                                  elevation: 4,
                                  margin: EdgeInsets.only(bottom: 30),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      children: <Widget>[
                                        ClipRRect(
                                          child: Image.network(
                                            item.shop.imageUrl,
                                            height: pHeight * 0.15,
                                            width: pWidth * 0.25,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        SizedBox(
                                          width: pWidth * 0.02,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  item.shop.name,
                                                  style: GoogleFonts.openSans(
                                                      color: kSecondaryColor,
                                                      fontSize: pHeight * 0.03,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                Container(
                                                  width: pWidth * 0.62,
                                                  child: Text(
                                                    item.shop.address,
                                                    style: GoogleFonts.openSans(
                                                        color: kSecondaryColor,
                                                        fontSize:
                                                            pHeight * 0.015,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              'Ordered on ${item.orderDate}',
                                              style: GoogleFonts.openSans(
                                                  color: kSecondaryColor,
                                                  fontSize: pHeight * 0.015,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              'Total amount - Rs. ${item.orderAmount}',
                                              style: GoogleFonts.openSans(
                                                  color: kSecondaryColor,
                                                  fontSize: pHeight * 0.018,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: pHeight * 0.01,
                                            ),
                                            item.isCompleted
                                                ? Row(
                                                    children: <Widget>[
                                                      Row(
                                                        children: <Widget>[
                                                          Icon(
                                                            Icons
                                                                .check_circle_outline,
                                                            color:
                                                                kSecondaryColor,
                                                            size:
                                                                pHeight * 0.02,
                                                          ),
                                                          SizedBox(
                                                            width:
                                                                pWidth * 0.02,
                                                          ),
                                                          Text(
                                                            'Delivered',
                                                            style: GoogleFonts.openSans(
                                                                color:
                                                                    kSecondaryColor,
                                                                fontSize:
                                                                    pHeight *
                                                                        0.018),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  )
                                                : Row(
                                                    children: <Widget>[
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Icon(
                                                            Icons.clear,
                                                            color: Colors.red,
                                                            size:
                                                                pHeight * 0.02,
                                                          ),
                                                          SizedBox(
                                                            width:
                                                                pWidth * 0.02,
                                                          ),
                                                          Text(
                                                            'Not delivered',
                                                            style: GoogleFonts
                                                                .openSans(
                                                                    color: Colors
                                                                        .red,
                                                                    fontSize:
                                                                        pHeight *
                                                                            0.018),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),
                      )),
          ],
        ),
      ),
    );
  }
}
