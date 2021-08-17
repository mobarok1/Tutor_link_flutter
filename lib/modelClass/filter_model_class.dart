class FilterModelClass {
  bool filtering;
  String cityName;
  int sortBy,age;
  Set<String> categoryNames;
  FilterModelClass(
      {
      this.categoryNames,
      this.cityName,
      this.sortBy,
        this.filtering,
        this.age,
      });
}
