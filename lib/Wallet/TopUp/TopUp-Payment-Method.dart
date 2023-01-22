import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timoti_project/Custom-UI/Custom-DefaultAppBar.dart';
import 'package:timoti_project/Data-Class/PaymentMethodResultClass.dart';
import 'package:timoti_project/Functions/ConvertToPaymentMethod.dart';
import 'package:timoti_project/Functions/Messager.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';
import 'package:timoti_project/Screen-Size/ui-utils.dart';
import 'package:timoti_project/Wallet/TopUp/TopUpPage.dart';
import 'package:timoti_project/enums/device-screen-type.dart';

class TopUpPaymentMethodPage extends StatefulWidget {
  static const routeName = '/TopUpPaymentMethodPage';

  @override
  State<TopUpPaymentMethodPage> createState() => _TopUpPaymentMethodPageState();
}

class _TopUpPaymentMethodPageState extends State<TopUpPaymentMethodPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool loading = false;
  List<DocumentSnapshot> paymentMethodsDocList = <DocumentSnapshot>[];

  @override
  void initState() {
    getPaymentMethodData();
    if (this.mounted) {
      setState(() {});
    }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // region UI
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
                      /// Empty Box
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back_ios_sharp,
                          color: Theme.of(context).primaryColor,
                          size:
                          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                        ),
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

  /// Top Up method ui
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
          "Please Select 1 Top Up Method",
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
    BuildContext context,
  ) {
    var mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () => onTapPaymentMethodFunction(
          status,
          id,
          text,
          _deviceDetails,
          context,
        ),
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
  // endregion

  // region Functions
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

  void onTapPaymentMethodFunction(
    bool status,
    String paymentMethodID,
    String paymentMethodName,
    DeviceDetails _deviceDetails,
    BuildContext context,
  ) {
    if (status == false) {
      showMessage(
        "",
        "This Top Up Method is temporary unavailable.",
        _deviceDetails,
        context,
      );
    } else {
      PaymentMethodResultClass result = new PaymentMethodResultClass(
        type: convertStringToPaymentMethodType(paymentMethodID),
        paymentMethodName: paymentMethodName,
      );

      /// Go To Top Up
      Navigator.pushNamed(
        context,
        TopUpPage.routeName,
        arguments: result,
      );
    }
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Scaffold(
      appBar: CustomDefaultAppBar(
        widgetSize: _widgetSize,
        appbarTitle: 'Select Top Up Method',
        onTapFunction: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: getPageContent(context, _deviceDetails, _widgetSize),
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  List<Widget> getPageContent(
    BuildContext context,
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    List<Widget> pageContent = [];

    /// Top Up Method UI
    pageContent.add(getPaymentMethodUI(_deviceDetails, _widgetSize));

    for (int i = 0; i < paymentMethodsDocList.length; ++i) {
      print("Length: " + paymentMethodsDocList.length.toString());
      Map<String, dynamic> tempMapData = Map<String, dynamic>();

      /// Assign Data
      tempMapData = paymentMethodsDocList[i].data() as Map<String, dynamic>;

      /// Ensure App Wallet is not display
      if (tempMapData["Id"] != "AppWallet") {
        pageContent.add(
          getSelectedMethodUI(
            _deviceDetails,
            _widgetSize,
            tempMapData["Name"],
            tempMapData["Id"],
            tempMapData["Descriptions"],
            tempMapData["Status"],
            context,
          ),
        );
      }
    }
    return pageContent;
  }
}
