import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tutorlink/Pages/section_view.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/modelClass/category_model_type.dart';
import 'package:tutorlink/modelClass/filter_model_class.dart';
import 'package:tutorlink/modelClass/section_model.dart';
import 'package:tutorlink/modelView/filter_age.dart';
import 'package:tutorlink/modelView/filter_location.dart';
import 'package:tutorlink/modelView/filter_sort_by_page.dart';
import 'package:tutorlink/widgets/input_fields.dart';

class FilterPage extends StatefulWidget {
  List<CategoryTypeModel> categoryList = List<CategoryTypeModel>();
  FilterModelClass filterModel;
  CallBackWith1 filterNow, cancelFilter;
  FilterPage(
      {this.categoryList, this.filterModel, this.filterNow, this.cancelFilter});

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  FilterModelClass filterModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    filterModel = widget.filterModel;
  }

  setSortType(value) async {
    filterModel.sortBy = value;
    setState(() {});
  }
  setAgeType(value) async {
    filterModel.age = value;
    setState(() {});
  }
  setLocationData(value){
    FilterModelClass filter = value;
    filterModel.cityName = filter.cityName;
    filterModel.filtering = filter.filtering;
    applyFilter();
  }

  getSortInput() async {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return Container(
              color: Colors.transparent,
              child: Container(
                margin: EdgeInsets.only(top: 50),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0))),
                child: FilterSortByPage(
                  sortType: filterModel.sortBy,
                  setSortByData: setSortType,
                  applyFilter: applyFilter,
                  clearFilter: clearFilerAndBack,
                ),
              ));
        });
  }
  getAgeInput() async {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return Container(
              color: Colors.transparent,
              child: Container(
                margin: EdgeInsets.only(top: 50),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0))),
                child: FilterAge(
                  ageType: filterModel.age,
                  setAgeTypeData: setAgeType,
                  applyFilter: applyFilter,
                  clearFilter: clearFilerAndBack,
                ),
              ));
        });
  }
  getLocationInput() async {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return Container(
              color: Colors.transparent,
              child: Container(
                margin: EdgeInsets.only(top: 50),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0))),
                child: FilterPageLocation(
                  filterModel: filterModel,
                  applyFilter: applyFilter,
                  clearFilter: clearFilerAndBack,
                  setLocationData: setLocationData,
                ),
              ));
        });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            height: 50,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 5, top: 2),
                  child: IconButton(
                      color: appsMainColor,
                      icon: Icon(
                        Icons.close,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: 40),
                    child: Text(
                      "Filters",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 60,
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(
                                color: appsMainColor.withOpacity(.2)))),
                    child: FlatButton(
                      onPressed: () {
                        getSortInput();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                          bottom:
                              BorderSide(color: appsMainColor.withOpacity(.2)),
                        )),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 10),
                              child: Icon(
                                Icons.sort,
                                size: 30,
                                color: Colors.black.withOpacity(.6),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(bottom: 1),
                                    child: Text(
                                      "Sort",
                                      style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.black.withOpacity(.8)),
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      filterModel.sortBy == 0
                                          ? "Price Low to High"
                                          : filterModel.sortBy == 1
                                              ? "Price High to Low"
                                              : filterModel.sortBy == 2
                                                  ? "By Rating"
                                                  : filterModel.sortBy == 3
                                                      ? "Newly Added"
                                                      : filterModel.sortBy == 4
                                                          ? "Starting Date"
                                                          : "By Default",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black.withOpacity(.6)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: appsMainColor,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    margin: EdgeInsets.only(top: 5),
                    child: FlatButton(
                      onPressed: () {
                        getLocationInput();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: appsMainColor.withOpacity(.2)))),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 10),
                              child: Icon(
                                Icons.location_on,
                                size: 30,
                                color: Colors.black.withOpacity(.6),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(bottom: 1),
                                    child: Text(
                                      "City",
                                      style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.black.withOpacity(.8)),
                                    ),
                                  ),
                                  Container(
                                    child: Text(filterModel.cityName !=null? filterModel.cityName: cityName!=null?cityName:"City Name",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black.withOpacity(.6)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: appsMainColor,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    margin: EdgeInsets.only(top: 5),
                    child: FlatButton(
                      onPressed: () {
                        getAgeInput();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: appsMainColor.withOpacity(.2)))),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 10),
                              child: Icon(
                                Icons.lock_clock,
                                size: 30,
                                color: Colors.black.withOpacity(.6),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(bottom: 1),
                                    child: Text(
                                      "Age",
                                      style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.black.withOpacity(.8)),
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                        filterModel.age==-1?"All":filterModel.age==-1?"Under 16":"16+",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black.withOpacity(.6)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: appsMainColor,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    margin: EdgeInsets.only(top: 5),
                    child: FlatButton(
                      onPressed: () {
                        Get.back();
                        Get.to(()=>SectionView(
                          sectionModel: SectionModel(
                          sectionName: "Free courses",
                          keyName: "free",
                          value: "freeView"
                          ),
                        ));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: appsMainColor.withOpacity(.2)))),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 10),
                              child: Icon(
                                Icons.book,
                                size: 30,
                                color: Colors.black.withOpacity(.6),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(bottom: 1),
                                child: Text(
                                  "Free Courses",
                                  style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.black.withOpacity(.8)),
                                ),
                              ),
                            ),
                            Container(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: appsMainColor,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    margin: EdgeInsets.only(top: 5),
                    child: FlatButton(
                      onPressed: () {
                        Get.back();
                        Get.to(()=>SectionView(
                          sectionModel: SectionModel(
                              sectionName: "Events",
                              keyName: "Events",
                              value: "EventView"
                          ),
                        ));                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: appsMainColor.withOpacity(.2)))),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 10),
                              child: Icon(
                                Icons.event_available,
                                size: 30,
                                color: Colors.black.withOpacity(.6),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(bottom: 1),
                                child: Text(
                                  "Events",
                                  style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.black.withOpacity(.8)),
                                ),
                              ),
                            ),
                            Container(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: appsMainColor,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 5),
                    padding: EdgeInsets.only(
                        left: 15, right: 10, top: 18, bottom: 10),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: appsMainColor.withOpacity(.2)))),
                    child: Text(
                      "Categories",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    )
                  ),
                  Column(
                    children: widget.categoryList.map((e) {
                      bool enabled = false;
                      filterModel.categoryNames.forEach((element) {
                        if (element == e.value) {
                          enabled = true;
                        }
                      });
                      return Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: appsMainColor.withOpacity(.1)))),
                        child: CheckboxListTile(
                          activeColor: appsMainColor,
                          title: Text(
                            e.displayName,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          value: enabled,
                          onChanged: (bool value) {
                            if (value) {
                              filterModel.categoryNames.add(e.value);
                            } else {
                              filterModel.categoryNames.removeWhere(
                                  (selected) => selected == e.value);
                            }
                            setState(() {});
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 55,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                filterModel.categoryNames.length == 0
                    ? Container()
                    : Expanded(
                        child: Container(
                          margin:
                              EdgeInsets.only(left: 10, right: 10, bottom: 5),
                          child: FlatButton(
                            color: Colors.black.withOpacity(.1),
                            onPressed: () {
                              clearFiler();
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Clear All",
                              style: TextStyle(
                                  color: appsMainColor,
                                  fontSize: 18,
                                  letterSpacing: 1),
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
                        if(filterModel.categoryNames.length ==0){
                          filterModel.filtering = false;
                        }else{
                          filterModel.filtering = true;
                        }
                        widget.filterNow(filterModel);
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Done",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            letterSpacing: 1),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  clearFiler() {
    filterModel.categoryNames = {};
    filterModel.sortBy = -1;
    widget.cancelFilter(filterModel);
    setState(() {});
  }

  clearFilerAndBack() {
    filterModel.categoryNames = {};
    filterModel.sortBy = -1;
    filterModel.age = -1;
    filterModel.filtering = false;
    widget.cancelFilter(filterModel);
    Navigator.pop(context);
  }

  applyFilter() {
    filterModel.filtering =true;
    widget.filterNow(filterModel);
    Navigator.pop(context);
  }
}

class SortByItem extends StatelessWidget {
  String name;
  IconData icon;
  bool selected;
  SortByItem(
      {@required this.icon, @required this.name, @required this.selected});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                  padding: EdgeInsets.only(left: 0, right: 8),
                  child: Icon(
                    icon,
                    color: Colors.black.withOpacity(.5),
                    size: 24,
                  )),
              Container(
                child: Text(
                  name,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: appsMainColor,
          size: 30,
        )
      ],
    );
  }
}
