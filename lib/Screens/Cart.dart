import 'package:date_field/date_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:groceryapp/Classes/Constants.dart';
import 'package:groceryapp/Classes/DatabaseHelper.dart';
import 'package:groceryapp/Classes/Products.dart';
import 'package:groceryapp/Classes/User.dart';
import 'package:intl/intl.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
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
      // print(userData.uid);

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
        // print(products);
        // print(products.length);
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

  DateTime selectedDate;

  void removeItem(String name) async {
    // Assuming that the number of rows is the id for the last row.
    final rowsDeleted = await dbHelper.delete(name);
    getAllItems();
    Fluttertoast.showToast(
        msg: 'Removed from cart', toastLength: Toast.LENGTH_SHORT);
  }

  onTakeAwayPlaced() async {
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
      print(shopKey);
      final dbRef = FirebaseDatabase.instance
          .reference()
          .child(shopCategory)
          .child(shopKey)
          .child('Categories')
          .child(products[i].prodCategory)
          .child(products[i].key);
      await dbRef.once().then((DataSnapshot snapshot) async {
        if (snapshot.value == null)
          print('===============${snapshot.value}');
        else
          print('===============');
        stockQty = await snapshot.value['stockQty'];
      }).then((value) {
        print('${products[i].name}\'s quantity fetched');
      });
      await dbRef
          .update({'stockQty': stockQty - products[i].qty}).then((value) {
        print('${products[i].name} Updated');
      });
      await print('Order Placed');
    }

    FirebaseUser user = await mAuth.currentUser();
    final dbRef1 = await FirebaseDatabase.instance
        .reference()
        .child('Users')
        .child(user.uid)
        .child('Orders')
        .child(dateTime)
        .set({
      'type': 'takeaway',
      'takeawaytime': selectedDate.toString(),
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
      'type': 'takeaway',
      'takeawaytime': selectedDate.toString(),
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

  onHomeDeliveryPlaced() async {
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
      print(shopKey);
      final dbRef = FirebaseDatabase.instance
          .reference()
          .child(shopCategory)
          .child(shopKey)
          .child('Categories')
          .child(products[i].prodCategory)
          .child(products[i].key);
      await dbRef.once().then((DataSnapshot snapshot) async {
        if (snapshot.value == null)
          print('===============${snapshot.value}');
        else
          print('===============');
        stockQty = await snapshot.value['stockQty'];
      }).then((value) {
        print('${products[i].name}\'s quantity fetched');
      });
      await dbRef
          .update({'stockQty': stockQty - products[i].qty}).then((value) {
        print('${products[i].name} Updated');
      });
      await print('Order Placed');
    }

    FirebaseUser user = await mAuth.currentUser();
    final dbRef1 = await FirebaseDatabase.instance
        .reference()
        .child('Users')
        .child(user.uid)
        .child('Orders')
        .child(dateTime)
        .set({
      'type': 'homedelivery',
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
      'type': 'homedelivery',
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

  var startdate;

  Future<DateTime> getDate(BuildContext context) {
    // Imagine that this function is
    // more complex and slow.
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2018),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark(),
          child: child,
        );
      },
    );
  }

  void startDatePicker() async {
    var order1 = await getDate(context);
    String date;
    setState(() {
      if (order1.month < 10) {
        if (order1.day < 10) {
          date = '${order1.year}-0${order1.month}-0${order1.day}';
        } else {
          date = '${order1.year}-0${order1.month}-${order1.day}';
        }
      } else {
        if (order1.day < 10) {
          date = '${order1.year}-0${order1.month}-0${order1.day}-';
        } else {
          date = '${order1.year}-0${order1.month}-${order1.day}';
        }
      }
      startdate = date;

      Navigator.pop(context);
    });
  }

  // Razorpay _razorpay;
  String type;
  @override
  void initState() {
    // _razorpay = Razorpay();
    // _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    // _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    // _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    type = 'HomeDelivery';
    getUser();
    getAllItems();
  }

  @override
  Widget build(BuildContext context) {
    double pHeight = MediaQuery.of(context).size.height;
    double pWidth = MediaQuery.of(context).size.width;
    getAllItems();
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
                left: pWidth * 0.01, top: 40.0, right: pWidth * 0.01),
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
                                    style: GoogleFonts.openSans(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                      color: kSecondaryColor,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    'Delivery Address',
                                    style: GoogleFonts.openSans(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: kSecondaryColor,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    userData.address,
                                    style: GoogleFonts.openSans(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15,
                                      color: kSecondaryColor,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    'Pin : ${userData.zip}',
                                    style: GoogleFonts.openSans(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: kSecondaryColor,
                                    ),
                                  ),
                                  Text(
                                    'No : ${userData.phoneNo}',
                                    style: GoogleFonts.openSans(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: kSecondaryColor,
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
                                        style: GoogleFonts.openSans(
                                          fontSize: 15,
                                          color: kSecondaryColor,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: pHeight * 0.045,
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Icon(
                                        Icons.edit,
                                        size: 25,
                                      ),
                                      Text(
                                        'Change',
                                        style: GoogleFonts.openSans(
                                          fontSize: 15,
                                          color: kSecondaryColor,
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
                    color: Color(0xfff0f5f9),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Total = Rs.',
                              style: GoogleFonts.openSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: kSecondaryColor,
                              ),
                            ),
                            orderAmount == null
                                ? Text(
                                    '0.0',
                                    style: GoogleFonts.openSans(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: kSecondaryColor,
                                    ),
                                  )
                                : Text(
                                    orderAmount,
                                    style: GoogleFonts.openSans(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: kSecondaryColor,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              color: type == 'HomeDelivery'
                                  ? Color(0xFFfc6011)
                                  : Colors.grey,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  'Home Delivery',
                                  style: GoogleFonts.openSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  type = 'HomeDelivery';
                                });
                                // onOrderPlaced();
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              color: type == 'TakeAway'
                                  ? Color(0xFFfc6011)
                                  : Colors.grey,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  'Take Away',
                                  style: GoogleFonts.openSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  type = 'TakeAway';
                                });
                                // onOrderPlaced();
                              },
                            ),
                          ),
                        ],
                      ),
                      type == 'TakeAway'
                          ? Container(
                              width: 200,
                              child: DateTimeField(
                                selectedDate: selectedDate,
                                onDateSelected: (DateTime date) {
                                  setState(() {
                                    selectedDate = date;
                                  });
                                },
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2021),
                              ),
                            )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          color: Color(0xFFfc6011),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Confirm Order',
                              style: GoogleFonts.openSans(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          onPressed: () {
                            type == 'HomeDelivery'
                                ? onHomeDeliveryPlaced()
                                : onTakeAwayPlaced();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          products.length == 0
              ? Expanded(
                  child: Center(
                    child: Text(
                      'No items in the cart',
                      style: GoogleFonts.openSans(color: kSecondaryColor),
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
                                  left: 10.0,
                                  right: 10.0,
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
                                          style: GoogleFonts.openSans(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        Text(
                                          item.desc,
                                          style: GoogleFonts.openSans(
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
                                              style: GoogleFonts.openSans(
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
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'MRP',
                                          style: GoogleFonts.openSans(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          item.price,
                                          style: GoogleFonts.openSans(
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

  // void openCheckout() async {
  //   var options = {
  //     'key': 'rzp_test_uqORQiidCVwzWI',
  //     'amount': orderAmount,
  //     'name': 'Axact Studios',
  //     'description': 'Bill',
  //     'prefill': {'contact': '', '': 'test@razorpay.com'},
  //     'external': {
  //       'wallets': ['paytm']
  //     }
  //   };
  //
  //   try {
  //     _razorpay.open(options);
  //   } catch (e) {
  //     debugPrint(e);
  //   }
  // }
  //
  // void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  //   Fluttertoast.showToast(
  //       msg: "SUCCESS: " + response.paymentId, timeInSecForIosWeb: 4);
  //   onOrderPlaced();
  // }
  //
  // void _handlePaymentError(PaymentFailureResponse response) {
  //   Fluttertoast.showToast(
  //       msg: "ERROR: " + response.code.toString() + " - " + response.message,
  //       timeInSecForIosWeb: 4);
  // }
  //
  // void _handleExternalWallet(ExternalWalletResponse response) {
  //   Fluttertoast.showToast(
  //       msg: "EXTERNAL_WALLET: " + response.walletName, timeInSecForIosWeb: 4);
  // }
}
