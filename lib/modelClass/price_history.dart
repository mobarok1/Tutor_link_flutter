class PriceModel {
  String priceUuid;
  double price,vat,serviceCharge,extraCategoryPriceTotal,perCategoryPrice;
  DateTime startDate, endDate;
  PriceModel({this.endDate, this.price, this.priceUuid,this.extraCategoryPriceTotal,this.perCategoryPrice, this.startDate,this.serviceCharge,this.vat});
}
