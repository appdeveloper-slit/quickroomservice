import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quick_room_services/manage/static_method.dart';
import 'package:quick_room_services/sign_in.dart';
import 'package:quick_room_services/values/dimens.dart';
import 'package:quick_room_services/values/global_urls.dart';
import 'package:quick_room_services/values/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'add_hostel.dart';
import 'values/colors.dart';

class MyHostel extends StatefulWidget {
  const MyHostel({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyHostelWidget();
  }
}

class MyHostelWidget extends State with SingleTickerProviderStateMixin {
  late BuildContext ctx;
  List<String> tabList = ['Hostel', 'Leads'];
  int selectedTab = 0;
  List<String> imageList = ['assets/home.png'];
  var resultList = [];
  var leadResultList = [];
  bool loaded = true;
  int initialIndex = 0;
  void getHostelsAndLeads() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    // sp.getString('location_id').toString();
    setState(() {
      loaded = false;
    });
    var dio = Dio();
    var formData = FormData.fromMap({
      'user_id': sp.getString('user_id').toString(),
    });
    var response = await dio.post(getUserHostel(), data: formData);
    var hostelres = response.data;
    print("GET HOSTELS");
    print(hostelres);
    var formData2 = FormData.fromMap({
      'user_id': sp.getString('user_id').toString(),
    });
    var leadresponse = await dio.post(getUserLead(), data: formData2);
    var leadres = leadresponse.data;
    print("GET LEADS");
    print(leadres);

    setState(() {
      loaded = true;
      resultList = hostelres['hostel'];
      leadResultList = leadres['leads'];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getHostelsAndLeads();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: selectedTab == 0
            ? FloatingActionButton(
                onPressed: () {
                  STM().redirect2page(ctx, Add(false, "0"));
                },
                child: Icon(Icons.add),
                backgroundColor: const Color(0xff21488c))
            : null,
        appBar: AppBar(
          backgroundColor: const Color(0xff21488c),
          leading: InkWell(
              onTap: () {
                STM().back2Previous(ctx);
              },
              child: const Icon(Icons.arrow_back_ios)),
          centerTitle: true,
          title: Text(
            initialIndex == 0 ? 'My Hostel' : 'My Leads',
            style: Sty().largeText.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 22,
                ),
          ),
        ),
        body: Column(
          children: [
            loaded
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: Dim().d20),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Clr().grey))
                      ),
                      child: TabBar(
                          unselectedLabelColor: Color(0xff21488C).withOpacity(0.5),
                          labelColor: Color(0xff21488C),
                          unselectedLabelStyle: TextStyle(color: Clr().grey),
                          onTap: (value){
                            setState(() {
                              initialIndex = value;
                            });
                          },
                          physics: BouncingScrollPhysics(),
                          tabs: const [
                            Tab(text: 'Hostel'),
                            Tab(text: 'Leads'),
                          ]),
                    ),
                  )
                : Container(),
            SizedBox(height: Dim().d28),
            loaded
                ? Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: Dim().d20),
                      child: TabBarView(children: [
                      resultList.length > 0
                          ? ListView.builder(
                              shrinkWrap: true,
                              // itemCount: resultList.length,
                              itemCount: resultList.length,
                              itemBuilder: (context, index) {
                                return itemHostelLayout(ctx, index, resultList);
                              },
                            )
                          : Center(
                              child: Text(
                                "No Data Found",
                                style: TextStyle(color: Clr().blue, fontSize: 24),
                              ),
                            ),
                      leadResultList.length > 0
                          ? ListView.builder(
                              shrinkWrap: true,
                              // itemCount: resultList.length,
                              itemCount: leadResultList.length,
                              itemBuilder: (context, index) {
                                return itemLeadLayout(ctx, index, leadResultList);
                              },
                            )
                          : Center(
                              child: Text(
                                "No Data Found",
                                style: TextStyle(color: Clr().blue, fontSize: 24),
                              ),
                            )
                  ]),
                    ))
                : Expanded(
                    child: Column(
                    children: [
                      Center(child: CircularProgressIndicator()),
                    ],
                  )),
            // SizedBox(height: 12,),
            InkWell(
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Dim().d12)),
                        insetPadding:
                            EdgeInsets.symmetric(horizontal: Dim().d16),
                        title: Image.asset('assets/exit.jpg',
                            height: Dim().d220, width: Dim().d350),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: InkWell(onTap:(){
                                  STM().back2Previous(ctx);
                                },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(Dim().d12),
                                        border: Border.all(
                                            color: Clr().primaryColor)),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: Dim().d12),
                                      child: Center(
                                        child: Text('Cancel',
                                            style: Sty().mediumText.copyWith(
                                                color: Clr().primaryColor)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: Dim().d12),
                              Expanded(
                                child: InkWell(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(Dim().d12),
                                        border: Border.all(
                                            color: Clr().primaryColor)),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: Dim().d12),
                                      child: Center(
                                        child: Text('ok',
                                            style: Sty().mediumText.copyWith(
                                                color: Clr().primaryColor)),
                                      ),
                                    ),
                                  ),
                                  onTap: () async {
                                    SharedPreferences sp =
                                        await SharedPreferences.getInstance();
                                    sp.clear();
                                    STM().finishAffinity(context, SignIn());
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: Dim().d20,
                          ),
                        ],
                      );
                    });
              },
              child: Center(
                child: Container(
                  child: Column(
                    children: [
                      Text('Log Out',
                          style: Sty().mediumBoldText.copyWith(
                                color: Clr().primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: Dim().d20,
                              ))
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            //
          ],
        ),
      ),
    );
  }

  //Item
  Widget itemLayout(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(Dim().d12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: selectedTab == index ? Clr().primaryColor : Colors.white,
                width: 2),
          ),
        ),
        child: Text(
          tabList[index],
          style: Sty().mediumText.copyWith(
                color: selectedTab == index ? Clr().primaryColor : Colors.grey,
              ),
        ),
      ),
    );
  }

  //Hostel Item
  Widget itemHostelLayout(ctx, index, list) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.all(Dim().d8),
      child: Padding(
        padding: EdgeInsets.all(Dim().d8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                list[index]['image_path'] != null
                    ? Container(
                        child: CachedNetworkImage(
                            imageUrl: list[index]['image_path'],
                            placeholder: (context, url) => Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [CircularProgressIndicator()],
                                ),
                            fit: BoxFit.cover,
                            width: 130,
                            height: 100))
                    : Icon(
                        Icons.broken_image,
                        size: 100,
                      ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list[index]['name'],
                        style: Sty().mediumText.copyWith(
                              fontSize: 18,
                            ),
                      ),
                      SizedBox(height: Dim().d4),
                      Text(
                        list[index]['hostel_type'],
                        style: Sty().mediumText.copyWith(
                              fontSize: Dim().d16,
                            ),
                      ),
                      SizedBox(height: Dim().d4),
                      Text(
                        list[index]['address'],
                        maxLines: 2,
                        style: Sty().mediumText.copyWith(
                              fontSize: 14,
                            ),
                      ),
                      SizedBox(height: Dim().d4),
                      // list[index]['status'] != 0
                      //     ? Text(
                      //         "Active",
                      //         style: TextStyle(
                      //           color: Colors.green,
                      //           fontSize: 14,
                      //         ),
                      //       )
                      //     : Text(
                      //         "Inactive",
                      //         style: TextStyle(
                      //           color: Colors.red,
                      //           fontSize: 14,
                      //         ),
                      //       ),
                      Text(
                        "Views: ${list[index]['count'] ?? 0}",
                        style: Sty().mediumText.copyWith(fontSize: Dim().d14),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        _showSuccessDialog(ctx, list[index]['id'].toString());
                      },
                      child: SvgPicture.asset('assets/delete.svg'),
                    ),
                    SizedBox(
                      height: Dim().d16,
                    ),
                    if (list[index]['status'] != 0)
                      InkWell(
                        onTap: () {
                          STM().redirect2page(
                              context, Add(true, list[index]['id'].toString()));
                        },
                        child: Icon(Icons.edit_outlined),
                      ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  //Lead Item
  Widget itemLeadLayout(ctx, index, list) {
    return Card(
        elevation: 3,
        margin: EdgeInsets.all(Dim().d8),
        child: Padding(
          padding: EdgeInsets.all(Dim().d12),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    list[index]['name'],
                    style: Sty().mediumText.copyWith(
                          fontSize: Dim().d20,
                        ),
                  ),
                  SizedBox(height: Dim().d8),
                  Text(
                    'For : ' + list[index]['hostel_name'],
                    style: Sty().mediumText.copyWith(
                          fontSize: 14,
                        ),
                  ),
                  SizedBox(height: Dim().d8),
                  Text(
                    'Mobile: ' + list[index]['phone'],
                    style: Sty().mediumText.copyWith(
                          fontSize: 14,
                        ),
                  ),
                ],
              )),
              Container(
                height: Dim().d100,
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(list[index]['created_at'].toString()),
                    InkWell(
                        onTap: () async {
                          var url = "tel:" + list[index]['phone'].toString();
                          if (await canLaunchUrlString(url)) {
                            await launchUrlString(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                        child: SvgPicture.asset('assets/call.svg')),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  _showSuccessDialog(ctx, String id) async {
    AwesomeDialog(
      context: ctx,
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.BOTTOMSLIDE,
      title: 'Are you sure you want to delete ?',
      // desc: 'Dialog description here.............',
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        var dio = Dio();
        var formData = FormData.fromMap({
          'id': id,
        });
        var response = await dio.post(deleteHostelUrl(), data: formData);
        var res = response.data;
        print(res);

        getHostelsAndLeads();
      },
    )..show();
  }
}
