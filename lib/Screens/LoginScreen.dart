import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groceryapp/Classes/Constants.dart';
import 'package:groceryapp/Classes/CustomIcons.dart';
import 'package:groceryapp/Screens/RegistrationPage.dart';

import '../Classes/Constants.dart';

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
    final pWidth = MediaQuery.of(context).size.width;

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
                height: pHeight * 0.040,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'images/onboarding.png',
                  height: pHeight * 0.35,
                ),
              ),
              // SizedBox(
              //   height: pHeight * 0.01,
              // ),
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
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.only(
                            left: pWidth * 0.08,
                            right: pWidth * 0.08,
                            top: pHeight * 0.03,
                          ),
                          child: TextFormField(
                            validator: (value) {
                              if (value.length == 10) _verifyPhoneNumber();
                              if (value.length < 10) {
                                return 'Invalid phone number';
                              } else {
                                _verifyPhoneNumber();
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
                          padding: EdgeInsets.only(
                            left: pWidth * 0.08,
                            right: pWidth * 0.08,
                            top: pHeight * 0.01,
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
                          padding: EdgeInsets.only(
                              top: pHeight * 0.02,
                              left: pWidth * 0.2,
                              right: pWidth * 0.2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                height: pHeight * 0.07,
                                width: pHeight * 0.07,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 3, color: Colors.white),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(pHeight * 0.035),
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
                                      iconSize: pHeight * 0.07,
                                      onPressed: () {},
                                    )),
                              ),
                              Container(
                                height: pHeight * 0.07,
                                width: pHeight * 0.07,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 3, color: Colors.white),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(pHeight * 0.035),
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
                                      iconSize: pHeight * 0.07,
                                      onPressed: () {},
                                    )),
                              ),
                              Container(
                                height: pHeight * 0.07,
                                width: pHeight * 0.07,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 3, color: Colors.white),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(pHeight * 0.035),
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
                                      iconSize: pHeight * 0.07,
                                      onPressed: _verifyPhoneNumber,
                                    )),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                  right: 8.0, bottom: pHeight * 0.02),
                              child: InkWell(
                                onTap: () async {
                                  if (_formKey.currentState.validate()) {
                                    await _signInWithPhoneNumber();
                                    await Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) =>
                                            RegistrationPage(),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  height: pHeight * 0.07,
                                  width: pHeight * 0.07,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(pHeight * 0.035),
                                    ),
                                    color: kAccentColor,
                                  ),
                                  child: Icon(
                                    Icons.chevron_right,
                                    size: pHeight * 0.05,
//                                color: Color.fromARGB(255, 242, 96, 22),
                                  ),
                                ),
                              ),
                            ),
                          ],
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

  String _message, _verificationId;
  FirebaseAuth _auth = FirebaseAuth.instance;
  // Example code of how to verify phone number
  void _verifyPhoneNumber() async {
    setState(() {
      _message = '';
    });
    print('a');
    PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential phoneAuthCredential) async {
      print('b');
      await _auth.signInWithCredential(phoneAuthCredential);
      print(
          "Phone number automatically verified and user signed in: ${phoneAuthCredential}");
    };

    PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      print('c');
      setState(() {
        _message =
            'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}';
        print(_message);
      });
    };

    PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      print('d');
      print('Please check your phone for the verification code.');
      _verificationId = verificationId;
    };

    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      print('e');
      _verificationId = verificationId;
    };

    try {
      print('sd');
      await _auth.verifyPhoneNumber(
          phoneNumber: phone.text,
          timeout: const Duration(seconds: 5),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    } catch (e) {
      print("Failed to Verify Phone Number: ${e}");
    }
  }

  void _signInWithPhoneNumber() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp.text,
      );
      final User user = (await _auth.signInWithCredential(credential)).user;
      print("Successfully signed in UID: ${user.uid}");
    } catch (e) {
      print(e);
    }
  }
}
