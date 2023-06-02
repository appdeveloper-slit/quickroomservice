import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quick_room_services/home.dart';
import 'package:quick_room_services/manage/static_method.dart';
import 'package:quick_room_services/values/colors.dart';
import 'package:quick_room_services/values/dimens.dart';
import 'package:quick_room_services/values/global_urls.dart';
import 'package:quick_room_services/values/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectLocation extends StatefulWidget {
  const SelectLocation({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SelectLocationWidget();
  }
}

class SelectLocationWidget extends State {
  late BuildContext ctx;
  String selectedValue = '';
  List arrayList = [];
  AwesomeDialog? dialog;
  // List<String> location_ids = [];
  // String v = "0";
  bool loaded = true;
  late Position position;

  void setLocationNameAndId(String location_id) async {
    // String location_name, 
    SharedPreferences sp = await SharedPreferences.getInstance();
    // sp.setString('location_name', location_name.toString());
    sp.setString('location_id', location_id.toString());
    // sp.setString('show_location_name',2 location)
    // print("SET LOCATION: " + sp.getString('location_name').toString());
    print("SET LOCATION ID: " + sp.getString('location_id').toString());
  }

  void getLocations() async {
    setState(() {
      loaded = false;
    });
    var dio = Dio();
    // var formData = FormData.fromMap({
    // });
    var response = await dio.get(getLocationsUrl());
    var res = response.data;
    print(res);

    if(res['locations'].length > 0){
      arrayList = [];
      for (int i = 0; i < res['locations'].length; i++){
        arrayList.add([res['locations'][i]['id'].toString(), res['locations'][i]['name'].toString()]);
      }
      selectedValue = res['locations'][0]['id'].toString();

      setLocationNameAndId(res['locations'][0]['id'].toString());
      // , res['locations'][0]['id'].toString()
    }
    else{
      arrayList.add(['0', 'No value']);
    }
    setState(() {
      arrayList = arrayList;
      selectedValue = selectedValue;
      loaded = true;
    });
  }

  void initState(){
    Geolocator.requestPermission();
    getLocations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return WillPopScope(onWillPop: ()async{
      STM().finishAffinity(ctx, Home());
      return false;
    },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff21488c),
          leading: InkWell(onTap: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
          },
              child: Icon(Icons.arrow_back_ios)),
          centerTitle: true,
          title: Text('Select Location'),
        ),
        body: loaded ? Padding(
          padding: EdgeInsets.all(Dim().d32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkWell(onTap: (){
                permissionHandle();
              },
                child: Container(
                  height: Dim().d52,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Clr().lightGrey),
                    borderRadius: BorderRadius.all(Radius.circular(Dim().d12))
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: Dim().d20),
                      SvgPicture.asset('assets/gps.svg'),
                      SizedBox(width: Dim().d20),
                      Text("Pick current location",style: Sty().mediumText.copyWith(color: Clr().primaryColor)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Dim().d56),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    border: Border.all(
                  color: Colors.black87,
                )),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedValue,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down),
                    style: TextStyle(color: Color(0xff000000)),
                    items: arrayList.map((val) {
                      return DropdownMenuItem<String>(
                        value: val[0],
                        child: Text(val[1]),
                      );
                    }).toList(),
                    onChanged: (v) async {
                      SharedPreferences sp = await SharedPreferences.getInstance();
                      setState(() {
                        selectedValue = v!;
                        print(selectedValue);
                        setLocationNameAndId(selectedValue.toString());
                        sp.remove('lat');
                        sp.remove('lng');
                      });
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
                    },
                  ),
                ),
              ),
            ],
          ),
        ) : Center(child: CircularProgressIndicator(),),
      ),
    );
  }

  Future<void> permissionHandle() async {
    LocationPermission permission = await Geolocator.requestPermission();
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      getLocation();
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      STM().displayToast('Location permission is required');
      await Geolocator.openAppSettings();
    }
  }

  // getLocation
  getLocation() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    LocationPermission permission = await Geolocator.requestPermission();
    dialog = STM().loadingDialog(ctx, 'Fetch location');
    dialog!.show();
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((Position position)  {
      setState(()  {
        STM().displayToast('Current location is selected');
        sp.setString('lat', position.latitude.toString());
        sp.setString('lng', position.longitude.toString());
        dialog!.dismiss();
        sp.remove('location_id');
        STM().finishAffinity(ctx, Home());
      });
    }).catchError((e){
      dialog!.dismiss();
    });
  }

}
