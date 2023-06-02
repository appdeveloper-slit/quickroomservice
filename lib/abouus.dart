import 'package:flutter/material.dart';
import 'package:quick_room_services/values/colors.dart';
import 'package:quick_room_services/values/dimens.dart';
import 'package:quick_room_services/values/styles.dart';

import 'manage/static_method.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({Key? key}) : super(key: key);

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  late BuildContext ctx;

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return WillPopScope(
      onWillPop: () async {
        STM().back2Previous(ctx);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Clr().primaryColor,
          leading: InkWell(
              onTap: () {
                STM().back2Previous(ctx);
              },
              child: Icon(Icons.arrow_back, color: Clr().white)),
          title: Text('About Us',
              style: Sty().mediumText.copyWith(color: Clr().white)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: Dim().d40),
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: Dim().d16),
                child: Center(
                    child: Text.rich(
                        TextSpan(
                          style: Sty().mediumText,
                          children: [
                            TextSpan(text: "Our Introduction\nResiEasy application owned by Alcyoneus private limited (CIN -U55209MH2022PTC387925) is a residence providing platform that helps people to find their affordable residance.  \n\n\nOur goal is to make finding of residence  easy and safe for Indian people. Our dedicated team is passionate about helping those people who wants residance on rent.For further information, please contact us at", style: Sty().mediumText.copyWith(fontSize: Dim().d20),),
                            WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {
                                    const url = 'mailto: help@resieasy.com';
                                    STM().openWeb(url);
                                  },
                                  child: Text(
                                    ' help@resieasy.com. ',
                                    style: Sty().mediumText.copyWith(fontSize: Dim().d20,color: Clr().linkColor),
                                  ),
                                )),
                          ],
                        ),),
                ),

              ),
            ],
          ),
        ),
      ),
    );
  }
}
