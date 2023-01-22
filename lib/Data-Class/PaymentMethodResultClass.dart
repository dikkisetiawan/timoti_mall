import '/enums/Payment-Method-Type.dart';

class PaymentMethodResultClass {
  PaymentMethodType type;
  String paymentMethodName;

  PaymentMethodResultClass({
    required this.paymentMethodName,
    required this.type,
  });
}
