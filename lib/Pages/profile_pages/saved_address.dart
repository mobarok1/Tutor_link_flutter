import 'package:flutter/material.dart';
import 'package:tutorlink/Pages/profile_pages/addEditAddress.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/api/api_response.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/modelClass/address.dart';
import 'package:tutorlink/storage/SharedPrefManager.dart';

class SaveAddress extends StatefulWidget {
  @override
  _SaveAddressState createState() => _SaveAddressState();
}

class _SaveAddressState extends State<SaveAddress> {
  bool loading = false;
  ApiResponse<List<Address>> myAddressData;
  Address homeAddress = Address();
  Address invoiceAddress = Address();

  @override
  void initState() {
    // TODO: implement initState
    getAddress();
    super.initState();
  }

  void getAddress() async {
    setState(() {
      loading = true;
    });
    myAddressData = await ApiRequest(context).viewAddress();
    if(myAddressData!= null)
        myAddressData.response.forEach((e){
          if(e.type=="DELIVERY")
            homeAddress = e;
          else
            invoiceAddress = e;
        });
    setState(() {
      loading = false;
    });
  }

  openAddEditPage(route) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (BuildContext context) => route));
    getAddress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Address Information',
            style: TextStyle(color: Colors.black87),
          ),
          iconTheme: IconThemeData(color: appsMainColor),
        ),
        body: loading
            ? loaderMaterialLinear
            : SingleChildScrollView(
                    child: Column(
                      children:[
                        Container(
                          padding: EdgeInsets.only(
                              left: 15, right: 15, top: 6, bottom: 5),
                          child: Column(
                            children: [
                              Container(
                                height: 30,
                                margin: EdgeInsets.only(bottom: 5),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color:
                                            appsMainColor.withOpacity(.3)))),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "HOME",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    FlatButton(
                                      padding: EdgeInsets.only(left: 0),
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      child: Text(
                                        homeAddress.address_uuid == null?"Add":"Edit",
                                        style: TextStyle(color: appsMainColor),
                                      ),
                                      onPressed: () {
                                        if(homeAddress.address_uuid == null){
                                          openAddEditPage(AddEditAddress(
                                            addressType: "DELIVERY",
                                          ));
                                        }else{
                                          openAddEditPage(AddEditAddress(
                                            addressId: homeAddress.address_uuid,
                                            address: homeAddress,
                                          ));
                                        }
                                      },
                                    )
                                  ],
                                ),
                              ),
                              homeAddress.address_uuid == null?
                                  Container(
                                    margin: EdgeInsets.only(top: 20),
                                    child: Text("Please Add Home Address"),
                                  )
                              :Column(
                                children: [
                                  AddressLine(
                                    label: "Building",
                                    value: homeAddress.properties.building,
                                  ),
                                  AddressLine(
                                    label: "Street Number",
                                    value: homeAddress.properties.street_number,
                                  ),
                                  AddressLine(
                                    label: "Street Name",
                                    value: homeAddress.properties.street_name,
                                  ),
                                  AddressLine(
                                    label: "Postcode",
                                    value: homeAddress.properties.zip_code != null
                                        ? homeAddress.properties.zip_code
                                        : "0",
                                  ),
                                  AddressLine(
                                    label: "City",
                                    value: homeAddress.properties.city,
                                  ),
                                  AddressLine(
                                    label: "State",
                                    value: homeAddress.properties.state,
                                  ),
                                  AddressLine(
                                    label: "Country",
                                    value: homeAddress.properties.country,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              left: 15, right: 15, top: 6, bottom: 5),
                          child: Column(
                            children: [
                              Container(
                                height: 30,
                                margin: EdgeInsets.only(bottom: 5),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color:
                                            appsMainColor.withOpacity(.3)))),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "INVOICE",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    FlatButton(
                                      padding: EdgeInsets.only(left: 0),
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      child: Text(
                                        invoiceAddress.address_uuid == null?"Add":"Edit",
                                        style: TextStyle(color: appsMainColor),
                                      ),
                                      onPressed: () {
                                        if(invoiceAddress.address_uuid == null){
                                          openAddEditPage(AddEditAddress(
                                            addressType: "INVOICE",
                                            homeAddress: homeAddress,
                                          ));
                                        }else{
                                          openAddEditPage(AddEditAddress(
                                            addressId: invoiceAddress.address_uuid,
                                            address: invoiceAddress,
                                            homeAddress: homeAddress,
                                          ));
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              invoiceAddress.address_uuid==null?Container(
                                margin: EdgeInsets.only(top: 20),
                                child: Text("Please Add Invoice Address"),
                              ):Column(
                              children: [
                                AddressLine(
                                  label: "Building",
                                  value: invoiceAddress.properties.building,
                                ),
                                AddressLine(
                                  label: "Street Number",
                                  value: invoiceAddress.properties.street_number,
                                ),
                                AddressLine(
                                  label: "Street Name",
                                  value: invoiceAddress.properties.street_name,
                                ),
                                AddressLine(
                                  label: "Postcode",
                                  value: invoiceAddress.properties.zip_code != null
                                      ? invoiceAddress.properties.zip_code
                                      : "0",
                                ),
                                AddressLine(
                                  label: "City",
                                  value: invoiceAddress.properties.city,
                                ),
                                AddressLine(
                                  label: "State",
                                  value: invoiceAddress.properties.state,
                                ),
                                AddressLine(
                                  label: "Country",
                                  value: invoiceAddress.properties.country,
                                ),
                              ],
                            )
                            ],
                          ),
                        )
                      ],
                    ),
                  ));
  }
}

class AddressLine extends StatelessWidget {
  final String label;
  final String value;
  AddressLine({this.value, this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: appsMainColor.withOpacity(.2)))),
      child: Row(
        children: [
          Container(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 16),
            ),
          ),
          Container(
            child: Text(":  "),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}
