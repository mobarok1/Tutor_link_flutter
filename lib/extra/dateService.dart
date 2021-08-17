import 'package:intl/intl.dart';

class DateFormatHelper{

  static String fromString(String str){
      if (str == null) {
        return "";
      }
      try{
        DateTime f = DateTime.parse(str);
        return DateFormat('dd-MM-yyyy').format(f);
      }catch(e){
        return str;
      }
  }
  static String fromDate(DateTime dateTime){
    String str = dateTime.toString().substring(0,10);
    if (str == null) {
      return "";
    }
    try{
      return DateFormat('dd-MM-yyyy').format(dateTime);
    }catch(e){
      return str;
    }
  }
  static DateTime parseDate(String str) {
    if (str == null) {
      return DateTime.parse("2000-01-01");
    }
    try{
      return DateTime.parse(str);
    }catch(e){
      return DateTime.parse("2000-01-01");
    }

  }
}