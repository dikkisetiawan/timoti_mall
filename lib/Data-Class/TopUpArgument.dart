import 'package:timoti_project/enums/Payment-Method-Type.dart';

class TopUpArgument {
  PaymentMethodType type;
  String bankName;
  String id;
  String name;

  TopUpArgument({
    required this.type,
    required this.bankName,
    required this.id,
    required this.name,
  });
}
