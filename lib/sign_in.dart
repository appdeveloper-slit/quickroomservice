import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:quick_room_services/home.dart';
import 'package:quick_room_services/manage/static_method.dart';
import 'package:quick_room_services/register.dart';
import 'package:quick_room_services/values/global_urls.dart';
import 'package:quick_room_services/values/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validators/validators.dart';

import 'location.dart';
import 'otp_verification.dart';
import 'pre_register_form_only_number.dart';

// void main() => runApp(SignIn());

class SignIn extends StatefulWidget {
  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  late BuildContext ctx;
  TextEditingController phoneNumber = TextEditingController();
  bool loaded = true;

  bool isLoggedIn = false;
  String locationSet = "none";

  void checkLogin() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    isLoggedIn =
        sp.getBool("isLoggedIn") != null ? sp.getBool("isLoggedIn")! : false;
    locationSet = sp.getString("location_id") != null
        ? sp.getString("location_id")!
        : "none";
    print(locationSet);
    if (isLoggedIn == true) {
      if (locationSet == "none") {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => SelectLocation()));
      } else {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) => Home()));
      }
    } else {}
  }

  void checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    print(connectivityResult);
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      // Do nothing
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            titlePadding: EdgeInsets.all(30),
            contentPadding: EdgeInsets.all(30),
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.wifi_off,
                size: 100,
                color: Colors.blue,
              ),
              SizedBox(
                height: 15,
              ),
              Align(
                  alignment: Alignment.center,
                  child:
                      Text("Connection Error", style: TextStyle(fontSize: 20))),
              SizedBox(
                height: 5,
              ),
              Align(
                  alignment: Alignment.center,
                  child: Text("No internet connection found.",
                      style: TextStyle(fontSize: 18))),
              SizedBox(
                height: 10,
              ),
              Container(
                // margin: EdgeInsets.only(left: 10, right: 10),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => SignIn()));
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Center(child: Text("TRY AGAIN"))),
                          Icon(Icons.refresh)
                        ],
                      ),
                    )),
              )
            ],
          );
        },
      );

      //  children: [
      //   Icon(Icons.wifi_off),
      //   Text("No internet connection!"),
      // ]);
    }
  }

  @override
  void initState() {
    checkLogin();
    checkConnectivity();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // appBar: AppBar(
        //   leading: Icon(Icons.menu),
        //   title: Text('QRS'),
        //
        //   actions: [
        //     Padding(padding: EdgeInsets.only(right: 20.0),
        //       child: GestureDetector(
        //         onTap: () {},
        //         child: Icon(Icons.notifications),
        //       ),)
        //   ],
        // ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 50),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Enter Your Number',
                    style: Sty().mediumText,
                  )),
              SizedBox(
                height: 12,
              ),
              TextFormField(
                controller: phoneNumber,
                maxLength: 10,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(8),
                  // label: Text('Enter Your Number'),
                  hintText: "Enter Your Number",
                  counterText: "",

                  border: InputBorder.none,
                  fillColor: Colors.black12,
                  filled: true,
                ),
              ),
              Container(
                margin: EdgeInsets.all(20),
                child: loaded
                    ? ElevatedButton(
                        child: Text('Sign In'),
                        onPressed: () async {
                          if (isLength(phoneNumber.text, 10)) {
                            setState(() {
                              loaded = false;
                            });

                            var dio = Dio();
                            var formdata = FormData.fromMap({
                              "phone": phoneNumber.text.toString(),
                              "page_type": "login"
                            });
                            final response =
                                await dio.post(sendOTP(), data: formdata);
                            var result = response.data;
                            print(result);
                            setState(() {
                              loaded = true;
                            });

                            if (result['error'] != true) {
                              // SnackBar sn = new SnackBar(
                              //     content: Text(result['message'].toString()));
                              // ScaffoldMessenger.of(context).showSnackBar(sn);
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) =>
                                          OTPVerificationScreen(
                                            mobileNumebr:
                                                phoneNumber.text.toString(),
                                            name: "",
                                            email: "",
                                            companyName: "",
                                            otptype: "login",
                                            type: ""
                                          ))),
                                  (route) => false);
                            } else {

                               showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    "Error",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  content:
                                      Text(result['message'].toString()),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("OK")),
                                  ],
                                );
                              },
                            );
                              // SnackBar sn = new SnackBar(
                              //     content: Text(result['message'].toString()));
                              // ScaffoldMessenger.of(context).showSnackBar(sn);
                            }
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    "Error",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  content:
                                      Text("Please enter a 10 digit number"),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("OK")),
                                  ],
                                );
                              },
                            );
                          }
                          // STM().redirect2page(ctx, const SelectLocation());
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFF21488c),
                          padding: EdgeInsets.all(12),
                          minimumSize: Size(150.0, 12.0),
                        ),
                      )
                    : CircularProgressIndicator(),
              ),
              GestureDetector(
                onTap: () {
                  // STM().redirect2page(ctx, Register());
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => Register()));
                },
                child: RichText(
                  text: TextSpan(
                    text: 'Don’t have an account? ',
                    style: Sty().smallText,
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Sign Up',
                        style: Sty().smallText.copyWith(
                              color: Color(0xFF21488c),
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
