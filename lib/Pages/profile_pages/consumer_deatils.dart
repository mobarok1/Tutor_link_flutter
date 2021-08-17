import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/api/api_response.dart';
import 'package:tutorlink/controller/user_controller.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/modelClass/my_details_model.dart';
import 'package:tutorlink/modelView/filter_sort_by_page.dart';
import 'package:tutorlink/storage/SharedPrefManager.dart';
import 'package:tutorlink/widgets/input_fields.dart';

class ConsumerDetails extends StatefulWidget {
  @override
  _ConsumerDetailsState createState() => _ConsumerDetailsState();
}

class _ConsumerDetailsState extends State<ConsumerDetails> {
  File myFile;
  final picker = ImagePicker();
  PickedFile _pickedFile;
  String _profileImage;
  String profileImageId;
  bool loading = false;
  String gender="M";

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  bool errorFirstName = false;
  bool errorLastName = false;
  bool errorPassword = false;
  bool errorRepeatPassword = false;
  bool sendMeNews = false;
  String errorMessagePassword = "Required";
  String userNameMessage = "Required";

  UserController userController = Get.find();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataFromServer();
  }

  getDataFromServer() async {
    setState(() {
      loading = true;
    });
    ApiResponse response = await ApiRequest(context).getProfileData();
    if(response.responseCode == -1){
      return;
    }
    var data = json.decode(response.response);
    userController.updateUserInfo(UserDetailsModel.fromJSON(data));
    firstNameController.text = userController.userDetails.profile.firstName;
    lastNameController.text = userController.userDetails.profile.lastName;
    phoneController.text = userController.userDetails.profile.phoneNumber==null? null:
    userController.userDetails.profile.phoneNumber.length < 11 ?
    userController.userDetails.profile.phoneNumber
        : userController.userDetails.profile.phoneNumber.toString().substring(2, 11);
    emailController.text = userController.userDetails.email;

    try{
      profileImageId = data["files"].singleWhere((element) => element.keyName == "course_image").fileUid;
    }catch(e){
      print(e);
    }
    if (data["files"] != null) {
      if (data["files"].length != 0) {
        try{
          profileImageId = data["files"].singleWhere((element) => element.keyName == "course_image").fileUid;
        }catch(e){
          print(e);
        }
        _profileImage = profileImageId;
      }
    }
    setState(() {
      loading = false;
    });
  }

  pickAFile() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if(File(pickedFile.path).statSync().size > 51200){
        Toast.show("Your file size is too large. Please ensure you do not exceed the maximum file size and dimensions,", context,
            backgroundColor: Colors.red, textColor: Colors.white,duration: 7);
        return;
      }
      _pickedFile = pickedFile;
      myFile = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        maxWidth: 500,
        maxHeight: 281,
      );
    }
    setState(() {});
  }

  uploadNewFile() async {
    setState(() {
      loading = true;
    });
    File __file = new File(myFile.path);
    String fileName = __file.path.split('/').last;
    var response = await ApiRequest(context).uploadNewFile(
        myFile,
        fileName,
        fileName.split(".").last,
        "profile_image",
        "public");
    if (response.responseCode == 201) {
      Toast.show("Successfully Uploaded", context,
          backgroundColor: Colors.green, textColor: Colors.white);
    } else {
      Toast.show("Failed to upload", context,
          backgroundColor: Colors.red, textColor: Colors.white);
    }
    setState(() {
      loading = false;
    });
  }

  updateFile() async {
    setState(() {
      loading = true;
    });
    ApiResponse response =
        await ApiRequest(context).deleteFileData(profileImageId);
    print("Deleted Code " + response.responseCode.toString());
    uploadNewFile();
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: appsMainColor),
        actions: [
          FlatButton(
            onPressed: () {
              updateDetails();
            },
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Text(
              "SAVE",
              style: TextStyle(
                color: appsMainColor,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          )
        ],
        title: Text(
          'Account Information',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: loading
          ? Center(child: loader)
          : SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(left: 15, right: 15, bottom: 25),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 20, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: myFile == null
                                        ? _profileImage == null
                                            ? AssetImage(
                                                "assets/images/profe.png")
                                            : NetworkImage(ApiRequest.BASE_URL+'/delivery/consumer/${userController.userId}/file/$_profileImage')
                                        : FileImage(myFile),
                                  )),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 50),
                            child: InkWell(
                                // color: Colors.grey,
                                onTap: () {
                                  pickAFile();
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Text(
                                    "Choose",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )),
                          ),
                          myFile == null
                              ? Container()
                              : Container(
                                  margin: EdgeInsets.only(left: 20),
                                  child: InkWell(
                                      onTap: () {
                                        if (_profileImage == null) {
                                          uploadNewFile();
                                        } else {
                                          updateFile();
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            color: appsMainColor,
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        child: Text(
                                          "Update",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )),
                                ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        "* Max File Size : 50 KB",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: 10,
                      ),
                      child: InputField1(
                        hintText: "First Name",
                        controller: firstNameController,
                        obSecure: false,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: 10,
                      ),
                      child: InputField1(
                        hintText: "Last Name",
                        controller: lastNameController,
                        obSecure: false,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: 10,
                      ),
                      child: TextField(
                        keyboardType: TextInputType.text,
                        autofocus: false,
                        autocorrect: false,
                        textInputAction: TextInputAction.done,
                        maxLength: 9,
                        maxLengthEnforced: true,
                        decoration: InputDecoration(
                          hintText: "Phone Number",
                          labelText: "Phone Number",
                          prefix: Text("07 "),
                          labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: appsMainColor, width: 2)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: appsMainColor,
                          )),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: appsMainColor,
                              )),
                          contentPadding: EdgeInsets.only(
                              left: 15, bottom: 0, top: 0, right: 15),
                        ),
                        controller: phoneController,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: InputField1(
                        hintText: "Email",
                        controller: emailController,
                        obSecure: false,
                        errorText: null,
                        readOnly: true,
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 0, bottom: 10),
                        padding: EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 120,
                              margin: EdgeInsets.only(left: 10),
                              child: Text(
                                "Category :",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Flexible(
                                child: CustomRadioGroup(
                                    labels: ["Male", "Female"],
                                    values: ["M", "F"],
                                    selectedItemValue: gender,
                                    spacing: 2,
                                    onChanged: (value) {
                                      setState(() {
                                        gender = value;
                                      });
                                    },
                                    selectedColor: appsMainColor,
                                    unSelectedColor:
                                    Colors.grey.withOpacity(.3))),
                          ],
                        )),
                  ],
                ),
              ),
            ),
    );
  }

  updateDetails() async {
    setState(() {
      loading = true;
    });
    var formData = jsonEncode({
      "profile": {
        "first_name": firstNameController.text,
        "last_name": lastNameController.text,
        "gender": gender,
        "phone": "07" + phoneController.text.toString()
      }
    });
    await ApiRequest(context).updateMyDetails(formData).then((value) {
      setState(() {
        loading = false;
      });
      if (value.responseCode == 202) {
        Toast.show('Successfully Updated', context,
            duration: 2,
            backgroundColor: Colors.green,
            textColor: Colors.white);
      } else {
        Toast.show(
          'Failed to Add Profile info',
          context,
          duration: 2,
          backgroundColor: Colors.redAccent,
        );
      }
    });
  }
}