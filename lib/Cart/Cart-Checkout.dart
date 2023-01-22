import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import '/Api/BillPlz-Payment-Api/Fetch-BillPlzPayment-Api.dart';
import '/Api/CashOnDelivery-Api/Fetch-CashOnDelivery-Api.dart';
import '/Api/Payex-Payment-Api/Fetch-PayexPayment-Api.dart';
import '/Api/WalletPayment-Api/Fetch-WalletPayment-Api.dart';
import '/Cart/Order-Completed-Page.dart';
import '/Cart/Payment-Failed-Page.dart';
import '/Custom-UI/Custom-LoadingUI.dart';
import '/Data-Class/PaymentMethodResultClass.dart';
import '/Functions/Messager.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '/Address-Page/Address-Main.dart';
import '/Address-Page/AddressClass.dart';
import '/Api/CreateOrder-Api/Fetch-CreateOrder-Api.dart';
import '/Api/CustomerToken-Api/Fetch-GetToken-Api.dart';
import '/Api/GkashPayment-Api/Fetch-GkashPayment-Api.dart';
import '/Api/TopUpWalletAndPay-Api/Fetch-TopUpWalletPayment-Api.dart';
import '/Cart/Payment-Method-Page.dart';
import '/Cart/Shipping-Option-Page.dart';
import '/CheckInternet/CheckInternetFunction.dart';
import '/Custom-UI/Custom-CheckOutUI.dart';
import '/Data-Class/BranchShippingClass.dart';
import '/Data-Class/CartCheckoutArgument.dart';
import '/Data-Class/CreateOrderClass.dart';
import '/Data-Class/CreateOrderDetailsClass.dart';
import '/Data-Class/ListCreateOrderClass.dart';
import '/Data-Class/ShippingDataClass.dart';
import '/Data-Class/VoucherDataClass.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';
import '/Screen-Size/ui-utils.dart';
import '/Webview/Webview-Web.dart';
import '/Webview/Webview.dart';
import '/enums/Payment-Method-Type.dart';
import '/enums/Shipping-Method-Type.dart';
import '/enums/VoucherType.dart';
import '/enums/device-screen-type.dart';
import '/main.dart';

import 'package:url_launcher/url_launcher.dart';

/* Important Note
First Index for ProductMap is to identify the whole branch status
Such as:
boolValue = item checkbox
totalPrice = total price of branch
shippingData = shipping details of branch
voucherData = voucher details of branch
priceAfterDiscount = total price after discount of branch
hasItemChecked = has item or not in the branch
 */

class CartCheckoutPage extends StatefulWidget {
  static const routeName = '/CartCheckoutPage';
  @override
  _CartCheckoutPageState createState() => _CartCheckoutPageState();
}

class _CartCheckoutPageState extends State<CartCheckoutPage> {
  bool printData = true;

  bool enableNotice = true;
  String usernameString = '';
  String emailString = '';
  String phoneNoString = '';

  PaymentMethodResultClass? paymentMethodTypeClass;

  /// Firebase
  User firebaseUser = FirebaseAuth.instance.currentUser as User;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool loaded = false;
  late CartCheckoutArgument data;
  bool shippingLoading = false;

  final formatCurrency = new NumberFormat.currency(
    locale: "ms-MY",
    symbol: "",
    decimalDigits: 2,
  );
  bool updatePrice = false;
  bool hasPaymentMethod = true;
  bool hasShippingAddress = true;
  AddressClass? shippingAddressData;
  String checkoutMessageString = '';

  List<ShippingData> shippingDataList = [];

  bool isLoading = false;
  String walletAmount = '0';

  /// For Voucher
  final TextEditingController voucherController = TextEditingController();
  bool voucherError = false;
  String voucherErrorMessage = '';

  double totalSubtotalAmount = 0.00;
  double totalShippingAmount = 0.00;
  double totalFinalAmount = 0.00;

  @override
  void initState() {
    /// Get Shipping Data
    getShippingData();

    /// Get User Data
    print(firebaseUser.displayName);

    getUserAddress();

    if (firebaseUser.displayName != null) {
      usernameString = firebaseUser.displayName as String;
    }
    if (firebaseUser.phoneNumber != null) {
      phoneNoString = firebaseUser.phoneNumber as String;
    }

    getEmail();
    getWalletAmountInit();

    updatePrice = true;
    super.initState();
  }

  @override
  void dispose() {
    voucherController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (loaded == false) {
      data = ModalRoute.of(context)?.settings.arguments as CartCheckoutArgument;
      loaded = true;
    }
  }

  void getEmail() async {
    DocumentSnapshot userData =
        await firestore.collection('Customers').doc(firebaseUser.uid).get();

    if (this.mounted) {
      /// Define Map Data
      Map<String, dynamic> uData = Map<String, dynamic>();

      /// Assign Data
      uData = userData.data() as Map<String, dynamic>;

      emailString = uData["Email"];
      setState(() {});
    }
  }

  // region UI
  /// Custom Button
  Widget getCustomButton(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    String price,
    String discountPrice,
    String discountPercent,
    int quantity,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          discountPrice,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            decoration: TextDecoration.lineThrough,
            fontSize: _deviceDetails.getNormalFontSize(),
            color: Colors.grey,
          ),
        ),
        Text(
          price,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: _deviceDetails.getNormalFontSize(),
            color: Theme.of(context).canvasColor,
          ),
        ),
        Text(
          "Qty: " + quantity.toString(),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: _deviceDetails.getNormalFontSize(),
            color: Theme.of(context).canvasColor,
          ),
        ),
      ],
    );
  }

  /// Custom App bar
  PreferredSize _getCustomAppBar(
    String title,
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
  ) {
    var mediaQuery = MediaQuery.of(context);

    return PreferredSize(
      preferredSize: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
          ? Size.fromHeight(55.0)
          : Size.fromHeight(80.0),
      child: Material(
        elevation: 8,
        shadowColor: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  decoration:
                      BoxDecoration(color: Theme.of(context).backgroundColor),
                ),
                SafeArea(
                  minimum: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                      ? EdgeInsets.fromLTRB(
                          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                          0,
                          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                          0,
                        )
                      : EdgeInsets.fromLTRB(
                          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                          0,
                          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                          0,
                        ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// back button
                      InkWell(
                        onTap: () =>
                            isLoading == false ? Navigator.pop(context) : null,
                        child: isLoading == false
                            ? Icon(
                                Icons.arrow_back_ios_sharp,
                                color: Theme.of(context).primaryColor,
                                size: _widgetSize.getResponsiveWidth(
                                    0.05, 0.05, 0.05),
                              )
                            : CustomLoading(),
                      ),

                      /// Title
                      SizedBox(
                        width:
                            getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                                ? _widgetSize.getResponsiveWidth(0.6, 0.6, 0.6)
                                : _widgetSize.getResponsiveWidth(0.5, 0.5, 0.5),
                        child: Center(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: _deviceDetails.getTitleFontSize(),
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      /// Empty
                      SizedBox(
                        width: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// User Info UI
  Widget getUserInfoUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        /// Empty Shipping Address
        if (shippingAddressData == null)
          Padding(
            padding: EdgeInsets.only(
                bottom: _widgetSize.getResponsiveHeight(0.01, 0.01, 0.01)),
            child: Container(
              color: hasShippingAddress == false
                  ? Colors.red
                  : Theme.of(context).shadowColor,
              child: ListTile(
                onTap: () {
                  goToSelectShippingAddress();
                },
                contentPadding: EdgeInsets.fromLTRB(
                    _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
                    _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02)),
                leading: Icon(
                  Icons.location_on,
                  size: _widgetSize.getResponsiveWidth(0.06, 0.06, 0.06),
                  color: hasShippingAddress == false
                      ? Theme.of(context).backgroundColor
                      : Colors.grey,
                ),
                title: Text(
                  'Please Select Shipping Address',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: _deviceDetails.getNormalFontSize(),
                    color: hasShippingAddress == false
                        ? Theme.of(context).backgroundColor
                        : Theme.of(context).primaryColor,
                  ),
                ),
                trailing: InkWell(
                  splashColor: Colors.transparent,
                  onTap: () {
                    goToSelectShippingAddress();
                  },
                  child: Text(
                    "Edit",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: hasShippingAddress == false
                          ? Theme.of(context).backgroundColor
                          : Theme.of(context).highlightColor,
                      fontSize: _deviceDetails.getNormalFontSize(),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),

        /// Shipping Address
        if (shippingAddressData != null)
          Padding(
            padding: EdgeInsets.only(
                bottom: _widgetSize.getResponsiveHeight(0.01, 0.01, 0.01)),
            child: Container(
              color: Theme.of(context).shadowColor,
              child: ListTile(
                onTap: () {
                  goToSelectShippingAddress();
                },
                contentPadding: EdgeInsets.fromLTRB(
                    _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
                    _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02)),
                leading: Icon(
                  Icons.location_on,
                  size: _widgetSize.getResponsiveWidth(0.06, 0.06, 0.06),
                  color: Colors.grey,
                ),
                title: Text(
                  'Deliver To ${shippingAddressData?.label}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: _deviceDetails.getNormalFontSize(),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                isThreeLine: true,
                subtitle: Text(
                  "${shippingAddressData?.fullName}"
                  "\n${shippingAddressData?.addressDetails}"
                  "\n${shippingAddressData?.postcode}, ${shippingAddressData?.city}, ${shippingAddressData?.state}",
                  style: TextStyle(
                    height: 1.5,
                    fontSize: _deviceDetails.getNormalFontSize() - 2,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                trailing: InkWell(
                  splashColor: Colors.transparent,
                  onTap: () {
                    goToSelectShippingAddress();
                  },
                  child: Text(
                    "Edit",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Theme.of(context).highlightColor,
                      fontSize: _deviceDetails.getNormalFontSize(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),

        if (shippingAddressData == null)
          Padding(
            padding: EdgeInsets.only(
                bottom: _widgetSize.getResponsiveHeight(0.01, 0.01, 0.01)),
            child: Container(
              color: Theme.of(context).shadowColor,
              child: ListTile(
                contentPadding: EdgeInsets.fromLTRB(
                    _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
                    _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02)),
                leading: Icon(
                  Icons.phone,
                  size: _widgetSize.getResponsiveWidth(0.06, 0.06, 0.06),
                  color: Colors.grey,
                ),
                title: Text(
                  'xxx - xxxxxxxxx',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: _deviceDetails.getNormalFontSize(),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),

        /// Contact
        if (shippingAddressData != null)
          Padding(
            padding: EdgeInsets.only(
                bottom: _widgetSize.getResponsiveHeight(0.01, 0.01, 0.01)),
            child: Container(
              color: Theme.of(context).shadowColor,
              child: ListTile(
                contentPadding: EdgeInsets.fromLTRB(
                    _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
                    _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02)),
                leading: Icon(
                  Icons.phone,
                  size: _widgetSize.getResponsiveWidth(0.06, 0.06, 0.06),
                  color: Colors.grey,
                ),
                title: Text(
                  shippingAddressData?.phone != null
                      ? shippingAddressData?.phone as String
                      : '',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: _deviceDetails.getNormalFontSize(),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),

        /// Email
        Padding(
          padding: EdgeInsets.only(
              bottom: _widgetSize.getResponsiveHeight(0.01, 0.01, 0.01)),
          child: Container(
            color: Theme.of(context).shadowColor,
            child: ListTile(
              contentPadding: EdgeInsets.fromLTRB(
                  _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                  _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
                  _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                  _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02)),
              leading: Icon(
                Icons.email,
                size: _widgetSize.getResponsiveWidth(0.06, 0.06, 0.06),
                color: Colors.grey,
              ),
              title: Text(
                emailString,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Order Details Text UI
  Widget getOrderDetailsUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return ListTile(
      leading: Icon(
        Icons.label,
        size: _widgetSize.getResponsiveWidth(0.06, 0.06, 0.06),
        color: Theme.of(context).highlightColor,
      ),
      title: Text(
        "Order Details",
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: _deviceDetails.getTitleFontSize(),
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  // region Calculation UI
  /// Each Branch Subtotal Items UI
  Widget getEachBranchSubTotalUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    String branchName,
  ) {
    return Container(
      color: Theme.of(context).shadowColor,
      padding: EdgeInsets.fromLTRB(
        0,
        _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
        _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          /// Subtotal
          Text(
            'Subtotal',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: _deviceDetails.getNormalFontSize(),
              color: Theme.of(context).primaryColor,
            ),
          ),

          ///Spacing
          SizedBox(width: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),

          /// Price
          if (data.productsMap[branchName]?[0].totalPrice != null)
            Text(
              "RM " +
                  formatCurrency
                      .format(getBranchSubTotalPrice(branchName))
                      .toString(),
              style: TextStyle(
                decoration: TextDecoration.lineThrough,
                fontWeight: FontWeight.w600,
                fontSize: _deviceDetails.getTitleFontSize(),
                color: Theme.of(context).highlightColor,
              ),
            ),
          if (data.productsMap[branchName]?[0].totalPrice == null)
            Text(
              "RM " + formatCurrency.format(0).toString(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: _deviceDetails.getTitleFontSize(),
                color: Theme.of(context).highlightColor,
              ),
            ),
        ],
      ),
    );
  }

  /// Each Branch Voucher UI
  Widget getEachBranchVoucherUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    String branchName,
  ) {
    return Container(
      width: _widgetSize.getResponsiveWidth(1, 1, 1),
      decoration: BoxDecoration(
        color: Theme.of(context).shadowColor,
        // color: Theme.of(context).backgroundColor,
        // border: Border(
        //   top: BorderSide(
        //     width: 0.5,
        //     color: Theme.of(context).primaryColor,
        //   ),
        //   bottom: BorderSide(
        //     width: 0.5,
        //     color: Theme.of(context).primaryColor,
        //   ),
        // ),
      ),
      padding: EdgeInsets.only(
        right: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          /// Voucher Code
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              /// Voucher Applied Title
              if (data.productsMap[branchName]?[0].voucherData != null)
                Text(
                  'Store Voucher',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: _deviceDetails.getNormalFontSize(),
                    color: Theme.of(context).primaryColor,
                  ),
                ),

              /// Voucher Code
              if (data.productsMap[branchName]?[0].voucherData != null)
                Text(
                  " (" +
                      data.productsMap[branchName]![0].voucherData!
                          .voucherCode +
                      ")",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: _deviceDetails.getNormalFontSize(),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
            ],
          ),

          ///Spacing
          SizedBox(width: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),

          /// Voucher Discount price
          Text(
            "-RM " +
                formatCurrency
                    .format(getVoucherDiscountPrice(branchName))
                    .toString(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: _deviceDetails.getTitleFontSize(),
              color: Theme.of(context).highlightColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Each Branch Total Price UI
  Widget getEachBranchTotalUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    String branchName,
  ) {
    double priceAfterDiscount =
        data.productsMap[branchName]![0].totalPrice as double;

    /// Price After Discount = Branch Total Price - Voucher Discount Price
    priceAfterDiscount -= getVoucherDiscountPrice(branchName);

    /// Assign priceAfterDiscount
    data.productsMap[branchName]?[0].priceAfterDiscount = priceAfterDiscount;

    /// Update Price
    priceUpdate();

    return Container(
      color: Theme.of(context).shadowColor,
      padding: EdgeInsets.fromLTRB(
        0,
        _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
        _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "Total Item  (${data.productsMap[branchName]!.length - 1})",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: _deviceDetails.getNormalFontSize(),
              color: Theme.of(context).primaryColor,
            ),
          ),

          ///Spacing
          SizedBox(width: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),

          /// Price
          if (priceAfterDiscount >= 0)
            Text(
              "RM " + formatCurrency.format(priceAfterDiscount).toString(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: _deviceDetails.getTitleFontSize(),
                color: Theme.of(context).primaryColor,
              ),
            ),

          /// Price
          if (priceAfterDiscount < 0)
            Text(
              "RM " + formatCurrency.format(0).toString(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: _deviceDetails.getTitleFontSize(),
                color: Theme.of(context).primaryColor,
              ),
            ),
        ],
      ),
    );
  }
  // endregion

  /// Each Branch Total Items UI
  Widget getEachBranchShippingUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    String branchName,
  ) {
    return Container(
      color: Theme.of(context).shadowColor,
      padding: EdgeInsets.fromLTRB(
        _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        0,
        _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        0,
      ),
      child: Container(
        width: _widgetSize.getResponsiveWidth(1, 1, 1),
        decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            border: Border.all(
              color: Colors.black,
            )),
        padding: EdgeInsets.fromLTRB(
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
        ),
        child: InkWell(
          onTap: () => goToShippingOptionScreen(branchName, shippingDataList),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Shipping Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Shipping Option",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: _deviceDetails.getTitleFontSize(),
                      color: Colors.black,
                    ),
                  ),

                  /// Shipping Price
                  Text(
                    "Select >",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: _deviceDetails.getNormalFontSize(),
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              /// Spacing
              SizedBox(height: 10),

              /// Shipping Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (data.productsMap[branchName]?[0].shippingData!.isNULL ==
                      true)
                    Container(
                      child: Text(
                        'Select Shipping Method',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: _deviceDetails.getNormalFontSize(),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                  /// Arrow
                  if (data.productsMap[branchName]?[0].shippingData!.isNULL ==
                      true)
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).primaryColor,
                      size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    ),

                  if (data.productsMap[branchName]?[0].shippingData!.isNULL ==
                      false)
                    Container(
                      child: Text(
                        data.productsMap[branchName]![0].shippingData!
                            .shippingName,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: _deviceDetails.getNormalFontSize(),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                  if (data.productsMap[branchName]?[0].shippingData!.isNULL ==
                      false)

                    /// Shipping Price
                    Text(
                      "RM " +
                          formatCurrency
                              .format(data.productsMap[branchName]![0]
                                  .shippingData!.shippingPrice)
                              .toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: _deviceDetails.getNormalFontSize(),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Voucher Code Input UI
  Widget getVoucherInputUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return Container(
      color: Theme.of(context).shadowColor,
      padding: EdgeInsets.fromLTRB(
        _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
        _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
      ),
      child: TextField(
        controller: voucherController,
        inputFormatters: <TextInputFormatter>[
          LengthLimitingTextInputFormatter(10),
        ],
        style: TextStyle(
          fontSize: _deviceDetails.getNormalFontSize(),
          color: Theme.of(context).primaryColor,
        ),
        cursorColor: Theme.of(context).primaryColor,
        // keyboardType: TextInputType.number,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          suffixIcon: InkWell(
            onTap: () {
              print("Voucher Code Apply Button");
            },
            child: Container(
              alignment: Alignment.centerRight,
              width: _widgetSize.getResponsiveWidth(0.2, 0.2, 0.2),
              padding: EdgeInsets.only(
                right: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
              ),
              child: FittedBox(
                child: Text(
                  'Apply',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: _deviceDetails.getNormalFontSize(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          hintText: "Enter Voucher Code",
          hintStyle: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: _deviceDetails.getNormalFontSize(),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: new BorderSide(color: Colors.red),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: new BorderSide(color: Theme.of(context).primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: new BorderSide(color: Theme.of(context).primaryColor),
          ),
          errorText: voucherError ? voucherErrorMessage : null,
          errorStyle: TextStyle(
              color: Colors.red,
              fontSize: _deviceDetails.getNormalFontSize(),
              fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  /// SubTotal + Shipping + Total Items UI
  Widget getTotalUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return Container(
      color: Theme.of(context).shadowColor,
      padding: EdgeInsets.all(_widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),
      child: Column(
        children: [
          /// SubTotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Subtotal
              Text(
                "Subtotal",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).primaryColor,
                ),
              ),

              /// Price
              if (totalSubtotalAmount >= 0)
                Text(
                  "RM " + formatCurrency.format(totalSubtotalAmount),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: _deviceDetails.getNormalFontSize(),
                    color: Theme.of(context).primaryColor,
                  ),
                ),

              /// Negative Price
              if (totalSubtotalAmount < 0)
                Text(
                  "RM " + formatCurrency.format(0),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: _deviceDetails.getNormalFontSize(),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
            ],
          ),

          /// Spacing
          SizedBox(height: _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02)),

          /// Total Shipping
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Total Shipping
              Text(
                "Total Shipping",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).primaryColor,
                ),
              ),

              /// Price
              Text(
                "RM " + formatCurrency.format(totalShippingAmount).toString(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).primaryColor,
                ),
              )
            ],
          ),

          /// Spacing
          SizedBox(height: _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02)),

          /// Total Item
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Total Item
              Text(
                "Total Amount  (${data.totalItem} Items)",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: _deviceDetails.getTitleFontSize(),
                  color: Theme.of(context).primaryColor,
                ),
              ),

              /// Price
              if (totalFinalAmount >= 0)
                Text(
                  "RM " + formatCurrency.format(totalFinalAmount).toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: _deviceDetails.getTitleFontSize(),
                    color: Theme.of(context).primaryColor,
                  ),
                ),

              /// Negative Price
              if (totalFinalAmount < 0)
                Text(
                  "RM " + formatCurrency.format(0).toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: _deviceDetails.getTitleFontSize(),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
            ],
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
    var mediaQuery = MediaQuery.of(context);

    return Container(
      width: _widgetSize.getResponsiveWidth(1, 1, 1),
      child: Column(
        children: [
          if (paymentMethodTypeClass == null)
            Container(
              decoration: BoxDecoration(
                color: hasPaymentMethod == true ? Colors.black : Colors.red,
                border: Border(
                  bottom: BorderSide(
                    width: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                        ? 1
                        : 3.0,
                    color: Theme.of(context).shadowColor,
                  ),
                ),
              ),
              child: InkWell(
                onTap: goToPaymentScreen,
                child: ListTile(
                  leading: Icon(
                    Icons.monetization_on,
                    size: _widgetSize.getResponsiveWidth(0.06, 0.06, 0.06),
                    color: hasPaymentMethod == true
                        ? Theme.of(context).highlightColor
                        : Colors.black,
                  ),
                  title: Text(
                    "Payment Methods",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: _deviceDetails.getNormalFontSize(),
                      color: hasPaymentMethod == true
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    color: hasPaymentMethod == true
                        ? Theme.of(context).highlightColor
                        : Colors.black,
                  ),
                ),
              ),
            ),

          /// App Wallet
          if (paymentMethodTypeClass?.type == PaymentMethodType.AppWallet)
            getSelectedMethodWalletUI(
              _deviceDetails,
              _widgetSize,
              paymentMethodTypeClass!.paymentMethodName,
              Image.asset(
                'assets/icon/logo.png',
                width: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
              ),
            ),

          /// Other Payment Method
          if (paymentMethodTypeClass != null &&
              paymentMethodTypeClass?.type != PaymentMethodType.AppWallet)
            getSelectedMethodUI(
              _deviceDetails,
              _widgetSize,
              paymentMethodTypeClass!.paymentMethodName,
              Icon(
                Icons.monetization_on_outlined,
                color: Theme.of(context).highlightColor,
                size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
              ),
            ),
        ],
      ),
    );
  }

  /// Payment method ui
  Widget getSelectedMethodUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    String text,
    Widget icons,
  ) {
    var mediaQuery = MediaQuery.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          bottom: BorderSide(
            width:
                getDeviceType(mediaQuery) == DeviceScreenType.Mobile ? 1 : 3.0,
            color: Theme.of(context).shadowColor,
          ),
        ),
      ),
      child: ListTile(
        onTap: goToPaymentScreen,
        leading: icons,
        title: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: _deviceDetails.getNormalFontSize(),
            color: Theme.of(context).canvasColor,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          color: Theme.of(context).highlightColor,
        ),
      ),
    );
  }

  Widget getSelectedMethodWalletUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    String text,
    Widget icons,
  ) {
    var mediaQuery = MediaQuery.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          bottom: BorderSide(
            width: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                ? 0.6
                : 3.0,
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: ListTile(
        onTap: goToPaymentScreen,
        leading: icons,
        title: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: _deviceDetails.getNormalFontSize(),
            color: Theme.of(context).canvasColor,
          ),
        ),
        trailing: Container(
          width: _widgetSize.getResponsiveWidth(0.3, 0.3, 0.3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "RM " +
                    formatCurrency
                        .format(double.parse(walletAmount))
                        .toString(),
                style: TextStyle(
                  color: Theme.of(context).highlightColor,
                  fontWeight: FontWeight.w600,
                  fontSize: _deviceDetails.getNormalFontSize(),
                ),
              ),
              SizedBox(width: 5),
              Icon(
                Icons.arrow_forward_ios,
                size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                color: Theme.of(context).highlightColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
  // endregion

  // region Functions
  /// Get Shipping Data
  Future<void> getShippingData() async {
    if (!mounted) {
      return;
    }

    shippingLoading = true;

    // region Shipping Basic Data
    /// Get Shipping Details (Only 1 document)
    QuerySnapshot shippingBasicSnapshots;
    shippingBasicSnapshots = await firestore
        .collection('ShippingCoverage')
        .where("Company_Name", isEqualTo: 'Manual')
        .get();
    // endregion

    // region Shipping Final Data
    /// Get Shipping Final Data
    QuerySnapshot shippingFinalSnapshots;
    shippingFinalSnapshots = await firestore.collection('Delivery_Hours').get();
    // endregion

    /// Has Document
    if (shippingFinalSnapshots.docs.length > 0) {
      print("Calling Shipping Data ########################");
      int currentDay = DateTime.now().weekday;

      /// Set Sunday to '0', because db Sunday is '0'
      if (currentDay == 7) {
        currentDay = 0;
      }
      // currentDay = 2;
      print("Current Day: " + currentDay.toString());

      String startTimeFormatedString = '';
      String endTimeFormatedString = '';

      ShippingData shippingData = ShippingData();

      /// Define Map Shipping Final Data
      Map<String, dynamic> shippingFinalData = Map<String, dynamic>();

      /// Define Map Shipping Basic Data
      Map<String, dynamic> shippingBasicData = Map<String, dynamic>();

      Map<String, dynamic> currentData = Map<String, dynamic>();
      Map<String, dynamic> currentDeliveryHoursData = Map<String, dynamic>();

      for (int i = 0; i < shippingFinalSnapshots.docs.length; ++i) {
        /// Assign Data
        shippingFinalData =
            shippingFinalSnapshots.docs[i].data() as Map<String, dynamic>;
        shippingBasicData =
            shippingBasicSnapshots.docs[0].data() as Map<String, dynamic>;
        currentData =
            shippingFinalSnapshots.docs[i].data() as Map<String, dynamic>;
        currentDeliveryHoursData =
            shippingFinalData["delivery_hours"][currentDay];

        startTimeFormatedString = DateFormat.jm().format(DateFormat("hh:mm:ss")
            .parse(currentDeliveryHoursData['start_time'] + ':00'));
        endTimeFormatedString = DateFormat.jm().format(DateFormat("hh:mm:ss")
            .parse(currentDeliveryHoursData['end_time'] + ':00'));

        /// Pick Up
        if (currentData["id"] == "Pickup") {
          shippingData = ShippingData(
            isActive: currentDeliveryHoursData['is_open'],
            shippingName: getShippingName(currentData["name"]),
            type: getShippingType(currentData["id"]),
            startTime: currentDeliveryHoursData['start_time'],
            endTime: currentDeliveryHoursData['end_time'],
            description: "Pick up your order",
            shippingPrice: 0,
          );
        }

        /// Other Delivery
        else {
          shippingData = ShippingData(
            isActive: currentDeliveryHoursData['is_open'],
            shippingName: getShippingName(currentData["name"]),
            type: getShippingType(currentData["id"]),
            startTime: currentDeliveryHoursData['start_time'],
            endTime: currentDeliveryHoursData['end_time'],
            description: currentData["id"] == 'Express'
                ? "Delivery ${shippingBasicData["Express_Delivery_Label"]} after place order"
                    "\nAvailable between $startTimeFormatedString to $endTimeFormatedString"
                : "Delivery in the next day after place order",
            shippingPrice:
                getShippingPrice(currentData["name"], shippingBasicData),
          );
        }

        print("Shipping Type: " + shippingData.shippingName);
        print("Current Day: " + currentDeliveryHoursData['name']);
        print("Current Status: " + shippingData.isActive.toString());
        print("Start Time: " + shippingData.startTime);
        print("End Time: " + shippingData.endTime);
        print("Shipping Price: " + shippingData.shippingPrice.toString());
        print("###########################");

        shippingDataList.add(shippingData);

        if (i == shippingFinalSnapshots.docs.length - 1) {
          /// Delivery Message
          if (shippingBasicSnapshots.docs.length > 0) {
            checkoutMessageString = shippingBasicData["Delivery_Message"];
          } else {
            print("No message");
          }

          shippingLoading = false;

          if (this.mounted) {
            setState(() {});
          }
        }
      }
    } else {
      showSnackBar('Error Retrieve Delivery Details', context);
    }
  }

  ShippingMethodType getShippingType(String dataString) {
    if (dataString == 'Pickup') {
      return ShippingMethodType.ExpressDelivery;
    }
    if (dataString == 'Standard') {
      return ShippingMethodType.StandardDelivery;
    }
    if (dataString == 'Cash_On_Delivery') {
      return ShippingMethodType.CashOnDelivery;
    }
    if (dataString == 'Express') {
      return ShippingMethodType.ExpressDelivery;
    } else {
      return ShippingMethodType.None;
    }
  }

  String getShippingName(String dataString) {
    if (dataString == 'Cash On Delivery') {
      return dataString;
    } else if (dataString == 'Pickup') {
      return dataString;
    } else {
      return dataString + ' Delivery';
    }
  }

  double getShippingPrice(
    String dataString,
    Map<String, dynamic> shippingBasicData,
  ) {
    if (dataString == 'Cash On Delivery') {
      return 0.00;
    } else if (dataString == 'Express') {
      return shippingBasicData["Express_Delivery_Charges"].toDouble();
    } else if (dataString == 'Standard') {
      return shippingBasicData["Standard_Delivery_Charges"].toDouble();
    } else {
      return 0.00;
    }
  }

  /// Get Wallet Amount In Real Time Update
  void getWalletAmountInit() async {
    FirebaseFirestore.instance
        .collection("Customers")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .listen((value) {
      /// Define Map Data
      Map<String, dynamic> walletMapData = Map<String, dynamic>();

      /// Assign Data
      walletMapData = value.data() as Map<String, dynamic>;

      if (walletMapData["walletAmount"] != null) {
        if (walletMapData["walletAmount"] != '') {
          walletAmount = walletMapData["walletAmount"];
          if (this.mounted) {
            setState(() {});
          }
        }
      } else {
        walletAmount = '0';
        if (this.mounted) {
          setState(() {});
        }
      }
    });
  }

  // region (Wallet) Place Order Process
  /// Place Order if wallet amount Enough
  void placeOrderWalletEnoughAmount(
    DeviceDetails _deviceDetails,
    String token,
    String dateTime,
  ) async {
    print("Token: " + token);

    /// Define Order List
    List<CreateOrderClass> createOrderClassList = <CreateOrderClass>[];
    setLoadingStatus(true);

    data.productsMap.forEach((branchName, value) async {
      print("========================");
      print("Branch [$branchName]: " +
          data.productsMap[branchName]![0].providerId);
      // print(data.productsMap[branchName][0].shippingData!.shippingName);

      /// Define Single Order
      CreateOrderClass tempFinalOrder = new CreateOrderClass(
        customerFirstName: shippingAddressData?.fullName as String,
        customerId: firebaseUser.uid,
        deliveryType:
            data.productsMap[branchName]![0].shippingData!.shippingName,
        orderBillingAddress: shippingAddressData?.addressDetails as String,
        orderBillingAddressCity: shippingAddressData?.city as String,
        orderBillingAddressEmail: emailString,
        orderBillingAddressFirstName: shippingAddressData?.fullName as String,
        orderBillingAddressPhone: shippingAddressData?.phone as String,
        orderBillingAddressProvince: shippingAddressData?.state as String,
        orderBillingAddressZip: shippingAddressData?.postcode as String,
        orderCreatedAt: dateTime,
        orderCustomerFirstName: shippingAddressData?.fullName as String,
        orderCustomerId: firebaseUser.uid,
        orderCustomerPhone: shippingAddressData?.phone as String,
        orderShippingAddress: shippingAddressData?.addressDetails as String,
        orderShippingAddressCity: shippingAddressData?.city as String,
        orderShippingAddressEmail: emailString,
        orderShippingAddressFirstName: shippingAddressData?.fullName as String,
        orderShippingAddressPhone: shippingAddressData?.phone as String,
        orderShippingAddressProvince: shippingAddressData?.state as String,
        orderShippingAddressZip: shippingAddressData?.postcode as String,
        providerId: data.productsMap[branchName]?[0].providerId as String,
        VoucherID: data.productsMap[branchName]?[0].voucherData != null
            ? data.productsMap[branchName]![0].voucherData!.voucherId
            : '',
      );

      /// Define Single Order Details
      CreateOrderDetailsClass tempOrderDetail = new CreateOrderDetailsClass();

      /// Define Order Details List
      List<CreateOrderDetailsClass> tempOrderDetailList =
          <CreateOrderDetailsClass>[];

      for (int i = 0; i < data.productsMap[branchName]!.length; ++i) {
        if (i > 0) {
          if (i == data.productsMap[branchName]!.length - 1) {
            /// Assign CreateOrderDetailsClass
            tempOrderDetail = new CreateOrderDetailsClass(
              productId: data.productsMap[branchName]![i].productId,
              quantity: data.productsMap[branchName]![i].quantity,
            );

            /// Add to CreateOrderDetailsClass List
            tempOrderDetailList.add(tempOrderDetail);
            print("Added Product to order: " + tempOrderDetail.productId);
            print("Added Product Quantity: " +
                tempOrderDetail.quantity.toString());

            /// Assign order details to Order
            tempFinalOrder.orderDetails = tempOrderDetailList;

            /// Add CreateOrderClass to List (Final List)
            createOrderClassList.add(tempFinalOrder);
          } else {
            /// Assign CreateOrderDetailsClass
            tempOrderDetail = new CreateOrderDetailsClass(
              productId: data.productsMap[branchName]![i].productId,
              quantity: data.productsMap[branchName]![i].quantity,
            );

            /// Add to CreateOrderDetailsClass List
            tempOrderDetailList.add(tempOrderDetail);
            print("Added Product to order: " + tempOrderDetail.productId);
            print("Added Product Quantity: " +
                tempOrderDetail.quantity.toString());
          }
        }
      }
    });

    setLoadingStatus(false);

    /// Assign to List JSON
    ListCreateOrderClass orderList = new ListCreateOrderClass(
      orders: createOrderClassList,
    );

    if (printData == true) {
      for (int i = 0; i < createOrderClassList.length; ++i) {
        print("${createOrderClassList[i].providerId} ====================");
        print(
            'customerFirstName: ' + createOrderClassList[i].customerFirstName);
        print('customerId: ' + createOrderClassList[i].customerId);
        print('customerLastName: ' + createOrderClassList[i].customerLastName);
        print('deliveryType: ' + createOrderClassList[i].deliveryType);
        print('orderBillingAddress: ' +
            createOrderClassList[i].orderBillingAddress);
        print('orderBillingAddressCity: ' +
            createOrderClassList[i].orderBillingAddressCity);
        print('orderBillingAddressCountry: ' +
            createOrderClassList[i].orderBillingAddressCountry);
        print('orderBillingAddressCountryCode: ' +
            createOrderClassList[i].orderBillingAddressCountryCode);
        print('orderBillingAddressEmail: ' +
            createOrderClassList[i].orderBillingAddressEmail);
        print('orderBillingAddressFirstName: ' +
            createOrderClassList[i].orderBillingAddressFirstName);
        print('orderBillingAddressLastName: ' +
            createOrderClassList[i].orderBillingAddressLastName);
        print('orderBillingAddressPhone: ' +
            createOrderClassList[i].orderBillingAddressPhone);
        print('orderBillingAddressProvince: ' +
            createOrderClassList[i].orderBillingAddressProvince);
        print('orderBillingAddressProvinceCode: ' +
            createOrderClassList[i].orderBillingAddressProvinceCode);
        print('orderBillingAddressZip: ' +
            createOrderClassList[i].orderBillingAddressZip);
        print('orderCreatedAt: ' + createOrderClassList[i].orderCreatedAt);
        print('orderCustomerCountryCode: ' +
            createOrderClassList[i].orderCustomerCountryCode);
        print('orderCustomerFirstName: ' +
            createOrderClassList[i].orderCustomerFirstName);
        print('orderCustomerId: ' + createOrderClassList[i].orderCustomerId);
        print('orderCustomerPhone: ' +
            createOrderClassList[i].orderCustomerPhone);
        print('orderRemark: ' + createOrderClassList[i].orderRemark);
        print('orderShippingAddress: ' +
            createOrderClassList[i].orderShippingAddress);
        print('orderShippingAddressCity: ' +
            createOrderClassList[i].orderShippingAddressCity);
        print('orderShippingAddressCountry: ' +
            createOrderClassList[i].orderShippingAddressCountry);
        print('orderShippingAddressCountryCode: ' +
            createOrderClassList[i].orderShippingAddressCountryCode);
        print('orderShippingAddressEmail: ' +
            createOrderClassList[i].orderShippingAddressEmail);
        print('orderShippingAddressFirstName: ' +
            createOrderClassList[i].orderShippingAddressFirstName);
        print('orderShippingAddressLastName: ' +
            createOrderClassList[i].orderShippingAddressLastName);
        print('orderShippingAddressPhone: ' +
            createOrderClassList[i].orderShippingAddressPhone);
        print('orderShippingAddressProvince: ' +
            createOrderClassList[i].orderShippingAddressProvince);
        print('orderShippingAddressProvinceCode: ' +
            createOrderClassList[i].orderShippingAddressProvinceCode);
        print('orderShippingAddressZip: ' +
            createOrderClassList[i].orderShippingAddressZip);
        print('orderSourceType: ' + createOrderClassList[i].orderSourceType);
        print('providerId: ' + createOrderClassList[i].providerId);
        print('Voucher_ID: ' + createOrderClassList[i].VoucherID);

        for (int j = 0; j < createOrderClassList[i].orderDetails!.length; ++j) {
          print("product ID: " +
              createOrderClassList[i].orderDetails![j].productId);
          print("product quantity: " +
              createOrderClassList[i].orderDetails![j].quantity.toString());
        }
      }
      // String jsonData = jsonEncode(createOrderClassList);
      // print(jsonData);
      // isLoading = false;
      // setState(() {});
      // return;
    }

    setLoadingStatus(true);

    print('Calling Create Order API');
    await fetchCreateOrderApi(
      token,
      orderList,
      createOrderClassList,
    ).then((value) {
      if (value.isSuccess == true) {
        /// List of OrderID
        List<String> orderIDList = <String>[];

        for (int i = 0; i < value.orderIds!.length; ++i) {
          /// Reach last index
          if (i == value.orderIds!.length - 1) {
            print("Order Created: " + value.orderIds![i]);

            /// Add to List
            orderIDList.add(value.orderIds![i]);
            print("Success Added All Order");

            setLoadingStatus(false);

            appWalletPay(token, orderIDList, _deviceDetails);
          } else {
            print("Order Created: " + value.orderIds![i]);

            /// Add to List
            orderIDList.add(value.orderIds![i]);
          }
        }
      } else {
        setLoadingStatus(false);

        /// Show Error Message
        showMessage(
          "",
          value.errorMessage as String,
          _deviceDetails,
          context,
        );
      }
    });
  }

  /// Place order for not enough wallet amount
  void placeOrderWalletNotEnough(
    DeviceDetails _deviceDetails,
    String token,
    String dateTime,
  ) async {
    print("Token: " + token);

    /// Define Order List
    List<CreateOrderClass> createOrderClassList = <CreateOrderClass>[];

    data.productsMap.forEach((branchName, value) async {
      print("========================");
      print("Branch [$branchName]: " +
          data.productsMap[branchName]![0].providerId);
      // print(data.productsMap[branchName][0].shippingData!.shippingName);

      /// Define Single Order
      CreateOrderClass tempFinalOrder = new CreateOrderClass(
        customerFirstName: shippingAddressData?.fullName as String,
        customerId: firebaseUser.uid,
        deliveryType:
            data.productsMap[branchName]![0].shippingData!.shippingName,
        orderBillingAddress: shippingAddressData!.addressDetails as String,
        orderBillingAddressCity: shippingAddressData!.city as String,
        orderBillingAddressEmail: emailString,
        orderBillingAddressFirstName: shippingAddressData!.fullName as String,
        orderBillingAddressPhone: shippingAddressData!.phone as String,
        orderBillingAddressProvince: shippingAddressData!.state as String,
        orderBillingAddressZip: shippingAddressData!.postcode as String,
        orderCreatedAt: dateTime,
        orderCustomerFirstName: shippingAddressData!.fullName as String,
        orderCustomerId: firebaseUser.uid,
        orderCustomerPhone: shippingAddressData!.phone as String,
        orderShippingAddress: shippingAddressData!.addressDetails as String,
        orderShippingAddressCity: shippingAddressData!.city as String,
        orderShippingAddressEmail: emailString,
        orderShippingAddressFirstName: shippingAddressData!.fullName as String,
        orderShippingAddressPhone: shippingAddressData!.phone as String,
        orderShippingAddressProvince: shippingAddressData!.state as String,
        orderShippingAddressZip: shippingAddressData!.postcode as String,
        providerId: data.productsMap[branchName]![0].providerId,
        VoucherID: data.productsMap[branchName]?[0].voucherData != null
            ? data.productsMap[branchName]![0].voucherData!.voucherId
            : '',
      );

      /// Define Single Order Details
      CreateOrderDetailsClass tempOrderDetail = new CreateOrderDetailsClass();

      /// Define Order Details List
      List<CreateOrderDetailsClass> tempOrderDetailList =
          <CreateOrderDetailsClass>[];

      for (int i = 0; i < data.productsMap[branchName]!.length; ++i) {
        if (i > 0) {
          if (i == data.productsMap[branchName]!.length - 1) {
            /// Assign CreateOrderDetailsClass
            tempOrderDetail = new CreateOrderDetailsClass(
              productId: data.productsMap[branchName]![i].productId,
              quantity: data.productsMap[branchName]![i].quantity,
            );

            /// Add to CreateOrderDetailsClass List
            tempOrderDetailList.add(tempOrderDetail);
            print("Added Product to order: " + tempOrderDetail.productId);
            print("Added Product Quantity: " +
                tempOrderDetail.quantity.toString());

            /// Assign order details to Order
            tempFinalOrder.orderDetails = tempOrderDetailList;

            /// Add CreateOrderClass to List (Final List)
            createOrderClassList.add(tempFinalOrder);
          } else {
            /// Assign CreateOrderDetailsClass
            tempOrderDetail = new CreateOrderDetailsClass(
              productId: data.productsMap[branchName]![i].productId,
              quantity: data.productsMap[branchName]![i].quantity,
            );

            /// Add to CreateOrderDetailsClass List
            tempOrderDetailList.add(tempOrderDetail);
            print("Added Product to order: " + tempOrderDetail.productId);
            print("Added Product Quantity: " +
                tempOrderDetail.quantity.toString());
          }
        }
      }
    });

    /// Assign to List JSON
    ListCreateOrderClass orderList = new ListCreateOrderClass(
      orders: createOrderClassList,
    );
    for (int i = 0; i < createOrderClassList.length; ++i) {
      print("${createOrderClassList[i].providerId} ====================");
      print('customerFirstName: ' + createOrderClassList[i].customerFirstName);
      print('customerId: ' + createOrderClassList[i].customerId);
      print('customerLastName: ' + createOrderClassList[i].customerLastName);
      print('deliveryType: ' + createOrderClassList[i].deliveryType);
      print('orderBillingAddress: ' +
          createOrderClassList[i].orderBillingAddress);
      print('orderBillingAddressCity: ' +
          createOrderClassList[i].orderBillingAddressCity);
      print('orderBillingAddressCountry: ' +
          createOrderClassList[i].orderBillingAddressCountry);
      print('orderBillingAddressCountryCode: ' +
          createOrderClassList[i].orderBillingAddressCountryCode);
      print('orderBillingAddressEmail: ' +
          createOrderClassList[i].orderBillingAddressEmail);
      print('orderBillingAddressFirstName: ' +
          createOrderClassList[i].orderBillingAddressFirstName);
      print('orderBillingAddressLastName: ' +
          createOrderClassList[i].orderBillingAddressLastName);
      print('orderBillingAddressPhone: ' +
          createOrderClassList[i].orderBillingAddressPhone);
      print('orderBillingAddressProvince: ' +
          createOrderClassList[i].orderBillingAddressProvince);
      print('orderBillingAddressProvinceCode: ' +
          createOrderClassList[i].orderBillingAddressProvinceCode);
      print('orderBillingAddressZip: ' +
          createOrderClassList[i].orderBillingAddressZip);
      print('orderCreatedAt: ' + createOrderClassList[i].orderCreatedAt);
      print('orderCustomerCountryCode: ' +
          createOrderClassList[i].orderCustomerCountryCode);
      print('orderCustomerFirstName: ' +
          createOrderClassList[i].orderCustomerFirstName);
      print('orderCustomerId: ' + createOrderClassList[i].orderCustomerId);
      print(
          'orderCustomerPhone: ' + createOrderClassList[i].orderCustomerPhone);
      print('orderRemark: ' + createOrderClassList[i].orderRemark);
      print('orderShippingAddress: ' +
          createOrderClassList[i].orderShippingAddress);
      print('orderShippingAddressCity: ' +
          createOrderClassList[i].orderShippingAddressCity);
      print('orderShippingAddressCountry: ' +
          createOrderClassList[i].orderShippingAddressCountry);
      print('orderShippingAddressCountryCode: ' +
          createOrderClassList[i].orderShippingAddressCountryCode);
      print('orderShippingAddressEmail: ' +
          createOrderClassList[i].orderShippingAddressEmail);
      print('orderShippingAddressFirstName: ' +
          createOrderClassList[i].orderShippingAddressFirstName);
      print('orderShippingAddressLastName: ' +
          createOrderClassList[i].orderShippingAddressLastName);
      print('orderShippingAddressPhone: ' +
          createOrderClassList[i].orderShippingAddressPhone);
      print('orderShippingAddressProvince: ' +
          createOrderClassList[i].orderShippingAddressProvince);
      print('orderShippingAddressProvinceCode: ' +
          createOrderClassList[i].orderShippingAddressProvinceCode);
      print('orderShippingAddressZip: ' +
          createOrderClassList[i].orderShippingAddressZip);
      print('orderSourceType: ' + createOrderClassList[i].orderSourceType);
      print('providerId: ' + createOrderClassList[i].providerId);
      print('Voucher_ID: ' + createOrderClassList[i].VoucherID);

      for (int j = 0; j < createOrderClassList[i].orderDetails!.length; ++j) {
        print("product ID: " +
            createOrderClassList[i].orderDetails![j].productId);
        print("product quantity: " +
            createOrderClassList[i].orderDetails![j].quantity.toString());
      }
    }
    // String jsonData = jsonEncode(createOrderClassList);
    // print(jsonData);
    // isLoading = false;
    // setState(() {});
    // return;
    print('Calling Create Order API');
    isLoading = true;
    setState(() {});
    await fetchCreateOrderApi(
      token,
      orderList,
      createOrderClassList,
    ).then((value) {
      if (value.isSuccess == true) {
        /// List of OrderID
        List<String> orderIDList = <String>[];

        for (int i = 0; i < value.orderIds!.length; ++i) {
          /// Reach last index
          if (i == value.orderIds!.length - 1) {
            print("Order Created: " + value.orderIds![i]);

            /// Add to List
            orderIDList.add(value.orderIds![i]);
            print("Success Added All Order");

            isLoading = false;
            setState(() {});

            createTopUpWalletPayment(token, orderIDList, _deviceDetails);
          } else {
            print("Order Created: " + value.orderIds![i]);

            /// Add to List
            orderIDList.add(value.orderIds![i]);
          }
        }
      } else {
        isLoading = false;
        setState(() {});

        /// Show Error Message
        showMessage(
          "",
          value.errorMessage as String,
          _deviceDetails,
          context,
        );
      }
    });
  }

  /// Create Wallet Payment
  Future<void> appWalletPay(
    String token,
    List<String> orderIdList,
    DeviceDetails _deviceDetails,
  ) async {
    if (!mounted) {
      return;
    }
    setLoadingStatus(true);

    print("Calling Wallet Payment API");

    await fetchWalletPaymentApi(
      token,
      orderIdList,
    ).then((value) {
      setLoadingStatus(false);

      if (value.isSuccess == true) {
        removeCart();
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).backgroundColor,
              elevation: 10,
              scrollable: true,
              title: Text(
                'Your Order(s) are created, please check your Purchase History',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              actions: [
                /// Ok
                TextButton(
                  child: Text(
                    "Ok",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          },
        ).then((result) async {
          // This will return back to cart page
          Navigator.pop(context);
        });
      } else {
        print("Failed Calling Wallet Payment API");

        showMessage(
          "",
          value.errorMessage as String,
          _deviceDetails,
          context,
        );
      }
    });
  }

  /// Create Wallet Payment
  Future<void> createTopUpWalletPayment(
    String token,
    List<String> orderIdList,
    DeviceDetails _deviceDetails,
  ) async {
    if (!mounted) {
      return;
    }
    setLoadingStatus(true);

    print("--- Creating Payment Document -------------");
    String targetDate =
        DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
    print(targetDate);

    FirebaseFirestore.instance.collection("Payments").add({
      'OrderIds': orderIdList,
      "POID": null,
      "PaymentId": "",
      "PaymentType": null,
      "Source": null,
      "Status": null,
      "UpdatedAt": targetDate,
      "UserId": firebaseUser.uid,
    }).then((value) {
      String paymentID = value.id.toString();
      FirebaseFirestore.instance
          .collection("Payments")
          .doc(value.id.toString())
          .update({
        "PaymentId": value.id.toString(),
      }).then((value) async {
        print("Created Payment Document [$paymentID]");

        /// Call Payment API
        print("Calling Payment API");

        await fetchTopUpWalletPaymentApi(
          token,
          orderIdList,
          'EBANKING',
        ).then((value) {
          setLoadingStatus(false);

          if (value.paymentForm != null) {
            print("url: " + (value.paymentForm!.url as String));
            launchURL(
              value.paymentForm!.url as String,
              "Top Up Wallet & Pay",
              paymentID,
              orderIdList,
            );
          } else {
            print("Failed Calling Payment ID");

            showMessage(
              "",
              value.errorMessage as String,
              _deviceDetails,
              context,
            );
          }
        });
      });
    });
  }
  // endregion

  // region Place Order Process
  /// Place Order
  void placeOrder(
    DeviceDetails _deviceDetails,
    String token,
    String dateTime,
  ) async {
    setLoadingStatus(true);

    print("Other payment");

    /// Define Order List
    List<CreateOrderClass> createOrderClassList = <CreateOrderClass>[];

    data.productsMap.forEach((branchName, value) async {
      print("========================");
      print("Branch [$branchName]: " +
          data.productsMap[branchName]![0].providerId);

      /// Define Single Order
      CreateOrderClass tempFinalOrder = new CreateOrderClass(
        customerFirstName: shippingAddressData!.fullName as String,
        customerId: firebaseUser.uid,
        deliveryType:
            data.productsMap[branchName]![0].shippingData!.shippingName,
        orderBillingAddress: shippingAddressData!.addressDetails as String,
        orderBillingAddressCity: shippingAddressData!.city as String,
        orderBillingAddressEmail: emailString,
        orderBillingAddressFirstName: shippingAddressData!.fullName as String,
        orderBillingAddressPhone: shippingAddressData!.phone as String,
        orderBillingAddressProvince: shippingAddressData!.state as String,
        orderBillingAddressZip: shippingAddressData!.postcode as String,
        orderCreatedAt: dateTime,
        orderCustomerFirstName: shippingAddressData!.fullName as String,
        orderCustomerId: firebaseUser.uid,
        orderCustomerPhone: shippingAddressData!.phone as String,
        orderShippingAddress: shippingAddressData!.addressDetails as String,
        orderShippingAddressCity: shippingAddressData!.city as String,
        orderShippingAddressEmail: emailString,
        orderShippingAddressFirstName: shippingAddressData!.fullName as String,
        orderShippingAddressPhone: shippingAddressData!.phone as String,
        orderShippingAddressProvince: shippingAddressData!.state as String,
        orderShippingAddressZip: shippingAddressData!.postcode as String,
        providerId: data.productsMap[branchName]![0].providerId,
        VoucherID: data.productsMap[branchName]?[0].voucherData != null
            ? data.productsMap[branchName]![0].voucherData!.voucherId
            : '',
      );

      /// Define Single Order Details
      CreateOrderDetailsClass tempOrderDetail = new CreateOrderDetailsClass();

      /// Define Order Details List
      List<CreateOrderDetailsClass> tempOrderDetailList =
          <CreateOrderDetailsClass>[];

      for (int i = 0; i < data.productsMap[branchName]!.length; ++i) {
        if (i > 0) {
          if (i == data.productsMap[branchName]!.length - 1) {
            /// Assign CreateOrderDetailsClass
            tempOrderDetail = new CreateOrderDetailsClass(
              productId: data.productsMap[branchName]![i].productId,
              quantity: data.productsMap[branchName]![i].quantity,
            );

            /// Add to CreateOrderDetailsClass List
            tempOrderDetailList.add(tempOrderDetail);
            print("Added Product to order: " + tempOrderDetail.productId);
            print("Added Product Quantity: " +
                tempOrderDetail.quantity.toString());

            /// Assign order details to Order
            tempFinalOrder.orderDetails = tempOrderDetailList;

            /// Add CreateOrderClass to List (Final List)
            createOrderClassList.add(tempFinalOrder);
          } else {
            /// Assign CreateOrderDetailsClass
            tempOrderDetail = new CreateOrderDetailsClass(
              productId: data.productsMap[branchName]![i].productId,
              quantity: data.productsMap[branchName]![i].quantity,
            );

            /// Add to CreateOrderDetailsClass List
            tempOrderDetailList.add(tempOrderDetail);
            print("Added Product to order: " + tempOrderDetail.productId);
            print("Added Product Quantity: " +
                tempOrderDetail.quantity.toString());
          }
        }
      }
    });

    setLoadingStatus(false);

    /// Assign to List JSON
    ListCreateOrderClass orderList = new ListCreateOrderClass(
      orders: createOrderClassList,
    );
    if (printData == true) {
      for (int i = 0; i < createOrderClassList.length; ++i) {
        print("${createOrderClassList[i].providerId} ====================");
        print(
            'customerFirstName: ' + createOrderClassList[i].customerFirstName);
        print('customerId: ' + createOrderClassList[i].customerId);
        print('customerLastName: ' + createOrderClassList[i].customerLastName);
        print('deliveryType: ' + createOrderClassList[i].deliveryType);
        print('orderBillingAddress: ' +
            createOrderClassList[i].orderBillingAddress);
        print('orderBillingAddressCity: ' +
            createOrderClassList[i].orderBillingAddressCity);
        print('orderBillingAddressCountry: ' +
            createOrderClassList[i].orderBillingAddressCountry);
        print('orderBillingAddressCountryCode: ' +
            createOrderClassList[i].orderBillingAddressCountryCode);
        print('orderBillingAddressEmail: ' +
            createOrderClassList[i].orderBillingAddressEmail);
        print('orderBillingAddressFirstName: ' +
            createOrderClassList[i].orderBillingAddressFirstName);
        print('orderBillingAddressLastName: ' +
            createOrderClassList[i].orderBillingAddressLastName);
        print('orderBillingAddressPhone: ' +
            createOrderClassList[i].orderBillingAddressPhone);
        print('orderBillingAddressProvince: ' +
            createOrderClassList[i].orderBillingAddressProvince);
        print('orderBillingAddressProvinceCode: ' +
            createOrderClassList[i].orderBillingAddressProvinceCode);
        print('orderBillingAddressZip: ' +
            createOrderClassList[i].orderBillingAddressZip);
        print('orderCreatedAt: ' + createOrderClassList[i].orderCreatedAt);
        print('orderCustomerCountryCode: ' +
            createOrderClassList[i].orderCustomerCountryCode);
        print('orderCustomerFirstName: ' +
            createOrderClassList[i].orderCustomerFirstName);
        print('orderCustomerId: ' + createOrderClassList[i].orderCustomerId);
        print('orderCustomerPhone: ' +
            createOrderClassList[i].orderCustomerPhone);
        print('orderRemark: ' + createOrderClassList[i].orderRemark);
        print('orderShippingAddress: ' +
            createOrderClassList[i].orderShippingAddress);
        print('orderShippingAddressCity: ' +
            createOrderClassList[i].orderShippingAddressCity);
        print('orderShippingAddressCountry: ' +
            createOrderClassList[i].orderShippingAddressCountry);
        print('orderShippingAddressCountryCode: ' +
            createOrderClassList[i].orderShippingAddressCountryCode);
        print('orderShippingAddressEmail: ' +
            createOrderClassList[i].orderShippingAddressEmail);
        print('orderShippingAddressFirstName: ' +
            createOrderClassList[i].orderShippingAddressFirstName);
        print('orderShippingAddressLastName: ' +
            createOrderClassList[i].orderShippingAddressLastName);
        print('orderShippingAddressPhone: ' +
            createOrderClassList[i].orderShippingAddressPhone);
        print('orderShippingAddressProvince: ' +
            createOrderClassList[i].orderShippingAddressProvince);
        print('orderShippingAddressProvinceCode: ' +
            createOrderClassList[i].orderShippingAddressProvinceCode);
        print('orderShippingAddressZip: ' +
            createOrderClassList[i].orderShippingAddressZip);
        print('orderSourceType: ' + createOrderClassList[i].orderSourceType);
        print('providerId: ' + createOrderClassList[i].providerId);
        print('Voucher_ID: ' + createOrderClassList[i].VoucherID);

        for (int j = 0; j < createOrderClassList[i].orderDetails!.length; ++j) {
          print("product ID: " +
              createOrderClassList[i].orderDetails![j].productId);
          print("product quantity: " +
              createOrderClassList[i].orderDetails![j].quantity.toString());
        }
      }
      // String jsonData = jsonEncode(createOrderClassList);
      // print(jsonData);
      // isLoading = false;
      // setState(() {});
      // return;
    }
    print('Calling Create Order API');

    setLoadingStatus(true);

    await fetchCreateOrderApi(
      token,
      orderList,
      createOrderClassList,
    ).then((value) {
      if (value.isSuccess == true) {
        /// List of OrderID
        List<String> orderIDList = <String>[];

        for (int i = 0; i < value.orderIds!.length; ++i) {
          /// Reach last index
          if (i == value.orderIds!.length - 1) {
            print("Order Created: " + value.orderIds![i]);

            /// Add to List
            orderIDList.add(value.orderIds![i]);
            print("Success Added All Order");

            setLoadingStatus(false);

            /// Cash On Delivery
            if (paymentMethodTypeClass!.type ==
                PaymentMethodType.Cash_On_Delivery) {
              createCodProcess(token, orderIDList, _deviceDetails);
            }

            /// EGHL
            else if (paymentMethodTypeClass!.type == PaymentMethodType.EGHL) {
              eghlPaymentProcess(token, orderIDList, _deviceDetails);
            }

            /// BillPlz
            else if (paymentMethodTypeClass!.type ==
                PaymentMethodType.BillPlz) {
              billPlzPaymentProcess(
                token,
                orderIDList,
                _deviceDetails,
                createOrderClassList[i].customerFirstName,
                createOrderClassList[i].customerLastName,
                createOrderClassList[i].orderShippingAddressEmail,
              );
            }

            /// Payex
            else if (paymentMethodTypeClass!.type == PaymentMethodType.Payex) {
              payexPaymentProcess(
                token,
                orderIDList,
                _deviceDetails,
                createOrderClassList[i].customerFirstName,
                createOrderClassList[i].customerLastName,
                createOrderClassList[i].orderShippingAddressEmail,
              );
            } else {
              showMessage(
                "",
                'The Payment Method is Empty',
                _deviceDetails,
                context,
              );
            }
          } else {
            print("Order Created: " + value.orderIds![i]);

            /// Add to List
            orderIDList.add(value.orderIds![i]);
          }
        }
      } else {
        setLoadingStatus(false);

        /// Show Error Message
        showMessage(
          "",
          value.errorMessage as String,
          _deviceDetails,
          context,
        );
      }
    });
  }

  // region Cash On Delivery
  /// Create Cash On Delivery Process
  Future<void> createCodProcess(
    String token,
    List<String> orderIdList,
    DeviceDetails _deviceDetails,
  ) async {
    if (!mounted) {
      return;
    }

    setLoadingStatus(true);

    print("--- Going Through Cash On Delivery Process -------------");

    await fetchCashOnDeliveryApi(
      token,
      orderIdList,
      '',
      '',
    ).then((value) {
      setLoadingStatus(false);

      if (value.isSuccess == true) {
        showMessage(
          "",
          "Hooray! You just make a Cash on Delivery order!",
          _deviceDetails,
          context,
        );
      } else {
        print("Failed Calling COD API");
        showMessage(
          "",
          value.errorMessage as String,
          _deviceDetails,
          context,
        );
      }
    });
  }
  // endregion

  // region BillPlz
  /// BillPlz Payment Process
  Future<void> billPlzPaymentProcess(
    String token,
    List<String> orderIdList,
    DeviceDetails _deviceDetails,
    String firstName,
    String lastName,
    String email,
  ) async {
    if (!mounted) {
      return;
    }
    setLoadingStatus(true);

    print("--- Going Through BillPlz Payment Process -------------");

    await fetchBillPlzPaymentApi(
      token,
      orderIdList,
      firstName,
      lastName,
      email,
      '',
      '',
    ).then((value) {
      // setLoadingStatus(false);

      if (value.paymentForm != null) {
        if (value.paymentForm!.url != null) {
          print("url: " + (value.paymentForm!.url as String));
          if (value.paymentId != null) {
            print('payment id: ' + (value.paymentId as String));
          } else {
            print('** Payment ID is null');
          }
          launchURL(
            value.paymentForm!.url as String,
            "BillPlz Payment",
            value.paymentId,
            orderIdList,
          );
        } else {
          setLoadingStatus(false);
          showMessage(
            'Error BillPlz Top Up Api has error',
            'The payment url is null',
            _deviceDetails,
            context,
          );
        }
      } else {
        print("Failed Calling Payment ID");
        showMessage(
          "",
          value.errorMessage as String,
          _deviceDetails,
          context,
        );
      }
    });
  }
  // endregion

  // region EGHL
  /// EGHL Payment Process
  Future<void> eghlPaymentProcess(
    String token,
    List<String> orderIdList,
    DeviceDetails _deviceDetails,
  ) async {
    return;
    if (!mounted) {
      return;
    }
    isLoading = true;
    setState(() {});

    print("--- Going Through EGHL Payment Process -------------");
    await fetchGkashPaymentApi(
      token,
      '',
      '',
    ).then((value) {
      isLoading = false;
      setState(() {});
      if (value.paymentForm != null) {
        print("url: " + (value.paymentForm!.url as String));
        // launchURL(value.paymentForm!.url as String, "Payment"     ,value.paymentId as String,
        //   orderIdList,);
      } else {
        print("Failed Calling Payment ID");
        showMessage(
          "",
          value.errorMessage as String,
          _deviceDetails,
          context,
        );
      }
    });
  }
// endregion

  // region Payex
  /// Payex Payment Process
  Future<void> payexPaymentProcess(
    String token,
    List<String> orderIdList,
    DeviceDetails _deviceDetails,
    String firstName,
    String lastName,
    String email,
  ) async {
    if (!mounted) {
      return;
    }
    setLoadingStatus(true);

    print("--- Going Through Payex Payment Process -------------");

    await fetchPayexPaymentApi(
      token,
      orderIdList,
      firstName,
      lastName,
      email,
      '',
      '',
    ).then((value) {
      // setLoadingStatus(false);

      if (value.paymentForm != null) {
        if (value.paymentForm!.url != null) {
          print("url: " + (value.paymentForm!.url as String));
          if (value.paymentId != null) {
            print('payment id: ' + (value.paymentId as String));
          } else {
            print('** Payment ID is null');
          }
          launchURL(
            value.paymentForm!.url as String,
            "Payex Payment",
            value.paymentId,
            orderIdList,
          );
        } else {
          setLoadingStatus(false);
          showMessage(
            'Error Payex Api has error',
            'The payment url is null',
            _deviceDetails,
            context,
          );
        }
      } else {
        print("Failed Calling Payment ID");
        showMessage(
          "",
          value.errorMessage as String,
          _deviceDetails,
          context,
        );
      }
    });
  }
  // endregion

  Future<void> launchURL(
    String url,
    String title,
    String? paymentID,
    List<String> orderID,
  ) async {
    if (kIsWeb) {
      if (await canLaunch(url)) {
        await launch(
          url,
          forceSafariVC: true,
          forceWebView: true,
          // webOnlyWindowName: '_self',
          webOnlyWindowName: '_blank',
        );
      } else {
        throw 'Could not launch $url';
      }
      // await Navigator.pushReplacement(
      //   context,
      //   PageTransition(
      //     type: PageTransitionType.rightToLeft,
      //     child: WebViewWebEx(
      //       title: title,
      //       targetURL: url,
      //       orderIDS: orderID,
      //       paymentID: paymentID,
      //     ),
      //   ),
      // );
    } else {
      await Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: WebViewApp(
            targetURL: url,
            title: title,
          ),
        ),
      );
    }

    if (paymentID != null) {
      /// Check Payment Status
      await getPaymentStatusRT(paymentID, orderID);
    }

    /// Remove Cart
    removeCart();
  }

  void removeCart() {
    /// Delete Selected Items
    data.productsMap.forEach((branchName, list) {
      /// If the first index is checked (whole branch selected)
      if (list[0].boolValue == true) {
        /// Remove the whole branch cart and Products
        removeBranchCartFromDB(
          list[0].branchCartID as String,
          firebaseUser.uid,
        ).then((value) {
          for (int i = 0; i < list.length; ++i) {
            if (i > 0) {
              /// Reach last index
              if (i == list.length - 1) {
                /// Remove Item from DB
                removeItemFromDB(
                    list[i].branchCartID as String, list[i].productId);
                list[i].isDisable = true;

                /// Remove From Map
                data.productsMap.remove(
                  branchName,
                );
                // showSnackBar("Product removed from Cart", context);
                setState(() {});
              } else {
                removeItemFromDB(
                    list[i].branchCartID as String, list[i].productId);
                list[i].isDisable = true;
              }
            } else {
              list[0].isDisable = true;
            }
          }
        });
      }
    });
  }

  /// Remove Branch Cart From DB
  Future<void> removeBranchCartFromDB(String cartID, String userID) async {
    print("===== Removing Branch Cart From DB ======");
    print("Cart ID: " + cartID);
    print("User ID: " + userID);

    QuerySnapshot cartData;
    cartData = await firestore
        .collection('Cart')
        .where("Cart_ID", isEqualTo: cartID)
        .where("User_ID", isEqualTo: userID)
        .get();

    /// Existing Data
    if (cartData.docs.length > 0) {
      /// Remove Cart Details Document
      // region Remove Cart Details Data
      FirebaseFirestore.instance
          .collection("Cart")
          .doc(cartData.docs[0].id)
          .delete()
          .then((value) async {
        // widget.bottomAppBarState.updateCartQuantity();
        print("Removed Branch Cart from [$userID]");
      });
      // endregion
    } else {
      showSnackBar("Branch Cart Not Exist", context);
    }
  }

  /// Remove Item from DB
  Future<void> removeItemFromDB(String cartID, String productID) async {
    print("===== Removing Product From DB ======");
    print("Cart ID: " + cartID);
    print("Product ID: " + productID);

    QuerySnapshot cartDetails;
    cartDetails = await firestore
        .collection('CartDetails')
        .where("Cart_ID", isEqualTo: cartID)
        .where("Product_ID", isEqualTo: productID)
        .get();

    /// Existing Data
    if (cartDetails.docs.length > 0) {
      /// Remove Cart Details Document
      // region Remove Cart Details Data
      FirebaseFirestore.instance
          .collection("CartDetails")
          .doc(cartDetails.docs[0].id)
          .delete()
          .then((value) async {
        print("Product Removed From Cart Details and Cart");

        /// Update branch cart price
        // region Update Branch Cart Price & Quantity
        QuerySnapshot allCartDetailsSnapshot;
        allCartDetailsSnapshot = await firestore
            .collection('CartDetails')
            .where("Cart_ID", isEqualTo: cartID)
            .get();
        double totalPrice = 0;
        double eachPrice;
        int eachQuantity;
        double eachFinalPrice;

        /// Define Map Data
        Map<String, dynamic> allCartDetailsMapData = Map<String, dynamic>();

        for (int i = 0; i < allCartDetailsSnapshot.docs.length; ++i) {
          /// Assign Data
          allCartDetailsMapData =
              allCartDetailsSnapshot.docs[i].data() as Map<String, dynamic>;

          /// Get Each Quantity + Price
          eachPrice = double.parse(allCartDetailsMapData["Price"]);
          eachQuantity = int.parse(allCartDetailsMapData["Quantity"]);

          /// Each Final Price = Each Quantity * Each Price
          eachFinalPrice = eachPrice * eachQuantity;

          /// Add to total price
          totalPrice += eachFinalPrice;

          /// Reach Final index
          if (i == allCartDetailsSnapshot.docs.length - 1) {
            /// Update Branch Cart Price
            FirebaseFirestore.instance.collection("Cart").doc(cartID).update({
              "Price": totalPrice.toStringAsFixed(2),
              "Quantity": allCartDetailsSnapshot.docs.length,
              "Qty": allCartDetailsSnapshot.docs.length,
            }).then((value) {
              print("Updated Cart Price: " + totalPrice.toString());
            });
          }
        }
        // endregion
      });
      // endregion
    } else {
      showSnackBar("Item Not Exist", context);
    }
  }
  // endregion

  /// Get Delivery Message
  Future<void> getMessageData() async {
    if (!mounted) {
      return;
    }

    QuerySnapshot checkoutMessage;
    checkoutMessage = await firestore
        .collection('ShippingCoverage')
        .where("Company_Name", isEqualTo: 'Manual')
        .get();

    /// Define Map Data
    Map<String, dynamic> checkoutMData = Map<String, dynamic>();

    /// Assign Data
    checkoutMData = checkoutMessage.docs[0].data() as Map<String, dynamic>;

    /// Has Message
    if (checkoutMessage.docs.length > 0) {
      checkoutMessageString = checkoutMData["Delivery_Message"];
      print("Has message");
      setState(() {});
    } else {
      print("No message");
    }
  }

  void getUserAddress() async {
    if (firebaseUser == null) {
      print("Didnt get User Data");
      return;
    }

    /// -> Check if the current user cart has this branch cart or not
    DocumentSnapshot userDocument;
    userDocument =
        await firestore.collection('Customers').doc(firebaseUser.uid).get();

    /// Define Map Data
    Map<String, dynamic> userData = Map<String, dynamic>();

    /// Assign Data
    userData = userDocument.data() as Map<String, dynamic>;

    /// - If data found
    if (userData["Address"] != null) {
      print("Has Address");
      if (userData["Address"].length > 0) {
        AddressClass temp = AddressClass();
        temp = AddressClass(
          addressDetails: userData["Address"][0]["Address_Details"],
          city: userData["Address"][0]["City"],
          state: userData["Address"][0]["State"],
          postcode: userData["Address"][0]["Postcode"],
          country: userData["Address"][0]["Country"],
          phone: userData["Address"][0]["Phone"],
          fullName: userData["Address"][0]["Full_Name"],
          label: userData["Address"][0]["Label"] != null
              ? userData["Address"][0]["Label"]
              : "Address ${0 + 1}",
        );
        shippingAddressData = temp;
        setState(() {});
      }
    } else {
      print("No Address Found");
    }
  }

  /// Calculate and Assign Each Branch Total Price
  void calculateAndAssignEachBranchTotalPrice(String branchName) {
    /// Calculate Each Branch Total Price
    double eachTotalPrice = 0;
    for (int i = 0; i < data.productsMap[branchName]!.length; ++i) {
      if (i > 0) {
        eachTotalPrice += (data.productsMap[branchName]![i].price)! *
            (data.productsMap[branchName]![i].quantity);
      }
    }

    /// Assign Total Price to first Index
    if (data.productsMap[branchName]?[0].shippingData!.isNULL == false) {
      data.productsMap[branchName]?[0].totalPrice = eachTotalPrice +
          data.productsMap[branchName]![0].shippingData!.shippingPrice;
    }
  }

  /// Calculate Shipping Price
  void calculateFinalPrice() {
    totalShippingAmount = 0.00;
    totalFinalAmount = 0.00;

    data.productsMap.forEach((branchName, index) {
      if (data.productsMap[branchName]?[0].shippingData!.isNULL == false) {
        totalShippingAmount +=
            data.productsMap[branchName]![0].shippingData!.shippingPrice;
        totalFinalAmount += data.productsMap[branchName]![0].totalPrice! -
            getVoucherDiscountPrice(branchName);
      }
    });
  }

  void goToPaymentScreen() async {
    PaymentMethodResultClass result = await Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (BuildContext context) => new PaymentMethodPage(),
        fullscreenDialog: true,
      ),
    );

    if (result != null) {
      setState(() {
        paymentMethodTypeClass = result;
        hasPaymentMethod = true;
      });
    }
  }

  void goToShippingOptionScreen(
    String branchName,
    List<ShippingData> shippingList,
  ) async {
    BranchShippingOption result = await Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (BuildContext context) => new ShippingOptionPage(
          branchName: branchName,
          shippingDataList: shippingList,
        ),
        fullscreenDialog: true,
      ),
    );

    if (result != null) {
      data.productsMap[result.branchName]?[0].shippingData =
          result.shippingData;

      if (this.mounted) {
        setState(() {});
      }

      priceUpdate();
    }
  }

  /// Go To Address Screen
  void goToSelectShippingAddress() async {
    var result = await Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (BuildContext context) => new AddressMainPage(),
        fullscreenDialog: true,
      ),
    );

    if (result != null) {
      setState(() {
        shippingAddressData = result;
        hasShippingAddress = true;
      });
    }
  }

  /// Check all branch price
  String checkEachBranchShippingMethod() {
    int j = 0;
    String currentShippingMethod = '';
    data.productsMap.forEach((branchName, list) {
      for (int i = 0; i < data.productsMap[branchName]!.length; ++i) {
        if (i == 0) {
          if (data.productsMap[branchName]?[0].shippingData!.isNULL == true) {
            currentShippingMethod = branchName;
          }
          // break;
        }
        ++j;
      }
    });

    return currentShippingMethod;
  }

  // region Get Each Branch Calculation
  /// Get Target Branch Total Price
  getBranchSubTotalPrice(String branchName) {
    double subTotal = data.productsMap[branchName]![0].totalPrice as double;

    return subTotal;
  }

  /// Get Voucher Discount Price
  double getVoucherDiscountPrice(String branchName) {
    double voucherDiscountPrice = 0;
    VoucherData? voucherData = data.productsMap[branchName]![0].voucherData;

    if (voucherData != null) {
      /// Voucher Percentage
      if (voucherData.voucherValueType == VoucherValueType.Percentage) {
        print("** Voucher Type is Percentage");

        /// Get branch sub total price
        double subTotal = data.productsMap[branchName]![0].totalPrice as double;

        /// Calculate the percentage and store into temp var
        double discountAmount = subTotal * voucherData.voucherPercentage / 100;

        print("Subtotal: " + subTotal.toString());
        print(
            'Voucher Percentage: ' + voucherData.voucherPercentage.toString());
        print("discountAmount: " + discountAmount.toString());
        print("Voucher Max Amount: " + voucherData.maxDiscount.toString());

        if (discountAmount > 0) {
          /// Check var is > the voucher max discount
          if (discountAmount > voucherData.maxDiscount) {
            /// Use the Voucher Max Discount
            voucherDiscountPrice = voucherData.maxDiscount;
          } else {
            /// Else use the var as voucher discount price
            voucherDiscountPrice = discountAmount;
          }
        } else {
          print("Discount Amount is 0 or negative");
        }
      }

      /// Voucher Value
      else {
        print("** Voucher Type is Value");

        if (voucherData.voucherValue > 0) {
          /// Get the voucher value
          voucherDiscountPrice = voucherData.voucherValue;
        } else {
          print("voucher Discount Price is 0 or negative");
        }
      }
    }

    return voucherDiscountPrice;
  }
  // endregion

  // region Get All Branch Price
  /// Total Price
  void calAllBranchTotalPrice() {
    double bTotalPrice = 0;

    data.productsMap.forEach((branchName, value) {
      bTotalPrice += data.productsMap[branchName]![0].priceAfterDiscount;
    });

    totalSubtotalAmount = bTotalPrice;
    if (this.mounted) {
      setState(() {});
    }
  }

  /// Shipping Price
  void calAllBranchShippingPrice() {
    double bTotalShippingPrice = 0;

    data.productsMap.forEach((branchName, value) {
      if (data.productsMap[branchName]?[0].shippingData!.isNULL == false) {
        bTotalShippingPrice +=
            data.productsMap[branchName]![0].shippingData!.shippingPrice;
      }
    });

    totalShippingAmount = bTotalShippingPrice;
    if (this.mounted) {
      setState(() {});
    }
  }

  /// Calculate Final Amount (All Branch Subtotal + All Branch Shipping Price)
  void getFinalAmount() {
    totalFinalAmount = totalSubtotalAmount + totalShippingAmount;
    if (this.mounted) {
      setState(() {});
    }
  }

  void priceUpdate() {
    /// Calculate All Shipping Price
    calAllBranchTotalPrice();

    /// Calculate All Shipping Price
    calAllBranchShippingPrice();

    /// Calculate Final Amount
    getFinalAmount();
  }
  // endregion

  void setLoadingStatus(bool value) {
    isLoading = value;
    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> getPaymentStatusRT(
    String paymentID,
    List<String> orderIDS,
  ) async {
    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }

    if (FirebaseAuth.instance.currentUser!.isAnonymous == true) {
      return;
    }
    // print("** Customer UID: " + FirebaseAuth.instance.currentUser!.uid);

    print("** Checking Payment Status");
    await FirebaseFirestore.instance
        .collection("Payments")
        .doc(paymentID)
        .snapshots()
        .listen((value) {
      /// Define Temp Map Data
      Map<String, dynamic>? tempMapData = Map<String, dynamic>();

      /// Assign Data
      tempMapData = value.data() as Map<String, dynamic>;

      if (tempMapData["Status"] != null) {
        if (tempMapData["Status"] != '') {
          if (tempMapData["Status"] == '88 - Transferred') {
            /// Go to Order Completed Page
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: OrderCompletedPage(orderIDs: orderIDS),
              ),
            );
          } else if (tempMapData["Status"] == '66 - Failed') {
            /// Go to Payment Failed Page
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: PaymentFailedPage(orderIDs: orderIDS),
              ),
            );
          }
        } else {
          print('Status is Empty');
        }
      } else {
        print("** Status is Null");
      }
    });
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    var bottomBarHeight = _widgetSize.getResponsiveHeight(0.08, 0.08, 0.08);
    return Scaffold(
      appBar: _getCustomAppBar('Checkout', _widgetSize, _deviceDetails),
      backgroundColor: Theme.of(context).backgroundColor,
      body: ModalProgressHUD(
        opacity: 0.5,
        color: Colors.grey,
        inAsyncCall: isLoading,
        progressIndicator: SpinKitFoldingCube(
          color: Theme.of(context).highlightColor,
        ),
        child: SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
              minWidth: MediaQuery.of(context).size.width,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Main Part
                Expanded(
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

                /// Bottom Bar
                Column(
                  children: [
                    /// Payment Method Bar
                    getPaymentMethodUI(_deviceDetails, _widgetSize),

                    /// Check out bar
                    Container(
                      height: bottomBarHeight,
                      width: _widgetSize.getResponsiveWidth(1, 1, 1),
                      color: Colors.black,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                          _widgetSize.getResponsiveHeight(0.01, 0.01, 0.01),
                          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                          _widgetSize.getResponsiveHeight(0.01, 0.01, 0.01),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /// Shipping and Total Price
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Total Amount
                                Text(
                                  "Total Amount",
                                  style: TextStyle(
                                    fontSize:
                                        _deviceDetails.getNormalFontSize() - 2,
                                    color: Colors.white,
                                  ),
                                ),

                                /// Spacing
                                SizedBox(height: 2),

                                /// Total Amount
                                if (totalFinalAmount >= 0)
                                  Expanded(
                                    child: Text(
                                      "RM " +
                                          formatCurrency
                                              .format(totalFinalAmount),
                                      style: TextStyle(
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.w600,
                                        fontSize:
                                            _deviceDetails.getTitleFontSize(),
                                        color:
                                            Theme.of(context).primaryColorLight,
                                      ),
                                    ),
                                  ),

                                /// Negative Total Amount
                                if (totalFinalAmount < 0)
                                  Expanded(
                                    child: Text(
                                      "RM " + formatCurrency.format(0),
                                      style: TextStyle(
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.w600,
                                        fontSize:
                                            _deviceDetails.getTitleFontSize(),
                                        color:
                                            Theme.of(context).primaryColorLight,
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            /// Check Out
                            InkWell(
                              onTap: () {
                                if (shippingLoading == false) {
                                  /// Selected Shipping Address
                                  if (shippingAddressData != null) {
                                    String errorBranch =
                                        checkEachBranchShippingMethod();
                                    if (errorBranch == '') {
                                      /// Create Order
                                      if (paymentMethodTypeClass != null) {
                                        /// OTHER PAYMENT
                                        if (paymentMethodTypeClass!.type !=
                                            PaymentMethodType.AppWallet) {
                                          hasInternet().then((value) async {
                                            /// Has Internet
                                            if (value == true) {
                                              String date = DateFormat(
                                                      "yyyy-MM-dd HH:mm:ss")
                                                  .format(DateTime.now());
                                              String finalDate = date + ".000";
                                              print("Order Date Time: " +
                                                  finalDate);

                                              firebaseUser
                                                  .getIdToken()
                                                  .then((value) {
                                                setLoadingStatus(true);

                                                fetchGetTokenApi(value)
                                                    .then((value) {
                                                  setLoadingStatus(false);

                                                  if (value.errorMessage ==
                                                      null) {
                                                    String token = value
                                                        .accessToken as String;

                                                    /// Place Order
                                                    placeOrder(
                                                      _deviceDetails,
                                                      token,
                                                      finalDate,
                                                    );
                                                  } else {
                                                    showMessage(
                                                      '',
                                                      value.errorMessage
                                                          as String,
                                                      _deviceDetails,
                                                      context,
                                                    );
                                                  }
                                                });
                                              });
                                            } else {
                                              /// No internet
                                              showSnackBar(
                                                'No internet connection',
                                                context,
                                              );
                                            }
                                          });
                                        }

                                        /// App Wallet
                                        else {
                                          hasInternet().then((value) async {
                                            /// Has Internet
                                            if (value == true) {
                                              String date = DateFormat(
                                                      "yyyy-MM-dd HH:mm:ss")
                                                  .format(DateTime.now());
                                              String finalDate = date + ".000";
                                              print("Order Date Time: " +
                                                  finalDate);
                                              // getToken().then((token) {
                                              firebaseUser
                                                  .getIdToken()
                                                  .then((value) {
                                                setLoadingStatus(true);

                                                fetchGetTokenApi(value)
                                                    .then((value) {
                                                  setLoadingStatus(false);

                                                  if (value.errorMessage ==
                                                      null) {
                                                    String? token =
                                                        value.accessToken;

                                                    if (token != null) {
                                                      /// Enough Wallet Balance
                                                      if (double.parse(
                                                              walletAmount) >
                                                          totalFinalAmount) {
                                                        print(
                                                            "Wallet Balance is Enough");
                                                        placeOrderWalletEnoughAmount(
                                                          _deviceDetails,
                                                          token,
                                                          finalDate,
                                                        );
                                                      }

                                                      /// Not Enough Balance
                                                      else {
                                                        print(
                                                            "Wallet Balance Not Enough");
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                'Your wallet balance is not enough',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize:
                                                                      _deviceDetails
                                                                          .getNormalFontSize(),
                                                                ),
                                                              ),
                                                              backgroundColor:
                                                                  Theme.of(
                                                                          context)
                                                                      .backgroundColor,
                                                              // content: Text(
                                                              //   'Do you want to top up your wallet and pay for this order?',
                                                              //   style:
                                                              //       TextStyle(
                                                              //     color: Colors
                                                              //         .black,
                                                              //     fontSize:
                                                              //         _deviceDetails
                                                              //             .getNormalFontSize(),
                                                              //     fontWeight:
                                                              //         FontWeight
                                                              //             .w400,
                                                              //   ),
                                                              // ),
                                                              // actions: [
                                                              //   TextButton(
                                                              //     child: Text(
                                                              //       "Cancel",
                                                              //       style:
                                                              //           TextStyle(
                                                              //         color: Colors
                                                              //             .black,
                                                              //         fontWeight:
                                                              //             FontWeight
                                                              //                 .w400,
                                                              //         fontSize:
                                                              //             _deviceDetails
                                                              //                 .getNormalFontSize(),
                                                              //       ),
                                                              //     ),
                                                              //     onPressed:
                                                              //         () {
                                                              //       Navigator.of(
                                                              //               context)
                                                              //           .pop();
                                                              //     },
                                                              //   ),
                                                              //   TextButton(
                                                              //     child: Text(
                                                              //       "Ok",
                                                              //       style:
                                                              //           TextStyle(
                                                              //         color: Colors
                                                              //             .black,
                                                              //         fontWeight:
                                                              //             FontWeight
                                                              //                 .w400,
                                                              //         fontSize:
                                                              //             _deviceDetails
                                                              //                 .getNormalFontSize(),
                                                              //       ),
                                                              //     ),
                                                              //     onPressed:
                                                              //         () {
                                                              //       placeOrderWalletNotEnough(
                                                              //         _deviceDetails,
                                                              //         token,
                                                              //         finalDate,
                                                              //       );
                                                              //       Navigator.of(
                                                              //               context)
                                                              //           .pop();
                                                              //     },
                                                              //   ),
                                                              // ],
                                                            );
                                                          },
                                                        );
                                                      }
                                                    } else {
                                                      print(
                                                          "Couldnt get Token");
                                                    }
                                                  } else {
                                                    print("Error Message: " +
                                                        (value.errorMessage
                                                            as String));
                                                  }
                                                });
                                              });
                                            } else {
                                              /// No internet
                                              showSnackBar(
                                                'No internet connection',
                                                context,
                                              );
                                            }
                                          });
                                        }
                                      }

                                      /// Not payment method selected
                                      else {
                                        setState(() {
                                          hasPaymentMethod = false;
                                        });

                                        showMessage(
                                          '',
                                          'Please Select a Payment Method',
                                          _deviceDetails,
                                          context,
                                        );
                                      }
                                    } else {
                                      showMessage(
                                        '',
                                        "Please select shipping method in $errorBranch",
                                        _deviceDetails,
                                        context,
                                      );
                                    }
                                  } else {
                                    setState(() {
                                      hasShippingAddress = false;
                                    });
                                    showMessage(
                                      '',
                                      'Please Select Shipping Address',
                                      _deviceDetails,
                                      context,
                                    );
                                  }
                                } else {
                                  showMessage(
                                    '',
                                    'Shipping Data is still loading',
                                    _deviceDetails,
                                    context,
                                  );
                                }
                              },
                              child: Container(
                                width: _widgetSize.getResponsiveWidth(
                                  0.25,
                                  0.25,
                                  0.25,
                                ),
                                height: bottomBarHeight,
                                decoration: BoxDecoration(
                                    color: Theme.of(context).highlightColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                  child: Text(
                                    "Place Order",
                                    style: TextStyle(
                                      fontSize:
                                          _deviceDetails.getNormalFontSize() -
                                              2,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getPageContent(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    List<Widget> pageContent = [];

    /// Spacing
    SizedBox _spacing = SizedBox(
      height: _widgetSize.getResponsiveHeight(0.03, 0.03, 0.03),
    );

    /// Spacing
    SizedBox _spacing2 = SizedBox(
      height: _widgetSize.getResponsiveHeight(0.1, 0.1, 0.1),
    );

    /// Notice
    if (enableNotice == true) {
      pageContent.add(Padding(
        padding: EdgeInsets.only(
            bottom: _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02)),
        child: Container(
          color: Theme.of(context).shadowColor,
          child: ListTile(
            trailing: InkWell(
              onTap: () {
                enableNotice = false;
                setState(() {});
              },
              child: Icon(
                Icons.clear,
                size: _widgetSize.getResponsiveWidth(0.04, 0.04, 0.04),
                color: Theme.of(context).primaryColor,
              ),
            ),
            leading: Icon(
              Icons.notifications,
              size: _widgetSize.getResponsiveWidth(0.04, 0.04, 0.04),
              color: Colors.grey,
            ),
            title: Text(
              checkoutMessageString,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: _deviceDetails.getNormalFontSize() - 2,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ));
    }

    /// User info UI
    pageContent.add(getUserInfoUI(_deviceDetails, _widgetSize));

    /// Line
    pageContent.add(
      Container(
        height: _widgetSize.getResponsiveHeight(0.005, 0.005, 0.005),
        color: Theme.of(context).highlightColor,
      ),
    );

    /// Details
    pageContent.add(getOrderDetailsUI(_deviceDetails, _widgetSize));

    /// List of Products
    data.productsMap.forEach((branchName, value) {
      /// List of Product Details
      for (int index = 0; index < value.length; ++index) {
        /// Branch Name
        if (index == 0) {
          pageContent.add(
            Padding(
              padding: EdgeInsets.only(
                  top: _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02)),
              child: Container(
                color: Theme.of(context).shadowColor,
                width: _widgetSize.getResponsiveWidth(1, 1, 1),
                height: _widgetSize.getResponsiveWidth(0.12, 0.12, 0.12),
                child: Row(
                  children: [
                    /// Spacing
                    SizedBox(
                        width:
                            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),

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
                        width:
                            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),

                    Text(
                      branchName,
                      style: TextStyle(
                        fontSize: _deviceDetails.getTitleFontSize(),
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        /// Because first index is empty
        else if (index > 0) {
          /// Last Index No line
          if (index == data.productsMap[branchName]!.length - 1) {
            pageContent.add(
              Container(
                color: Theme.of(context).shadowColor,
                height: _widgetSize.getResponsiveWidth(0.25, 0.25, 0.25),
                padding: EdgeInsets.fromLTRB(
                  _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                  0,
                  _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                  0,
                ),
                child: CustomCheckOutUI(
                  quantity: data.productsMap[branchName]![index].quantity,
                  title: data.productsMap[branchName]![index].productName,
                  titleColor: Theme.of(context).primaryColor,
                  fontColor: Theme.of(context).primaryColor,
                  finalPrice: formatCurrency.format(
                    data.productsMap[branchName]![index].price,
                  ),
                  networkImagePath:
                      data.productsMap[branchName]![index].image as String,
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
                  selectedProductVariant: data
                      .productsMap[branchName]![index].selectedProductVariant,
                  productVariantFinal:
                      data.productsMap[branchName]![index].productVariantFinal,
                ),
              ),
            );
          }

          /// Has line
          else {
            pageContent.add(
              Container(
                height: _widgetSize.getResponsiveWidth(0.25, 0.25, 0.25),
                decoration: BoxDecoration(
                  color: Theme.of(context).shadowColor,
                  border: Border(
                    bottom: BorderSide(
                      width: 0.9,
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
                  quantity: data.productsMap[branchName]![index].quantity,
                  title: data.productsMap[branchName]![index].productName,
                  titleColor: Theme.of(context).primaryColor,
                  fontColor: Theme.of(context).primaryColor,
                  finalPrice: formatCurrency.format(
                    data.productsMap[branchName]![index].price,
                  ),
                  networkImagePath:
                      data.productsMap[branchName]![index].image as String,
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
                  selectedProductVariant: data
                      .productsMap[branchName]![index].selectedProductVariant,
                  productVariantFinal:
                      data.productsMap[branchName]![index].productVariantFinal,
                ),
              ),
            );
          }
        }
      }

      // /// Update All Price
      // if (updatePrice == true) {
      //   calculateAndAssignEachBranchTotalPrice(branchName);
      //   calculateFinalPrice();
      // }

      /// Shipping data is done loading
      if (shippingLoading == false) {
        pageContent.add(
          getEachBranchShippingUI(
            _deviceDetails,
            _widgetSize,
            branchName,
          ),
        );
      }

      if (data.productsMap[branchName]?[0].voucherData != null) {
        /// Branch Total Price
        pageContent.add(
          getEachBranchSubTotalUI(
            _deviceDetails,
            _widgetSize,
            branchName,
          ),
        );

        /// Voucher UI
        pageContent.add(
          getEachBranchVoucherUI(
            _deviceDetails,
            _widgetSize,
            branchName,
          ),
        );
      }

      /// Branch Total Price
      pageContent.add(
        getEachBranchTotalUI(
          _deviceDetails,
          _widgetSize,
          branchName,
        ),
      );
    });

    updatePrice = false;

    if (App.testing == true) {
      pageContent.add(_spacing);

      /// Voucher Code Input UI
      pageContent.add(getVoucherInputUI(_deviceDetails, _widgetSize));
    }

    pageContent.add(_spacing);

    /// Subtotal + Shipping + Total Item
    pageContent.add(getTotalUI(_deviceDetails, _widgetSize));

    pageContent.add(_spacing2);

    return pageContent;
  }
}
