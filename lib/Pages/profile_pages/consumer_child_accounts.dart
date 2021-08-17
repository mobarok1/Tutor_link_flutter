import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:tutorlink/Pages/profile_pages/add_Edit_child.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/extra/dateService.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/modelClass/child_account.dart';

class ChildAccounts extends StatefulWidget {
  @override
  _ChildAccountsState createState() => _ChildAccountsState();
}

class _ChildAccountsState extends State<ChildAccounts> {
  bool loading = false;
  List<ChildAccountModel> myChildData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllChild();
  }

  void getAllChild() async {
    setState(() {
      loading = true;
    });
    myChildData = await ApiRequest(context).getAllChild();
    setState(() {
      loading = false;
    });
  }

  openAddEditPage(route) async {
   var result = await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => route));
   getAllChild();
  }
  deleteChild(uuid) async {
    setState(() {
      loading = true;
    });
   bool result = await ApiRequest(context).deleteChild(uuid);
   if(result){
     Toast.show("Successfully Deleted", context);
   }else{
     Toast.show("Failed to Delete", context);
   }
   getAllChild();

  }

  @override
  Widget build(BuildContext context) {
    int count = 0;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Child Accounts',
            style: TextStyle(color: Colors.black87),
          ),
          iconTheme: IconThemeData(color: appsMainColor),
          actions: [
            Container(
              child: !loading
                  ? IconButton(
                  onPressed: () {
                    getAllChild();
                  },
                  icon:Icon(
                      Icons.refresh
                  ))
                  : Container(),
            ),
            Container(
              child: !loading
                  ? FlatButton(
                  onPressed: () {
                    openAddEditPage(AddEditChild());
                  },
                  child: Container(
                    child: Text(
                      "Add New",
                      style: TextStyle(
                          color: appsMainColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ))
                  : Container(),
            ),
          ],
        ),
        body: loading
            ? loaderMaterialLinear
            : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            myChildData.isEmpty
                ? Center(
              child: Container(
                margin:
                EdgeInsets.only(left: 15, right: 15, top: 50),
                child: Text(
                  "No Child Found",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),
            )
                : Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: myChildData.map((e) {
                    count++;
                    return Container(
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
                                        color: appsMainColor.withOpacity(.3)))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Child $count",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  width: 150,
                                  child: Row(
                                    children: [
                                      Container(
                                        width:70,
                                        child: FlatButton(
                                          padding: EdgeInsets.only(left: 0),
                                          splashColor: Colors.transparent,
                                          highlightColor:
                                          Colors.transparent,
                                          child: Text(
                                            "Edit",
                                            style: TextStyle(
                                                color: appsMainColor),
                                          ),
                                          onPressed: () {
                                    openAddEditPage(AddEditChild(
                                      child: e,
                                    ));
                                          },
                                        ),
                                      ),
                                      Container(
                                        width: 70,
                                        child: FlatButton(
                                          padding: EdgeInsets.only(left: 0),
                                          splashColor: Colors.transparent,
                                          highlightColor:
                                          Colors.transparent,
                                          child: Text(
                                            "Delete",
                                            style: TextStyle(
                                                color: appsMainColor),
                                          ),
                                          onPressed: () {
                                            deleteChild(e.childUid);
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ChildItem(
                            label: "First Name",
                            value: e.firstName,
                          ),
                          ChildItem(
                            label: "Middle Name",
                            value: e.middleName,
                          ),
                          ChildItem(
                            label: "Last Name",
                            value: e.lastName,
                          ),
                          ChildItem(
                            label: "Gender",
                            value: e.gender == "m"?"Male":"Female",
                          ),
                          ChildItem(
                            label: "Date Of Birth",
                            value: DateFormatHelper.fromDate(e.dateOfBirth),
                          ),
                          ChildItem(
                            label: "Educational History",
                            value: e.achievement,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            )
          ],
        ));
  }
}
class ChildItem extends StatelessWidget {
  final String label;
  final String value;
  ChildItem({this.value, this.label});
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

