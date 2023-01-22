import 'package:timoti_project/enums/AddressType.dart';

class AddressArgument {
  AddressType addressType;
  String title;

  AddressArgument({
    required this.addressType,
    required this.title,
  });
}