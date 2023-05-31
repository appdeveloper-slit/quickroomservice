import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_crop/multi_image_crop.dart';
import 'package:quick_room_services/home.dart';
import 'package:quick_room_services/manage/static_method.dart';
import 'package:quick_room_services/values/colors.dart';
import 'package:quick_room_services/values/global_urls.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validators/validators.dart';
import 'package:image_picker/image_picker.dart';
import 'my_hostel.dart';
import 'values/styles.dart';

// void main() => runApp(Add());

class Add extends StatefulWidget {
  bool? isThisForUpdate;
  String? hostelID;
  Add(this.isThisForUpdate, this.hostelID);

  @override
  State<StatefulWidget> createState() {
    return AddPage(isThisForUpdate, hostelID);
  }
}

class AddPage extends State<Add> {
  bool? isThisForUpdate;
  String? hostelID;
  AddPage(this.isThisForUpdate, this.hostelID);

  late BuildContext ctx;
  List<String> genderList = [
    "Boys Hostel",
    "Girls Hostel",
    "Boys Room",
    "Girls Room",
    "Flat"
  ];
  String sGender = "Boys Hostel";

  List<String> actionList = ["Yes", "No"];
  String sAction = "Yes";

  List timeList = [
    ["Time", "0"],
    ["No Limit", "1"]
  ];
  String sTime = "0";

  bool loaded = true;
  String latitude = '';
  String longitude = '';

  String locationCapText =
      'Click on the button to capture your current location. You should be at your hostel location';

  String? selectedValue;
  List arrayList = [];

  TextEditingController hostelName = TextEditingController();
  TextEditingController hostelAddress = TextEditingController();
  // TextEditingController selectLocation = TextEditingController();
  TextEditingController ownerName = TextEditingController();
  TextEditingController ownerNumber = TextEditingController();
  TextEditingController alternateNumber = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController telephoneNumber = TextEditingController();
  TextEditingController vacancyInNumber = TextEditingController();
  TextEditingController monthlyCharge = TextEditingController();
  TextEditingController facility = TextEditingController();
  TextEditingController conditions = TextEditingController();
  TextEditingController closeTime = TextEditingController();


  int imageCount = 0;
  List<String> image64Strings = [];
  List<Widget> imagesList = [];

  List<String> allImagesBase64 = [];
  bool imagesChoosen = false;

  Future getLocations() async {
    setState(() {
      loaded = false;
    });
    var dio = Dio();
    // var formData = FormData.fromMap({
    // });
    var response = await dio.get(getLocationsUrl());
    var res = response.data;
    print(res);

    if (res['locations'].length > 0) {
      arrayList = [];
      for (int i = 0; i < res['locations'].length; i++) {
        arrayList.add([
          res['locations'][i]['id'].toString(),
          res['locations'][i]['name'].toString()
        ]);
      }
      selectedValue = res['locations'][0]['id'].toString();
    } else {
      arrayList.add(['0', 'No value']);
    }
    setState(() {
      arrayList = arrayList;
      // selectedValue = selectedValue;
      loaded = true;
    });
  }

  void getLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    print(_locationData.latitude);
    print(_locationData.longitude);
    latitude = _locationData.latitude.toString();
    longitude = _locationData.longitude.toString();

    setState(() {
      locationCapText =
          "latitude: " + latitude + "\n" + "longitude: " + longitude;
    });
  }


  List<dynamic> imageList = [
    ];

  void getAndUpdateImagesOnly() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    // sp.getString('location_id').toString();

    setState(() {
      loaded = false;
    });
    var dio = Dio();
    var formData = FormData.fromMap({
      'hostel_id': hostelID.toString(),
      'user_id': sp.getString('user_id').toString()
    });

    print("HOSTEL ID: " + hostelID.toString());
    print("USER ID: " + sp.getString('user_id').toString());

    var response = await dio.post(getHostelDetails(), data: formData);
    var res = response.data;
    print(res);

    imageList = [];
    for (int i = 0; i < res['hostel']['imgs'].length; i++){
      imageList.add([res['hostel']['imgs'][i]['image_path'].toString(), res['hostel']['imgs'][i]['id'].toString()]);
    }
    setState(() {
      loaded = true;
      imageList = imageList;
    });

  }

  void getHostel() async {
    print("Fetching HOSTEL DETAILS FOR UPDATE");
    SharedPreferences sp = await SharedPreferences.getInstance();
    // sp.getString('location_id').toString();

    setState(() {
      loaded = false;
    });
    var dio = Dio();
    var formData = FormData.fromMap({
      'hostel_id': hostelID.toString(),
      'user_id': sp.getString('user_id').toString()
    });

    print("HOSTEL ID: " + hostelID.toString());
    print("USER ID: " + sp.getString('user_id').toString());

    var response = await dio.post(getHostelDetails(), data: formData);
    var res = response.data;
    print(res);

    imageList = [];
    for (int i = 0; i < res['hostel']['imgs'].length; i++){
      imageList.add([res['hostel']['imgs'][i]['image_path'].toString(), res['hostel']['imgs'][i]['id'].toString()]);
    }
    if(res['error'] != true){

      hostelName.text = res['hostel']['name'].toString();
      print("Updated controllers");
      hostelAddress.text = res['hostel']['address'].toString();
      // locationIdentification
      
      ownerName.text = res['hostel']['owner_name'].toString();
      ownerNumber.text = res['hostel']['owner_number'].toString();
      alternateNumber.text = res['hostel']['alt_number'] != null ? res['hostel']['alt_number'].toString() : "";
      email.text = res['hostel']['email'] != null ? res['hostel']['email'].toString() : "";
      telephoneNumber.text = res['hostel']['tel_number'] != null ? res['hostel']['tel_number'].toString() : "";
      
      vacancyInNumber.text = res['hostel']['vancany'].toString();
      
      closeTime.text = res['hostel']['close_time'].toString();
      monthlyCharge.text = res['hostel']['monthly_charge'].toString();
      facility.text = res['hostel']['facility'].toString();
      conditions.text = res['hostel']['condition'].toString();

    setState(() {
      loaded = true;
      imageList = imageList;
      sGender = res['hostel']['hostel_type'].toString();
      sAction = res['hostel']['extra_charge'].toString();
      sTime = res['hostel']['has_close_time'].toString();
      locationCapText = res['hostel']['latitude'].toString() + " " + res['hostel']['longitude'].toString();
      latitude = res['hostel']['latitude'].toString();
      longitude = res['hostel']['longitude'].toString();
      selectedValue = res['hostel']['location_id'].toString();
      selectedValue = res['hostel']['location_id'].toString();
      selectedValue = res['hostel']['location_id'].toString();
    });
    }
    else{
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Error",
              style: TextStyle(color: Colors.red),
            ),
            content: Text('Cannot be updated since status is inactive'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context), child: Text("OK")),
            ],
          );
        },
      );
    }

  }
  void updateHostel(
    String hostelName,
    String hostelAddress,
    String locationIdentification,
    String ownerName,
    String ownerNumber,
    String altNumber,
    String email,
    String telNumber,
    String hostel_type,
    String vacancy,
    String extra_charge,
    String has_close_time,
    String monthly_charge,
    String facility,
    String condition,
    String latitude,
    String longitude,
  ) async {
    print("UPDATE METHOD CALLED");
    setState(() {
      loaded = false;
    });
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      print(has_close_time);
      var dio = Dio();
      var formData = FormData.fromMap({
        'id':  hostelID.toString(),
        'name': hostelName,
        'address': hostelAddress,
        'location_id': locationIdentification,
        'owner_name': ownerName,
        'owner_number': ownerNumber,
        'alt_number': altNumber,
        'email': email,
        'tel_number': telNumber,
        'hostel_type': hostel_type,
        'vancany': vacancy,
        'extra_charge': extra_charge,
        'has_close_time': has_close_time,
        'close_time': has_close_time == "0" ? closeTime.text.toString() : "0",
        'monthly_charge': monthly_charge,
        'facility': facility,
        'condition': condition,
        'latitude': latitude,
        'longitude': longitude,
        'images': jsonEncode(croppedFiles),     // allImagesBase64.toString(),
        'user_id': sp.getString('user_id').toString(),
      });
      var response = await dio.post(updateHostelUrl(), data: formData);
      var res = response.data;

      if (res['error'] == false) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "Success",
                style: TextStyle(color: Colors.green),
              ),
              content: Text(res['message'].toString()),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MyHostel()));
                    },
                    child: Text("OK")),
              ],
            );
          },
        );
      }
      print(res);
    } catch (e) {
      print("Error");
      print(e.runtimeType);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Error",
              style: TextStyle(color: Colors.red),
            ),
            content: Text('Server error'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context), child: Text("OK")),
            ],
          );
        },
      );
    }
    setState(() {
      loaded = true;
    });
  }

  void addHostel(
    String hostelName,
    String hostelAddress,
    String locationIdentification,
    String ownerName,
    String ownerNumber,
    String altNumber,
    String email,
    String telNumber,
    String hostel_type,
    String vacancy,
    String extra_charge,
    String has_close_time,
    String monthly_charge,
    String facility,
    String condition,
    String latitude,
    String longitude,
  ) async {
    setState(() {
      loaded = false;
    });
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      print(has_close_time);
      var dio = Dio();
      var formData = FormData.fromMap({
        'name': hostelName,
        'address': hostelAddress,
        'location_id': locationIdentification,
        'owner_name': ownerName,
        'owner_number': ownerNumber,
        'alt_number': altNumber,
        'email': email,
        'tel_number': telNumber,
        'hostel_type': hostel_type,
        'vancany': vacancy,
        'extra_charge': extra_charge,
        'has_close_time': has_close_time,
        'close_time': has_close_time == "0" ? closeTime.text.toString() : "0",
        'monthly_charge': monthly_charge,
        'facility': facility,
        'condition': condition,
        'latitude': latitude,
        'longitude': longitude,
        'images': jsonEncode(croppedFiles),//allImagesBase64.toString(),
        'user_id': sp.getString('user_id').toString(),
      });
      var response = await dio.post(addHostelUrl(), data: formData);
      var res = response.data;

      if (res['error'] == false) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "Success",
                style: TextStyle(color: Colors.green),
              ),
              content: Text(res['message'].toString()),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MyHostel()));
                    },
                    child: Text("OK")),
              ],
            );
          },
        );
      }
      print(res);
    } catch (e) {
      print("Error");
      print(e.runtimeType);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Error",
              style: TextStyle(color: Colors.red),
            ),
            content: Text('Server error'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context), child: Text("OK")),
            ],
          );
        },
      );
    }
    setState(() {
      loaded = true;
    });
  }



  void setAllStates() {
    print("SET ALL STATES");
    print(image64Strings);
    print(imagesList);

    setState(() {
      imagesList = imagesList;
      image64Strings = image64Strings;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          imagesList = imagesList;
          image64Strings = image64Strings;
        }));
  }

  String imgToBase64(Uint8List uint8list) {
    String base64String = base64Encode(uint8list);
    String header = "data:image/png;base64,";
    return base64String;
  }

  Widget imagePicker() {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: InkWell(
        onTap: () async {
          // ImagePicker _picker = ImagePicker();
          // print("picker set");
          // List<XFile>? image = await _picker.pickMultiImage();
          // print(image);
          // allImagesBase64 = [];
          // imageCount = 0;
          // for (int i = 0; i < image!.length; i++) {
          //   imageCount++;
          //   // image[i].readAsBytes()
          //   allImagesBase64.add("\"" +
          //       imgToBase64(await image[i].readAsBytes()).toString() +
          //       "\"");
          //   print(allImagesBase64[i]);
          // }
          // setState(() {
          //   imagesChoosen = true;
          //   imageCount = imageCount;
          // });
             //  print("image picked");
             // image64Strings[imageCount - 1] = image!.path.toString();
            // print("path set st state called");
            // setAllStates();
          chooseImage();
        },
        child: Container(
          padding: EdgeInsets.all(15),
          color: Color.fromARGB(255, 216, 216, 216),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(!imagesChoosen ? "Tap to open gallery" : "Ready to upload"),
              !imagesChoosen
                  ? Icon(
                      Icons.upload,
                      color: Colors.blue,
                    )
                  : Icon(Icons.done, color: Colors.green)
            ],
          ),
        ),
      ),
    );
  }
  List<XFile>? receivedFiles = [];
  List<String> croppedFiles = [];
  final ImagePicker _picker = ImagePicker();
  // void addImageWidget(){
  //    imageCount++;
  //     image64Strings.add("No Image");
  //     imagesList.add(imagePicker());
  //   setAllStates();
  // }

  // void insertInitials(){
  //   imageCount++;
  //   image64Strings.add("No Image");
  //   imagesList.add(imagePicker());
  //   setAllStates();
  // }

  // multiple image Cropper
  void chooseImage() async {
    receivedFiles = await _picker.pickMultiImage();
    MultiImageCrop.startCropping(
        context: context,
        alwaysShowGrid: true,
        aspectRatio: 8/8,
        activeColor: Colors.amber,
        pixelRatio: 18.0,
        files: List.generate(
            receivedFiles!.length, (index) => File(receivedFiles![index].path)),
        callBack: (List<File> images) {
          var image;
          for (var a = 0; a < images.length; a++) {
            setState(() {
              image = images[a].readAsBytesSync();
              croppedFiles.add(base64Encode(image).toString());
            });
          }
          print(croppedFiles.length);
        });
  }


  @override
  void initState() {
    getLocations().then((value){
      if(isThisForUpdate!){
        getHostel();
      }
    });
    
    // insertInitials();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    imagesList = imagesList;
    image64Strings = image64Strings;
    ctx = context;
    return Scaffold(
      backgroundColor: Clr().white,
      appBar: AppBar(
        backgroundColor: Color(0xff21488c),
        leading: InkWell(
            onTap: () {
              STM().back2Previous(ctx);
            },
            child: Icon(Icons.arrow_back_ios)),
        centerTitle: true,
        title: isThisForUpdate! ? Text("Update Hostel") : Text('Add Hostel'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hostel / Building Name: *',
                style: Sty().mediumText.copyWith(fontSize: 18)),
            SizedBox(height: 12),
            TextFormField(
              controller: hostelName,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                hintText: 'Enter Hostel / Building Name',
                border: InputBorder.none,
                fillColor: Colors.black12,
                filled: true,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text('Hostel / Building Address: *',
                style: Sty().mediumText.copyWith(fontSize: 18)),
            SizedBox(height: 12),
            TextFormField(
              maxLines: 5,
              controller: hostelAddress,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                hintText: 'Enter Hostel / Building Address',
                border: InputBorder.none,
                fillColor: Colors.black12,
                filled: true,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text('Select Location: *',
                style: Sty().mediumText.copyWith(
                      fontSize: 18,
                    )),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                  border: Border.all(
                color: Colors.black12,
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
                  onChanged: (v) {
                    setState(() {
                      selectedValue = v!;
                      print(selectedValue);
                    });
                  },
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              color: Clr().lightShadow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Map Location: *',
                    style: Sty().mediumText.copyWith(
                          fontSize: 18,
                        ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: Text(
                        locationCapText,
                        style: Sty().mediumText.copyWith(
                              fontSize: 16,
                            ),
                      )),
                      SizedBox(
                        width: 5,
                      ),
                      SizedBox(
                        height: 50,
                        width: 120,
                        child: ElevatedButton(
                            style: Sty().primaryButton,
                            onPressed: () {
                              getLocation();
                            },
                            child: Text('Capture',
                                style: Sty().mediumText.copyWith(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ))),
                      )
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text('Owner Name: *',
                style: Sty().mediumText.copyWith(fontSize: 18)),
            SizedBox(height: 12),
            TextFormField(
              controller: ownerName,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                hintText: 'Enter Owner Name',
                border: InputBorder.none,
                fillColor: Colors.black12,
                filled: true,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text('Owner Number: *',
                style: Sty().mediumText.copyWith(fontSize: 18)),
            SizedBox(height: 12),
            TextFormField(
              controller: ownerNumber,
              maxLength: 10,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                counterText: "",
                contentPadding: EdgeInsets.all(10),
                hintText: 'Enter Owner Number',
                border: InputBorder.none,
                fillColor: Colors.black12,
                filled: true,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text('Whatsapp Number:',
                style: Sty().mediumText.copyWith(fontSize: 18)),
            SizedBox(height: 12),
            TextFormField(
              maxLength: 10,
              keyboardType: TextInputType.number,
              controller: alternateNumber,
              decoration: InputDecoration(
                counterText: "",
                contentPadding: EdgeInsets.all(10),
                hintText: 'Enter whatsapp Number',
                border: InputBorder.none,
                fillColor: Colors.black12,
                filled: true,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text('Email:', style: Sty().mediumText.copyWith(fontSize: 18)),
            SizedBox(height: 12),
            TextFormField(
              controller: email,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                hintText: 'Enter Email',
                border: InputBorder.none,
                fillColor: Colors.black12,
                filled: true,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text('Telephone Number:',
                style: Sty().mediumText.copyWith(fontSize: 18)),
            SizedBox(height: 12),
            TextFormField(
              maxLength: 10,
              keyboardType: TextInputType.number,
              controller: telephoneNumber,
              decoration: InputDecoration(
                counterText: "",
                contentPadding: EdgeInsets.all(10),
                hintText: 'Enter Telephone Number',
                border: InputBorder.none,
                fillColor: Colors.black12,
                filled: true,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Hostel Type *',
              style: Sty().mediumText.copyWith(
                    fontSize: 18,
                  ),
            ),
            SizedBox(
              height: 12,
            ),
            Column(
              children: [
                Row(
                  children: [
                    Radio<String>(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: genderList[0],
                      groupValue: sGender,
                      onChanged: (value) {
                        setState(() {
                          sGender = value!;
                        });
                      },
                      activeColor: Clr().primaryColor,
                    ),
                    Text(
                      genderList[0],
                      style: Sty().mediumText,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Radio<String>(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: genderList[1],
                      groupValue: sGender,
                      onChanged: (value) {
                        setState(() {
                          sGender = value!;
                        });
                      },
                      activeColor: Clr().primaryColor,
                    ),
                    Text(
                      genderList[1],
                      style: Sty().mediumText,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Radio<String>(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: genderList[2],
                      groupValue: sGender,
                      onChanged: (value) {
                        setState(() {
                          sGender = value!;
                        });
                      },
                      activeColor: Clr().primaryColor,
                    ),
                    Text(
                      genderList[2],
                      style: Sty().mediumText,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Radio<String>(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: genderList[3],
                      groupValue: sGender,
                      onChanged: (value) {
                        setState(() {
                          sGender = value!;
                        });
                      },
                      activeColor: Clr().primaryColor,
                    ),
                    Text(
                      genderList[3],
                      style: Sty().mediumText,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Radio<String>(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: genderList[4],
                      groupValue: sGender,
                      onChanged: (value) {
                        setState(() {
                          sGender = value!;
                        });
                      },
                      activeColor: Clr().primaryColor,
                    ),
                    Text(
                      genderList[4],
                      style: Sty().mediumText,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Text('Vacancy In Number: *',
                style: Sty().mediumText.copyWith(fontSize: 18)),
            SizedBox(height: 12),
            TextFormField(
              keyboardType: TextInputType.number,
              controller: vacancyInNumber,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                hintText: 'Enter Vacancy In Number',
                border: InputBorder.none,
                fillColor: Colors.black12,
                filled: true,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Extra Charges: *',
              style: Sty().mediumText.copyWith(
                    fontSize: 18,
                  ),
            ),
            SizedBox(
              height: 12,
            ),
            Column(
              children: [
                Row(
                  children: [
                    Radio<String>(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: actionList[0],
                      groupValue: sAction,
                      onChanged: (value) {
                        setState(() {
                          sAction = value!;
                        });
                      },
                      activeColor: Clr().primaryColor,
                    ),
                    Text(
                      actionList[0],
                      style: Sty().mediumText,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Radio<String>(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: actionList[1],
                      groupValue: sAction,
                      onChanged: (String? value) {
                        setState(() {
                          sAction = value!;
                        });
                      },
                      activeColor: Clr().primaryColor,
                    ),
                    Text(
                      actionList[1],
                      style: Sty().mediumText,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Gate Closing Time: *',
              style: Sty().mediumText.copyWith(
                    fontSize: 18,
                  ),
            ),
            SizedBox(
              height: 12,
            ),
            Column(
              children: [
                Row(
                  children: [
                    Radio<String>(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: timeList[0][1],
                      groupValue: sTime,
                      onChanged: (value) {
                        setState(() {
                          sTime = value!;
                        });
                      },
                      activeColor: Clr().primaryColor,
                    ),
                    Text(
                      timeList[0][0],
                      style: Sty().mediumText,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Radio<String>(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: timeList[1][1],
                      groupValue: sTime,
                      onChanged: (String? value) {
                        setState(() {
                          sTime = value!;
                        });
                      },
                      activeColor: Clr().primaryColor,
                    ),
                    Text(
                      timeList[1][0],
                      style: Sty().mediumText,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            sTime == timeList[0][1]
                ? Text('Time of close: *',
                    style: Sty().mediumText.copyWith(fontSize: 18))
                : SizedBox(
                    height: 0,
                  ),
            sTime == timeList[0][1]
                ? SizedBox(height: 12)
                : SizedBox(
                    height: 0,
                  ),
            sTime == timeList[0][1]
                ? InkWell(
                    onTap: () async {
                      closeTime.text = "";
                      TimeOfDay time = TimeOfDay.now();
                      FocusScope.of(context).requestFocus(new FocusNode());

                      TimeOfDay? picked = await showTimePicker(
                          context: context, initialTime: time);
                      if (picked != null && picked != time) {
                        closeTime.text = "";
                        print(picked.format(context).toString());
                        closeTime.text = picked.hour.toString() +
                            ':' +
                            picked.minute.toString() +
                            ':' +
                            '00'; // add this line.
                        setState(() {
                          time = picked;
                        });
                      }
                    },
                    child: TextFormField(
                      keyboardType: TextInputType.datetime,
                      controller: closeTime,
                      enabled: false,
                      onTap: () async {},
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'cant be empty';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        hintText: "Tap to Enter Gate Closing Time",
                        // hintText: '\u20b91000',
                        border: InputBorder.none,
                        fillColor: Colors.black12,
                        filled: true,
                      ),
                    ),
                  )
                : SizedBox(
                    height: 0,
                  ),
            SizedBox(height: 20),
            Text('Monthly Charge: *',
                style: Sty().mediumText.copyWith(fontSize: 18)),
            SizedBox(height: 12),
            TextFormField(
              keyboardType: TextInputType.number,
              controller: monthlyCharge,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                hintText: '\u20b91000',
                border: InputBorder.none,
                fillColor: Colors.black12,
                filled: true,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Facility: *',
              style: Sty().mediumText.copyWith(
                    fontSize: 18,
                  ),
            ),
            SizedBox(height: 12),
            TextFormField(
              maxLines: 5,
              controller: facility,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                hintText: 'Enter Facilities',
                border: InputBorder.none,
                fillColor: Colors.black12,
                filled: true,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Conditions: *',
              style: Sty().mediumText.copyWith(
                    fontSize: 18,
                  ),
            ),
            SizedBox(height: 12),
            TextFormField(
              maxLines: 5,
              controller: conditions,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                hintText: 'Enter Conditions',
                border: InputBorder.none,
                fillColor: Colors.black12,
                filled: true,
              ),
            ),

            SizedBox(height: 20),
            Text(
              'Images: *',
              style: Sty().mediumText.copyWith(
                    fontSize: 18,
                  ),
            ),

            imagePicker(),
            (croppedFiles.length == 0)
                ? Text("")
                : Text("Images: " + '${croppedFiles.length}'),

            if(isThisForUpdate!) Text("Remove existing images", style: Sty().mediumText.copyWith(
                    fontSize: 18,
                  ),),
            if(isThisForUpdate!) Text("Tap an image to remove", style: Sty().mediumText.copyWith(
              fontSize: 14,
            ),),
            if(isThisForUpdate!) SizedBox(height: 10,),
            if(isThisForUpdate!) SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                for (int i = 0; i < imageList.length; i++) InkWell(
                  onTap: (){
                    print(imageList[i][1].toString());
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                          content: Text('Delete image?'),
                          actions: [
                            TextButton(
                                onPressed: () async {
                                  SharedPreferences sp = await SharedPreferences.getInstance();
                                  var dio = Dio();
                                  var formData = FormData.fromMap({
                                    'id' : imageList[i][1].toString()
                                  });
                                  var response = await dio.post(deleteImageUrl(), data: formData);
                                  var res = response.data;
                                  print(res);
                                  getAndUpdateImagesOnly();
                                  Navigator.pop(context);
                                }, child: Text("OK")),
                            TextButton(
                            onPressed: () => Navigator.pop(context), child: Text("CANCEL")),
                          ],
                        );
                      },
                    );
                  },
                  child: Stack(children:[CachedNetworkImage(imageUrl: imageList[i][0].toString(), width: 100, height: 100),
                  Icon(Icons.delete, color: Colors.red,),
                  ]),
                )
              ],),
            ),

            // Column(
            //   children: imagesList,
            // ),
            // Align(
            //   alignment: Alignment.centerRight,
            //   child: TextButton(onPressed: (){
            //     addImageWidget();
            //   }, child: Text("Add image")),
            // ),
            // Align(
            //   alignment: Alignment.centerRight,
            //   child: TextButton(onPressed: (){
            //     setAllStates();
            //   }, child: Text("set state")),
            // ),

            SizedBox(
              height: 30,
            ),
            Center(
              child: SizedBox(
                height: 50,
                width: 190,
                child: loaded
                    ? ElevatedButton(
                        style: Sty().primaryButton,
                        onPressed: () {
                          if (isLength(hostelName.text, 1)) {
                            print("HOSTEL NAME OK");
                            if (isLength(hostelAddress.text, 1)) {
                              print("HOSTEL ADDRESS OK");
                              if (selectedValue != null) {
                                print("SELECT LOCATION OK");
                                if (latitude.isNotEmpty &&
                                    longitude.isNotEmpty) {
                                  print("LAT LONG OK");
                                  if (isLength(ownerName.text, 1)) {
                                    print("OWNER NAME OK");
                                    if (isLength(ownerNumber.text, 10)) {
                                      print("OWNER NUMBER OK");
                                      if (isLength(alternateNumber.text, 10) ||
                                          alternateNumber.text.isEmpty) {
                                        print("ALTERNATE NUMBER OK");
                                        if (isEmail(email.text) ||
                                            email.text.isEmpty) {
                                          print("EMAIL OK");
                                          if (isLength(
                                                  telephoneNumber.text, 10) ||
                                              telephoneNumber.text.isEmpty) {
                                            print("TELEPHONE NUMBER OK");
                                            if (sGender.isNotEmpty) {
                                              print("GENDER (sGender) OK");
                                              if (isLength(
                                                  vacancyInNumber.text, 1)) {
                                                print("VACANCY IN NUMBER OK");
                                                if (sAction.isNotEmpty) {
                                                  print("CHARGE (sAction) OK");
                                                  if (sTime.isNotEmpty) {
                                                    print(
                                                        "GATE CLOSE (sTime) OK");
                                                    if (monthlyCharge
                                                        .text.isNotEmpty) {
                                                      print(
                                                          "MONTHLY CHARGE OK");
                                                      if (facility
                                                          .text.isNotEmpty) {
                                                        print("FACILITY OK");
                                                        if (conditions
                                                            .text.isNotEmpty) {
                                                          print(
                                                              "CONDITIONS OK");
                                                          if (croppedFiles.length > 0 || isThisForUpdate!) {
                                                            print("PERFECT!");
                                                            if(isThisForUpdate != null && isThisForUpdate != true){
                                                             addHostel(
                                                                hostelName.text
                                                                    .toString(),
                                                                hostelAddress.text
                                                                    .toString(),
                                                                selectedValue
                                                                    .toString(),
                                                                ownerName.text
                                                                    .toString(),
                                                                ownerNumber.text
                                                                    .toString(),
                                                                alternateNumber
                                                                    .text
                                                                    .toString(),
                                                                email
                                                                    .text
                                                                    .toString(),
                                                                telephoneNumber
                                                                    .text
                                                                    .toString(),
                                                                sGender
                                                                    .toString(),
                                                                vacancyInNumber
                                                                    .text
                                                                    .toString(),
                                                                sAction
                                                                    .toString(),
                                                                sTime
                                                                    .toString(),
                                                                monthlyCharge
                                                                    .text
                                                                    .toString(),
                                                                facility.text
                                                                    .toString(),
                                                                conditions
                                                                    .text
                                                                    .toString(),
                                                                latitude
                                                                    .toString(),
                                                                longitude
                                                                    .toString()); 
                                                            }
                                                            else{ 
                                                              updateHostel(
                                                                hostelName.text
                                                                    .toString(),
                                                                hostelAddress.text
                                                                    .toString(),
                                                                selectedValue
                                                                    .toString(),
                                                                ownerName.text
                                                                    .toString(),
                                                                ownerNumber.text
                                                                    .toString(),
                                                                alternateNumber
                                                                    .text
                                                                    .toString(),
                                                                email
                                                                    .text
                                                                    .toString(),
                                                                telephoneNumber
                                                                    .text
                                                                    .toString(),
                                                                sGender
                                                                    .toString(),
                                                                vacancyInNumber
                                                                    .text
                                                                    .toString(),
                                                                sAction
                                                                    .toString(),
                                                                sTime
                                                                    .toString(),
                                                                monthlyCharge
                                                                    .text
                                                                    .toString(),
                                                                facility.text
                                                                    .toString(),
                                                                conditions
                                                                    .text
                                                                    .toString(),
                                                                latitude
                                                                    .toString(),
                                                                longitude
                                                                    .toString()); 
                                                            }
                                                            
                                                          } else {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                    "Error",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .red),
                                                                  ),
                                                                  content: Text(
                                                                      "Please add at least one image."),
                                                                  actions: [
                                                                    TextButton(
                                                                        onPressed: () =>
                                                                            Navigator.pop(
                                                                                context),
                                                                        child: Text(
                                                                            "OK")),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          }
                                                        } else {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                  "Error",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ),
                                                                content: Text(
                                                                    "Please enter a condition."),
                                                                actions: [
                                                                  TextButton(
                                                                      onPressed: () =>
                                                                          Navigator.pop(
                                                                              context),
                                                                      child: Text(
                                                                          "OK")),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        }
                                                      } else {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                "Error",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red),
                                                              ),
                                                              content: Text(
                                                                  "Please enter a facility."),
                                                              actions: [
                                                                TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            context),
                                                                    child: Text(
                                                                        "OK")),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      }
                                                    } else {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: Text(
                                                              "Error",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                            content: Text(
                                                                "Please enter monthly charges."),
                                                            actions: [
                                                              TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context),
                                                                  child: Text(
                                                                      "OK")),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    }
                                                  } else {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                            "Error",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                          content: Text(
                                                              "Please enter gate closing time."),
                                                          actions: [
                                                            TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        context),
                                                                child:
                                                                    Text("OK")),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }
                                                } else {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                          "Error",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                        content: Text(
                                                            "Please select charges."),
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context),
                                                              child:
                                                                  Text("OK")),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                              } else {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                        "Error",
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                      content: Text(
                                                          "Please enter vacancy."),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            child: Text("OK")),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                      "Error",
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                    content: Text(
                                                        "Please select a type."),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                          child: Text("OK")),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          } else {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text(
                                                    "Error",
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                  content: Text(
                                                      "Please enter a valid telephone number."),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: Text("OK")),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        } else {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(
                                                  "Error",
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                                content: Text(
                                                    "Please enter a valid email."),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child: Text("OK")),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(
                                                "Error",
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                              content: Text(
                                                  "Please enter a valid whatsapp number."),
                                              actions: [
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: Text("OK")),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                              "Error",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                            content: Text(
                                                "Please enter a valid owner number."),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text("OK")),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                            "Error",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                          content:
                                              Text("Please enter owner name."),
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text("OK")),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                          "Error",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        content: Text(
                                            "Please capture your location."),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text("OK")),
                                        ],
                                      );
                                    },
                                  );
                                }
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        "Error",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      content: Text("Please set a location."),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text("OK")),
                                      ],
                                    );
                                  },
                                );
                              }
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      "Error",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    content:
                                        Text("Please enter hostel address."),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text("OK")),
                                    ],
                                  );
                                },
                              );
                            }
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    "Error",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  content: Text("Please enter hostel name."),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("OK")),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: Text(
                          'Submit',
                          style: Sty().mediumText.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                        ],
                      ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}