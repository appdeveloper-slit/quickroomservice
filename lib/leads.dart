import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quick_room_services/values/dimens.dart';
import 'package:quick_room_services/values/styles.dart';

class MyApp extends StatelessWidget {
  late BuildContext ctx;

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add),
          backgroundColor: Color(0xff21488c)),
      appBar: AppBar(
        backgroundColor: Color(0xff21488c),
        leading: Icon(Icons.arrow_back_ios),
        centerTitle: true,
        title: Text(
          'My Hostel',
          style: Sty().largeText.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(Dim().d16),
        children: [
          Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(padding: EdgeInsets.all(4)),
                    Text('18 May, 2022 '),
                    Row(
                      children: [
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Prashant Sharma',
                                  style: Sty().mediumText.copyWith(
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  'For : Aniket Hostel',
                                  style: Sty().mediumText.copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Mobile: 9632587414',
                                  style: Sty().mediumText.copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            )),
                        SvgPicture.asset('assets/call.svg')
                      ],
                    )
                  ],
                ),
              )),
          SizedBox(
            height: 8,
          ),
          Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(padding: EdgeInsets.all(4)),
                    Text('18 May, 2022 '),
                    Row(
                      children: [
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Prashant Sharma',
                                  style: Sty().mediumText.copyWith(
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  'For : Aniket Hostel',
                                  style: Sty().mediumText.copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Mobile: 9632587414',
                                  style: Sty().mediumText.copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            )),
                        SvgPicture.asset('assets/call.svg')
                      ],
                    )
                  ],
                ),
              )),
          SizedBox(
            height: 8,
          ),
          Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(padding: EdgeInsets.all(4)),
                    Text('18 May, 2022 '),
                    Row(
                      children: [
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Prashant Sharma',
                                  style: Sty().mediumText.copyWith(
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  'For : Aniket Hostel',
                                  style: Sty().mediumText.copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Mobile: 9632587414',
                                  style: Sty().mediumText.copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            )),
                        SvgPicture.asset('assets/call.svg')
                      ],
                    )
                  ],
                ),
              )),
          SizedBox(
            height: 8,
          ),
          Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(padding: EdgeInsets.all(4)),
                    Text('18 May, 2022 '),
                    Row(
                      children: [
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Prashant Sharma',
                                  style: Sty().mediumText.copyWith(
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  'For : Aniket Hostel',
                                  style: Sty().mediumText.copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Mobile: 9632587414',
                                  style: Sty().mediumText.copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            )),
                        SvgPicture.asset('assets/call.svg')
                      ],
                    )
                  ],
                ),
              )),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Log Out',
                style: Sty().mediumText.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff21488c),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
