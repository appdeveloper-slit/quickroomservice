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

class ReviewPage extends StatefulWidget {
  final String? hostelId;

  const ReviewPage({Key? key, this.hostelId}) : super(key: key);

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late BuildContext ctx;
  List percentList = [];

  List<dynamic> reviewList = [];
  var averageRate;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      getReview();
    });
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
                      STM().redirect2page(ctx, WriteReview(hostelid: widget.hostelId));
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
            SizedBox(width: Dim().d8),
            Column(
              children: [
                Wrap(
                  children: [
                    Text(
                      '${averageRate}',
                      style: Sty().extraLargeText,
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
                      .copyWith(color: Color(0xff000000).withOpacity(0.2)),
                )
              ],
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
                            style: Sty().largeText,
                          ),
                        ),
                        RatingBar.builder(
                          initialRating: double.parse(reviewList[index]['rating'].toString()),
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
                    Text('${reviewList[index]['review'].toString()}', style: Sty().mediumText)
                  ],
                ),
              );
            }),
      ],
    );
  }

// get Review
  void getReview() async {
    FormData body = FormData.fromMap({
      'hostel_id': widget.hostelId,
    });
    var result = await STM().post(ctx, Str().loading, 'show_review', body);
    setState(() {
      reviewList = result['review'];
      averageRate = result['review_avg'];
      percentList = result['review_summary'];
    });
  }
}
