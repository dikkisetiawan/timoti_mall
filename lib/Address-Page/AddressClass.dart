class AddressClass {
  String? addressDetails;
  String? city;
  String? country;
  String? fullName;
  String? label;
  String? phone;
  String? postcode;
  String? state;
  int? index;
  String? email;
  double? latitude;
  double? longitude;

  AddressClass({
    this.addressDetails,
    this.city,
    this.country,
    this.fullName,
    this.label,
    this.phone,
    this.postcode,
    this.state,
    this.index,
    this.email,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'Address_Details': addressDetails,
      'City': city,
      'Country': country,
      'Full_Name': fullName,
      'Label': label,
      'Phone': phone,
      'Postcode': postcode,
      'State': state,
      'Latitude': latitude,
      'Longitude': longitude,
    };
  }
}
