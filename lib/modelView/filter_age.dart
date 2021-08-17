import 'package:flutter/material.dart';
import 'package:tutorlink/Pages/filter_page.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/modelView/filter_sort_by_page.dart';

class FilterAge extends StatefulWidget {
  int ageType;
  CallBackWith1 setAgeTypeData;
  VoidCallback applyFilter, clearFilter;
  FilterAge(
      {this.ageType, this.setAgeTypeData, this.applyFilter, this.clearFilter});
  @override
  _FilterAgeState createState() => _FilterAgeState();
}
class _FilterAgeState extends State<FilterAge> {
  int ageType = -1;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      ageType = widget.ageType;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: Column(
            children: [
              Container(
                height: 50,
                margin: EdgeInsets.only(top: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_back_ios,
                                size: 25,
                                color: appsMainColor,
                              ),
                              Text(
                                "Filter",
                                style: TextStyle(
                                    color: appsMainColor, fontSize: 16),
                              ),
                            ],
                          ),
                        )),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          right: 100,
                        ),
                        child: Text(
                          "Age",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 19, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 15, right: 15, top: 10),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color:appsMainColor.withOpacity(.1), width: 2),
                      top: BorderSide(
                          color: appsMainColor.withOpacity(.1), width: 2)),
                ),
                child: FlatButton(
                    onPressed: () {
                      setState(() {
                        ageType = 0;
                      });
                      widget.setAgeTypeData(ageType);
                    },
                    padding: EdgeInsets.all(0),
                    child: SortByItem(
                      name: "Under 16",
                      icon: Icons.account_balance_wallet,
                      selected: ageType == 0 ? true : false,
                    )),
              ),
              Container(
                margin: EdgeInsets.only(left: 15, right: 15),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: appsMainColor.withOpacity(.1), width: 2))),
                child: FlatButton(
                    onPressed: () {
                      setState(() {
                        ageType = 1;
                      });
                      widget.setAgeTypeData(ageType);
                    },
                    padding: EdgeInsets.only(left: 0),
                    child: SortByItem(
                        icon: Icons.sort,
                        name: "Age 16+",
                        selected: ageType == 1 ? true : false)),
              ),
              Container(
                margin: EdgeInsets.only(left: 15, right: 15),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: appsMainColor.withOpacity(.1), width: 2))),
                child: FlatButton(
                    onPressed: () {
                      setState(() {
                        ageType = -1;
                      });
                      widget.setAgeTypeData(ageType);
                    },
                    padding: EdgeInsets.only(left: 0),
                    child: SortByItem(
                        icon: Icons.star,
                        name: "Both",
                        selected: ageType == -1 ? true : false)),
              ),
            ],
          ),
        ),
        Container(
          height: 55,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                  child: FlatButton(
                    color: Colors.black.withOpacity(.1),
                    onPressed: () {
                      if(ageType == -1){
                        Navigator.pop(context);
                      }else
                        setState(() {
                          ageType = -1;
                          widget.setAgeTypeData(ageType);
                        });
                    },
                    child: Text(
                      ageType == -1?"Back":"Clear",
                      style: TextStyle(
                          color: appsMainColor, fontSize: 18, letterSpacing: 1),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                  child: FlatButton(
                    color: appsMainColor,
                    onPressed: () {
                      Navigator.pop(context);
                      widget.applyFilter();
                    },
                    child: Text(
                      "Done",
                      style: TextStyle(
                          color: Colors.white, fontSize: 18, letterSpacing: 1),
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
