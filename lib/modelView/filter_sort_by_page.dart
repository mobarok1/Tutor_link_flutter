import 'package:flutter/material.dart';
import 'package:tutorlink/Pages/filter_page.dart';
import 'package:tutorlink/extra/theme_data.dart';

class FilterSortByPage extends StatefulWidget {
  int sortType;
  CallBackWith1 setSortByData;
  VoidCallback applyFilter, clearFilter;
  FilterSortByPage(
      {this.sortType, this.setSortByData, this.applyFilter, this.clearFilter});
  @override
  _FilterSortByPageState createState() => _FilterSortByPageState();
}

class _FilterSortByPageState extends State<FilterSortByPage> {
  int sortType = -1;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      sortType = widget.sortType;
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
                          "Sort By",
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
                          color: appsMainColor.withOpacity(.1), width: 2),
                      top: BorderSide(
                          color: appsMainColor.withOpacity(.1), width: 2)),
                ),
                child: FlatButton(
                    onPressed: () {
                      setState(() {
                        sortType = 0;
                      });
                      widget.setSortByData(sortType);
                    },
                    padding: EdgeInsets.all(0),
                    child: SortByItem(
                      name: "Price Low to High",
                      icon: Icons.account_balance_wallet,
                      selected: sortType == 0 ? true : false,
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
                        sortType = 1;
                      });
                      widget.setSortByData(sortType);
                    },
                    padding: EdgeInsets.only(left: 0),
                    child: SortByItem(
                        icon: Icons.sort,
                        name: "Price High to Low",
                        selected: sortType == 1 ? true : false)),
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
                        sortType = 2;
                      });
                      widget.setSortByData(sortType);
                    },
                    padding: EdgeInsets.only(left: 0),
                    child: SortByItem(
                        icon: Icons.star,
                        name: "By Rating",
                        selected: sortType == 2 ? true : false)),
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
                        sortType = 3;
                      });
                      widget.setSortByData(sortType);
                    },
                    padding: EdgeInsets.only(left: 0),
                    child: SortByItem(
                        icon: Icons.update,
                        name: "Newly Added",
                        selected: sortType == 3 ? true : false)),
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
                        sortType = 4;
                      });
                      widget.setSortByData(sortType);
                    },
                    padding: EdgeInsets.only(left: 0),
                    child: SortByItem(
                        icon: Icons.date_range,
                        name: "Starting Date",
                        selected: sortType == 4 ? true : false)),
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
                    color: appsMainColor.withOpacity(.1),
                    onPressed: () {
                      if(sortType == -1){
                        Navigator.pop(context);
                      }else
                        setState(() {
                          sortType = -1;
                          widget.setSortByData(sortType);
                        });
                    },
                    child: Text(
                      sortType == -1?"Back":"Clear",
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
typedef CallBackWith1(dynamic value);

class CustomRadioGroup extends StatelessWidget {
  List<String> labels;
  List values;
  CallBackWith1 onChanged;
  double spacing;
  dynamic selectedItemValue;
  Color selectedColor, unSelectedColor;
  CustomRadioGroup(
      {@required this.labels,
        @required this.values,
        @required this.selectedItemValue,
        @required this.spacing,
        @required this.onChanged,
        @required this.selectedColor,
        @required this.unSelectedColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      margin: EdgeInsets.only(top: 5),
      child: ListView.builder(
          itemCount: labels.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) {
            bool selected = false;
            if (selectedItemValue == values[index]) {
              selected = true;
            }
            return Container(
              margin: EdgeInsets.only(left: spacing, right: spacing),
              decoration: BoxDecoration(
                  color: selected ? selectedColor : unSelectedColor,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: FlatButton(
                color: Colors.transparent,
                onPressed: () {
                  onChanged(values[index]);
                },
                child: Text(
                  labels[index],
                  style: TextStyle(
                      color: selected ? Colors.white : appsMainColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: .5),
                ),
              ),
            );
          }),
    );
  }
}

