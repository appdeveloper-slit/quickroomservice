import 'package:flutter/material.dart';
import 'package:quick_room_services/otp_verification.dart';
import 'package:quick_room_services/sign_in.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'register.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
  OneSignal.shared.setAppId("37556f28-684a-430f-86c1-4bf6e0405b5d");
  OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
      print("Accepted permission: $accepted");
  });

  // SharedPreferences sp = await SharedPreferences.getInstance();
  // bool isLogin =
  // sp.getBool('is_login') != null ? sp.getBool("is_login")! : false;
  // bool isID = sp.getString('user_id') != null ? true : false;
  await Future.delayed(const Duration(seconds: 3));
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: isLogin
      //     ? const Home()
      //     : isID
      //     ? const SelectCourse()
      //     : const Register(),
      home: SignIn(),
      // home: OTPVerificationScreen(mobileNumebr: "1234567890", name : "test", email: "test@test.co", companyName: "test", otptype: "register",),
    ),
  );
}