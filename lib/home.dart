import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:quick_room_services/hostel_details.dart';
import 'package:quick_room_services/manage/static_method.dart';
import 'package:quick_room_services/sign_in.dart';
import 'package:quick_room_services/values/colors.dart';
import 'package:quick_room_services/values/dimens.dart';
import 'package:quick_room_services/values/global_urls.dart';
import 'package:quick_room_services/values/strings.dart';
import 'package:quick_room_services/values/styles.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

import 'location.dart';
import 'my_hostel.dart';
import 'sidedrawer.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late BuildContext ctx;
  String owner_type = "";
  bool loaded = true;
  String setLocation = "";
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  List<dynamic> resultList = [];
  List<dynamic> FillterList = [];

  List<String> imageList = [
    // "assets/img1.png",
    // "assets/img1.png",
    // "assets/home.png",
  ];

  void checkownertype() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    owner_type = sp.getString("user_type") != null
        ? sp.getString("user_type")!
        : "UNKNOWN";
    print('${owner_type}dagv');

    setState(() {
      owner_type = owner_type;
    });
  }

  int pageIndex = 0;

  void viewallhostels() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    // sp.getString('location_id').toString();
    var deviceState = await OneSignal.shared.getDeviceState();
    var playerId = deviceState!.userId!;

    setState(() {
      loaded = false;
    });
    var dio = Dio();
    var formData = FormData.fromMap({
      'user_id': sp.getString('user_id').toString(),
      'player_id': playerId.toString(),
      'location_id': sp.getString('location_id').toString(),
      'latitude': sp.getString('lat').toString(),
      'longitude': sp.getString('lng').toString(),
    });
    var response = await dio.post(viewAllHostelsUrl(), data: formData);
    var res = response.data;
    print(res);
    setState(() {
      loaded = true;
    });
    imageList = [];
    for (int i = 0; i < res['sliders'].length; i++) {
      imageList.add(res['sliders'][i]['img_path']);
    }
    print(res['location']);
    print(sp.getString('location_id').toString());
    print(sp.getString('lat').toString());
    print(sp.getString('lng').toString());
    setState(() {
      setLocation = res['location'].toString();
    });

    if (res['error'] == false) {
      imageList = imageList;
      resultList = res['hostel'];
      FillterList = resultList;
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

  @override
  void initState() {
    // TODO: implement initState
    checkConnectivity();
    checkownertype();
    viewallhostels();
    super.initState();
  }

  DateTime? currentBackPressTime;

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
                          MaterialPageRoute(builder: (context) => Home()));
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
  Widget build(BuildContext context) {
    ctx = context;
    return WillPopScope(
      onWillPop: () async {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              // title: Text(
              //   "Error",
              //   style: TextStyle(color: Colors.red),
              // ),
              content: Text("Do you want to exist application?"),
              actions: [
                TextButton(
                    onPressed: () => SystemNavigator.pop(), child: Text("Yes")),
                TextButton(
                    onPressed: () => Navigator.pop(ctx), child: Text("No")),
              ],
            );
          },
        );
        return false;
        // DateTime now = DateTime.now();
        // if (currentBackPressTime == null ||
        //     now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
        //   currentBackPressTime = now;
        //   SnackBar sn = SnackBar(content: Text("Press back again to exit"), duration: Duration(milliseconds: 500),);
        //   ScaffoldMessenger.of(context).showSnackBar(sn);
        //   return Future.value(false);
        // }
        // else{
        //   SystemNavigator.pop();
        //   return Future.value(true);
        // }
      },
      child: Scaffold(
        drawer: navbar(ctx, scaffoldState, owner_type),
        key: scaffoldState,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(0xff21488c),
          leading: InkWell(
            onTap: () {
              scaffoldState.currentState?.openDrawer();
            },
            child: Padding(
              padding: EdgeInsets.all(Dim().d14),
              child: SvgPicture.asset(
                'assets/menu.svg',
                fit: BoxFit.contain,
                height: Dim().d16,
                width: Dim().d16,
              ),
            ),
          ),
          title: Image.asset('assets/homelogo.jpg', height: Dim().d36),
          // Wrap(
          //   children: [
          //     Text(
          //       setLocation.isNotEmpty ? setLocation.toString() + " " : '',
          //       style: Sty().largeText.copyWith(
          //             color: Colors.white,
          //             fontWeight: FontWeight.w400,
          //             fontSize: 22,
          //           ),
          //     ),
          //     Container(
          //         child: GestureDetector(
          //         onTap:(){
          //           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SelectLocation()));
          //     },
          //           child: SvgPicture.asset('assets/pen.svg')))
          //   ],
          // ),
          actions: [
            InkWell(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => SelectLocation()));
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SvgPicture.asset('assets/location.svg', height: Dim().d20),
                    SizedBox(width: Dim().d8),
                    SizedBox(
                      width: Dim().d80,
                      child: Text(
                        setLocation.isNotEmpty
                            ? setLocation.toString() + " "
                            : '',
                        overflow: TextOverflow.ellipsis,
                        style: Sty().mediumText.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Container(child: GestureDetector(
            //   onTap: (){
            //     Share.share('Download Quick room service app\n\n\nhttps://play.google.com/store/apps/details?id=com.app.quick_room_services');
            //   },
            //   child: Icon(Icons.share)),),
            // SizedBox(width: 10,),
            // owner_type == "2" ? Container(
            //   margin: EdgeInsets.only(right: Dim().d12),
            //   child: GestureDetector(
            //     onTap: () {
            //       STM().redirect2page(ctx, MyHostel());
            //     },
            //     child: SvgPicture.asset(
            //       'assets/hostel.svg',
            //     ),
            //   ),
            // ) : InkWell(
            //   onTap: () async {
            //     SharedPreferences sp = await SharedPreferences.getInstance();
            //     sp.setBool("isLoggedIn", false);
            //     sp.setString("user_id", '');
            //     sp.setString("user_type", '');
            //     sp.setString("user_name", '');
            //     sp.setString("user_phone", '');
            //     Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => SignIn()), (route) => false);
            //   },
            //   child: Container(
            //     child: Row(
            //       children: [
            //         Icon(Icons.logout_outlined,
            //         // style: Sty().mediumBoldText.copyWith(
            //         //   color: Clr().white,
            //         //   fontWeight: FontWeight.w600,
            //         //   fontSize: Dim().d20,
            //         // )
            //         )
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
        body: loaded
            ? UpgradeAlert(
                upgrader: Upgrader(dialogStyle: UpgradeDialogStyle.material),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(Dim().d12),
                  child: Column(
                    children: [
                      // SizedBox(height: 0),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Center(
                      //       child: Container(
                      //         margin: EdgeInsets.only(right: 8),
                      //         child: Text(
                      //           'Want to list your Hostel?',
                      //           style: Sty().mediumText.copyWith(
                      //                 fontSize: 18,
                      //               ),
                      //         ),
                      //       ),
                      //     ),
                      //     SizedBox(
                      //       height: 40,
                      //       width: 100,
                      //       child: ElevatedButton(
                      //           style: Sty().primaryButton,
                      //           onPressed: () {},
                      //           child: Text(
                      //             'Tap Here',
                      //             style: Sty().mediumText.copyWith(
                      //                   color: Clr().white,
                      //                 ),
                      //           )),
                      //     ),
                      //   ],
                      // ),
                      owner_type == "2"
                          ? Container()
                          : Row(
                              children: [
                                Expanded(
                                  child: Material(
                                    shadowColor: Clr().grey.withOpacity(0.4),
                                    elevation: 3.0,
                                    borderRadius:
                                        BorderRadius.circular(Dim().d20),
                                    child: TextFormField(
                                      decoration: Sty()
                                          .TextFormFieldOutlineStyleWithHome
                                          .copyWith(
                                            hintText: 'Search Place, home,',
                                            suffixIcon: Padding(
                                              padding:
                                                  EdgeInsets.all(Dim().d16),
                                              child: const Icon(Icons.search,
                                                  color: Color(0xFF343E42)),
                                            ),
                                          ),
                                      onChanged: searchresult,
                                    ),
                                  ),
                                ),
                                SizedBox(width: Dim().d20),
                                PopupMenuButton(
                                  // ignore: sort_child_properties_last
                                  child: SvgPicture.asset(
                                      'assets/filterhome.svg',
                                      height: Dim().d52),
                                  color: Color(0xff333741),
                                  offset: Offset(-40, 19),
                                  itemBuilder: (context) {
                                    return [
                                      PopupMenuItem(
                                        child: Text(
                                          'Boys Hostel',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'NotoSansTaiTham',
                                              color: Colors.white),
                                        ),
                                        onTap: () {
                                          getSearchList('Boys Hostel');
                                        },
                                      ),
                                      PopupMenuItem(
                                        child: Text(
                                          'Girls Room',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'NotoSansTaiTham',
                                              color: Colors.white),
                                        ),
                                        onTap: () {
                                          getSearchList('Girls Room');
                                        },
                                      ),
                                    ];
                                  },
                                ),
                              ],
                            ),
                      SizedBox(height: Dim().d20),
                      Column(
                        children: [
                          CarouselSlider(
                            options: CarouselOptions(
                              viewportFraction: 1,
                              enlargeCenterPage: true,
                              enableInfiniteScroll: true,
                              autoPlay: true,
                              aspectRatio: 2.0,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  pageIndex = index;
                                });
                              },
                            ),
                            items: imageList
                                .map((e) => ClipRRect(
                                      // borderRadius: BorderRadius.circular(10),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: <Widget>[
                                          CachedNetworkImage(
                                            imageUrl: mainDomain() + e,
                                            width: 1200,
                                            height: 300,
                                            fit: BoxFit.cover,
                                            //                       placeholder:Row(
                                            //   mainAxisAlignment: MainAxisAlignment.center,
                                            //   children: [
                                            //     CircularProgressIndicator(),
                                            //   ],
                                            // ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                          SizedBox(
                            height: Dim().d16,
                          ),
                          CarouselIndicator(
                            height: 8.0,
                            width: 8.0,
                            cornerRadius: 100.0,
                            activeColor: Clr().black,
                            index: pageIndex,
                            count: imageList.length,
                            color: Clr().grey,
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
                          //         shape:BoxShape.circle,
                          //         color: Clr().primaryColor,
                          //       ),
                          //     );
                          //   }).toList(),
                          // ),
                          SizedBox(height: 12),
                          (FillterList.length > 0)
                              ? GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisExtent: 225,
                                  ),
                                  // itemCount: resultList.length,
                                  itemCount: FillterList.length,
                                  itemBuilder: (context, index) {
                                    return itemLayout(
                                        context, index, FillterList);
                                  },
                                )
                              : Container(
                                  margin: EdgeInsets.only(top: 150),
                                  child: Center(
                                      child: Text("No Data Found",
                                          style: TextStyle(
                                              color: Clr().blue,
                                              fontSize: 24)))),
                        ],
                      )
                    ],
                  ),
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  //Item
  Widget itemLayout(context, index, list) {
    return InkWell(
      onTap: () {
        STM().redirect2page(
            ctx,
            Details(
                hostel_id: list[index]['id'].toString(),
                hostelName: list[index]['name'].toString(),
                hostelAddress: list[index]['address'].toString(),
                ownerName: list[index]['owner_name'].toString(),
                ownerNumber: list[index]['owner_number'].toString(),
                alternateNumber: list[index]['alt_number'].toString(),
                ownerEmail: list[index]['email'].toString(),
                hostelTelephoneNumber: list[index]['tel_number'].toString(),
                hostelType: list[index]['hostel_type'].toString(),
                vacancyCountAvailable: list[index]['vancany'].toString(),
                extraCharges: list[index]['extra_charge'].toString(),
                gateClosingTime: list[index]['close_time'].toString(),
                monthly_charge: list[index]['monthly_charge'].toString(),
                facility: list[index]['facility'].toString(),
                conditions: list[index]['condition'].toString(),
                lat: list[index]['latitude'].toString(),
                long: list[index]['longitude'].toString()));
      },
      child: Card(
        margin: const EdgeInsets.all(4),
        child: Column(
          children: [
            list[index]['image_path'] != null
                ? CachedNetworkImage(
                    imageUrl: list[index]['image_path'].toString(),
                    height: 130,
                    placeholder: (context, url) => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [CircularProgressIndicator()]),
                  )
                : Icon(
                    Icons.broken_image,
                    size: 130,
                  ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dim().d8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 7,
                  ),
                  Text(
                    list[index]['name'].toString(),
                    textAlign: TextAlign.left,
                    style: Sty().mediumText.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    list[index]["hostel_type"].toString() +
                        '  \u20b9' +
                        list[index]['monthly_charge'].toString() +
                        '/month',
                    textAlign: TextAlign.start,
                    style: Sty().mediumText.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    list[index]['address'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Sty().mediumText.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void searchresult(String value) {
    if (value.isEmpty) {
      setState(() {
        FillterList = resultList;
      });
    } else {
      setState(() {
        FillterList = resultList.where((element) {
          final resultTitle = element['name'].toLowerCase();
          final input = value.toLowerCase();
          return resultTitle
              .toString()
              .toLowerCase()
              .startsWith(input.toString().toLowerCase());
        }).toList();
      });
    }
  }

  void getSearchList(type) async {
    FormData body = FormData.fromMap({
      'hostel_type': type,
    });
    var result = await STM().post(ctx, Str().loading, 'search', body);
    var success = result['error'];
    var message = result['message'];
    if (success) {
      setState(() {
        resultList = result['hostel'];
        FillterList = resultList;
      });
    } else {
      STM().errorDialog(ctx, message);
    }
  }
}
