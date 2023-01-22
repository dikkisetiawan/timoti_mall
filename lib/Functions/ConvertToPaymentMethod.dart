import 'package:timoti_project/enums/Payment-Method-Type.dart';

/// Use Payment Method ID to convert
PaymentMethodType convertStringToPaymentMethodType(String data){
  /// Cash On Delivery
  if(data == 'Cash_On_Delivery'){
    return PaymentMethodType.Cash_On_Delivery;
  }
  /// EGHL
  else if(data == 'EGHL'){
    return PaymentMethodType.EGHL;
  }
  /// BillPlz
  else if(data == 'BillPlz') {
    return PaymentMethodType.BillPlz;
  }
  /// Payex
  else if(data == 'Payex') {
    return PaymentMethodType.Payex;
  }
  /// AppWallet
  else{
    return PaymentMethodType.AppWallet;
  }
}