import 'package:flutter/foundation.dart';

class Address {
  var address_uuid;
  var name;
  var type;
  var creator_type;
  var creator_uuid;
  var location;
  Properties properties;
  var creation_date;
  var last_update;

  Address(
      {this.address_uuid,
      this.name,
      this.type,
      this.creator_type,
      this.creator_uuid,
      this.location,
      this.properties,
      this.creation_date,
      this.last_update});
  factory Address.fromData(Map<String,dynamic> data){
    return Address(
        address_uuid: data['address_uuid'],
        name: data['name'],
        type: data['type'],
        creator_type: data['creator_type'],
        creator_uuid: data['creator_uuid'],
        location: data['location'],
        properties: Properties.fromJSON(data["properties"]),
        creation_date: data['creation_date'],
        last_update: data['last_update']);
  }
}
class Properties {
  var street_name;
  var street_number;
  var building;
  var zip_code;
  var country;
  var city;
  var state;

  Properties(
      {this.street_name,
      this.street_number,
      this.building,
      this.zip_code,
      this.country,
      this.city,
      this.state});
  factory Properties.fromJSON(Map<String,dynamic> data){
    return Properties(
        country: data['country'],
        city: data['city'],
        zip_code: data['zip'],
        street_number: data['street_number'],
        state: data['state'],
        building: data['building'],
        street_name: data['street_name']);
  }
}

class SaveAddressData {
  var name;
  var type;
  Properties properties;

  SaveAddressData({this.name, this.type, this.properties});
}
