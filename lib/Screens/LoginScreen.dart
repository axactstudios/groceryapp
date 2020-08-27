import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groceryapp/Classes/Constants.dart';
import 'package:groceryapp/Classes/CustomIcons.dart';
import 'package:groceryapp/Screens/RegistrationPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController phone = new TextEditingController(text: '');
  TextEditingController otp = new TextEditingController(text: '');
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final pHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kPrimaryColor,
      body: Form(
        key: _formKey,
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: pHeight * 0.06),
                child: Text(
                  'Logo',
                  style: TextStyle(
                      fontSize: pHeight * 0.045, fontFamily: 'Poppins'),
                ),
              ),
              SizedBox(
                height: pHeight * 0.042,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset('images/onboarding.png'),
              ),
              SizedBox(
                height: pHeight * 0.01,
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: kSecondaryColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10))),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 32.0,
                            right: 32,
                            top: 36,
                          ),
                          child: TextFormField(
                            validator: (value) {
                              if (value.length < 10) {
                                return 'Invalid phone number';
                              } else {
                                return null;
                              }
                            },
                            controller: phone,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: kFormColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              hintText: 'Enter Mobile Number',
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 32.0,
                            right: 32,
                            top: 15,
                          ),
                          child: TextFormField(
                            validator: (value) {
                              if (value.length < 6) {
                                return 'Invalid OTP';
                              } else {
                                return null;
                              }
                            },
                            controller: otp,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: kFormColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              hintText: 'Enter OTP',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 20, left: 90, right: 90),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 3, color: Colors.white),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(40),
                                  ),
                                ),
                                child: Ink(
                                    decoration: const ShapeDecoration(
                                      color: Colors.lightBlue,
                                      shape: CircleBorder(),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Custom_icons_iconsdart.facebook,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      iconSize: 50,
                                      onPressed: () {},
                                    )),
                              ),
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 3, color: Colors.white),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(40),
                                  ),
                                ),
                                child: Ink(
                                    decoration: const ShapeDecoration(
                                      color: Colors.green,
                                      shape: CircleBorder(),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Custom_icons_iconsdart.twitter,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      iconSize: 50,
                                      onPressed: () {},
                                    )),
                              ),
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 3, color: Colors.white),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(40),
                                  ),
                                ),
                                child: Ink(
                                    decoration: const ShapeDecoration(
                                      color: Colors.lightBlue,
                                      shape: CircleBorder(),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Custom_icons_iconsdart.gplus,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      iconSize: 50,
                                      onPressed: () {},
                                    )),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FloatingActionButton(
                                  onPressed: () {
                                    if (_formKey.currentState.validate()) {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) =>
                                              RegistrationPage(),
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
            ],
          ),
        ),
      ),
//      floatingActionButton: FloatingActionButton(
////        tooltip: 'Increment',
//        child: Icon(Icons.add),
//      ),
    );
  }
}
