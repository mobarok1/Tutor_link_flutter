import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/extra/dateService.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/modelClass/child_account.dart';
import 'package:tutorlink/modelView/filter_sort_by_page.dart';
import 'package:tutorlink/widgets/input_fields.dart';
class AddEditChild extends StatefulWidget {
  final ChildAccountModel child;
  AddEditChild({this.child});
  @override
  _AddEditChildState createState() => _AddEditChildState();
}

class _AddEditChildState extends State<AddEditChild> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController middleNameController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();
  TextEditingController achievementController = TextEditingController();
  String gender = "m";
  DateTime dateOfBirth = DateTime.now().subtract(Duration(days: 10));
  bool loading = false;
  GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.child != null) {
      ChildAccountModel child = widget.child;
      firstNameController.text = child.firstName;
      lastNameController.text = child.lastName;
      middleNameController.text = child.middleName;
      achievementController.text = child.achievement;
      dateOfBirthController.text =  DateFormatHelper.fromDate(child.dateOfBirth);
      gender = child.gender;
      setState(() {});
    }else{
      dateOfBirthController.text =  DateFormatHelper.fromDate(dateOfBirth);
      }
    }
    updateChild(ChildAccountModel e) async{
    setState(() {
      loading = true;
    });
    print(dateOfBirth.toString().substring(0,10));
      bool response = await ApiRequest(context).editChild(ChildAccountModel(
        childUid: e.childUid,
        firstName: firstNameController.text,
        middleName: middleNameController.text,
        lastName: lastNameController.text,
        dateOfBirth: dateOfBirth,
        gender: gender, achievement: achievementController.text
      ));
      if(response){
        Toast.show("Successfully Updated", context,backgroundColor: Colors.green,textColor: Colors.white);
        Navigator.pop(context);
      }else{
        Toast.show("Failed to Update", context);
      }
    setState(() {
      loading = false;
    });
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.child == null ?'Add new child':"Edit Child",
          style: TextStyle(color: Colors.black87),
        ),
        iconTheme: IconThemeData(color: appsMainColor),
      ),
      body: loading ? Center(
        child: Container(
          child: loader,
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: EdgeInsets.only(top: 5, bottom: 10),
                child: InputField1(
                  hintText: 'First Name',
                  controller: firstNameController,
                  obSecure: false,
                  validator: (str){
                    if(str.isEmpty){
                      return "required";
                    }else{
                      return null;
                    }
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 5, bottom: 10),
                child: InputField1(
                  hintText: 'Middle Name',
                  controller: middleNameController,
                  obSecure: false,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 5, bottom: 10),
                child: InputField1(
                  hintText: 'Last Name',
                  controller: lastNameController,
                  obSecure: false,
                  validator: (str){
                    if(str.isEmpty){
                      return "required";
                    }else{
                      return null;
                    }
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 5, bottom: 10),
                child: InputField1(
                  hintText: 'Date Of Birth',
                  controller: dateOfBirthController,
                  obSecure: false,
                  readOnly: true,
                  onTap: (){
                    _selectDate(context);
                  },
                  validator: (str){
                    if(str.isEmpty){
                      return "required";
                    }else{
                      return null;
                    }
                  },
                ),
              ),
              Container(
                child: TextField(
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  minLines: 3,
                  maxLines: 5,
                  decoration: new InputDecoration(
                    labelText: "Educational History",
                    labelStyle: TextStyle(
                        color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: appsMainColor, width: 2)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: appsMainColor,
                        )),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: appsMainColor,
                        )),
                    contentPadding:
                    EdgeInsets.only(left: 15, bottom: 10, top: 10, right: 15),
                  ),
                  controller: achievementController,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 10, top: 10),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      margin: EdgeInsets.only(),
                      child: Text(
                        "Gender :",
                        style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Flexible(
                        child: CustomRadioGroup(labels: ["Male","Female"],
                            values: ["m","f"],
                            selectedItemValue: gender.toLowerCase(),
                            spacing: 2,
                            onChanged: (value){
                              setState(() {
                                gender = value;
                              });
                            },
                            selectedColor: appsMainColor,
                            unSelectedColor: Colors.grey.withOpacity(.3))
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 15),
                child: FlatButton(
                  padding: EdgeInsets.only(top: 15,bottom: 15),
                    onPressed: () {
                    bool result = _formKey.currentState.validate();
                    if(!result){
                      return;
                    }
                      if (widget.child == null) {
                        addNewChild();
                      } else
                        updateChild(widget.child);
                    },
                    color: appsMainColor,
                    textColor: Colors.white,
                    child: Container(
                      child: Text(
                        widget.child == null ? 'Add' : "Save",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ChildAccountModel getChildDataToAdd() {
    return ChildAccountModel(
        firstName: firstNameController.text,
        middleName: middleNameController.text,
        lastName: lastNameController.text,
        dateOfBirth: dateOfBirth,
        gender: gender,
        achievement: achievementController.text
    );
  }


  void addNewChild() async {
    setState(() {
      loading = true;
    });
    await ApiRequest(context).addNewChild(getChildDataToAdd()).then((value){

      if (value.responseCode == 201) {
        Navigator.pop(context);
        Toast.show('Success', context);

      } else {
        Toast.show('Something is Wrong', context);
      }
      setState(() {
        loading = false;
      });
    });

  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(Duration(days: 5844)),
        lastDate: DateTime.now());
    if (picked != null && picked != dateOfBirth) {
      setState(() {
        dateOfBirth = picked;
        dateOfBirthController.text = DateFormatHelper.fromDate(dateOfBirth).toString();
      });
    }
  }
}
