import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:tutorlink/api/api_request.dart';
import 'package:tutorlink/extra/theme_data.dart';
import 'package:tutorlink/modelClass/filter_model_class.dart';
import 'package:tutorlink/modelView/filter_sort_by_page.dart';
import 'package:tutorlink/storage/SharedPrefManager.dart';
import 'package:tutorlink/widgets/input_fields.dart';
class FilterPageLocation extends StatefulWidget {
  FilterModelClass filterModel;
  CallBackWith1 setLocationData;
  VoidCallback applyFilter, clearFilter;
  FilterPageLocation({this.applyFilter,this.clearFilter,this.setLocationData,this.filterModel});
  @override
  _FilterPageLocationState createState() => _FilterPageLocationState();
}

class _FilterPageLocationState extends State<FilterPageLocation> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController _stateNameController = TextEditingController();
  String _selectedCity;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.filterModel.cityName != null){
      _typeAheadController.text = widget.filterModel.cityName;
      _stateNameController.text = stateName;
    }else if(cityName != null){
      _typeAheadController.text = cityName;
      _stateNameController.text = stateName;
    }
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
                          "City Name",
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
                margin: EdgeInsets.only(left: 20,right: 20,top: 15),
                height: 50,
                child: TypeAheadFormField(
                  textFieldConfiguration: TextFieldConfiguration(
                      controller: this._typeAheadController,
                      decoration: InputDecoration(
                          labelText: 'City Name',
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
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
                    this._typeAheadController.text = suggestion.name;
                    this._stateNameController.text = suggestion.country;
                  },
                  onSaved: (value) => this._selectedCity = value,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 20,right: 20,top: 15),
                child: InputField1(
                  obSecure: false,
                  controller: _stateNameController,
                  readOnly: true,
                  hintText: "State Name",
                ),
              ),
              SizedBox(height: 10.0,),
              RaisedButton(
                child: Text('Save'),
                onPressed: () {
                  widget.filterModel.cityName = _typeAheadController.text;
                  widget.filterModel.filtering = true;
                  widget.setLocationData(widget.filterModel);
                  setCityName(_typeAheadController.text.replaceAll(" ", "+"), _stateNameController.text.replaceAll(" ", "+"));
                  widget.applyFilter();
                },
              )
            ],
          ),
        ),
      ],
    );
  }
  setCityName(city,state) async {
    await SharedPrefManager.saveString("city_name", city);
    await SharedPrefManager.saveString("sate_name", state);
  }
}
