import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:quick_room_services/manage/static_method.dart';
import 'package:quick_room_services/values/colors.dart';
import 'package:quick_room_services/values/dimens.dart';
import 'package:quick_room_services/values/strings.dart';
import 'package:quick_room_services/values/styles.dart';
import 'package:quick_room_services/writereview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewPage extends StatefulWidget {
  final String? hostelId;

  const ReviewPage({Key? key, this.hostelId}) : super(key: key);

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late BuildContext ctx;
  List percentList = [];
  String? userId;
  String owner_type = "";
  List<dynamic> reviewList = [];
  var averageRate;
  int? ownerID;

  getSession() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      userId = sp.getString('user_id').toString() ?? '';
    });
    STM().checkInternet(context, widget).then((value) {
      if (value) {
        getReview();
        checkownertype();
        print(userId);
      }
    });
  }


  @override
  void initState() {
    getSession();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return WillPopScope(
      onWillPop: () async{
        STM().back2Previous(ctx);
        return false;
      },
      child: Scaffold(
          backgroundColor: Clr().white,
          appBar: AppBar(
            backgroundColor: Color(0xff21488c),
            leading: InkWell(
                onTap: () {
                  STM().back2Previous(ctx);
                },
                child: const Icon(Icons.arrow_back_ios_new)),
            centerTitle: true,
            title: const Text(
              'Ratings & Reviews',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dim().d14),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: Dim().d56),
                  summaryLayout(),
                  // write review and click go to write
                  InkWell(
                    onTap: () {
                      STM().replacePage(ctx, WriteReview(hostelid: widget.hostelId));
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xff21488C)),
                        borderRadius: BorderRadius.circular(Dim().d8),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: Dim().d14),
                        child: Center(
                          child: Text(
                            'Write a review',
                            style: Sty()
                                .mediumText
                                .copyWith(color: Color(0xff21488C)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  reviewLayout(),
                ],
              ),
            ),
          )),
    );
  }

  // Summary part below
  Widget summaryLayout() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Summary',
              style: Sty()
                  .mediumBoldText
                  .copyWith(fontSize: Dim().d24, fontWeight: FontWeight.w400)),
        ),
        SizedBox(height: Dim().d16),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: ListView.builder(
                  itemCount: percentList.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: Dim().d12),
                      child: Row(
                        children: [
                          Text('${percentList[index]['text']}',
                              style: Sty().mediumText),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: Dim().d12),
                            child: LinearPercentIndicator(
                              width: Dim().d220,
                              animation: true,
                              lineHeight: 8.0,
                              animationDuration: 2500,
                              percent: percentList[index]['percent'] / 100,
                              linearStrokeCap: LinearStrokeCap.roundAll,
                              progressColor: Colors.yellow[700],
                              barRadius: Radius.circular(Dim().d4),
                              backgroundColor: Color(0xff000000).withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
            Expanded(
              flex: 1,
              child: SizedBox(
                child: Column(
                  children: [
                    Wrap(
                      children: [
                        Text(
                          '${averageRate}',
                          style: Sty().mediumText,
                        ),
                        RatingBar.builder(
                          initialRating: 1,
                          minRating: 1,
                          direction: Axis.horizontal,
                          ignoreGestures: true,
                          allowHalfRating: true,
                          itemCount: 1,
                          itemSize: Dim().d16,
                          unratedColor: Color(0xff7F7A7A),
                          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rate) {
                            // print(rating);
                            // setState(() {
                            //   rating = rate;
                            // });
                          },
                        ),
                      ],
                    ),
                    Text(
                      '${reviewList.length} Reviews',
                      style: Sty()
                          .mediumText
                          .copyWith(color: Color(0xff000000).withOpacity(0.2),fontSize: Dim().d12),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
        SizedBox(height: Dim().d12),
      ],
    );
  }

// review part below
  Widget reviewLayout() {
    return Column(
      children: [
        SizedBox(height: Dim().d16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Review', style: Sty().mediumBoldText),
        ),
        SizedBox(height: Dim().d20),
        ListView.builder(
            itemCount: reviewList.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              print(reviewList[index]['user_id']);
              return Padding(
                padding: EdgeInsets.only(bottom: Dim().d20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${reviewList[index]['user']['name']}',
                            style: Sty().mediumBoldText.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                        RatingBar.builder(
                          initialRating: reviewList[index]['rating'] == null ? 0.0 : double.parse(reviewList[index]['rating'].toString()),
                          direction: Axis.horizontal,
                          ignoreGestures: true,
                          itemCount: 5,
                          itemSize: Dim().d16,
                          unratedColor: const Color(0xff7F7A7A),
                          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rate) {
                            // print(rating);
                            // setState(() {
                            //   rating = rate;
                            // });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: Dim().d16),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: Text('${reviewList[index]['review'].toString()}', style: Sty().mediumText.copyWith(fontWeight: FontWeight.w300,fontSize: Dim().d14))),
                        ownerID == int.parse(userId.toString()) ?  InkWell(onTap: (){
                          deleteReview(reviewList[index]['id']);
                        },child: Icon(Icons.delete,color: Clr().primaryColor,size: 20.00,)) : reviewList[index]['user_id'] == int.parse(userId.toString()) ?  InkWell(onTap: (){
                          deleteReview(reviewList[index]['id']);
                        },child: Icon(Icons.delete,color: Clr().primaryColor,size: 20.00,)) : Container()
                      ],
                    )
                  ],
                ),
              );
            }),
      ],
    );
  }

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

   deletedIcon(userid,index,id) {
    if(ownerID == int.parse(userId.toString()) && userid == reviewList[index]['user_id']){
      InkWell(onTap: (){
        deleteReview(id);
      },child: Icon(Icons.delete,color: Clr().primaryColor,size: 20.00,));
    }else{
      Container();
    }
  }


// get Review
  void getReview() async {
    FormData body = FormData.fromMap({
      'hostel_id': widget.hostelId,
    });
    var result = await STM().post(ctx, Str().loading, 'show_review', body);
    setState(() {
      reviewList = result['review'];
      ownerID = result['owner_id'];
      print(ownerID);
      averageRate = result['review_avg'];
      percentList = result['review_summary'];
    });
  }

  // get Review
  void deleteReview(id) async {
    FormData body = FormData.fromMap({
      'review_id': id,
    });
    var result = await STM().post(ctx, Str().deleting, 'delete_review', body);
    var success = result['success'];
    var message = result['message'];
    if(success){
      STM().displayToast(message);
      getReview();
    }else{
      STM().errorDialog(ctx, message);
    }
  }
}
