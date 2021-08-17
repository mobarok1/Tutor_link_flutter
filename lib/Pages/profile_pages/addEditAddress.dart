import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:toast/toast.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/modelClass/address.dart';
import 'package:tutorlink/widgets/input_fields.dart';

class AddEditAddress extends StatefulWidget {
  String addressId;
  String addressType;
  Address address;
  Address homeAddress;
  AddEditAddress({this.addressType,this.addressId, this.address,this.homeAddress});
  @override
  _AddEditAddressState createState() => _AddEditAddressState();
}

class _AddEditAddressState extends State<AddEditAddress> {
  TextEditingController cityController = TextEditingController();
  TextEditingController streetNumberController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController buildingController = TextEditingController();
  TextEditingController streetNameController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.addressId != null) {
      Address address = widget.address;
      streetNameController.text = address.properties.street_name;
      streetNumberController.text = address.properties.street_number;
      buildingController.text = address.properties.building;
      cityController.text = address.properties.city;
      stateController.text = address.properties.state;
      zipCodeController.text = address.properties.zip_code;
      setState(() {});
    }
  }
  copyFromHome(){
    Address address = widget.homeAddress;
    streetNameController.text = address.properties.street_name;
    streetNumberController.text = address.properties.street_number;
    buildingController.text = address.properties.building;
    cityController.text = address.properties.city;
    stateController.text = address.properties.state;
    zipCodeController.text = address.properties.zip_code;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.addressId == null ? 'Add a new Address' : "Edit Address",
          style: TextStyle(color: Colors.black87),
        ),
        iconTheme: IconThemeData(color: appsMainColor),
        actions: [
          Container(
            child: FlatButton(
                onPressed: () {
                  if (widget.addressId == null) {
                    addNewAddress();
                  } else
                    updateAddress();
                },
                child: Container(
                  child: Text(
                    widget.addressId == null ? 'Add' : "Save",
                    style: TextStyle(
                        color: appsMainColor, fontWeight: FontWeight.bold),
                  ),
                )),
          ),
        ],
      ),
      body: loading
          ? Center(
              child: Container(
                child: loader,
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  widget.homeAddress!=null?Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: FlatButton(
                      color: Colors.grey.withOpacity(.5),
                        child: Text(" Copy from Home address"),
                      onPressed: (){
                          copyFromHome();
                      },
                    ),
                  ):Container(),
                  Container(
                    margin: EdgeInsets.only(top: 5, bottom: 10),
                    child: InputField1(
                      hintText: 'House No/Flat No',
                      controller: buildingController,
                      obSecure: false,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5, bottom: 10),
                    child: InputField1(
                      hintText: 'Street Number',
                      controller: streetNumberController,
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
                    height: 50,
                    child: TypeAheadFormField(
                      textFieldConfiguration: TextFieldConfiguration(
                          controller: this.cityController,
                          decoration: InputDecoration(
                              labelText: 'City Name',
                              labelStyle: TextStyle(
                                color: Colors.black,
                              ),
                              border: OutlineInputBorder()
                          )
                      ),
                      suggestionsCallback: (pattern) async{
                        return await ApiRequest(context).getCitySuggestions(pattern);
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          leading: Icon(Icons.location_city),
                          title: Text(suggestion.name+" - "+suggestion.country),
                        );
                      },
                      transitionBuilder: (context, suggestionsBox, controller) {
                        return suggestionsBox;
                      },
                      onSuggestionSelected: (suggestion) {
                        this.cityController.text = suggestion.name;
                        this.stateController.text = suggestion.country;
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5, bottom: 10),
                    child: InputField1(
                      hintText: 'State',
                      controller: stateController,
                      obSecure: false,
                      readOnly: true,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  SaveAddressData getAddressDataToAdd() {
    return SaveAddressData(
        name: 'Home',
        type: widget.addressType,
        properties: Properties(
            street_name: streetNameController.text,
            street_number: streetNumberController.text,
            building: buildingController.text,
            zip_code: zipCodeController.text,
            country: "United Kingdom",
            city: cityController.text,
            state: stateController.text));
  }

  SaveAddressData getAddressDataToUpdate() {
    return SaveAddressData(
        name: 'Home',
        type: widget.address.type,
        properties: Properties(
            street_name: streetNameController.text,
            street_number: streetNumberController.text,
            building: buildingController.text,
            zip_code: zipCodeController.text,
            country: "United Kingdom",
            city: cityController.text,
            state: stateController.text));
  }

  void addNewAddress() async {
    setState(() {
      loading = true;
    });
    await ApiRequest(context)
        .addNewAddress(getAddressDataToAdd())
        .then((value) {
      if (value.responseCode == 201) {
        approvedLocation(value.response);
      } else {
        Toast.show('Something is Wrong', context);
        setState(() {
          loading = false;
        });
      }
    });
  }

  void updateAddress() async {
    setState(() {
      loading = true;
    });
    await ApiRequest(context)
        .updateAddress(getAddressDataToUpdate(), widget.addressId)
        .then((value) {
      setState(() {
        loading = false;
      });
      if (value.responseCode == 202) {
        Toast.show('Update Successfully Completed', context,
            backgroundColor: Colors.green, textColor: Colors.white);
        Navigator.pop(context);
      } else {
        Toast.show('Something is Wrong', context);
      }
    });
  }

  void approvedLocation(String location) async {
    await ApiRequest(context).approvedAddress(location).then((value) {
      setState(() {
        loading = false;
      });

      if (value.response == "Accepted") {
        Navigator.pop(context);
      } else {
        Toast.show('Something is wrong', context);
      }
    });
  }
}
