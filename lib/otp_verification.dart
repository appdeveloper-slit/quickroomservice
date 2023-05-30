import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';
import 'location.dart';
import 'values/global_urls.dart';

class OTPVerificationScreen extends StatefulWidget {
  String mobileNumebr;
  String name;
  String email;
  String companyName;
  String otptype;
  String type;

  OTPVerificationScreen({required this.mobileNumebr, required this.name, required this.email, required this.companyName, required this.otptype, required this.type});
  @override
  State<OTPVerificationScreen> createState() =>
      OTPVerificationScreenState(mobileNumebr: mobileNumebr, name: name, email: email, companyName: companyName, otptype: otptype, type: type);
}

class OTPVerificationScreenState extends State<OTPVerificationScreen> {
  String mobileNumebr;
  String name;
  String email;
  String companyName;
  String otptype;
  String type;
  OTPVerificationScreenState({required this.mobileNumebr, required this.name, required this.email, required this.companyName, required this.otptype, required this.type});


  void signInUser() async {
    setState(() {
      sendload = false;
    });
    var dio = Dio();
    var formData = FormData.fromMap({
      'phone': mobileNumebr,
    });
    var response = await dio.post(signInUrl(), data: formData);
    var res = response.data;
    print(res);
    setState(() {
      sendload = true;
    });

    if (res['error'] == false) {
      SharedPreferences sp = await SharedPreferences.getInstance();
      sp.setBool("isLoggedIn", true);
      sp.setString("user_id", res['user']['id'].toString());
      sp.setString("user_type", res['user']['type'].toString());
      sp.setString("user_name", res['user']['name'].toString());
      sp.setString("user_phone", res['user']['phone'].toString());
      Navigator
          .pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SelectLocation()), (route) => false);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Error",
              style: TextStyle(color: Colors.red),
            ),
            content: Text(res['message'].toString()),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context), child: Text("OK")),
            ],
          );
        },
      );
    }
  }

















  TextEditingController otpController = TextEditingController();
  bool sendload = true;
  var periodicTimer;
  int totaltime = 60;
  bool resendEnabled = false;
  bool shouldStop = true;
  void resetTimer(){
    setState(() {
       sendload = true;
       periodicTimer;
       totaltime = 60;
       resendEnabled = false;
       shouldStop = true;
    });
  }

    void resendOtpTimer(){
    shouldStop = false;

    periodicTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        
        // Update user about remaining time
        setState(() {
          if (timer.isActive) {
            print("Timer Active...");
            if (shouldStop) {
            timer.cancel();
          }
        }
          if(totaltime <= 0){
            resendEnabled = true;
            shouldStop = true;
            totaltime = 0;
          }
          else{
            totaltime--;
          }
          
        });
        
      });
    

  }

  @override
  void initState() {
    // TODO: implement initState
    resendOtpTimer();
    super.initState();
  }

    @override
  void dispose() {
    super.dispose();
    print("[i] Disposing timer periodic....");
    periodicTimer?.cancel();
    print("[+] Dispose executed...");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        SizedBox(
          height: 150,
        ),
        Center(
          child: Text(
            "OTP Verification",
            style: TextStyle(
              fontSize: 30,
            ),
          ),
        ),
        Center(child: Text("code is sent to " + mobileNumebr.toString())),
        SizedBox(
          height: 25,
        ),
        // OTP Fields
        Container(
          margin: EdgeInsets.only(left: 50, right: 50),
          child: PinCodeTextField(
            keyboardType: TextInputType.number,
            length: 4,
            obscureText: false,
            animationType: AnimationType.scale,
            cursorColor: Color(0xff21488c),
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.underline,
              borderRadius: BorderRadius.circular(2),
              fieldHeight: 50,
              fieldWidth: 50,
              activeFillColor: Colors.white,
              selectedFillColor: Colors.white,
              inactiveFillColor: Colors.white,
              inactiveColor: Colors.grey,
              activeColor: Color(0xff21488c),
              selectedColor: Color.fromARGB(255, 0, 26, 70),
            ),
            // animationDuration: Duration(milliseconds: 300),
            enableActiveFill: true,
            controller: otpController,
            onCompleted: (v) {
              print("Completed");
              print(v);
            },
            onChanged: (value) {},
            // validator: (value) {
            //   if (value!.isEmpty || !RegExp(r'(.{4,})').hasMatch(value)) {
            //     return "";
            //   } else {
            //     return null;
            //   }
            // },
            appContext: context,
          ),
        ),
        SizedBox(
          height: 25,
        ),
        resendEnabled ? Center(
          child: InkWell(
            onTap: () async {
              print("resend tapped");
              setState(() {
                resendEnabled = false;        
              });
              
              var dio = Dio();
              var formdata =
                  FormData.fromMap({'phone': mobileNumebr.toString()});
              final response = await dio.post(resendOTP(), data: formdata);
              var result = response.data;
              print(result);

              setState(() {
                resendEnabled = true;        
              });

              if (result['error'] != true) {
                resetTimer();
                resendOtpTimer();
                SnackBar sn = new SnackBar(
                    content: Text(
                        result['message'].toString()));
                ScaffoldMessenger.of(context).showSnackBar(sn);
              } else {
                SnackBar sn =
                    new SnackBar(content: Text(result['message'].toString()));
                ScaffoldMessenger.of(context).showSnackBar(sn);
              }
            },
            child: RichText(
                text: TextSpan(
                    text: "",
                    children: [
                      TextSpan(text: "If you didn't receive code! "),
                      TextSpan(
                        text: "Resend",
                        style:
                            TextStyle(color: Color(0xff21488c), fontWeight: FontWeight.w600),
                      ),
                    ],
                    style: TextStyle(color: Colors.black))),
          ),
        ) : Text("Resend OTP (" + totaltime.toString() + " seconds)"),

        SizedBox(
          height: 25,
        ),
        Container(
          width: 250,
          child: sendload
              ? ElevatedButton(
                  onPressed: () async {
                    print("CURRENT OTP : " + otpController.text.toString());
                    print("CURRENT MOBILE NUMBER : " + mobileNumebr.toString());
                    setState(() {
                            sendload = false;  
                          });
                    
                    
                    if(otptype == 'login'){

                    var dio = Dio();
                    var formdata = FormData.fromMap({
                      'phone': mobileNumebr.toString(),
                      'otp': otpController.text.toString(),
                      'page_type' : 'login',
                      // 'type' : 'login'
                    });
                    final response = await dio.post(verifyOTP(), data: formdata);
                    var result = response.data;
                    print(result);
                    setState(() {
                            sendload = true;  
                          });

                    if (result['error'] != true) {

                           SharedPreferences sp = await SharedPreferences.getInstance();
                            sp.setBool("isLoggedIn", true);
                            sp.setString("user_id", result['user']['id'].toString());
                            sp.setString("user_type", result['user']['type'].toString());
                            sp.setString("user_name", result['user']['name'].toString());
                            sp.setString("user_phone", result['user']['phone'].toString());
                            Navigator
                                .pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SelectLocation()), (route) => false);
   
                    } else {
                      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Error",
              style: TextStyle(color: Colors.red),
            ),
            content: Text(result['message']),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context), child: Text("OK")),
            ],
          );
        },
      );
                    }

                    }
                    else{

                      // For signing up the user
                      
                    var dio = Dio();
                    var formdata = FormData.fromMap({
                      'phone': mobileNumebr.toString(),
                      'otp': otpController.text.toString(),
                      'page_type' : 'register',
                      'type' : type.toString(),
                      'name' : name.toString()
                      
                    });
                    final response = await dio.post(verifyOTP(), data: formdata);
                    var result = response.data;
                    print(result);
                    setState(() {
                            sendload = true;  
                          });

                    if (result['error'] != true) {
                      SharedPreferences sp = await SharedPreferences.getInstance();
                      sp.setBool("isLoggedIn", true);
                      sp.setString("user_id", result['user']['id'].toString());
                      sp.setString("user_type", result['user']['type'].toString());
                      sp.setString("user_name", result['user']['name'].toString());
                      sp.setString("user_phone", result['user']['phone'].toString());
                      Navigator.of(context)
                          .pushReplacement(MaterialPageRoute(builder: (context) => SelectLocation()));
                    } else {
                      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Error",
              style: TextStyle(color: Colors.red),
            ),
            content: Text(result['message']),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context), child: Text("OK")),
            ],
          );
        },
      );
                    }

                    }


                  },
                  child: Text("Verify"))
              : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: CircularProgressIndicator()),
                ],
              ),
        )
      ],
    ));
  }
}
