import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:groceryapp/Classes/Constants.dart';
import 'package:groceryapp/Classes/DatabaseHelper.dart';
import 'package:groceryapp/Classes/Products.dart';
import 'package:groceryapp/Classes/User.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  FirebaseAuth mAuth = FirebaseAuth.instance;

  bool isFetchingUser = false;

  User userData = User();
  String city = '';

  String orderAmount = '';

  getUser() async {
    setState(() {
      isFetchingUser = true;
    });
    FirebaseUser user = await mAuth.currentUser();
    final dbRef =
        FirebaseDatabase.instance.reference().child('Users').child(user.uid);
    dbRef.once().then((DataSnapshot snapshot) async {
      userData.uid = await snapshot.value['uid'];
      print(userData.uid);
      userData.phoneNo = await snapshot.value['phoneNo'];
      userData.zip = await snapshot.value['zip'];
      userData.lat = await snapshot.value['lat'];
      userData.lng = await snapshot.value['lng'];
      userData.name = await snapshot.value['name'];
      userData.address = await snapshot.value['address'];
      if (this.mounted) {
        setState(() {
          print('User fetched');
          getLocation();
        });
      }
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
    if (this.mounted) {
      setState(() {
        isFetchingUser = false;
        city = first.subAdminArea;
      });
    }
  }

  final dbHelper = DatabaseHelper.instance;
  int newQty;

  List<Products> products = [];

  getOrderAmount() {
    int sum = 0;
    int i;
    for (i = 0; i < products.length; i++) {
      int price = int.parse(products[i].price);
      int cost = price * products[i].qty;
      sum = sum + cost;
    }
    if (this.mounted) {
      setState(() {
        orderAmount = sum.toString();
      });
    }
  }

  void getAllItems() async {
    final allRows = await dbHelper.queryAllRows();
    products.clear();
    allRows.forEach((row) => products.add(Products.fromMap(row)));

    if (this.mounted) {
      setState(() {
        print(products.length);
        getOrderAmount();
      });
    }
  }

  void updateItem({Products product}) async {
    // row to update
    Products item = product;
    final rowsAffected = await dbHelper.update(item);
    Fluttertoast.showToast(
        msg: 'Updated',
        toastLength: Toast.LENGTH_SHORT,
        textColor: Colors.black,
        backgroundColor: Colors.white);
    if (this.mounted) {
      setState(() {
        getAllItems();
      });
    }
  }

  void removeItem(String name) async {
    // Assuming that the number of rows is the id for the last row.
    final rowsDeleted = await dbHelper.delete(name);
    getAllItems();
    Fluttertoast.showToast(
        msg: 'Removed from cart', toastLength: Toast.LENGTH_SHORT);
  }

  onOrderPlaced() async {
    print('Placing your order');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String shopKey = await prefs.getString('key');
    String shopCategory = await prefs.getString('category');
    String shopName = await prefs.getString('name');

    DateTime orderDate = DateTime.now();
    String date = DateFormat('dd-MM-yyyy').format(orderDate);
    String time = DateFormat('kk:mm').format(orderDate);
    String dateTime = DateFormat('dd-MM-yyyy kk:mm').format(orderDate);

    List<String> itemsName = [];
    List<int> itemsQty = [];
    int i;

    for (i = 0; i < products.length; i++) {
      itemsName.add(products[i].name);
      itemsQty.add(products[i].qty);
      print(products[i].prodCategory);
      print(products[i].key);

      int stockQty;

      final dbRef = FirebaseDatabase.instance
          .reference()
          .child(shopCategory)
          .child(shopKey)
          .child('Categories')
          .child(products[i].prodCategory)
          .child(products[i].key);
      await dbRef.once().then((DataSnapshot snapshot) async {
        stockQty = await snapshot.value['stockQty'];
      }).then((value) {
        print('${products[i].name}\'s quantity fetched');
      });
      await dbRef
          .update({'stockQty': stockQty - products[i].qty}).then((value) {
        print('${products[i].name} Updated');
      });
    }

    FirebaseUser user = await mAuth.currentUser();
    final dbRef1 = await FirebaseDatabase.instance
        .reference()
        .child('Users')
        .child(user.uid)
        .child('Orders')
        .child(dateTime)
        .set({
      'isCompleted': false,
      'orderDate': date,
      'orderTime': time,
      'orderAmount': orderAmount,
      'shopKey': shopKey,
      'shopName': shopName,
      'shopCategory': shopCategory,
      'orderKey': dateTime,
      'itemsName': itemsName,
      'itemsQty': itemsQty,
      'status': 'Placed',
      'shippingDate': 'Not yet shipped',
      'deliveryDate': 'Not yet delivered'
    });

    final dbRef2 = await FirebaseDatabase.instance
        .reference()
        .child(shopCategory)
        .child(shopKey)
        .child('Orders')
        .child(dateTime)
        .set({
      'isCompleted': false,
      'status': 'Placed',
      'orderDate': date,
      'orderTime': time,
      'orderAmount': orderAmount,
      'orderKey': dateTime,
      'itemsName': itemsName,
      'itemsQty': itemsQty,
      'shippingDate': 'Not yet shipped',
      'deliveryDate': 'Not yet delivered',
      'customerName': userData.name,
      'customerPhone': userData.phoneNo,
      'customerAddress': userData.address,
      'customerZip': userData.zip,
      'customerUid': userData.uid
    });

    emptyCart();
  }

  void emptyCart() async {
    final rowsDeleted = await dbHelper.empty();
    print('Cart empty');
    getAllItems();
  }

  Razorpay _razorpay;

  @override
  void initState() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    getUser();
    getAllItems();
  }

  @override
  Widget build(BuildContext context) {
    getAllItems();
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 40.0, top: 40.0, right: 40.0),
            child: Column(
              children: <Widget>[
                isFetchingUser
                    ? Center(
                        child: SpinKitFadingFour(
                          color: kSecondaryColor,
                        ),
                      )
                    : Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: <Widget>[
                                  CircleAvatar(
                                    backgroundImage:
                                        ExactAssetImage('images/guy.png'),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    userData.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 27.5,
                                      color: kSecondaryColor,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    'Delivery Address',
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      color: kSecondaryColor,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    userData.address,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15,
                                      color: kSecondaryColor,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    'Pin : ${userData.zip}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: kSecondaryColor,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  Text(
                                    'No : ${userData.phoneNo}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: kSecondaryColor,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      Icon(
                                        Icons.location_on,
                                        size: 25,
                                        color: Colors.deepOrange,
                                      ),
                                      Text(
                                        city,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: kSecondaryColor,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 70,
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Icon(
                                        Icons.edit,
                                        size: 25,
                                      ),
                                      Text(
                                        'Change',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: kSecondaryColor,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: kFormColor,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Total = Rs.',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: kSecondaryColor,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            orderAmount == null
                                ? Text(
                                    '0.0',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: kSecondaryColor,
                                      fontFamily: 'Poppins',
                                    ),
                                  )
                                : Text(
                                    orderAmount,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: kSecondaryColor,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          color: Colors.orange[800],
                          child: Text(
                            'Proceed to Pay',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          onPressed: () {
                            onOrderPlaced();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
          Container(
            color: Colors.grey[300],
            child: Padding(
              padding: const EdgeInsets.only(left: 40.0, right: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Icons.sort,
                          size: 35,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Icon(
                          Icons.format_line_spacing,
                          size: 35,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          products.length == 0
              ? Expanded(
                  child: Center(
                    child: Text(
                      'No items in the cart',
                      style: TextStyle(
                          fontFamily: 'Poppins', color: kSecondaryColor),
                    ),
                  ),
                )
              : Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(0.0),
                    children: <Widget>[
                      ListView.builder(
                        padding: EdgeInsets.all(0.0),
                        itemCount: products.length,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          var item = products[index];
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 5.0),
                            child: Container(
                              padding: EdgeInsets.only(
                                  left: 40.0,
                                  right: 40.0,
                                  top: 5.0,
                                  bottom: 5.0),
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Image.network(
                                          item.imageUrl,
                                          height: 55,
                                          width: 55,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          item.name,
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        Text(
                                          item.desc,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(
                                              width: 5,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                if (item.qty == 1) {
                                                  removeItem(item.name);
                                                } else {
                                                  item.qty = item.qty - 1;
                                                  updateItem(product: item);
                                                }
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(0.0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                  border: Border.all(
                                                    width: 0.5,
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.remove,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              item.qty.toString(),
                                              style: TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  item.qty = item.qty + 1;
                                                  updateItem(product: item);
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(0.0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                  border: Border.all(
                                                    width: 0.5,
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.add,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'MRP',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          item.price,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  void openCheckout() async {
    var options = {
      'key': 'rzp_test_uqORQiidCVwzWI',
      'amount': orderAmount,
      'name': 'Axact Studios',
      'description': 'Bill',
      'prefill': {'contact': '', '': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Fluttertoast.showToast(
        msg: "SUCCESS: " + response.paymentId, timeInSecForIosWeb: 4);
    onOrderPlaced();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "ERROR: " + response.code.toString() + " - " + response.message,
        timeInSecForIosWeb: 4);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName, timeInSecForIosWeb: 4);
  }
}
