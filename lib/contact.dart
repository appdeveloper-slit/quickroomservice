import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quick_room_services/manage/static_method.dart';
import 'package:quick_room_services/values/colors.dart';
import 'package:quick_room_services/values/dimens.dart';
import 'package:quick_room_services/values/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({Key? key}) : super(key: key);

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  late BuildContext ctx;
  @override
  Widget build(BuildContext context) {
    ctx = context;
    return WillPopScope(
      onWillPop: ()async{
        STM().back2Previous(ctx);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Clr().primaryColor,
          leading: InkWell(onTap: (){
            STM().back2Previous(ctx);
          },child: Icon(Icons.arrow_back,color: Clr().white)),
          title: Text('Contact Us',style: Sty().mediumText.copyWith(color: Clr().white)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
                SizedBox(height: Dim().d40),
              Center(
                child: InkWell(onTap: ()async{
                  await launch('mailto:help@resieasy.com');
                },
                  child: Column(
                    children: [
                      SvgPicture.asset('assets/mail.svg',height: Dim().d20,),
                      SizedBox(height: Dim().d8),
                      Text('help@resieasy.com',
                        style: Sty().mediumText.copyWith(
                            fontWeight: FontWeight.w500,
                          fontSize: Dim().d24,
                        ),),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Dim().d20),
            ],
          ),
        ),
      ),
    );
  }
}
