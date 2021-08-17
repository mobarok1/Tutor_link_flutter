class CategoryTypeModel {
  String keyName, value, displayName, shortDescription;
  CategoryTypeModel(
      {this.keyName, this.value, this.displayName, this.shortDescription});
  factory CategoryTypeModel.fromJSON(Map<String,dynamic> data){
    return CategoryTypeModel(
      keyName: data["key_name"],
      value: data["value"],
      displayName: data["display_name"],
      shortDescription: data["description"],
    );
  }
}
