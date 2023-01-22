import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/Core/auth.dart';
import '/Custom-UI/Custom-LoadingUI.dart';
import '/Functions/Messager.dart';
import '/Functions/Wallet-Amount-RealTime.dart';
import '/QrCode-Page/Qr-Request-Page.dart';
import '/QrCode-Page/Qr-Scanner.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';
import '/Wallet/SendWallet/SelectContactPage.dart';
import '/Wallet/StatementDetailsPage.dart';
import '/Wallet/TopUp/TopUp-Payment-Method.dart';
import '/main.dart';

class WalletPage extends StatefulWidget {
  static const routeName = '/WalletPage';
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  List<DocumentSnapshot> statements = [];
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 5;
  DocumentSnapshot? lastDocument;

  final ScrollController _scrollController = ScrollController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isWalletLoading = false;
  String name = '';

  final formatCurrency = new NumberFormat.currency(
    locale: "ms-MY",
    symbol: "",
    decimalDigits: 2,
  );

  @override
  void initState() {
    if (FirebaseAuth.instance.currentUser?.isAnonymous == false) {
      /// Get User Data
      print(FirebaseAuth.instance.currentUser?.displayName);
      getName();
      getStatements();
    }

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // region UI
  Widget getBGImage(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    /// Just Background
    return Container(
      height: _widgetSize.getResponsiveHeight(0.25, 0.25, 0.25),
      width: _widgetSize.getResponsiveWidth(1, 1, 1),
      color: Theme.of(context).primaryColor,
    );

    /// With Image
    // return Image(
    //   height: _widgetSize.getResponsiveHeight(0.25, 0.25, 0.25),
    //   width: _widgetSize.getResponsiveWidth(1, 1, 1),
    //   image: AssetImage('assets/icon/walletbg.jpg'),
    //   fit: BoxFit.fill,
    // );
  }

  /// Wallet UI
  Widget getWalletUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return Column(
      children: [
        /// Title + Settings
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Title
            Text(
              "Wallet  ",
              style: TextStyle(
                color: Colors.white,
                fontSize: _deviceDetails.getTitleFontSize() + 5,
                fontWeight: FontWeight.w400,
              ),
            ),

            /// Setting button
            // InkWell(
            //   onTap: () {
            //     print('Tapped Settings');
            //   },
            //   child: Image(
            //     height: _widgetSize.getResponsiveWidth(0.08),
            //     image: AssetImage('assets/icon/setting.png'),
            //     color: Theme.of(context).primaryColor,
            //     fit: BoxFit.contain,
            //   ),
            // ),

            SizedBox(width: 5),
          ],
        ),

        SizedBox(
          height: 10,
        ),

        /// Wallet
        Material(
          borderRadius: BorderRadius.circular(10),
          shadowColor: Colors.black,
          elevation: 15,
          child: Container(
            width: _widgetSize.getResponsiveWidth(0.9, 0.9, 0.9),
            height: _widgetSize.getResponsiveHeight(0.25, 0.25, 0.25),
            decoration: BoxDecoration(
              // color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                /// Top
                Expanded(
                  flex: 7,
                  child: InkWell(
                    onTap: () {
                      // Navigator.pushNamed(context, WalletDetailsPage.routeName);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        borderRadius: new BorderRadius.only(
                          // bottomLeft: const Radius.circular(10.0),
                          // bottomRight: const Radius.circular(10.0),
                          topLeft: const Radius.circular(10.0),
                          topRight: const Radius.circular(10.0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Title
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                              _widgetSize.getResponsiveWidth(0.04, 0.04, 0.04),
                              0,
                              _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "${App.appName} Wallet",
                                // 'Kemayu Wallet',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: _deviceDetails.getTitleFontSize(),
                                ),
                              ),
                            ),
                          ),

                          /// RM + 0.00
                          WalletAmountUIEx(
                            widgetSize: _widgetSize,
                            deviceDetails: _deviceDetails,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                /// Bottom
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).shadowColor,
                      borderRadius: new BorderRadius.only(
                        bottomLeft: const Radius.circular(10.0),
                        bottomRight: const Radius.circular(10.0),
                      ),
                    ),
                    child: Center(
                      child: InkWell(
                        onTap: () {
                          // Navigator.pushNamed(context, WalletDetailsPage.routeName);
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                            0,
                            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                            0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              /// Text
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "",
                                  style: TextStyle(
                                      fontSize:
                                          _deviceDetails.getNormalFontSize(),
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),

                              /// Arrow
                              // Icon(
                              //   Icons.arrow_forward_ios,
                              //   color: Colors.grey,
                              //   size: _widgetSize.getResponsiveWidth(0.03,0.03,0.03),
                              // ),
                            ],
                          ),
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
    );
  }

  /// Wallet Feature
  Widget getWalletFeatureUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return Container(
      height: _widgetSize.getResponsiveWidth(0.25, 0.25, 0.25),
      padding: EdgeInsets.fromLTRB(
        _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          /// Top Up
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                0,
                0,
                0,
                0,
              ),
              child: Material(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).shadowColor,
                elevation: 10,
                child: InkWell(
                  onTap: () async {
                    if (FirebaseAuth.instance.currentUser?.isAnonymous ==
                        false) {
                      Navigator.pushNamed(
                        context,
                        TopUpPaymentMethodPage.routeName,
                      );
                    } else {
                      showLoginMessage(0, 15, context);
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// Icon
                      Expanded(
                        child: Image(
                          // height: _widgetSize.getResponsiveHeight(0.25,0.25,0.25),
                          // width: _widgetSize.getResponsiveHeight(0.25,0.25,0.25),
                          image: AssetImage('assets/icon/topup.png'),
                          // color: Theme.of(context).highlightColor,
                          fit: BoxFit.contain,
                        ),
                      ),

                      /// Text
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          "Top Up",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: _deviceDetails.getNormalFontSize() - 2,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// Scan to Pay
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
                0,
                0,
                0,
              ),
              child: Material(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).shadowColor,
                elevation: 10,
                child: InkWell(
                  onTap: () => showTempMessage(_deviceDetails, context),
                  // onTap: () async {
                  //   if (FirebaseAuth.instance.currentUser?.isAnonymous == false) {
                  //     Navigator.pushNamed(context, QrScanner.routeName);
                  //   } else {
                  //     showLoginMessage(0, 15, context);
                  //   }
                  // },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// Icon
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Image(
                            // height: _widgetSize.getResponsiveHeight(0.25,0.25,0.25),
                            // width: _widgetSize.getResponsiveHeight(0.25,0.25,0.25),
                            image: AssetImage('assets/icon/scan.png'),
                            // color: Theme.of(context).shadowColor,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),

                      /// Text
                      FittedBox(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(5, 0, 5, 10),
                          child: Text(
                            "Scan to Pay",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: _deviceDetails.getNormalFontSize() - 2,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// Send
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
                0,
                0,
                0,
              ),
              child: Material(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).shadowColor,
                elevation: 10,
                child: InkWell(
                  onTap: () => showTempMessage(_deviceDetails, context),
                  // onTap: () async {
                  //   if (FirebaseAuth.instance.currentUser?.isAnonymous == false) {
                  //     Navigator.pushNamed(context, SelectContactPage.routeName);
                  //   } else {
                  //     showLoginMessage(0, 15, context);
                  //   }
                  // },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// Icon
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Image(
                            // height: _widgetSize.getResponsiveHeight(0.25,0.25,0.25),
                            // width: _widgetSize.getResponsiveHeight(0.25,0.25,0.25),
                            image: AssetImage('assets/icon/send.png'),
                            // color: Theme.of(context).shadowColor,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),

                      /// Text
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          "Send",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: _deviceDetails.getNormalFontSize() - 2,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// Receive
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
                0,
                0,
                0,
              ),
              child: Material(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).shadowColor,
                elevation: 10,
                child: InkWell(
                  onTap: () => showTempMessage(_deviceDetails, context),
                  // onTap: () async {
                  //   if (FirebaseAuth.instance.currentUser?.isAnonymous == false) {
                  //     if (FirebaseAuth.instance.currentUser != null && name != '')
                  //       Navigator.push(
                  //           context,
                  //           new MaterialPageRoute(
                  //             builder: (BuildContext context) => QrRequestPage(
                  //               uid: firebaseUser.uid,
                  //               userfullname: name,
                  //             ),
                  //           ));
                  //   } else {
                  //     showLoginMessage(0, 15, context);
                  //   }
                  // },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// Icon
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Image(
                            // height: _widgetSize.getResponsiveHeight(0.25,0.25,0.25),
                            // width: _widgetSize.getResponsiveHeight(0.25,0.25,0.25),
                            image: AssetImage('assets/icon/receive.png'),
                            // color: Theme.of(context).shadowColor,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),

                      /// Text
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          "Receive",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: _deviceDetails.getNormalFontSize() - 2,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Recent Transaction
  Widget getRecentTransactionsTitle(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return Padding(
      // color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        _widgetSize.getResponsiveWidth(0.01, 0.01, 0.01),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Title
            Text(
              "Recent Transactions",
              style: TextStyle(
                fontSize: _deviceDetails.getTitleFontSize(),
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),

            /// Refresh Button
            IconButton(
              iconSize: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
              icon: Icon(
                Icons.refresh,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                if (FirebaseAuth.instance.currentUser?.isAnonymous == false) {
                  refreshStatements();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Return Subtitle Text of Statement
  Widget returnSubtitleText(
    DeviceDetails _deviceDetails,
    DocumentSnapshot snapshot,
  ) {
    Map<String, dynamic>? snapshotMapData =
        snapshot.data() as Map<String, dynamic>;

    /// Top Up
    if (snapshotMapData['Statement_Type'] == "Top Up") {
      if (snapshotMapData['Statement_Payment_Method'] != null) {
        return Text(
          "Using " + snapshotMapData['Statement_Payment_Method'],
          style: TextStyle(
              fontSize: _deviceDetails.getNormalFontSize() - 2,
              color: Colors.black,
              fontWeight: FontWeight.w500),
        );
      } else {
        return Text(
          snapshot.id.toString(),
          style: TextStyle(
            fontSize: _deviceDetails.getNormalFontSize() - 2,
            color: Colors.black,
          ),
        );
      }
    }

    /// Send
    else if (snapshotMapData['Statement_Type'] == "Send") {
      if (snapshotMapData['Statement_Sent_To_Name'] != null) {
        return Text(
          "To " + snapshotMapData['Statement_Sent_To_Name'],
          style: TextStyle(
              fontSize: _deviceDetails.getNormalFontSize() - 2,
              color: Colors.black,
              fontWeight: FontWeight.w500),
        );
      } else {
        return Text(
          "Old Statement ID (Send) " + snapshot.id.toString(),
          style: TextStyle(
            fontSize: _deviceDetails.getNormalFontSize() - 2,
            color: Colors.black,
          ),
        );
      }
    }

    /// Receive
    else if (snapshotMapData['Statement_Type'] == "Receive") {
      if (snapshotMapData['Statement_Received_From_Name'] != null) {
        return Text(
          "From " + snapshotMapData['Statement_Received_From_Name'],
          style: TextStyle(
              fontSize: _deviceDetails.getNormalFontSize() - 2,
              color: Colors.black,
              fontWeight: FontWeight.w500),
        );
      } else {
        return Text(
          "Old Statement ID (Receive) " + snapshot.id.toString(),
          style: TextStyle(
            fontSize: _deviceDetails.getNormalFontSize() - 2,
            color: Colors.black,
          ),
        );
      }
    }

    /// Payment
    else if (snapshotMapData['Statement_Type'] == "Payment") {
      if (snapshotMapData['Statement_Payment_Method'] != null) {
        return Text(
          "Using " + snapshotMapData['Statement_Payment_Method'],
          style: TextStyle(
              fontSize: _deviceDetails.getNormalFontSize() - 2,
              color: Colors.black,
              fontWeight: FontWeight.w500),
        );
      } else {
        return Text(
          "Old Statement ID (Payment) " + snapshot.id.toString(),
          style: TextStyle(
            fontSize: _deviceDetails.getNormalFontSize() - 2,
            color: Colors.black,
          ),
        );
      }
    }

    /// Refund
    else if (snapshot['Statement_Type'] == "Refund") {
      if (snapshot['Statement_Refund_Method'] != null) {
        return Text(
          "Refunded to ${snapshot['Statement_Refund_Method']}",
          style: TextStyle(
              fontSize: _deviceDetails.getNormalFontSize() - 2,
              color: Colors.black,
              fontWeight: FontWeight.w500),
        );
      } else {
        return Text(
          "Old Statement ID (Send) " + snapshot.id.toString(),
          style: TextStyle(
            color: Colors.black,
          ),
        );
      }
    } else {
      return Text(
        snapshot.id.toString(),
        style: TextStyle(
          color: Colors.black,
        ),
      );
    }
  }

  /// Return Amount Text of Statement
  Widget returnAmountText(
    DeviceDetails _deviceDetails,
    DocumentSnapshot snapshot,
  ) {
    Map<String, dynamic>? snapshotMapData =
        snapshot.data() as Map<String, dynamic>;

    /// Top Up
    if (snapshotMapData['Statement_Type'] == "Top Up") {
      return Text(
        "RM " +
            formatCurrency
                .format(double.parse(snapshotMapData['Statement_Amount']))
                .toString(),
        style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: _deviceDetails.getNormalFontSize()),
      );
    }

    /// Send
    else if (snapshotMapData['Statement_Type'] == "Send") {
      return Text(
        "RM -" +
            formatCurrency
                .format(double.parse(snapshotMapData['Statement_Amount']))
                .toString(),
        style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: _deviceDetails.getNormalFontSize()),
      );
    }

    /// Receive
    else if (snapshotMapData['Statement_Type'] == "Receive") {
      return Text(
        "RM " +
            formatCurrency
                .format(double.parse(snapshotMapData['Statement_Amount']))
                .toString(),
        style: TextStyle(
            color: Theme.of(context).highlightColor,
            fontWeight: FontWeight.bold,
            fontSize: _deviceDetails.getNormalFontSize()),
      );
    }

    /// Payment
    else {
      return Text(
        "RM -" +
            formatCurrency
                .format(double.parse(snapshotMapData['Statement_Amount']))
                .toString(),
        style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: _deviceDetails.getNormalFontSize()),
      );
    }
  }

  Widget getStatementDateUI(
    int index,
    Map<String, dynamic>? statementMapData,
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    /// Show first index date
    if (index == 0) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          _widgetSize.getResponsiveWidth(0.01, 0.01, 0.01),
          0,
          _widgetSize.getResponsiveWidth(0.01, 0.01, 0.01),
        ),
        child: Text(
          getFormattedDate(statementMapData!['Statement_DateTime']),
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: _deviceDetails.getNormalFontSize() - 2),
        ),
      );
    }

    /// Not showing the date, if current index.date == previous index.date
    else if (index > 0) {
      Map<String, dynamic>? statementLASTMapData =
          statements[index - 1].data() as Map<String, dynamic>;

      if (getFormattedDate(statementMapData!['Statement_DateTime']) !=
          getFormattedDate(statementLASTMapData['Statement_DateTime'])) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
            _widgetSize.getResponsiveWidth(0.01, 0.01, 0.01),
            0,
            _widgetSize.getResponsiveWidth(0.01, 0.01, 0.01),
          ),
          child: Text(
            getFormattedDate(statementMapData['Statement_DateTime']),
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: _deviceDetails.getNormalFontSize() - 2),
          ),
        );
      }
    }
    return Container();
  }

  Widget getTransUI(
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
  ) {
    if (statements.length == 0) {
      return ListTile(
        tileColor: Theme.of(context).shadowColor,
        contentPadding: EdgeInsets.only(
            left: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),
        title: Text(
          'Your recent transaction history will display here',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        controller: _scrollController,
        itemCount: statements.length,
        itemBuilder: (context, index) {
          Map<String, dynamic>? statementMapData =
              statements[index].data() as Map<String, dynamic>;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Get Statement UI
              getStatementDateUI(
                index,
                statementMapData,
                _deviceDetails,
                _widgetSize,
              ),

              /// Data
              InkWell(
                onTap: () {
                  List<String> orderList = <String>[];
                  if (statementMapData['Statement_OrderID'] != null) {
                    if (statementMapData['Statement_OrderID'].length > 0) {
                      for (int i = 0;
                          i < statementMapData['Statement_OrderID'].length;
                          ++i) {
                        orderList.add(statementMapData['Statement_OrderID'][i]);
                      }
                    }
                  }
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                        builder: (BuildContext context) => StatementDetails(
                          Statement_Amount:
                              statementMapData['Statement_Amount'],
                          Statement_Bank_Name:
                              statementMapData['Statement_Bank_Name'],
                          Statement_DateTime: getStatementDetailsDate(
                              statementMapData['Statement_DateTime']),
                          Statement_Id: statements[index].id.toString(),
                          Statement_Note: statementMapData['Statement_Note'],
                          Statement_Payment_Method:
                              statementMapData['Statement_Payment_Method'],
                          Statement_Received_From:
                              statementMapData['Statement_Received_From'],
                          Statement_Sent_To:
                              statementMapData['Statement_Sent_To'],
                          Statement_Type: statementMapData['Statement_Type'],
                          Statement_Sent_To_Name:
                              statementMapData['Statement_Sent_To_Name'],
                          Statement_Received_From_Name:
                              statementMapData['Statement_Received_From_Name'],
                          Statement_Payment_ID:
                              statementMapData['Statement_Payment_ID'],
                          Statement_Refund_ID:
                              statementMapData['Statement_Refund_ID'],
                          Statement_Refund_Method:
                              statementMapData['Statement_Refund_Method'],
                          Statement_OrderID: orderList,
                        ),
                      ));
                },
                child: ListTile(
                  tileColor: Theme.of(context).shadowColor,
                  contentPadding: EdgeInsets.fromLTRB(
                    _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    0,
                    _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    0,
                  ),
                  title: Text(
                    statementMapData['Statement_Type'],
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: returnSubtitleText(
                    _deviceDetails,
                    statements[index],
                  ),
                  trailing: SizedBox(
                    width: _widgetSize.getResponsiveWidth(0.4, 0.4, 0.4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FittedBox(
                          child: returnAmountText(
                            _deviceDetails,
                            statements[index],
                          ),
                        ),
                        SizedBox(
                          width:
                              _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(context).primaryColor,
                          size:
                              _widgetSize.getResponsiveWidth(0.04, 0.04, 0.04),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              /// Spacing
              SizedBox(
                height: _widgetSize.getResponsiveHeight(0.01, 0.01, 0.01),
              ),
            ],
          );
        },
      );
    }
  }
  // endregion

  // region Functions
  void getName() async {
    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }
    DocumentSnapshot data = await firestore
        .collection('Customers')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (this.mounted) {
      /// Define Temp Map Data
      Map<String, dynamic>? tempMapData = Map<String, dynamic>();

      /// Assign Data
      tempMapData = data.data() as Map<String, dynamic>;
      name = tempMapData["Full_Name"];
      print("Name " + name.toString());
      // setState(() {});
    }
  }

  void refreshStatements() {
    hasMore = true;
    statements.clear();
    lastDocument = null;
    getStatements();
  }

  Future<String> getUserName(String id) async {
    String data = '';
    await FirebaseFirestore.instance
        .collection("Customers")
        .doc(id)
        .get()
        .then((value) {
      /// Define Temp Map Data
      Map<String, dynamic>? tempMapData = Map<String, dynamic>();

      /// Assign Data
      tempMapData = value.data() as Map<String, dynamic>;
      data = tempMapData["displayName"];
    });
    return data;
  }

  getStatements() async {
    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }

    if (!hasMore) {
      print('No More Data');
      if (this.mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }
    if (isLoading) {
      return;
    }

    /// Begin Here
    if (this.mounted) {
      setState(() {
        isLoading = true;
      });
    }

    QuerySnapshot querySnapshot;

    /// First Time Load
    if (lastDocument == null) {
      querySnapshot = await firestore
          .collection('Customers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Statement')
          .orderBy('Statement_DateTime', descending: true)
          .limit(documentLimit)
          .get();
    }

    /// Load more data
    else {
      querySnapshot = await firestore
          .collection('Customers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Statement')
          .orderBy('Statement_DateTime', descending: true)
          .startAfterDocument(lastDocument as DocumentSnapshot)
          .limit(documentLimit)
          .get();
      // print(1);
    }

    print('Length:' + querySnapshot.docs.length.toString());
    if (querySnapshot.docs.length == 0) {
      if (this.mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }
    if (querySnapshot.docs.length < documentLimit) {
      hasMore = false;
    }

    /// Get last document
    lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    statements.addAll(querySnapshot.docs);
    if (this.mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String getFormattedDate(String data) {
    return DateFormat('d MMM yyyy').format(
      DateTime.parse(data),
    );
  }

  String getStatementDetailsDate(String data) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(
      DateTime.parse(data),
    );
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);
    SizedBox _spacing =
        SizedBox(height: _widgetSize.getResponsiveHeight(0.12, 0.12, 0.12));

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Scrollbar(
        child: SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
              minWidth: MediaQuery.of(context).size.width,
            ),
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
                  getStatements();
                }
                return false;
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        /// Background Image
                        getBGImage(_deviceDetails, _widgetSize),

                        /// Spacing
                        _spacing,

                        /// Wallet Feature
                        getWalletFeatureUI(_deviceDetails, _widgetSize),

                        /// Wallet Transactions Title
                        getRecentTransactionsTitle(_deviceDetails, _widgetSize),

                        /// Wallet Transactions
                        getTransUI(_widgetSize, _deviceDetails),

                        if (isLoading == true) CustomLoading(),
                      ],
                    ),

                    /// Wallet Main UI
                    Positioned(
                      child: getWalletUI(_deviceDetails, _widgetSize),
                      top: _widgetSize.getResponsiveHeight(0.05, 0.05, 0.05),
                      left: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                      right: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    ),
                  ],
                ),
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

    /// Spacing
    SizedBox _spacing =
        SizedBox(height: _widgetSize.getResponsiveHeight(0.12, 0.12, 0.12));

    pageContent.add(
      getBGImage(_deviceDetails, _widgetSize),
    );

    /// Spacing
    pageContent.add(_spacing);

    /// Wallet Feature
    pageContent.add(getWalletFeatureUI(_deviceDetails, _widgetSize));

    /// Recent Transaction UI
    pageContent.add(getRecentTransactionsTitle(_deviceDetails, _widgetSize));

    pageContent.add(getTransUI(_widgetSize, _deviceDetails));

    if (isLoading == true) {
      pageContent.add(CustomLoading());
    }
    return pageContent;
  }
}

// region Wallet Amount
class WalletAmountUIEx extends StatelessWidget {
  final WidgetSizeCalculation widgetSize;
  final DeviceDetails deviceDetails;

  WalletAmountUIEx({
    required this.widgetSize,
    required this.deviceDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// RM
          Text(
            "RM ",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: Theme.of(context).primaryColor,
              fontSize: deviceDetails.getNormalFontSize(),
            ),
          ),
          WalletAmountRealTimeText(
            fontSize: deviceDetails.getTitleFontSize() + 5,
            fontColor: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}

// endregion
