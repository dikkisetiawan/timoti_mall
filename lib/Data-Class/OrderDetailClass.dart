class OrderDetailsClass {
  String order_ID;
  String order_Details_ID;
  String image;
  String price;
  String product_ID;
  String product_Name;
  int quantity;
  String product_ID_Base;
  String provider_ID;
  String? variant_ID;
  String? variant_Name;

  OrderDetailsClass({
    this.order_ID = '',
    this.order_Details_ID = '',
    this.image = '',
    this.price = '',
    this.product_ID = '',
    this.product_Name = '',
    this.quantity = -1,
    this.product_ID_Base = '',
    this.provider_ID = '',
    this.variant_ID,
    this.variant_Name,
  });
}
