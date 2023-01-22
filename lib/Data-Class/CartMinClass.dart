class CartMinOrder {
  String voucherCode;
  double minOrder;
  String branchName;
  bool hasError;

  CartMinOrder({
    this.voucherCode = '',
    this.minOrder = 0,
    this.branchName = '',
    this.hasError = false,
  });
}
