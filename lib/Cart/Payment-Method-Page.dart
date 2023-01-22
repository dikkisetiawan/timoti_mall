import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timoti_project/Custom-UI/Custom-DefaultAppBar.dart';
import 'package:timoti_project/Custom-UI/Custom-LoadingUI.dart';
import 'package:timoti_project/Data-Class/PaymentMethodResultClass.dart';
import 'package:timoti_project/Functions/ConvertToPaymentMethod.dart';
import 'package:timoti_project/Functions/Messager.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';
import 'package:timoti_project/Screen-Size/ui-utils.dart';
import 'package:timoti_project/enums/Payment-Method-Type.dart';
import 'package:timoti_project/enums/device-screen-type.dart';
import 'package:timoti_project/main.dart';

class PaymentMethodPage extends StatefulWidget {
  static const routeName = '/PaymentMethodPage';
  @override
  _PaymentMethodPageState createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  final formatCurrency = new NumberFormat.currency(
    locale: "ms-MY",
    symbol: "",
    decimalDigits: 2,
  );

  String walletAmount = '0';
  User firebaseUser = FirebaseAuth.instance.currentUser as User;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool loading = false;
  List<DocumentSnapshot> paymentMethodsDocList = <DocumentSnapshot>[];

  @override
  void initState() {
    getPaymentMethodData();
    getWalletAmountInit();

    print(firebaseUser.displayName);
    if (this.mounted) {
      setState(() {});
    }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Get Payment Data
  Future<void> getPaymentMethodData() async {
    if (!mounted) {
      return;
    }

    if (this.mounted) {
      loading = true;
      setState(() {});
    }

    /// Get Payment Methods Data
    QuerySnapshot paymentMethodsSnapShots;
    paymentMethodsSnapShots =
        await firestore.collection('PaymentMethods').get();

    /// Has Document
    if (paymentMethodsSnapShots.docs.length > 0) {
      for (int i = 0; i < paymentMethodsSnapShots.docs.length; ++i) {
        paymentMethodsDocList.add(paymentMethodsSnapShots.docs[i]);
      }
    } else {
      print("Payment Methods Not Found!!!");
    }

    if (this.mounted) {
      loading = false;
      setState(() {});
    }
  }

  /// Get Wallet Amount In Real Time Update
  void getWalletAmountInit() async {
    FirebaseFirestore.instance
        .collection("Customers")
        .doc(firebaseUser.uid)
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

  // region UI
  /// Payment method ui
  Widget getPaymentMethodUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        _widgetSize.getResponsiveHeight(0.02, 0.02, 0.02),
        0,
        _widgetSize.getResponsiveHeight(0.01, 0.01, 0.01),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Please Select 1 Payment Method",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: _deviceDetails.getNormalFontSize(),
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  /// Payment method ui
  Widget getSelectedMethodUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    String text,
    String id,
    String subText,
    bool status,
  ) {
    var mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () =>
            onTapPaymentMethodFunction(status, id, text, _deviceDetails),
        child: Container(
          decoration: BoxDecoration(
            color:
                status == true ? Theme.of(context).shadowColor : Colors.black45,
            border: Border(
              bottom: BorderSide(
                width: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                    ? 1
                    : 3.0,
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          child: ListTile(
            trailing: status == true
                ? Icon(
                    Icons.arrow_forward_ios,
                    size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    color: Theme.of(context).primaryColor,
                  )
                : Text(
                    'Temporary Unavailable',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: _deviceDetails.getNormalFontSize(),
                      color: Colors.white,
                    ),
                  ),
            subtitle: Text(
              subText,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: _deviceDetails.getNormalFontSize() - 2,
                color: status == true
                    ? Theme.of(context).primaryColor
                    : Colors.white,
              ),
            ),
            title: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: _deviceDetails.getNormalFontSize(),
                color: status == true
                    ? Theme.of(context).primaryColor
                    : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getSelectedMethodWalletUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    String text,
    String id,
    String subText,
    bool status,
  ) {
    var mediaQuery = MediaQuery.of(context);

    return InkWell(
      onTap: () => onTapPaymentMethodFunction(status, id, text, _deviceDetails),
      child: Container(
        decoration: BoxDecoration(
          color:
              status == true ? Theme.of(context).shadowColor : Colors.black45,
          border: Border(
            bottom: BorderSide(
              width: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                  ? 1
                  : 3.0,
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
        child: ListTile(
          trailing: Container(
            width: _widgetSize.getResponsiveWidth(0.3, 0.3, 0.3),
            child: status == true
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FittedBox(
                        child: Text(
                          "RM " +
                              formatCurrency
                                  .format(double.parse(walletAmount))
                                  .toString(),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: _deviceDetails.getNormalFontSize(),
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  )
                : Text(
                    'Temporary Unavailable',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: _deviceDetails.getNormalFontSize(),
                      color: Colors.white,
                    ),
                  ),
          ),
          subtitle: Text(
            subText,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: _deviceDetails.getNormalFontSize() - 2,
              color: status == true
                  ? Theme.of(context).primaryColor
                  : Colors.white,
            ),
          ),
          title: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: _deviceDetails.getNormalFontSize(),
              color: status == true
                  ? Theme.of(context).primaryColor
                  : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
  // endregion

  Future<String> getWalletAmount() async {
    if (!mounted) {
      return '0.00';
    }

    String amount = '0.00';
    await FirebaseFirestore.instance
        .collection("Customers")
        .doc(firebaseUser.uid)
        .get()
        .then((value) {
      /// Define Map Data
      Map<String, dynamic> walletMapData = Map<String, dynamic>();

      /// Assign Data
      walletMapData = value.data() as Map<String, dynamic>;

      if (walletMapData["walletAmount"] != null) {
        if (walletMapData["walletAmount"] != '') {
          walletAmount = walletMapData["walletAmount"];
          // print("Wallet Amount: " + walletAmount);
          amount = walletAmount;
          // print("Wallet Amount: " + amount);
        }
      }
    });

    return amount;
  }

  void onTapPaymentMethodFunction(
    bool status,
    String paymentMethodID,
    String paymentMethodName,
    DeviceDetails _deviceDetails,
  ) {
    if (status == false) {
      showMessage(
        "",
        "This payment method is temporary unavailable.",
        _deviceDetails,
        context,
      );
    } else {
      PaymentMethodResultClass result = new PaymentMethodResultClass(
        type: convertStringToPaymentMethodType(paymentMethodID),
        paymentMethodName: paymentMethodName,
      );
      Navigator.pop(
        context,
        result,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Scaffold(
      appBar: CustomDefaultAppBar(
        widgetSize: _widgetSize,
        appbarTitle: 'Select Payment Method',
        onTapFunction: () => Navigator.pop(context),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Scrollbar(
        child: SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
              minWidth: MediaQuery.of(context).size.width,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: loading == false
                    ? getPageContent(
                        _deviceDetails,
                        _widgetSize,
                      )
                    : [
                        Text(
                          "Loading...",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10),
                        CustomLoading(),
                      ],
              ),
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

    /// Payment Method UI
    pageContent.add(getPaymentMethodUI(_deviceDetails, _widgetSize));

    for (int i = 0; i < paymentMethodsDocList.length; ++i) {
      print("Length: " + paymentMethodsDocList.length.toString());
      Map<String, dynamic> tempMapData = Map<String, dynamic>();

      /// Assign Data
      tempMapData = paymentMethodsDocList[i].data() as Map<String, dynamic>;

      /// App Wallet
      if (tempMapData["Id"] == "AppWallet") {
        pageContent.add(
          getSelectedMethodWalletUI(
            _deviceDetails,
            _widgetSize,
            tempMapData["Name"],
            tempMapData["Id"],
            tempMapData["Descriptions"],
            tempMapData["Status"],
          ),
        );

        pageContent.add(Padding(
          padding: EdgeInsets.fromLTRB(
            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "OR",
              style: TextStyle(
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
                fontSize: _deviceDetails.getNormalFontSize(),
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ));
      }

      /// Other Payment Methods
      else {
        pageContent.add(
          getSelectedMethodUI(
            _deviceDetails,
            _widgetSize,
            tempMapData["Name"],
            tempMapData["Id"],
            tempMapData["Descriptions"],
            tempMapData["Status"],
          ),
        );
      }
    }

    return pageContent;
  }
}
