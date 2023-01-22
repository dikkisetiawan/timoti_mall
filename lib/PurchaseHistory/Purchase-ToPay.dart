import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:timoti_project/Account/PurchaseHistory/Purchase-OrderDetails.dart';
import 'package:timoti_project/Address-Page/AddressClass.dart';
import 'package:timoti_project/Custom-UI/Custom-CheckOutUI.dart';
import 'package:timoti_project/Custom-UI/Custom-LoadingUI.dart';
import 'package:timoti_project/Custom-UI/Custom-ShippingTotal.dart';
import 'package:timoti_project/Data-Class/OrderDetailClass.dart';
import 'package:timoti_project/Data-Class/OrderHistoryClass.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';
import 'package:timoti_project/enums/OrderHistoryType.dart';
import 'package:timoti_project/main.dart';

class ToPayPage extends StatefulWidget {
  // static const routeName = '/Coming-Soon-Page';

  @override
  _ToPayPageState createState() => _ToPayPageState();
}

class _ToPayPageState extends State<ToPayPage> {
  /// Testing Purpose
  bool debugMode = false;
  String testUserID = '103195359606008710233';

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
  bool hasMore = true;

  List<OrderHistoryClass> orderHistoryList = <OrderHistoryClass>[];
  bool firstLoad = false;

  @override
  void initState() {
    /// Get User data
    firebaseUser = FirebaseAuth.instance.currentUser as User;
    print(firebaseUser.displayName);
    if (debugMode == true) {
      /// Test Get Order Data
      getOrderData(testUserID);
    } else {
      /// Get Order Data
      getOrderData(firebaseUser.uid);
    }

    // FirebaseAuth.instance.currentUser().then((value) {
    //   print(value.displayName);
    //   print(value.uid);
    //   firebaseUser = value;
    //
    //   if (debugMode == true) {
    //     /// Test Get Order Data
    //     getOrderData(testUserID);
    //   } else {
    //     /// Get Order Data
    //     getOrderData(firebaseUser.uid);
    //   }
    // });

    super.initState();
  }

  // region Query Condition
  /// Query Condition
  Future<void> getOrderData(String userData) async {
    if (!this.mounted) {
      return;
    }
    if (firebaseUser == null) {
      print("Didnt get User Data");
      return;
    }
    if (!hasMore) {
      print('No More Data');
      setState(() {
        isLoading = false;
        firstLoad = false;
      });
      return;
    }
    if (isLoading) {
      return;
    }

    isLoading = true;
    setState(() {});

    QuerySnapshot orderSnapshot;

    /// First Time Load
    if (lastDocument == null) {
      firstLoad = true;
      isLoading = false;
      setState(() {});
      print("documentLimit : " + dataLimit.toString());

      orderSnapshot = await firestore
          .collection('Orders')
          .where("Customer_ID", isEqualTo: userData)
          .where("Financial_Status", isEqualTo: 'unpaid')
          .where("Order_Financial_Status", isEqualTo: 'unpaid')
          .orderBy("Order_Created_At", descending: true)
          .limit(dataLimit)
          .get();
    }

    /// Load more data
    else {
      firstLoad = false;
      setState(() {});
      print("Has more data");
      orderSnapshot = await firestore
          .collection('Orders')
          .where("Customer_ID", isEqualTo: userData)
          .where("Financial_Status", isEqualTo: 'unpaid')
          .where("Order_Financial_Status", isEqualTo: 'unpaid')
          .orderBy("Order_Created_At", descending: true)
          .startAfterDocument(lastDocument as DocumentSnapshot)
          .limit(dataLimit)
          .get();
    }
    // print("Watch me ====");
    // orderSnapshot.docs.forEach((element) {
    //   print(element.documentID);
    // });
    getOrderDataEx(orderSnapshot);
  }
  // endregion

  // region UI
  /// Each Shipping Status
  Widget getEachShippingStatus(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    OrderHistoryType type,
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
      child: Row(
        children: [
          Container(
            width: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
            child: Image.asset(
              'assets/icon/shipping.png',
              color: Theme.of(context).highlightColor,
            ),
          ),

          /// Spacing
          SizedBox(width: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),

          if (type == OrderHistoryType.ToPay)
            Text(
              "You have unpaid order",
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize() - 2,
                color: Theme.of(context).highlightColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (type == OrderHistoryType.ToShip)
            Text(
              "Your order is ready to be ship",
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize() - 2,
                color: Theme.of(context).highlightColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (type == OrderHistoryType.ToReceive)
            Text(
              "Your items are ready to be receive",
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize() - 2,
                color: Theme.of(context).highlightColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (type == OrderHistoryType.ToRate)
            Text(
              "Your items have been delivered",
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize() - 2,
                color: Theme.of(context).highlightColor,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  /// Each Order Details
  Widget getEachOrderDetails(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    OrderHistoryClass data,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// To Ship in Express
          if (data.type == OrderHistoryType.ToShip &&
              data.deliveryType == "Express Delivery")
            Container(
              width: _widgetSize.getResponsiveWidth(0.9, 0.9, 0.9),
              child: Text(
                'Product will be shipped out within 2 hours [Express Delivery]',
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize() - 2,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (data.type == OrderHistoryType.ToShip &&
              data.deliveryType == "Standard Delivery")
            Container(
              width: _widgetSize.getResponsiveWidth(0.9, 0.9, 0.9),
              child: Text(
                'Product will be shipped out soon [Standard Delivery]',
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize() - 2,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (data.type == OrderHistoryType.ToShip &&
              data.deliveryType == "Pick Up")
            Container(
              width: _widgetSize.getResponsiveWidth(0.9, 0.9, 0.9),
              child: Text(
                'Please Pick Up your order',
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize() - 2,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          /// To Receive
          if (data.type == OrderHistoryType.ToReceive)
            Container(
              width: _widgetSize.getResponsiveWidth(0.8, 0.8, 0.8),
              child: Text(
                'Confirm receipt of products by ${data.orderUpdatedTime}',
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize() - 2,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          /// To Rate
          if (data.type == OrderHistoryType.ToRate)
            Container(
              width: _widgetSize.getResponsiveWidth(0.6, 0.6, 0.6),
              child: Text(
                'Your items has been delivered',
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize() - 2,
                  color: Theme.of(context).highlightColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          // region Message for Cancelled, Refund, Pending Request
          if (data.type == OrderHistoryType.Cancelled)
            Container(
              width: _widgetSize.getResponsiveWidth(0.9, 0.9, 0.9),
              child: Text(
                'This Order has been Cancelled',
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize() - 2,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (data.type == OrderHistoryType.Refund)
            Container(
              width: _widgetSize.getResponsiveWidth(0.9, 0.9, 0.9),
              child: Text(
                'This Order has been Refunded',
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize() - 2,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (data.type == OrderHistoryType.PendingRefund)
            Container(
              width: _widgetSize.getResponsiveWidth(0.9, 0.9, 0.9),
              child: Text(
                'Your Refund request is processing',
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize() - 2,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (data.type == OrderHistoryType.PendingCancel)
            Container(
              width: _widgetSize.getResponsiveWidth(0.9, 0.9, 0.9),
              child: Text(
                'Your Cancel request is processing',
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize() - 2,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          // endregion

          /// To Pay
          if (data.type == OrderHistoryType.ToPay)
            Container(
              width: _widgetSize.getResponsiveWidth(0.6, 0.6, 0.6),
              child: Text(
                'You have pending payment for this order',
                style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize() - 2,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (data.type == OrderHistoryType.ToPay)
            InkWell(
              onTap: () {
                print("Tapped Pay now");
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
                width: _widgetSize.getResponsiveWidth(0.25, 0.25, 0.25),
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
            ),
        ],
      ),
    );
  }
  // endregion

  // region Function
  /// Get Actual Order Data
  Future<void> getOrderDataEx(QuerySnapshot orderSnapshot) async {
    print('Data Length:' + orderSnapshot.docs.length.toString());
    if (orderSnapshot.docs.length == 0) {
      setState(() {
        isLoading = false;
        firstLoad = false;
      });
      return;
    }
    if (orderSnapshot.docs.length < dataLimit) {
      hasMore = false;
    }

    /// Get last document
    lastDocument = orderSnapshot.docs[orderSnapshot.docs.length - 1];

    Map<String, dynamic> orderData = Map<String, dynamic>();

    /// Loop Data
    for (int i = 0; i < orderSnapshot.docs.length; ++i) {
      orderData = orderSnapshot.docs[i].data() as Map<String, dynamic>;

      String targetOrderID = orderData["Order_ID"];
      String branchID = orderData["Provider_ID"];

      /// Get Order Details Data
      QuerySnapshot orderDetailsSnapshot;
      orderDetailsSnapshot = await firestore
          .collection('Order Details')
          .where("Order_ID", isEqualTo: targetOrderID)
          .get();

      if (orderDetailsSnapshot.docs.length > 0) {
        print('===== Order [${orderData['Order_ID']}] =============');

        // region Branch Data
        DocumentSnapshot branchSnapshot;
        branchSnapshot =
            await firestore.collection('Branches').doc(branchID).get();

        /// Define Map for Branch Data
        Map<String, dynamic> branchData = Map<String, dynamic>();
        branchData = branchSnapshot.data() as Map<String, dynamic>;
        // endregion

        List<OrderDetailsClass> orderDetailsList = <OrderDetailsClass>[];
        OrderDetailsClass temp;

        /// Define Map Order Details Data
        Map<String, dynamic> orderDetailsData = Map<String, dynamic>();

        /// For Loop all order details
        for (int orderDetailsIndex = 0;
            orderDetailsIndex < orderDetailsSnapshot.docs.length;
            ++orderDetailsIndex) {
          orderDetailsData = orderDetailsSnapshot.docs[orderDetailsIndex].data()
              as Map<String, dynamic>;

          /// Reach Last Index
          if (orderDetailsIndex == orderDetailsSnapshot.docs.length - 1) {
            /// Assign and add Order Details to List
            temp = new OrderDetailsClass(
              order_ID: orderData['Order_ID'],
              order_Details_ID: orderDetailsSnapshot.docs[orderDetailsIndex].id,
              provider_ID: branchID,
              image: orderDetailsData['Image'],
              quantity: orderDetailsData['Quantity'],
              price: orderDetailsData['Price'],
              product_ID: orderDetailsData['Product_ID'],
              product_ID_Base: orderDetailsData['Product_ID_Base'],
              product_Name: orderDetailsData['Product_Name'],
              variant_ID: orderDetailsData['Variant_ID'] != null
                  ? orderDetailsData['Variant_ID']
                  : "NO VARIANT ID DEFINE",
              variant_Name: orderDetailsData['Variant_Name'] != null
                  ? orderDetailsData['Variant_Name']
                  : "NO VARIANT ID DEFINE",
            );
            orderDetailsList.add(temp);
            print("Order Details: " +
                orderDetailsSnapshot.docs[orderDetailsIndex].id);

            // region Order History Type
            OrderHistoryType targetType = OrderHistoryType.ToPay;

            /// Cancelled
            if (orderData['Order_Cancelled_Status'] == true) {
              targetType = OrderHistoryType.Cancelled;
            }

            /// Refund
            else if (orderData['Refund_Status'] == true) {
              targetType = OrderHistoryType.Refund;
            }

            /// Request Cancel Order
            else if (orderData['Order_Cancelled_Request_Status'] == true) {
              targetType = OrderHistoryType.PendingCancel;
            }

            /// To Pay, To Ship, To Receive, Completed
            else {
              /// Ship
              if (orderData['Financial_Status'] == 'paid' &&
                  orderData['Order_Financial_Status'] == 'paid') {
                /// Receive
                if (orderData['Order_Fulfillment_Status'] != 'unfulfilled') {
                  /// Received (To Rate)
                  if (orderData['Order_Received_Status'] == true) {
                    targetType = OrderHistoryType.ToRate;
                  } else {
                    targetType = OrderHistoryType.ToReceive;
                  }
                } else {
                  targetType = OrderHistoryType.ToShip;
                }
              }
            }

            // endregion

            // region Address Data
            AddressClass targetAddressData = new AddressClass(
              addressDetails: orderData['Order_Shipping_Address'],
              city: orderData['Order_Shipping_Address_City'],
              postcode: orderData['Order_Shipping_Address_Zip'],
              state: orderData['Order_Shipping_Address_Province'] != ''
                  ? orderData['Order_Shipping_Address_Province']
                  : "NO STATE DEFINE",
              country: orderData['Order_Shipping_Address_Country'],
              fullName: orderData['Order_Shipping_Address_First_Name'],
              phone: orderData['Order_Shipping_Address_Phone'],
              email: orderData['Order_Shipping_Address_Email'],
            );
            // endregion

            String order_CreatedTime = DateFormat('yyyy-MM-dd h:mm a')
                .format(DateTime.parse(orderData['Order_Created_At']));
            String order_UpdatedTime = DateFormat('yyyy-MM-dd h:mm a')
                .format(DateTime.parse(orderData['Order_Updated_At']));

            /// Assign and add Order to List (Final List)
            OrderHistoryClass data = new OrderHistoryClass(
              hasTrackingData: hasTrackingStatus(targetType),
              orderDetailsList: orderDetailsList,
              order_ID: orderData['Order_ID'],
              branchName: branchData["Area"],
              provider_ID: branchID,
              customer_ID: testUserID,
              customer_Name: testUserID,
              orderCreatedTime: order_CreatedTime,
              orderUpdatedTime: order_UpdatedTime,
              total_Price: orderData['Total_Price'],
              total_Shipping: orderData['Total_Shipping'],
              total_Amount: orderData['Total_Amount'],
              order_subtotal_price: orderData['Order_Subtotal_Price'],
              order_total_discount: orderData['Order_Total_Discount'],
              paymentMethod: orderData['Payment_Method'] != ''
                  ? orderData['Payment_Method']
                  : "NO DEFINE PAYMENT METHOD",
              type: targetType,
              payStatus: orderData['Financial_Status'] == 'paid' &&
                      orderData['Order_Financial_Status'] == 'paid'
                  ? true
                  : false,
              receivedDate: orderData['receivedAt'] != 'false'
                  ? orderData['receivedAt']
                  : null,
              addressData: targetAddressData,
              deliveryType: orderData['Delivery_Type'] != ''
                  ? orderData['Delivery_Type']
                  : "Standard Delivery",
            );
            orderHistoryList.add(data);
            print("Added Order to Final List: " + orderData['Order_ID']);
            print("Type: " + targetType.toString());
            // print("First Order Details ID: " +
            //     orderHistoryList[i].orderDetailsList[0].order_Details_ID);
            // print("First Product ID: " +
            //     orderHistoryList[i].orderDetailsList[0].product_ID);
            // print("First Product Name: " +
            //     orderHistoryList[i].orderDetailsList[0].product_Name);
          } else {
            /// Assign and add Order Details to List
            temp = new OrderDetailsClass(
              order_ID: orderData['Order_ID'],
              order_Details_ID: orderDetailsSnapshot.docs[orderDetailsIndex].id,
              provider_ID: branchID,
              image: orderDetailsData['Image'],
              quantity: orderDetailsData['Quantity'],
              price: orderDetailsData['Price'],
              product_ID: orderDetailsData['Product_ID'],
              product_ID_Base: orderDetailsData['Product_ID_Base'],
              product_Name: orderDetailsData['Product_Name'],
              variant_ID: orderDetailsData['Variant_ID'] != null
                  ? orderDetailsData['Variant_ID']
                  : "NO VARIANT ID DEFINE",
              variant_Name: orderDetailsData['Variant_Name'] != null
                  ? orderDetailsData['Variant_Name']
                  : "NO VARIANT ID DEFINE",
            );
            orderDetailsList.add(temp);

            print("Order Details: " +
                orderDetailsSnapshot.docs[orderDetailsIndex].id);
          }
        }
      } else {
        print("No Order Details Found for order: " + targetOrderID);
      }
    }

    setState(() {
      isLoading = false;
      firstLoad = false;
    });
  }

  bool hasTrackingStatus(OrderHistoryType type) {
    bool temp = true;
    if (type == OrderHistoryType.ToPay) {
      temp = false;
    } else if (type == OrderHistoryType.Cancelled) {
      temp = false;
    } else if (type == OrderHistoryType.Refund) {
      temp = false;
    } else if (type == OrderHistoryType.PendingCancel) {
      temp = false;
    } else if (type == OrderHistoryType.PendingRefund) {
      temp = false;
    }
    return temp;
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Scrollbar(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
              minWidth: MediaQuery.of(context).size.width,
            ),
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
                  if (firebaseUser != null) {
                    if (debugMode == true) {
                      getOrderData(testUserID);
                    } else {
                      getOrderData(firebaseUser.uid);
                    }
                  }
                }
                return false;
              },
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
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  List<Widget> getPageContent(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    List<Widget> pageContent = <Widget>[];

    if (firstLoad == true) {
      /// First Loading
      pageContent.add(SizedBox(
        height: _widgetSize.getResponsiveHeight(0.15, 0.15, 0.15),
      ));
      pageContent.add(Padding(
        padding: EdgeInsets.fromLTRB(
            _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
            _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
            0),
        child: CustomLoading(),
      ));
    } else {
      /// Has Data
      if (orderHistoryList.length > 0) {
        for (int i = 0; i < orderHistoryList.length; ++i) {
          /// Each Order Branch Name
          pageContent.add(InkWell(
            onTap: () {
              /// Go To Order Details
              Navigator.of(context).pushNamed(
                OrderDetailsPage.routeName,
                arguments: orderHistoryList[i],
              );
            },
            child: Padding(
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
                          width:
                              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                          child: Image.asset(
                            'assets/icon/store.png',
                            color: Theme.of(context).primaryColor,
                          ),
                        ),

                        /// Spacing
                        SizedBox(
                            width: _widgetSize.getResponsiveWidth(
                                0.05, 0.05, 0.05)),

                        Text(
                          orderHistoryList[i].branchName,
                          style: TextStyle(
                            fontSize: _deviceDetails.getTitleFontSize(),
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),

                    // /// Testing Order ID
                    // if (debugMode == true)
                    //   Text(
                    //     ' [${orderHistoryList[i].order_ID}]',
                    //     style: TextStyle(
                    //       fontSize: _deviceDetails.getTitleFontSize(),
                    //       color: Colors.grey,
                    //       fontWeight: FontWeight.w800,
                    //     ),
                    //   ),

                    /// To Pay
                    if (orderHistoryList[i].type == OrderHistoryType.ToPay)
                      Text(
                        'To Pay',
                        style: TextStyle(
                          fontSize: _deviceDetails.getNormalFontSize(),
                          color: Theme.of(context).highlightColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                    /// To Ship
                    if (orderHistoryList[i].type == OrderHistoryType.ToShip)
                      Text(
                        'To Ship',
                        style: TextStyle(
                          fontSize: _deviceDetails.getNormalFontSize(),
                          color: Theme.of(context).highlightColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                    /// To Receive
                    if (orderHistoryList[i].type == OrderHistoryType.ToReceive)
                      Text(
                        'To Receive',
                        style: TextStyle(
                          fontSize: _deviceDetails.getNormalFontSize(),
                          color: Theme.of(context).highlightColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                    /// Completed
                    if (orderHistoryList[i].type == OrderHistoryType.ToRate)
                      Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: _deviceDetails.getNormalFontSize(),
                          color: Theme.of(context).highlightColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                    /// Cancelled
                    if (orderHistoryList[i].type == OrderHistoryType.Cancelled)
                      Text(
                        'Cancelled',
                        style: TextStyle(
                          fontSize: _deviceDetails.getNormalFontSize(),
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                    /// Refund
                    if (orderHistoryList[i].type == OrderHistoryType.Refund)
                      Text(
                        'Refunded',
                        style: TextStyle(
                          fontSize: _deviceDetails.getNormalFontSize(),
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                    /// Pending Cancelled
                    if (orderHistoryList[i].type ==
                        OrderHistoryType.PendingCancel)
                      Text(
                        'Pending Cancel Request',
                        style: TextStyle(
                          fontSize: _deviceDetails.getNormalFontSize(),
                          color: Colors.yellow,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                    /// Pending Refund
                    if (orderHistoryList[i].type ==
                        OrderHistoryType.PendingRefund)
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
            ),
          ));

          /// Each Order Details
          for (int orderDetailsIndex = 0;
              orderDetailsIndex < orderHistoryList[i].orderDetailsList.length;
              ++orderDetailsIndex) {
            pageContent.add(
              InkWell(
                onTap: () {
                  /// Go To Order Details
                  Navigator.of(context).pushNamed(
                    OrderDetailsPage.routeName,
                    arguments: orderHistoryList[i],
                  );
                },
                child: Container(
                  height: _widgetSize.getResponsiveWidth(0.25, 0.25, 0.25),
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
                    quantity: orderHistoryList[i]
                        .orderDetailsList[orderDetailsIndex]
                        .quantity,
                    title: orderHistoryList[i]
                        .orderDetailsList[orderDetailsIndex]
                        .product_Name,
                    titleColor: Theme.of(context).primaryColor,
                    fontColor: Theme.of(context).highlightColor,
                    finalPrice: formatCurrency
                        .format(double.parse(orderHistoryList[i]
                            .orderDetailsList[orderDetailsIndex]
                            .price))
                        .toString(),
                    networkImagePath: orderHistoryList[i]
                        .orderDetailsList[orderDetailsIndex]
                        .image,
                    spacing: true,
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
              ),
            );
          }

          /// Each Order Shipping + Total Price
          pageContent.add(
            CustomShippingTotal(
              widgetSize: _widgetSize,
              deviceDetails: _deviceDetails,
              formatCurrency: formatCurrency,
              shippingPrice: orderHistoryList[i].total_Shipping,
              totalPrice: orderHistoryList[i].total_Amount,
              totalOrderLength: orderHistoryList[i].orderDetailsList.length,
              totalDiscount: orderHistoryList[i].order_total_discount != null
                  ? orderHistoryList[i].order_total_discount
                  : null,
              subtotal: orderHistoryList[i].order_subtotal_price,
            ),
          );

          /// Each Shipping Status
          if (orderHistoryList[i].hasTrackingData == true)
            pageContent.add(getEachShippingStatus(
              _deviceDetails,
              _widgetSize,
              orderHistoryList[i].type,
            ));

          /// Each Order Type
          if (orderHistoryList[i].deliveryType != null)
            pageContent.add(getEachOrderDetails(
              _deviceDetails,
              _widgetSize,
              orderHistoryList[i],
            ));

          /// State Checking
          // pageContent.add(Text("State: "+ orderHistoryList[i].addressData.state, style: TextStyle(
          //   color: Theme.of(context).primaryColor,
          // )));

          /// Payment Method Checking
          // pageContent.add(Text("Payment Method: "+ orderHistoryList[i].paymentMethod, style: TextStyle(
          //   color: Theme.of(context).primaryColor,
          // )));
        }
        if (hasMore == false)
          pageContent.add(
              SizedBox(height: _widgetSize.getResponsiveHeight(0.2, 0.2, 0.2)));
      }

      /// No Data
      else {
        pageContent.add(SizedBox(
          height: _widgetSize.getResponsiveHeight(0.15, 0.15, 0.15),
        ));
        pageContent.add(Icon(
          Icons.wysiwyg,
          color: Colors.grey,
          size: _widgetSize.getResponsiveWidth(0.25, 0.25, 0.25),
        ));

        pageContent.add(
          Padding(
            padding: EdgeInsets.fromLTRB(
                _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                0),
            child: Text(
              "Oops, Your Order History is Empty",
              style: TextStyle(
                fontSize: _deviceDetails.getTitleFontSize(),
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
        pageContent.add(
          Padding(
            padding: EdgeInsets.fromLTRB(
                _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
                _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                0),
            child: Text(
              "Check out more our ${App.appName} deals !",
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize(),
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    }

    if (isLoading == true) {
      pageContent.add(CustomLoading());
    }

    return pageContent;
  }
}
