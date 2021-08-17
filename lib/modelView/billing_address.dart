import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/modelClass/address.dart';
import 'package:tutorlink/modelView/filter_sort_by_page.dart';
import 'package:tutorlink/widgets/input_fields.dart';

class BillingAddressAdd extends StatefulWidget {
  CallBackWith1 setAddress;
  BillingAddressAdd({this.setAddress});
  @override
  _BillingAddressAddState createState() => _BillingAddressAddState();
}

class _BillingAddressAddState extends State<BillingAddressAdd> {
  TextEditingController addressName = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController streetNameController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading ? Center(
        child: Container(
          width: 300,
          child: loader,
        ),
      ) :
    Container(
      width: 300,
      child: SingleChildScrollView(
          padding: EdgeInsets.only(left:10,right: 10,top: 0,bottom: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: EdgeInsets.only(top: 5, bottom: 10),
                child: InputField1(
                  hintText: 'Address Name',
                  controller: addressName,
                  obSecure: false,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 5, bottom: 10),
                child: InputField1(
                  hintText: 'Street Name',
                  controller: streetNameController,
                  obSecure: false,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 5, bottom: 10),
                child: InputField1(
                  hintText: 'Post Code',
                  controller: zipCodeController,
                  obSecure: false,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 5, bottom: 10),
                child: InputField1(
                  hintText: 'Town',
                  controller: cityController,
                  obSecure: false,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 5, bottom: 10),
                child: InputField1(
                  hintText: 'State',
                  controller: stateController,
                  obSecure: false,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 5, bottom: 10),
                child: InputField1(
                  hintText: 'Country',
                  controller: countryController,
                  obSecure: false,
                ),
              ),
              Container(
                child: FlatButton(
                  color: appsMainColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.only(top: 15,bottom: 15),
                  onPressed: (){
                    SaveAddressData _sAddress = getAddressDataToAdd();
                    Address _address = Address(
                      address_uuid: "1",
                      name: _sAddress.name,
                      type: _sAddress.type,
                      properties: _sAddress.properties,
                    );
                    widget.setAddress(_address);
                    Navigator.pop(context);
                  },
                  child: Text("OK",style: TextStyle(color: Colors.white),),
                ),
              )
            ],
          ),
      ),
    );
  }

  SaveAddressData getAddressDataToAdd() {
    return SaveAddressData(
        name: addressName.text,
        type: "COURSE",
        properties: Properties(
            street_name: streetNameController.text,
            zip_code: zipCodeController.text,
            country: countryController.text,
            city: cityController.text,
            state: stateController.text));
  }
}
