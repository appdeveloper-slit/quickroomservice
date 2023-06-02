import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quick_room_services/reviewpage.dart';
import 'package:quick_room_services/values/colors.dart';
import 'package:quick_room_services/values/dimens.dart';
import 'package:quick_room_services/values/global_urls.dart';
import 'package:quick_room_services/values/strings.dart';

import 'package:quick_room_services/values/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'manage/static_method.dart';

class Details extends StatefulWidget {
  String hostel_id;
  String hostelName;
  String hostelAddress;
  String ownerName;
  String ownerNumber;
  String alternateNumber;
  String ownerEmail;
  String hostelTelephoneNumber;
  String hostelType;
  String vacancyCountAvailable;
  String extraCharges;
  String gateClosingTime;
  String monthly_charge;
  String facility;
  String conditions;

  String lat;
  String long;

  Details(
      {required this.hostel_id,
      required this.hostelName,
      required this.hostelAddress,
      required this.ownerName,
      required this.ownerNumber,
      required this.alternateNumber,
      required this.ownerEmail,
      required this.hostelTelephoneNumber,
      required this.hostelType,
      required this.vacancyCountAvailable,
      required this.extraCharges,
      required this.gateClosingTime,
      required this.monthly_charge,
      required this.facility,
      required this.conditions,
      required this.lat,
      required this.long});

  @override
  State<Details> createState() => _DetailsState(
      hostel_id: hostel_id,
      hostelName: hostelName,
      hostelAddress: hostelAddress,
      ownerName: ownerName,
      ownerNumber: ownerNumber,
      alternateNumber: alternateNumber,
      ownerEmail: ownerEmail,
      hostelTelephoneNumber: hostelTelephoneNumber,
      hostelType: hostelType,
      vacancyCountAvailable: vacancyCountAvailable,
      extraCharges: extraCharges,
      gateClosingTime: gateClosingTime,
      monthly_charge: monthly_charge,
      facility: facility,
      conditions: conditions,
      lat: lat,
      long: long);
}

class _DetailsState extends State<Details> {
  late BuildContext ctx;
  String hostel_id;
  String hostelName;
  String hostelAddress;
  String ownerName;
  String ownerNumber;
  String alternateNumber;
  String ownerEmail;
  String hostelTelephoneNumber;
  String hostelType;
  String vacancyCountAvailable;
  String extraCharges;
  String gateClosingTime;
  String monthly_charge;
  String facility;
  String conditions;

  String lat;
  String long;

  _DetailsState(
      {required this.hostel_id,
      required this.hostelName,
      required this.hostelAddress,
      required this.ownerName,
      required this.ownerNumber,
      required this.alternateNumber,
      required this.ownerEmail,
      required this.hostelTelephoneNumber,
      required this.hostelType,
      required this.vacancyCountAvailable,
      required this.extraCharges,
      required this.gateClosingTime,
      required this.monthly_charge,
      required this.facility,
      required this.conditions,
      required this.lat,
      required this.long});

  bool loaded = true;

  double? rating;

  List<String> imageList = [
    // "assets/img1.png",
    // "assets/img1.png"
  ];

  void getHostel() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    // sp.getString('location_id').toString();

    setState(() {
      loaded = false;
    });
    var dio = Dio();
    var formData = FormData.fromMap({
      'hostel_id': hostel_id.toString(),
      'user_id': sp.getString('user_id').toString()
    });
    var response = await dio.post(getHostelDetails(), data: formData);
    var res = response.data;
    print(res);

    imageList = [];
    for (int i = 0; i < res['hostel']['imgs'].length; i++) {
      imageList.add(res['hostel']['imgs'][i]['image_path']);
    }
    setState(() {
      loaded = true;
      imageList = imageList;
    });

    // if (res['error'] == false) {

    // } else {
    //   showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         title: Text(
    //           "Error",
    //           style: TextStyle(color: Colors.red),
    //         ),
    //         content: Text(res['message'].toString()),
    //         actions: [
    //           TextButton(
    //               onPressed: () => Navigator.pop(context), child: Text("OK")),
    //         ],
    //       );
    //     },
    //   );
    // }
  }

  double averageRate = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    getHostel();
    Future.delayed(Duration.zero,(){
      getReview();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return Scaffold(
      backgroundColor: Clr().white,
      appBar: AppBar(
        backgroundColor: Color(0xff21488c),
        leading: InkWell(
            onTap: () {
              STM().back2Previous(ctx);
            },
            child: Icon(Icons.arrow_back_ios_new)),
        centerTitle: true,
        title: Text(
          'Hostel Details',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                viewportFraction: 1,
                enlargeCenterPage: true,
                enableInfiniteScroll: true,
                autoPlay: true,
              ),
              items: imageList
                  .map((e) => ClipRRect(
                        // borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            CachedNetworkImage(
                              imageUrl: e.toString(),
                              width: 1200,
                              height: 300,
                              fit: BoxFit.fill,
                              placeholder: (context, url) => Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      color: Colors.blue,
                                    )
                                  ]),
                            )
                          ],
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(
              height: 8,
            ),
            // Wrap(
            //   children: imageList.asMap().entries.map((entry) {
            //     return Container(
            //       width: 8,
            //       height: 8,
            //       margin: const EdgeInsets.symmetric(
            //         horizontal: 2,
            //       ),
            //       decoration: BoxDecoration(
            //         shape: BoxShape.circle,
            //         color: Clr().primaryColor
            //       ),
            //     );
            //   }).toList(),
            // ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Clr().white,
                  borderRadius: BorderRadius.circular(Dim().d12),
                  boxShadow: [
                    BoxShadow(
                      color: Clr().grey.withOpacity(0.4),
                      spreadRadius: 0.5,
                      blurRadius: 5.0,
                      offset: Offset(0, 4),
                    )
                  ]),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Dim().d12, vertical: Dim().d12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${hostelName}', style: Sty().mediumBoldText),
                    SizedBox(height: Dim().d12),
                    Row(
                      children: [
                        SvgPicture.asset('assets/location.svg',
                            height: Dim().d20, color: Clr().primaryColor),
                        SizedBox(width: Dim().d12),
                        Expanded(
                            child: Text('${hostelAddress}',
                                style: Sty().mediumText,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis)),
                      ],
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: Dim().d8),
            Align(
              alignment: Alignment.centerLeft,
              child: RatingBar.builder(
                initialRating: averageRate,
                minRating: 1,
                direction: Axis.horizontal,
                ignoreGestures: true,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: Dim().d28,
                unratedColor: Color(0xff7F7A7A),
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rate) {
                  print(rating);
                  setState(() {
                    rating = rate;
                  });
                },
              ),
            ),
            SizedBox(height: Dim().d4),
            InkWell(onTap: (){
              STM().redirect2page(ctx, ReviewPage(hostelId: hostel_id.toString(),));
            },
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(' ${averageRate} + ratings',
                      style: Sty().mediumText.copyWith(
                            color: Color(0xff21488C),
                            fontWeight: FontWeight.w500,
                          ))),
            ),
            SizedBox(height: Dim().d8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  'Hostel Name / Building Name',
                  style: Sty().mediumText.copyWith(
                        fontSize: 18,
                      ),
                ),
                SizedBox(height: Dim().d12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  color: Colors.black12,
                  child: SelectableText(
                    hostelName,
                    style: Sty()
                        .mediumText
                        .copyWith(fontSize: 16, color: Colors.black54),
                  ),
                ),

                // Text('Hostel Name / Building Name',
                //   // textAlign: TextAlign.left,
                //   style: Sty().mediumText.copyWith(
                //     fontSize: 18,
                //   )
                // ),
                //
                // SizedBox(height: 12,),
                // TextFormField(
                //   decoration: InputDecoration(
                //     contentPadding: EdgeInsets.all(10),
                //     // label: Text('Hostel Name / Building Name'),
                //     hintText: 'Lorem Ipsum is simply dummy text',
                //     border: InputBorder.none,
                //     fillColor: Colors.black12,
                //     filled: true,
                //   ),
                // ),

                SizedBox(height: 20),
                Text(
                  'Hostel Address',
                  style: Sty().mediumText.copyWith(
                        fontSize: 18,
                      ),
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  color: Colors.black12,
                  child: SelectableText(
                    hostelAddress,
                    style: Sty()
                        .mediumText
                        .copyWith(fontSize: 16, color: Colors.black54),
                  ),
                ),

                // SizedBox(height: 20),
                // Text('Hostel Address',
                //     style: Sty().mediumText.copyWith(
                //       fontSize: 18,
                //     )
                // ),
                // SizedBox(height: 12),
                // TextFormField(
                //   decoration: InputDecoration(
                //     contentPadding: EdgeInsets.all(10),
                //     // label: Text('Hostel Name / Building Name'),
                //     hintText: 'Lorem Ipsum is simply dummy text',
                //     border: InputBorder.none,
                //     fillColor: Colors.black12,
                //     filled: true,
                //   ),
                // ),

                SizedBox(height: 20),
                Text(
                  'Owner Name',
                  style: Sty().mediumText.copyWith(
                        fontSize: 18,
                      ),
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  color: Colors.black12,
                  child: SelectableText(
                    ownerName,
                    style: Sty()
                        .mediumText
                        .copyWith(fontSize: 16, color: Colors.black54),
                  ),
                ),

                SizedBox(height: 20),
                Text(
                  'Owner Number',
                  style: Sty().mediumText.copyWith(
                        fontSize: 18,
                      ),
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  color: Colors.black12,
                  child: SelectableText(
                    ownerNumber,
                    style: Sty()
                        .mediumText
                        .copyWith(fontSize: 16, color: Colors.black54),
                  ),
                ),

                //
                // SizedBox(height: 20),
                // Text('Owner Number',
                //   style: Sty().mediumText.copyWith(
                //     fontSize: 18,
                //   ),),
                // SizedBox(height: 12),
                // TextFormField(
                //   decoration: InputDecoration(
                //     contentPadding: EdgeInsets.all(10),
                //     // label: Text('Hostel Name / Building Name'),
                //     hintText: '9898989898',
                //     border: InputBorder.none,
                //     fillColor: Colors.black12,
                //     filled: true,
                //   ),
                // ),

                SizedBox(height: 20),
                Text(
                  'Whatsapp Number',
                  style: Sty().mediumText.copyWith(
                        fontSize: 18,
                      ),
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  color: Colors.black12,
                  child: SelectableText(
                    alternateNumber,
                    style: Sty()
                        .mediumText
                        .copyWith(fontSize: 16, color: Colors.black54),
                  ),
                ),

                // SizedBox(height: 20),
                // Text('Alternate Number',
                //   style: Sty().mediumText.copyWith(
                //     fontSize: 18,
                //   ),),
                // SizedBox(height: 12),
                // TextFormField(
                //   decoration: InputDecoration(
                //     contentPadding: EdgeInsets.all(10),
                //     // label: Text('Hostel Name / Building Name'),
                //     hintText: '9898989898',
                //     border: InputBorder.none,
                //     fillColor: Colors.black12,
                //     filled: true,
                //   ),
                // ),

                SizedBox(height: 20),
                Text(
                  'Owner Email',
                  style: Sty().mediumText.copyWith(
                        fontSize: 18,
                      ),
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  color: Colors.black12,
                  child: SelectableText(
                    ownerEmail,
                    style: Sty()
                        .mediumText
                        .copyWith(fontSize: 16, color: Colors.black54),
                  ),
                ),

                // SizedBox(height: 20),
                // Text('Owner Email',
                //   style: Sty().mediumText.copyWith(
                //     fontSize: 18,
                //   ),),
                // SizedBox(height: 12),
                // TextFormField(
                //   decoration: InputDecoration(
                //     contentPadding: EdgeInsets.all(10),
                //     // label: Text('Hostel Name / Building Name'),
                //     hintText: 'johndoe@gmail.com',
                //     border: InputBorder.none,
                //     fillColor: Colors.black12,
                //     filled: true,
                //   ),
                // ),

                SizedBox(height: 20),
                Text(
                  'Hostel Telephone Number',
                  style: Sty().mediumText.copyWith(
                        fontSize: 18,
                      ),
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  color: Colors.black12,
                  child: SelectableText(
                    hostelTelephoneNumber,
                    style: Sty()
                        .mediumText
                        .copyWith(fontSize: 16, color: Colors.black54),
                  ),
                ),

                // SizedBox(height: 20),
                // Text('Hostel Telephone Number',
                //   style: Sty().mediumText.copyWith(
                //     fontSize: 18,
                //   ),),
                // SizedBox(height: 12),
                // TextFormField(
                //   decoration: InputDecoration(
                //     contentPadding: EdgeInsets.all(10),
                //     // label: Text('Hostel Name / Building Name'),
                //     hintText: '2589631563',
                //     border: InputBorder.none,
                //     fillColor: Colors.black12,
                //     filled: true,
                //   ),
                // ),

                SizedBox(height: 20),
                Text(
                  'Hostel Type',
                  style: Sty().mediumText.copyWith(
                        fontSize: 18,
                      ),
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  color: Colors.black12,
                  child: SelectableText(
                    hostelType,
                    style: Sty()
                        .mediumText
                        .copyWith(fontSize: 16, color: Colors.black54),
                  ),
                ),

                // SizedBox(height: 20),
                // Text('Hostel type',
                //   style: Sty().mediumText.copyWith(
                //     fontSize: 18,
                //   ),),
                // SizedBox(height: 12),
                // TextFormField(
                //   decoration: InputDecoration(
                //     contentPadding: EdgeInsets.all(10),
                //     // label: Text('Hostel Name / Building Name'),
                //     hintText: 'Girls',
                //     border: InputBorder.none,
                //     fillColor: Colors.black12,
                //     filled: true,
                //   ),
                // ),

                SizedBox(height: 20),
                Text(
                  'Vacancy Count Available',
                  style: Sty().mediumText.copyWith(
                        fontSize: 18,
                      ),
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  color: Colors.black12,
                  child: SelectableText(
                    vacancyCountAvailable,
                    style: Sty()
                        .mediumText
                        .copyWith(fontSize: 16, color: Colors.black54),
                  ),
                ),

                // SizedBox(height: 20),
                // Text('Vacancy Count Available',
                //   style: Sty().mediumText.copyWith(
                //     fontSize: 18,
                //   ),),
                // SizedBox(height: 12),
                // TextFormField(
                //   decoration: InputDecoration(
                //     contentPadding: EdgeInsets.all(10),
                //     // label: Text('Hostel Name / Building Name'),
                //     hintText: '9898989898',
                //     border: InputBorder.none,
                //     fillColor: Colors.black12,
                //     filled: true,
                //   ),
                // ),

                SizedBox(height: 20),
                Text(
                  'Extra Charges',
                  style: Sty().mediumText.copyWith(
                        fontSize: 18,
                      ),
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  color: Colors.black12,
                  child: SelectableText(
                    extraCharges,
                    style: Sty()
                        .mediumText
                        .copyWith(fontSize: 16, color: Colors.black54),
                  ),
                ),

                // SizedBox(height: 20),
                // Text('Extra Charges',
                //   style: Sty().mediumText.copyWith(
                //     fontSize: 18,
                //   ),),
                // SizedBox(height: 12),
                // TextFormField(
                //   decoration: InputDecoration(
                //     contentPadding: EdgeInsets.all(10),
                //     // label: Text('Hostel Name / Building Name'),
                //     hintText: 'No',
                //     border: InputBorder.none,
                //     fillColor: Colors.black12,
                //     filled: true,
                //   ),
                // ),

                SizedBox(height: 20),
                !(gateClosingTime == "00:00:00")
                    ? Text(
                        'Gate Closing Time',
                        style: Sty().mediumText.copyWith(
                              fontSize: 18,
                            ),
                      )
                    : Text(
                        'Gate Closing Time',
                        style: Sty().mediumText.copyWith(
                              fontSize: 18,
                            ),
                      ),
                SizedBox(height: 12),
                !(gateClosingTime == "00:00:00")
                    ? Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        color: Colors.black12,
                        child: SelectableText(
                          gateClosingTime,
                          style: Sty()
                              .mediumText
                              .copyWith(fontSize: 16, color: Colors.black54),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        color: Colors.black12,
                        child: Text(
                          "No gate closing time",
                          style: Sty()
                              .mediumText
                              .copyWith(fontSize: 16, color: Colors.black54),
                        ),
                      ),

                SizedBox(height: 20),
                Text(
                  'Monthly Charges',
                  style: Sty().mediumText.copyWith(
                        fontSize: 18,
                      ),
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  color: Colors.black12,
                  child: SelectableText(
                    '\u20b9' + monthly_charge,
                    style: Sty()
                        .mediumText
                        .copyWith(fontSize: 16, color: Colors.black54),
                  ),
                ),

                // SizedBox(height: 20),
                // Text('Gate Closing Time',
                //   style: Sty().mediumText.copyWith(
                //     fontSize: 18,
                //   ),),
                // SizedBox(height: 12),
                // TextFormField(
                //   decoration: InputDecoration(
                //     contentPadding: EdgeInsets.all(10),
                //     // label: Text('Hostel Name / Building Name'),
                //     hintText: 'No Limit',
                //     border: InputBorder.none,
                //     fillColor: Colors.black12,
                //     filled: true,
                //   ),
                // ),

                SizedBox(height: 20),
                Text(
                  'Facility',
                  style: Sty().mediumText.copyWith(
                        fontSize: 18,
                      ),
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  color: Colors.black12,
                  child: SelectableText(
                    facility,
                    style: Sty()
                        .mediumText
                        .copyWith(fontSize: 16, color: Colors.black54),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Conditions',
                  style: Sty().mediumText.copyWith(
                        fontSize: 18,
                      ),
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  color: Colors.black12,
                  child: SelectableText(
                    conditions,
                    style: Sty()
                        .mediumText
                        .copyWith(fontSize: 16, color: Colors.black54),
                  ),
                ),
                SizedBox(height: Dim().d16),

                // SizedBox(height: 20),
                // Text('Conditions',
                //   style: Sty().mediumText.copyWith(
                //     fontSize: 18,
                //   ),),
                // SizedBox(height: 12),
                // TextFormField(
                //   decoration: InputDecoration(
                //     contentPadding: EdgeInsets.all(10),
                //     // label: Text('Hostel Name / Building Name'),
                //     hintText: 'Lorem Ipsum is simply dummy text of the',
                //     border: InputBorder.none,
                //     fillColor: Colors.black12,
                //     filled: true,
                //   ),
                // ),
                // Padding(
                //   padding: EdgeInsets.only(top: 20),
                //   child: Row(
                //     children: [
                //       SizedBox(
                //         height: 50,
                //         width: double.infinity,
                //         child: ElevatedButton(
                //           onPressed: () async {
                //             var url = "tel:" + ownerNumber.toString();
                //             if (await canLaunchUrlString(url)) {
                //               await launchUrlString(url);
                //             } else {
                //               throw 'Could not launch $url';
                //             }
                //           },
                //           style: Sty().primaryButton,
                //           child: Row(
                //             children: [
                //               SvgPicture.asset('assets/calldetails.svg',height: Dim().d24),
                //               SizedBox(width: Dim().d12),
                //               Text(
                //                 'Contact Owner',
                //                 style: Sty()
                //                     .mediumText
                //                     .copyWith(color: Colors.white),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //       SizedBox(width:10, height: 10,),
                //       // SizedBox(
                //       //   height: 50,
                //       //   width: 150,
                //       //   child: ElevatedButton(
                //       //     style: Sty().primaryButton,
                //           onPressed: () async {
                //
                //             // String googleUrl = 'https://www.google.com/maps/@$lat,$long,18.25z';
                //             // String googleUrl = 'google.navigation:q=$lat,$long&mode=d';
                //             //  String googleUrl = 'http://maps.google.com/maps?saddr=$lat&daddr=$long';
                //             String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$long';
                //             if (await canLaunchUrlString(googleUrl)) {
                //               await launchUrlString(googleUrl, mode: LaunchMode.externalApplication);
                //             } else {
                //               throw 'Could not open the map.';
                //             }
                //           },
                //       //     child: Text(
                //       //       'View On Map',
                //       //       style: Sty().mediumText.copyWith(
                //       //             color: Colors.white,
                //       //           ),
                //       //     ),
                //       //   ),
                //       // )
                //     ],
                //   ),
                // ),
                SizedBox(height: Dim().d12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(onTap: ()async{
                     await launch("whatsapp://send?phone=${alternateNumber.toString()}");
                    },
                      child: Row(
                        children: [
                          SvgPicture.asset('assets/whatsapp.svg',
                              height: Dim().d28),
                          SizedBox(width: Dim().d8),
                          Text('What’s app',
                              style: Sty().mediumText.copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontSize: Dim().d16)),
                        ],
                      ),
                    ),
                    SizedBox(width: Dim().d24),

                    InkWell(
                      onTap: () async {
                        String googleUrl =
                            'https://www.google.com/maps/search/?api=1&query=$lat,$long';
                        if (await canLaunchUrlString(googleUrl)) {
                          await launchUrlString(googleUrl,
                              mode: LaunchMode.externalApplication);
                        } else {
                          throw 'Could not open the map.';
                        }
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset('assets/map.svg', height: Dim().d28),
                          SizedBox(width: Dim().d8),
                          Text('View On Map',
                              style: Sty().mediumText.copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontSize: Dim().d16)),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: Dim().d12),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      var url = "tel:" + ownerNumber.toString();
                      if (await canLaunchUrlString(url)) {
                        await launchUrlString(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    style: Sty().primaryButton,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset('assets/calldetails.svg',
                            height: Dim().d24),
                        SizedBox(width: Dim().d12),
                        Text(
                          'Contact Owner',
                          style: Sty().mediumText.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// get Review
  void getReview() async {
    FormData body = FormData.fromMap({
      'hostel_id': hostel_id.toString(),
    });
    var result = await STM().post(ctx, Str().loading, 'show_review', body);
    setState(() {
      averageRate = result['review_avg'];
    });
  }

}
