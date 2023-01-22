import '/enums/AddressType.dart';

class AddressArgument {
  AddressType addressType;
  String title;

  AddressArgument({
    required this.addressType,
    required this.title,
  });
}
