import '/enums/VoucherType.dart';

class VoucherData {
  String voucherName;
  String voucherCode;
  String voucherId;
  String discountDetails;
  int limitedVoucherQuantityRedeemedCustomer;
  bool isActive;
  int redeemQuantity;
  int tempRedeemQty;
  double minOrder;
  String redeemEndTime;
  VoucherValueType voucherValueType;
  double voucherValue;
  double voucherPercentage;
  double maxDiscount;
  bool shouldRemove;
  bool isNULL;

  VoucherData({
    this.isNULL = false,
    this.voucherName = '',
    this.voucherCode = '',
    this.voucherId = '',
    this.discountDetails = '',
    this.limitedVoucherQuantityRedeemedCustomer = 0,
    this.redeemQuantity = 0,
    this.tempRedeemQty = 0,
    this.isActive = false,
    this.redeemEndTime = '',
    this.minOrder = 0,
    this.voucherValueType = VoucherValueType.Value,
    this.voucherPercentage = 0,
    this.voucherValue = 0,
    this.maxDiscount = 0,
    this.shouldRemove = false,
  });
}
