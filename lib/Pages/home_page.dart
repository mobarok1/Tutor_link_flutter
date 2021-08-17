import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tutorlink/Pages/course_details.dart';
import 'package:tutorlink/Pages/filter_page.dart';
import 'package:tutorlink/Pages/register_login/login.dart';
import 'package:tutorlink/Pages/register_login/verify_email.dart';
import 'package:tutorlink/Pages/section_view.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/controller/cart_controller.dart';
import 'package:tutorlink/controller/favorite_controller.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/modelClass/category_model_type.dart';
import 'package:tutorlink/modelClass/course_model.dart';
import 'package:tutorlink/modelClass/filter_model_class.dart';
import 'package:tutorlink/modelClass/section_model.dart';
import 'package:tutorlink/modelView/filtered_curses.dart';
import 'package:tutorlink/storage/SharedPrefManager.dart';
import 'package:tutorlink/widgets/bottom_bar.dart';
import 'package:tutorlink/widgets/course_card.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  TextEditingController searchController = TextEditingController();
  bool isScrolling = false;
  bool loading = false, loadingMore = false;
  bool searching = false;
  double lastFilterScrollOffset = 0;
  String searchText;
  List<SectionModel> homePageSections = List<SectionModel>();
  int perSectionItems = 5;
  List<CategoryTypeModel> allCategory = List<CategoryTypeModel>().obs;
  Set<CourseModel> filteredCourse = Set<CourseModel>();
  Set<CourseModel> filteredFeaturedCourse = Set<CourseModel>();
  LatLng currentLatLong, filterLocation;
  FilterModelClass filterModel = FilterModelClass(
      categoryNames: <String>{},
      sortBy: -1,
      age: -1,
      filtering: false);

  List<int> filterRadiusArray = [10, 35, 50, 100];
  //refresh
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  CartController cartController = Get.find();
  FavoriteController favoriteController = Get.find();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getHomePageData();
  }

  getHomePageData() async {
    cityName = await SharedPrefManager.getString("city_name");
    stateName = await SharedPrefManager.getString("state_name");
    favoriteController.onInit();
    if (cityName == null) {
      getTownInput();
    } else {}
    String str = await SharedPrefManager.getString("__email");
    if (str != null) {
      Get.to(()=>VerifyEmail(
        emailAddress: str,
        returnCount: 1,
      ));
    }
    setState(() {
      loading =true;
    });
    allCategory = await ApiRequest(context).getAllCategoryType();
    homePageSections = await ApiRequest(context).getHomePageConfig();
    homePageSections.sort((a, b) => (a.sorting.compareTo(b.sorting)));
    for (int i = 0; i < homePageSections.length; i++) {
      String dataString =
          'skip_content=true&category=${homePageSections[i].value}&show_price_history=true&show_provider_info=true&page_items=$perSectionItems&current_page=1&sort_by_creationdate=true&sort_order=desc';
      if (homePageSections[i].value == "paid") {
        dataString =
            "skip_content=true&advertised=true&base_country=United+Kingdom&${cityName == null ? "" : "base_city=$cityName"}&show_provider_info=true&show_price_history=true&page_items=$perSectionItems&current_page=1&sort_by_creationdate=true&sort_order=desc";
        homePageSections[i].courses =
            (await ApiRequest(context).getAllCourse(dataString)).toSet();
        if (homePageSections[i].courses.length == 0) {
          dataString =
              "skip_content=true&advertised=true&base_country=United+Kingdom&show_provider_info=true&show_price_history=true&page_items=$perSectionItems&current_page=1&sort_by_creationdate=true&sort_order=desc";
          homePageSections[i].courses =
              (await ApiRequest(context).getAllCourse(dataString)).toSet();
        }
      } else if (homePageSections[i].value == "top10") {
        dataString =
            "skip_content=true&min_rate=5&show_provider_info=true&show_price_history=true&page_items=$perSectionItems&current_page=1&sort_by_creationdate=true&sort_order=desc";
        homePageSections[i].courses =
            (await ApiRequest(context).getAllCourse(dataString)).toSet();
      } else if (homePageSections[i].value == "online") {
        dataString =
            "skip_content=true&mode=online&show_provider_info=true&show_price_history=true&page_items=$perSectionItems&current_page=1&sort_by_creationdate=true&sort_order=desc";
        homePageSections[i].courses =
            (await ApiRequest(context).getAllCourse(dataString)).toSet();
      } else {
        homePageSections[i].courses =
            (await ApiRequest(context).getAllCourse(dataString)).toSet();
      }
    }
    setState(() {
      loading = false;
    });
  }

  getFilterPageData() async {
    setState(() {
      loading = true;
    });
    String str;
    for (int i = 0; i < filterModel.categoryNames.length; i++) {
      if (str == null) {
        str = filterModel.categoryNames.elementAt(i);
      } else {
        str = str + ";" + filterModel.categoryNames.elementAt(i);
      }
    }
    String sortByString = getSortByDataString();

    String  featureString = "skip_content=true&advertised=true&base_country=United+Kingdom&${filterModel.cityName == null ? "" : "base_city=${filterModel.cityName}"}&show_provider_info=true&${filterModel.categoryNames.length != 0 ? "type=$str" : ""}&show_price_history=true&page_items=5&current_page=1";
    filteredFeaturedCourse = (await ApiRequest(context).getAllCourse(featureString)).toSet();
    var dataString = 'skip_content=true&age_category=${filterModel.age == 0 ? "under_16" : filterModel.age == 1 ? "over_16" : ""}${searching ? ("&course_name="+searchText): ""}&${filterModel.categoryNames.length != 0 ? "type=$str" : ""}&$sortByString&show_price_history=true&show_provider_info=true&page_items=7&current_page=1';
    filteredCourse = (await ApiRequest(context).getAllCourse(dataString)).toSet();
    setState(() {
      loading = false;
    });
  }

  String getSortByDataString() {
    String sortByString = "";
    String sortOrder = "desc";
    if (filterModel.sortBy == 0) {
      sortOrder = "asc";
      sortByString = "sort_by_price=true&sort_order=$sortOrder";
    } else if (filterModel.sortBy == 1) {
      sortOrder = "desc";
      sortByString = "sort_by_price=true&sort_order=$sortOrder";
    } else if (filterModel.sortBy == 2) {
      sortOrder = "desc";
      sortByString = "sort_by_rate=true&sort_order=$sortOrder";
    } else if (filterModel.sortBy == 3) {
      sortOrder = "desc";
      sortByString = "sort_by_creationdate=true&sort_order=$sortOrder";
    } else if (filterModel.sortBy == 4) {
      sortOrder = "desc";
      sortByString = "sort_by_startdate=true&sort_order=$sortOrder";
    }
    return sortByString;
  }

  void _onRefresh() async {
    // monitor network fetch
    if (filterModel.filtering || searching) {
      await getFilterPageData();
    } else {
      await getHomePageData();
    }
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading?Center(
        child: loader,
      ):SafeArea(
              child: SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              enablePullUp: false,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              header: WaterDropMaterialHeader(
                color: Colors.white,
                backgroundColor: appsMainColor,
              ),
              child: Container(
                child: Column(
                  children: [
                    getHeader(),
                    filterModel.filtering || searching
                        ? getSearchBox()
                        : Container(),
                    filterModel.filtering || searching
                        ? getFilterItems()
                        : Container(),
                    filterModel.filtering || searching
                        ? Flexible(
                          child: FilteredCourses(
                            filteredFeaturedCourse: filteredFeaturedCourse,
                            searchText: searchText,
                            filterModel: filterModel,
                            searching: searching,
                            filteredCourseList: filteredCourse,
                          )
                        )
                        : Flexible(
                            child: ListView(children: [
                              getSearchBox(),
                              getHorizontalCategory("Category"),
                              Column(
                                  children: homePageSections.map((e) {
                                    return e.courses.length==0?Container():
                                    getHorizontalCourse(e);
                              }).toList()),
                            ]),
                          ),
                  ],
                ),
              ),
            )),
      bottomNavigationBar: BottomNavigationBarModelView(
        activeIndex: 0,
      ),
    );
  }

  Widget getHeader() {
    return Container(
      padding: EdgeInsets.only(bottom: 3),
      margin: EdgeInsets.only(bottom: 3),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey, width: .3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: FlatButton(
                    padding: EdgeInsets.only(left: 70),
                    onPressed: () {
                      getTownInput();
                    },
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    child: Container(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10, right: 10, top: 5),
                          child: Image.asset(
                            "assets/images/ustad_icon.png",
                            height: 40,
                            width: 40,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Current Location ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: appsMainColor,
                            )
                          ],
                        )
                      ],
                    )),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(right: 10, top: 5),
                  child: IconButton(
                    padding: EdgeInsets.only(
                        right: 10, left: 30, top: 10, bottom: 10),
                    onPressed: () {
                      Get.to(()=>LoginPage(returnCount: 1,));
                    },
                    icon: Icon(
                      Icons.person_outline,
                      color: appsMainColor,
                      size: 30,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getSearchBox() {
    return Container(
      height: 40,
      margin: EdgeInsets.only(left: 15, right: 5, top: 5, bottom: 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Color(0xFFEEEEEE).withOpacity(.7),
                  borderRadius: BorderRadius.circular(2)),
              child: TextFormField(
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                onFieldSubmitted: (str) {
                  if (str.length != 0) {
                    searching = true;
                    searchText = str;
                    getFilterPageData();
                  } else {
                    setState(() {
                      searching = false;
                      if (filterModel.filtering) {
                        getFilterPageData();
                      }
                    });
                  }
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    size: 24,
                    color: appsMainColor,
                  ),
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 15, letterSpacing: 1.1),
                  contentPadding:
                      EdgeInsets.only(left: 0, bottom: 5, top: 5, right: 0),
                  hintText: 'Search for a course',
                ),
                controller: searchController,
              ),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          IconButton(
            padding: EdgeInsets.all(0),
            icon: Icon(
              Icons.format_line_spacing,
              color: appsMainColor,
              size: 30,
            ),
            onPressed: () {
              openFilterPage(context);
            },
          ),
        ],
      ),
    );
  }

  Widget getFilterItems() {
    List<String> filterItems = filterModel.categoryNames.toList();
    if (filterModel.sortBy != -1) {
      String sort = "";
      if (filterModel.sortBy == 0) {
        sort = "Sort: Price Low to High";
      } else if (filterModel.sortBy == 1) {
        sort = "Sort: Price High to Low";
      } else if (filterModel.sortBy == 2) {
        sort = "Sort: By Rating";
      } else if (filterModel.sortBy == 3) {
        sort = "Sort: By Newly Added";
      } else if (filterModel.sortBy == 4) {
        sort = "Sort: By Stating Date";
      }
      filterItems.insert(0, sort);
    }
    if(filterModel.cityName != null){
      filterItems.insert(0, "Location : '${filterModel.cityName}'");
    }
    if (filterModel.age != -1) {
      if (filterModel.age == 0)
        filterItems.insert(0, "Age : Under 16");
      else
        filterItems.insert(0, "Age : 16+");
    }
    if (searching) {
      filterItems.insert(0, "Search : '$searchText'");
    }
    return Container(
      height: 30,
      margin: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 5),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        children: filterItems.map((e) {
          return Container(
            margin: EdgeInsets.only(right: 5),
            padding: EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
                color: appsMainColor, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Text(
                  e,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: .5),
                ),
                Container(
                  width: 25,
                  height: 25,
                  child: IconButton(
                      padding: EdgeInsets.only(
                          top: 0, bottom: 0, right: 10, left: 5),
                      onPressed: () {
                        filterModel.categoryNames
                            .removeWhere((selected) => selected == e);
                        if (e == "Sort: Price Low to High" ||
                            e == "Sort: Price High to Low" ||
                            e == "Sort: By Rating" ||
                            e == "Sort: By Newly Added" ||
                            e == "Sort: By Stating Date") {
                          filterModel.sortBy = -1;
                        }
                        if (e.contains("Location :")) {
                          //  filterItems.removeAt(0);
                          filterItems.removeWhere(
                              (element) => element.contains("Location :"));
                          filterModel.cityName = null;
                        }
                        if (e.contains("Age :")) {
                          filterItems.removeWhere(
                              (element) => element.contains("Age :"));
                          filterModel.age = -1;
                        }
                        if (filterModel.categoryNames.length == 0 &&
                            filterModel.sortBy == -1)
                          filterModel.filtering = false;
                        if (e.contains("Search")) {
                          searching = false;
                          searchText = "";
                          searchController.text = "";
                          filterItems.removeWhere(
                              (element) => element.contains("Search"));
                        }

                        if (filterModel.filtering || searching) {
                          getFilterPageData();
                        }
                        setState(() {});
                      },
                      icon: Icon(
                        Icons.clear,
                        color: Colors.white,
                      )),
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget getHorizontalCategory(String labelName) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          Container(
              margin: EdgeInsets.only(top: 10, bottom: 2, left: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      "Category",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: appsMainColor),
                    ),
                  ),
                  Container(
                      height: 25,
                      width: 30,
                      margin: EdgeInsets.only(bottom: 5, right: 10),
                      padding: EdgeInsets.only(bottom: 5, right: 0),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_forward,
                          color: appsMainColor,
                        ),
                        onPressed: () {},
                      ))
                ],
              )),
          Container(
            height: 100,
            padding: EdgeInsets.only(left: 0),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: allCategory.map((e) {
                return Container(
                    height: 100,
                    width: 100,
                    margin:
                    EdgeInsets.only(left: 0, right: 0, top: 5, bottom: 5),
                    padding: EdgeInsets.only(),
                    child: FlatButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Get.to(()=>SectionView(
                            sectionModel: SectionModel(
                              sectionName: e.displayName,
                              keyName: e.value,
                              value: "categoryView"
                            ),
                          ));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                              child: Image.network(
                                ApiRequest(context).getBaseUrl() +
                                    "/delivery/config/course/property/category/${e.value}/file",
                                fit: BoxFit.cover,
                              )),
                        )));
              }).toList(),
            ) ,

          )
        ],
      ),
    );
  }

  Widget getHorizontalCourse(SectionModel section) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      margin: EdgeInsets.only(top: 5),
      child: Column(
        children: [
          Container(
              margin: EdgeInsets.only(bottom: 2),
              child: LabelText(
                sectionModel: section,
              )),
          Container(
            height: 300,
            padding: EdgeInsets.only(left: 5),
            child: section.courses.length == 0
                ? Container(
                    child: Center(
                        child: Text(
                      "No Course Found",
                      style: TextStyle(fontSize: 18),
                    )),
                  )
                : ListView(
                    scrollDirection: Axis.horizontal,
                    children: section.courses.map((e) {
                      return Container(
                        height: 250,
                        width: 280,
                        padding: EdgeInsets.only(),
                        child: FlatButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () {
                            Get.to(()=>CourseDetails(
                              courseId: e.courseId,
                            ));
                          },
                          child: section.value == "paid"
                              ? CourseCardFeatured(
                                  courseModel: e,
                                )
                              : CourseCardHorizontal(
                                  courseModel: e,
                                ),
                        ),
                      );
                    }).toList(),
                  ),
          )
        ],
      ),
    );
  }
  void showCategoryInfo(String categoryName, String description) {
    showModalBottomSheet<dynamic>(
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return Wrap(children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 10, right: 5, top: 20, bottom: 20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: 5),
                    margin: EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: Colors.black.withOpacity(.1)))),
                    child: Text(
                      "What is $categoryName ?",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    child: Text(
                      description == null ? "No Description" : description,
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),
                  )
                ],
              ),
            )
          ]
          );
        });
  }

  openFilterPage(context) async {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return Container(
              color: Colors.transparent,
              child: Container(
                margin: EdgeInsets.only(top: 35),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0))),
                child: FilterPage(
                  filterModel: filterModel,
                  categoryList: allCategory,
                  filterNow: filterNow,
                  cancelFilter: cancelFilter,
                ),
              ));
        });
  }

  filterNow(model) {
    filterModel = model;
    getFilterPageData();
  }

  cancelFilter(model) {
    filterModel = model;
    setState(() {
      filterModel.filtering = false;
    });
  }
  getTownInput() async {
    TextEditingController controller = TextEditingController();
    controller.text = cityName;
    AlertDialog alert = AlertDialog(
      title: Text("Please enter your Town/City"),
      content: Container(
        child: TypeAheadField(
          textFieldConfiguration: TextFieldConfiguration(
              controller: controller,
              decoration: InputDecoration(
                  hintText: "Search for Town",
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: appsMainColor,
                    )),
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: appsMainColor,
                    )),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: appsMainColor,
                    )),
              )
          ),
          suggestionsCallback: (pattern) async {
            return await ApiRequest(context).getCitySuggestions(pattern);
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              leading: Icon(Icons.location_city),
              title: Text(suggestion.name+" - "+suggestion.country),
            );
          },
          onSuggestionSelected: (suggestion) {
            controller.text = suggestion.name;
            stateName = suggestion.country;
            setCityName(suggestion.name,suggestion.country);
            Navigator.pop(context);
          },
        ),
      ),
      actionsPadding: EdgeInsets.only(right: 10),
      actions: [
        FlatButton(
            padding: EdgeInsets.symmetric(horizontal: 15),
            color: appsMainColor,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.white),
            )),
        FlatButton(
            padding: EdgeInsets.symmetric(horizontal: 15),
            color: appsMainColor,
            onPressed: () {
              setCityName(controller.text.replaceAll(" ", "+"),stateName);
              Navigator.pop(context);
            },
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white),
            ))
      ],
      scrollable: true,
    );
    showDialog(
      context: context,
      builder:(ctx)=> alert,
    );
  }

  setCityName(city,state) async {
    await SharedPrefManager.saveString("city_name", city);
    await SharedPrefManager.saveString("state_name", state);
    getHomePageData();
  }
}

class LabelText extends StatelessWidget {
  final SectionModel sectionModel;
  LabelText({@required this.sectionModel});
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              sectionModel.sectionName,
              style: TextStyle(
                  fontSize: 18,
                  letterSpacing: .1,
                  color: appsMainColor,
                  fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () {
                Get.to(()=>SectionView(
                  sectionModel: sectionModel,
                ));
              },
              icon: Icon(
                Icons.arrow_forward,
                size: 25,
                color: appsMainColor,
              ),
            )
          ],
        ));
  }
}
