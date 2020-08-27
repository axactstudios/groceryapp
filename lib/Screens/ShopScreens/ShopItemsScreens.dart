import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:groceryapp/Classes/Constants.dart';
import 'package:groceryapp/Classes/Products.dart';
import 'package:groceryapp/Classes/Shops.dart';
import 'package:groceryapp/Widgets/SearchBar.dart';

// ignore: must_be_immutable
class ShopItemsScreen extends StatefulWidget {
  Shops shop = Shops();
  String category;
  ShopItemsScreen({this.shop, this.category});

  @override
  _ShopItemsScreenState createState() => _ShopItemsScreenState();
}

class _ShopItemsScreenState extends State<ShopItemsScreen> {
  List<String> categories = [];
  List<Products> products = [];

  bool isFetchingCategories = false;
  bool isFetchingProducts = false;

  int productsIndex = 0;

  void getCategories() async {
    setState(() {
      isFetchingCategories = true;
    });
    categories.clear();
    final dbRef = FirebaseDatabase.instance
        .reference()
        .child(widget.category)
        .child(widget.shop.key)
        .child('Categories');
    dbRef.once().then((DataSnapshot snap) {
      Map<dynamic, dynamic> values = snap.value;
      values.forEach((key, value) {
        categories.add(key);
      });
      setState(() {
        isFetchingCategories = false;
        print(categories.length);
        getProducts();
      });
    });
  }

  void getProducts() async {
    setState(() {
      isFetchingProducts = true;
    });
    products.clear();
    final dbRef = FirebaseDatabase.instance
        .reference()
        .child(widget.category)
        .child(widget.shop.key)
        .child('Categories')
        .child(categories[productsIndex]);
    dbRef.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, value) async {
        Products product = Products();
        product.key = key;
        product.name = await value['name'];
        product.price = await value['price'].toString();
        product.desc = await value['desc'];
        product.imageUrl = await value['imageUrl'];
        products.add(product);
      });
      setState(() {
        print(products.length);
        isFetchingProducts = false;
      });
    });
  }

  @override
  void initState() {
    getCategories();
  }

  @override
  Widget build(BuildContext context) {
    final pHeight = MediaQuery.of(context).size.height;
    final pWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          SizedBox(
            height: pHeight * 0.06,
          ),
          SearchBar(),
          SizedBox(
            height: pHeight * 0.02,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: pHeight * 0.15,
              width: double.infinity,
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.shop.imageUrl,
                      height: pHeight * 0.15,
                      width: pWidth * 0.3,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(
                    width: pWidth * 0.02,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4.0, vertical: 12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.shop.name,
                              style: TextStyle(
                                  color: kSecondaryColor,
                                  fontSize: pHeight * 0.025,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins'),
                            ),
                            Text(
                              widget.shop.desc,
                              style: TextStyle(
                                  color: kSecondaryColor,
                                  fontSize: pHeight * 0.015,
                                  fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.phone_in_talk,
                              size: pHeight * 0.02,
                            ),
                            SizedBox(
                              width: pWidth * 0.02,
                            ),
                            Text(
                              widget.shop.contactnum,
                              style: TextStyle(
                                  color: kSecondaryColor,
                                  fontSize: pHeight * 0.018,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.location_on,
                              size: pHeight * 0.02,
                            ),
                            SizedBox(
                              width: pWidth * 0.02,
                            ),
                            Text(
                              widget.shop.address,
                              style: TextStyle(
                                  color: kSecondaryColor,
                                  fontSize: pHeight * 0.018,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: pHeight * 0.02,
          ),
          isFetchingCategories
              ? SpinKitFadingFour(
                  color: kSecondaryColor,
                )
              : (categories.length == 0
                  ? Text(
                      'No categories added by the shop',
                      style: TextStyle(
                          color: kSecondaryColor,
                          fontSize: pHeight * 0.02,
                          fontWeight: FontWeight.w600),
                    )
                  : Container(
                      height: pHeight * 0.05,
                      child: Row(
                        children: <Widget>[
                          ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                var item = categories[index];
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      productsIndex = index;
                                      getProducts();
                                    });
                                  },
                                  child: Container(
                                      margin: EdgeInsets.only(left: 16),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                              color: productsIndex == index
                                                  ? kSecondaryColor
                                                  : kSecondaryColor
                                                      .withOpacity(0.5),
                                              fontFamily: 'Poppins',
                                              fontSize: pHeight * 0.025,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      )),
                                );
                              }),
                        ],
                      ),
                    )),
          SizedBox(
            height: pHeight * 0.02,
          ),
          isFetchingProducts
              ? SpinKitFadingFour(
                  color: kSecondaryColor,
                )
              : (categories.length == 0
                  ? Text(
                      'No products to display',
                      style: TextStyle(
                          color: kSecondaryColor,
                          fontSize: pHeight * 0.02,
                          fontWeight: FontWeight.w600),
                    )
                  : Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            var item = products[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0,
                                      top: 8.0,
                                      bottom: 8.0,
                                      right: 8.0),
                                  child: Container(
                                    height: pHeight * 0.15,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            item.imageUrl,
                                            height: pHeight * 0.15,
                                            width: pWidth * 0.25,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(
                                          width: pWidth * 0.02,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      item.name,
                                                      style: TextStyle(
                                                          color:
                                                              kSecondaryColor,
                                                          fontSize:
                                                              pHeight * 0.02,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              'Poppins'),
                                                    ),
                                                    Text(
                                                      item.desc,
                                                      style: TextStyle(
                                                          color:
                                                              kSecondaryColor,
                                                          fontSize:
                                                              pHeight * 0.015,
                                                          fontFamily:
                                                              'Poppins'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Text(
                                                    'Rs. ',
                                                    style: TextStyle(
                                                        color: kSecondaryColor,
                                                        fontSize:
                                                            pHeight * 0.018,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily: 'Poppins'),
                                                  ),
                                                  Text(
                                                    item.price,
                                                    style: TextStyle(
                                                        color: kSecondaryColor,
                                                        fontSize:
                                                            pHeight * 0.018,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily: 'Poppins'),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                height: pHeight * 0.04,
                                                width: pWidth * 0.574,
                                                decoration: BoxDecoration(
                                                  color: kSecondaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Add To Cart',
                                                    style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        color: Colors.white,
                                                        fontSize:
                                                            pHeight * 0.025),
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
                          }),
                    )),
        ],
      ),
    );
  }
}
