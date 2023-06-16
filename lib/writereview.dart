import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:quick_room_services/manage/static_method.dart';
import 'package:quick_room_services/reviewpage.dart';
import 'package:quick_room_services/values/colors.dart';
import 'package:quick_room_services/values/dimens.dart';
import 'package:quick_room_services/values/strings.dart';
import 'package:quick_room_services/values/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WriteReview extends StatefulWidget {
  final String? hostelid;
  const WriteReview({Key? key,this.hostelid}) : super(key: key);

  @override
  State<WriteReview> createState() => _WriteReviewState();
}

class _WriteReviewState extends State<WriteReview> {
  late BuildContext ctx;
  String? sUserid;
  TextEditingController reviewCtrl = TextEditingController();
  double? rating;
  getSession() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      sUserid = sp.getString('user_id') ?? "";
    });
    STM().checkInternet(context, widget).then((value) {
      if (value) {

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
    return Scaffold(
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Dim().d28),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Score:',style: Sty().mediumBoldText.copyWith(fontWeight: FontWeight.w400,fontSize: Dim().d20)),
            ),
            SizedBox(height: Dim().d14),
            RatingBar.builder(
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: Dim().d36,
              unratedColor: Color(0xff7F7A7A),
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rate) {
                // print(rating);
                setState(() {
                  rating = rate;
                });
              },
            ),
            SizedBox(height: Dim().d36),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Review:',style: Sty().mediumBoldText.copyWith(fontWeight: FontWeight.w400,fontSize: Dim().d20)),
            ),
            SizedBox(height: Dim().d14),
            TextField(
              maxLines: 5,
              controller: reviewCtrl,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: Sty().TextFormFieldOutlineStyle.copyWith(
                fillColor: Color(0xffD9D9D9).withOpacity(0.4),
                filled: true,
              ),
            ),
            SizedBox(height: Dim().d24),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 50,
                width: Dim().d180,
                child: ElevatedButton(
                  onPressed: () async {
                    addReview();
                  },
                  style: Sty().primaryButton,
                  child: Center(
                    child: Text(
                      'Submit',
                      style: Sty().mediumText.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // add review

void addReview() async {
    FormData body = FormData.fromMap({
      'user_id': sUserid,
      'hostel_id': widget.hostelid,
      'review': reviewCtrl.text,
      'rating': rating,
    });
    var result = await STM().post(ctx, Str().processing, 'add_review', body);
    var success = result['success'];
    var message = result['message'];
    if(success){
      STM().successDialogWithReplace(ctx, message, ReviewPage(hostelId: widget.hostelid));
    }else{
      STM().errorDialog(ctx, message);
    }
}

}
