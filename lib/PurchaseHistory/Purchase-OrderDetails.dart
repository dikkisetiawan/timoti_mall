import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:timoti_project/Custom-UI/Custom-CheckOutUI.dart';
import 'package:timoti_project/Data-Class/OrderHistoryClass.dart';
import 'package:timoti_project/Functions/Messager.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';
import 'package:timoti_project/enums/OrderHistoryType.dart';

class OrderDetailsPage extends StatefulWidget {
  static const routeName = '/Order-Details-Page';

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  bool debugMode = true;

  final formatCurrency = new NumberFormat.currency(
    locale: "ms-MY",
    symbol: "",
    decimalDigits: 2,
  );
  User firebaseUser = FirebaseAuth.instance.currentUser as User;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  DocumentSnapshot? lastDocument;
  int dataLimit = 5;
  String testUserID = '103195359606008710233';
  bool hasMore = true;

  List<OrderHistoryClass> orderHistoryList = <OrderHistoryClass>[];
  bool firstLoad = false;

  late OrderHistoryClass orderHistoryData;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (loaded == false) {
      orderHistoryData =
          ModalRoute.of(context)?.settings.arguments as OrderHistoryClass;
      loaded = true;
    }

    super.didChangeDependencies();
  }

  // region UI
  /// Status Type
  Widget getDeliveryStatus(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    String text,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Container(
        width: _widgetSize.getResponsiveWidth(1, 1, 1),
        decoration: BoxDecoration(
          color: Theme.of(context).highlightColor,
          border: Border(
            bottom: BorderSide(
              width: 2.5,
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(
              _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
              0,
              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
              0),
          trailing: Container(
            width: _widgetSize.getResponsiveWidth(0.06, 0.06, 0.06),
            child: Image.asset(
              'assets/icon/shipping.png',
              color: Theme.of(context).backgroundColor,
            ),
          ),
          title: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: _deviceDetails.getNormalFontSize(),
              color: Theme.of(context).backgroundColor,
            ),
          ),
        ),
      ),
    );
  }

  /// Delivery Type
  Widget getDeliveryType(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Container(
        width: _widgetSize.getResponsiveWidth(1, 1, 1),
        decoration: BoxDecoration(
          color: Theme.of(context).shadowColor,
          border: Border(
            bottom: BorderSide(
              width: 0.7,
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(
              _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
              0,
              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
              0),
          leading: Container(
            width: _widgetSize.getResponsiveWidth(0.06, 0.06, 0.06),
            child: Image.asset(
              'assets/icon/shipping.png',
              color: Colors.grey,
            ),
          ),
          title: Text(
            'Delivery Type',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: _deviceDetails.getNormalFontSize(),
              color: Theme.of(context).primaryColor,
            ),
          ),
          subtitle: Text(
            orderHistoryData.deliveryType,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: _deviceDetails.getNormalFontSize() - 2,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  /// Delivery Address
  Widget getDeliveryAddress(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return Container(
      width: _widgetSize.getResponsiveWidth(1, 1, 1),
      decoration: BoxDecoration(
        color: Theme.of(context).shadowColor,
        border: Border(
          bottom: BorderSide(
            width: 0.7,
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.fromLTRB(
            _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
            _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
            _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02)),
        leading: Icon(
          Icons.location_on,
          size: _widgetSize.getResponsiveWidth(0.06, 0.06, 0.06),
          color: Colors.grey,
        ),
        title: Text(
          'Delivery Address',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: _deviceDetails.getNormalFontSize(),
            color: Theme.of(context).primaryColor,
            height: 1.5,
          ),
        ),
        subtitle: Text(
          "${orderHistoryData.addressData!.fullName}"
          "\n${orderHistoryData.addressData!.phone}"
          "\n${orderHistoryData.addressData!.addressDetails}"
          "\n${orderHistoryData.addressData!.postcode}, ${orderHistoryData.addressData!.city}, ${orderHistoryData.addressData!.state}",
          style: TextStyle(
            height: 1.6,
            fontWeight: FontWeight.w400,
            fontSize: _deviceDetails.getNormalFontSize() - 2,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  /// Order Details Total Amount
  Widget getEachOrderTotalUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return Container(
      width: _widgetSize.getResponsiveWidth(1, 1, 1),
      decoration: BoxDecoration(
        color: Theme.of(context).shadowColor,
        border: Border(
          bottom: BorderSide(
            width: 0.7,
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          /// Subtotal Price
          Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: SizedBox(
              width: _widgetSize.getResponsiveWidth(0.5, 0.5, 0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// SubTotal
                  Expanded(
                    child: Text(
                      "Subtotal",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: _deviceDetails.getNormalFontSize(),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),

                  /// SubTotal Price
                  if (orderHistoryData.order_subtotal_price != '')
                    Expanded(
                      child: Text(
                        "RM " +
                            formatCurrency
                                .format(double.parse(
                                    orderHistoryData.order_subtotal_price))
                                .toString(),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: _deviceDetails.getTitleFontSize(),
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  if (orderHistoryData.order_subtotal_price == '')
                    Expanded(
                      child: Text(
                        "RM " + formatCurrency.format(0).toString(),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: _deviceDetails.getTitleFontSize(),
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          /// Shipping Price
          Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: SizedBox(
              width: _widgetSize.getResponsiveWidth(0.5, 0.5, 0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Shipping
                  Expanded(
                    child: Text(
                      "Shipping",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: _deviceDetails.getNormalFontSize(),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),

                  /// Shipping Price
                  if (orderHistoryData.total_Shipping != '')
                    Expanded(
                      child: Text(
                        "RM " +
                            formatCurrency
                                .format(double.parse(
                                    orderHistoryData.total_Shipping))
                                .toString(),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: _deviceDetails.getNormalFontSize(),
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  if (orderHistoryData.total_Shipping == '')
                    Expanded(
                      child: Text(
                        "RM " + formatCurrency.format(0).toString(),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: _deviceDetails.getNormalFontSize(),
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          /// Total Discount
          if (orderHistoryData.order_total_discount != '')
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: SizedBox(
                width: _widgetSize.getResponsiveWidth(0.5, 0.5, 0.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// Total Discount
                    Expanded(
                      child: Text(
                        "Total Discount",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: _deviceDetails.getNormalFontSize(),
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Text(
                        "- RM " +
                            formatCurrency
                                .format(double.parse(
                                    orderHistoryData.order_total_discount))
                                .toString(),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: _deviceDetails.getNormalFontSize(),
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          /// Total Amount
          SizedBox(
            width: _widgetSize.getResponsiveWidth(0.5, 0.5, 0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Total Item
                Expanded(
                  child: Text(
                    "Total Items (${orderHistoryData.orderDetailsList.length.toString()})",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: _deviceDetails.getNormalFontSize(),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),

                /// Total Amount
                if (orderHistoryData.total_Amount != null &&
                    orderHistoryData.total_Amount != '')
                  Expanded(
                    child: Text(
                      "RM " +
                          formatCurrency
                              .format(
                                  double.parse(orderHistoryData.total_Amount))
                              .toString(),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: _deviceDetails.getTitleFontSize(),
                        color: Theme.of(context).highlightColor,
                      ),
                    ),
                  ),
                if (orderHistoryData.total_Amount == null ||
                    orderHistoryData.total_Amount == '')
                  Expanded(
                    child: Text(
                      "RM " + formatCurrency.format(0).toString(),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: _deviceDetails.getTitleFontSize(),
                        color: Theme.of(context).highlightColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Payment method ui
  Widget getPaymentMethodUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return Container(
      width: _widgetSize.getResponsiveWidth(1, 1, 1),
      color: Theme.of(context).shadowColor,
      child: ListTile(
        leading: Icon(
          Icons.monetization_on,
          size: _widgetSize.getResponsiveWidth(0.06, 0.06, 0.06),
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          "Payment Methods",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: _deviceDetails.getNormalFontSize(),
            color: Theme.of(context).primaryColor,
          ),
        ),
        trailing: Text(
          orderHistoryData.paymentMethod != null
              ? orderHistoryData.paymentMethod
              : "Somethings goes wrong",
          style: TextStyle(
            color: Theme.of(context).highlightColor,
            fontWeight: FontWeight.w600,
            fontSize: _deviceDetails.getNormalFontSize(),
          ),
        ),
      ),
    );
  }

  /// OrderID + Order Created Time + Order Updated Time
  Widget getOrderTimelUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return Container(
      color: Theme.of(context).shadowColor,
      padding: EdgeInsets.all(_widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),
      child: Column(
        children: [
          /// Order ID
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Order ID
              Text(
                "Order ID",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).primaryColor,
                ),
              ),

              /// Date
              Text(
                orderHistoryData.order_ID,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).highlightColor,
                ),
              )
            ],
          ),

          /// Spacing
          SizedBox(height: _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02)),

          /// Order Created Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Order Updated Time
              Text(
                "Order Created Time",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).primaryColor,
                ),
              ),

              /// Date
              Expanded(
                child: Text(
                  orderHistoryData.orderCreatedTime,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: _deviceDetails.getNormalFontSize(),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              )
            ],
          ),

          /// Spacing
          SizedBox(height: _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02)),

          /// Order Updated Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Order Updated Time
              Text(
                "Order Updated Time",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).primaryColor,
                ),
              ),

              /// Date
              Expanded(
                child: Text(
                  orderHistoryData.orderUpdatedTime,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: _deviceDetails.getNormalFontSize(),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  // region Cancel / Refund Button by Type
  Widget cancelRefundButtonByType(
    OrderHistoryType type,
    String orderID,
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    if (type == OrderHistoryType.ToShip) {
      return getCancelButton(orderID, _deviceDetails, _widgetSize);
    } else if (type == OrderHistoryType.ToRate) {
      return getRefundButton(orderID, _deviceDetails, _widgetSize);
    }
    return Container();
  }

  Widget getCancelButton(
    String orderID,
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return Expanded(
      child: Align(
        alignment: FractionalOffset.bottomRight,
        child: Column(
          children: [
            SizedBox(height: 10),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomRight,
                child: InkWell(
                  onTap: () {
                    /// Message
                    showMessage(
                      'Cancel $orderID',
                      'This Feature Not Available Yet',
                      _deviceDetails,
                      context,
                    );
                  },
                  child: Container(
                    width: _widgetSize.getResponsiveWidth(0.25, 0.25, 0.25),
                    decoration: BoxDecoration(
                        color: Theme.of(context).shadowColor,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5)),
                    child: Center(
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: _deviceDetails.getNormalFontSize(),
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getRefundButton(
    String orderID,
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return Expanded(
      child: Align(
        alignment: FractionalOffset.bottomRight,
        child: Column(
          children: [
            SizedBox(height: 10),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomRight,
                child: InkWell(
                  onTap: () {
                    /// Message
                    showMessage(
                      'Refund $orderID',
                      'This Feature Not Available Yet',
                      _deviceDetails,
                      context,
                    );
                  },
                  child: Container(
                    width: _widgetSize.getResponsiveWidth(0.25, 0.25, 0.25),
                    decoration: BoxDecoration(
                        color: Theme.of(context).shadowColor,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5)),
                    child: Center(
                      child: Text(
                        "Refund",
                        style: TextStyle(
                          fontSize: _deviceDetails.getNormalFontSize(),
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // endregion

  // endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    orderHistoryData =
        ModalRoute.of(context)?.settings.arguments as OrderHistoryClass;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 10,
        shadowColor: Colors.black,
        leading: IconButton(
          color: Theme.of(context).primaryColor,
          iconSize: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          icon: Icon(Icons.arrow_back_ios_sharp),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Order Details",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: _deviceDetails.getTitleFontSize() + 2,
            color: Theme.of(context).primaryColor,
          ),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: SafeArea(
        child: Scrollbar(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
              minWidth: MediaQuery.of(context).size.width,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: getPageContent(
                  _deviceDetails,
                  _widgetSize,
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  List<Widget> getPageContent(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    List<Widget> pageContent = <Widget>[];

    // region Delivery Status
    /// To Ship + Express Delivery
    if (orderHistoryData.type == OrderHistoryType.ToShip &&
        orderHistoryData.deliveryType == "Express Delivery")
      pageContent.add(getDeliveryStatus(_deviceDetails, _widgetSize,
          'Product will be shipped out within 2 hours'));

    /// To Ship + Standard Delivery
    if (orderHistoryData.type == OrderHistoryType.ToShip &&
        orderHistoryData.deliveryType == "Standard Delivery")
      pageContent.add(getDeliveryStatus(
          _deviceDetails, _widgetSize, 'Product will be shipped out soon'));

    /// To Receive
    if (orderHistoryData.type == OrderHistoryType.ToReceive)
      pageContent.add(getDeliveryStatus(
          _deviceDetails, _widgetSize, 'Your order is on the way'));
    // endregion

    /// Delivery Type
    pageContent.add(getDeliveryType(_deviceDetails, _widgetSize));

    /// Delivery Address
    pageContent.add(getDeliveryAddress(_deviceDetails, _widgetSize));

    /// Each Order Branch Name & Status
    pageContent.add(Padding(
      padding: EdgeInsets.only(
          top: _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03)),
      child: Container(
        color: Theme.of(context).shadowColor,
        width: _widgetSize.getResponsiveWidth(1, 1, 1),
        height: _widgetSize.getResponsiveWidth(0.12, 0.12, 0.12),
        padding: EdgeInsets.fromLTRB(
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          0,
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Spacing
            Row(
              children: [
                /// Store Icon
                Container(
                  width: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                  child: Image.asset(
                    'assets/icon/store.png',
                    color: Theme.of(context).primaryColor,
                  ),
                ),

                /// Spacing
                SizedBox(
                    width: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),

                Text(
                  orderHistoryData.branchName,
                  style: TextStyle(
                    fontSize: _deviceDetails.getTitleFontSize(),
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            if (orderHistoryData.type == OrderHistoryType.ToPay)
              Text(
                'To Pay',
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).highlightColor,
                  fontWeight: FontWeight.w600,
                ),
              ),

            if (orderHistoryData.type == OrderHistoryType.ToShip)
              Text(
                'To Ship',
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).highlightColor,
                  fontWeight: FontWeight.w600,
                ),
              ),

            if (orderHistoryData.type == OrderHistoryType.ToReceive)
              Text(
                'To Receive',
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).highlightColor,
                  fontWeight: FontWeight.w600,
                ),
              ),

            /// Completed
            if (orderHistoryData.type == OrderHistoryType.ToRate)
              Text(
                'Completed',
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).highlightColor,
                  fontWeight: FontWeight.w600,
                ),
              ),

            /// Cancelled
            if (orderHistoryData.type == OrderHistoryType.Cancelled)
              Text(
                'Cancelled',
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),

            /// Refund
            if (orderHistoryData.type == OrderHistoryType.Refund)
              Text(
                'Refunded',
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),

            /// Pending Cancelled
            if (orderHistoryData.type == OrderHistoryType.PendingCancel)
              Text(
                'Pending Cancel Request',
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Colors.yellow,
                  fontWeight: FontWeight.w500,
                ),
              ),

            /// Pending Refund
            if (orderHistoryData.type == OrderHistoryType.PendingRefund)
              Text(
                'Pending Refund Request',
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Colors.yellow,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    ));

    /// Each Order Details
    for (int orderDetailsIndex = 0;
        orderDetailsIndex < orderHistoryData.orderDetailsList.length;
        ++orderDetailsIndex) {
      pageContent.add(
        Container(
          height: _widgetSize.getResponsiveWidth(0.3, 0.3, 0.3),
          decoration: BoxDecoration(
            color: Theme.of(context).shadowColor,
            border: Border(
              bottom: BorderSide(
                width: 0.7,
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
            0,
            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
            0,
          ),
          child: CustomCheckOutUI(
            quantity:
                orderHistoryData.orderDetailsList[orderDetailsIndex].quantity,
            title: orderHistoryData
                .orderDetailsList[orderDetailsIndex].product_Name,
            titleColor: Theme.of(context).primaryColor,
            fontColor: Theme.of(context).highlightColor,
            finalPrice: formatCurrency
                .format(double.parse(
                    orderHistoryData.orderDetailsList[orderDetailsIndex].price))
                .toString(),
            networkImagePath:
                orderHistoryData.orderDetailsList[orderDetailsIndex].image,
            spacing: true,
            // customButton: cancelRefundButtonByType(
            //   orderHistoryData.type,
            //   orderHistoryData.orderDetailsList[orderDetailsIndex].order_Details_ID,
            //   _deviceDetails,
            //   _widgetSize,
            // ),
            bgColor: Theme.of(context).shadowColor,
            maxLine: 2,
            shadowValue: 0,
            contentPaddingTop:
                _widgetSize.getResponsiveHeight(0.02, 0.02, 0.02),
            contentPaddingBottom:
                _widgetSize.getResponsiveHeight(0.02, 0.02, 0.02),
            contentPaddingLeft: 0,
            contentPaddingRight: 0,
          ),
        ),
      );
    }

    /// Order Details Total
    pageContent.add(getEachOrderTotalUI(_deviceDetails, _widgetSize));

    /// Spacing
    pageContent.add(
        SizedBox(height: _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03)));

    /// Payment Method
    if (orderHistoryData.type != OrderHistoryType.ToPay)
      pageContent.add(getPaymentMethodUI(_deviceDetails, _widgetSize));

    /// Spacing
    pageContent.add(
        SizedBox(height: _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03)));

    /// OrderID + Order Created Time + Order Updated Time
    pageContent.add(getOrderTimelUI(_deviceDetails, _widgetSize));

    /// Spacing
    pageContent.add(
        SizedBox(height: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)));

    // /// Cancel Order
    // if (orderHistoryData.type == OrderHistoryType.ToShip)
    //   pageContent.add(InkWell(
    //     onTap: () {
    //       print("Tapped Cancel Order");
    //
    //       /// Message
    //       showDialog(
    //         context: context,
    //         barrierDismissible: true,
    //         builder: (BuildContext context) {
    //           return AlertDialog(
    //             backgroundColor: Theme.of(context).highlightColor,
    //             elevation: 10,
    //             scrollable: true,
    //             content: Text(
    //               "Cancel Order / Refund Not Available",
    //               style: TextStyle(
    //                 color: Colors.black,
    //                 fontWeight: FontWeight.w600,
    //               ),
    //             ),
    //             actions: [
    //               FlatButton(
    //                 child: Text(
    //                   "Ok",
    //                   style: TextStyle(
    //                     color: Colors.black,
    //                   ),
    //                 ),
    //                 onPressed: () {
    //                   setState(() {
    //                     Navigator.pop(context);
    //                   });
    //                 },
    //               ),
    //             ],
    //           );
    //         },
    //       );
    //     },
    //     child: Container(
    //       width: _widgetSize.getResponsiveWidth(0.9),
    //       height: _widgetSize.getResponsiveWidth(0.1),
    //       decoration: BoxDecoration(
    //         color: Theme.of(context).backgroundColor,
    //         borderRadius: BorderRadius.circular(10),
    //         border: Border.all(color: Colors.grey),
    //       ),
    //       child: Center(
    //         child: Text(
    //           "Cancel Order / Refund",
    //           style: TextStyle(
    //             fontSize: _deviceDetails.getNormalFontSize(),
    //             fontWeight: FontWeight.w700,
    //             color: Colors.grey,
    //           ),
    //         ),
    //       ),
    //     ),
    //   ));
    //
    // /// Refund Order
    // if (orderHistoryData.type == OrderHistoryType.ToRate)
    //   pageContent.add(InkWell(
    //     onTap: () {
    //       print("Tapped Cancel Order");
    //
    //       /// Message
    //       showDialog(
    //         context: context,
    //         barrierDismissible: true,
    //         builder: (BuildContext context) {
    //           return AlertDialog(
    //             backgroundColor: Theme.of(context).highlightColor,
    //             elevation: 10,
    //             scrollable: true,
    //             content: Text(
    //               "Cancel Order / Refund Not Available",
    //               style: TextStyle(
    //                 color: Colors.black,
    //                 fontWeight: FontWeight.w600,
    //               ),
    //             ),
    //             actions: [
    //               FlatButton(
    //                 child: Text(
    //                   "Ok",
    //                   style: TextStyle(
    //                     color: Colors.black,
    //                   ),
    //                 ),
    //                 onPressed: () {
    //                   setState(() {
    //                     Navigator.pop(context);
    //                   });
    //                 },
    //               ),
    //             ],
    //           );
    //         },
    //       );
    //     },
    //     child: Container(
    //       width: _widgetSize.getResponsiveWidth(0.9),
    //       height: _widgetSize.getResponsiveWidth(0.1),
    //       decoration: BoxDecoration(
    //         color: Theme.of(context).backgroundColor,
    //         borderRadius: BorderRadius.circular(10),
    //         border: Border.all(color: Colors.grey),
    //       ),
    //       child: Center(
    //         child: Text(
    //           "Refund",
    //           style: TextStyle(
    //             fontSize: _deviceDetails.getNormalFontSize(),
    //             fontWeight: FontWeight.w700,
    //             color: Colors.grey,
    //           ),
    //         ),
    //       ),
    //     ),
    //   ));

    /// Spacing
    pageContent.add(
        SizedBox(height: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)));

    // /// Order Received
    // if (orderHistoryData.type == OrderHistoryType.ToReceive)
    //   pageContent.add(InkWell(
    //     onTap: () {
    //       print("Tapped Order Received");
    //     },
    //     child: Container(
    //       width: _widgetSize.getResponsiveWidth(0.9),
    //       height: _widgetSize.getResponsiveWidth(0.1),
    //       decoration: BoxDecoration(
    //           color: Theme.of(context).highlightColor,
    //           borderRadius: BorderRadius.circular(10)),
    //       child: Center(
    //         child: Text(
    //           "Order Received",
    //           style: TextStyle(
    //             fontSize: _deviceDetails.getNormalFontSize(),
    //             fontWeight: FontWeight.w700,
    //             color: Theme.of(context).backgroundColor,
    //           ),
    //         ),
    //       ),
    //     ),
    //   ));

    /// Pay Now
    if (orderHistoryData.type == OrderHistoryType.ToPay)
      pageContent.add(InkWell(
        onTap: () {
          print("Tapped Pay Now");

          /// Message
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Theme.of(context).highlightColor,
                elevation: 10,
                scrollable: true,
                content: Text(
                  "Pay Now Not Available",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text(
                      "Ok",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        Navigator.pop(context);
                      });
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Container(
          width: _widgetSize.getResponsiveWidth(0.9, 0.9, 0.9),
          height: _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
          decoration: BoxDecoration(
              color: Theme.of(context).highlightColor,
              borderRadius: BorderRadius.circular(10)),
          child: Center(
            child: Text(
              "Pay Now",
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize(),
                fontWeight: FontWeight.w700,
                color: Theme.of(context).backgroundColor,
              ),
            ),
          ),
        ),
      ));

    /// Spacing
    pageContent.add(
        SizedBox(height: _widgetSize.getResponsiveWidth(0.25, 0.25, 0.25)));

    return pageContent;
  }
}
