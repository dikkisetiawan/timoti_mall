import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timoti_project/Custom-UI/Custom-LoadingUI.dart';
import 'package:timoti_project/Data-Class/VoucherDataClass.dart';
import 'package:timoti_project/Functions/Messager.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';
import 'package:timoti_project/enums/VoucherType.dart';

/// Show Get Voucher Select Page
class GetVoucherSelectPage extends StatefulWidget {
  final String branchName;
  final double branchTotalPrice;

  GetVoucherSelectPage({
    required this.branchName,
    required this.branchTotalPrice,
  });

  @override
  _GetVoucherSelectPageState createState() => _GetVoucherSelectPageState();
}

class _GetVoucherSelectPageState extends State<GetVoucherSelectPage> {
  /// Firebase
  User firebaseUser = FirebaseAuth.instance.currentUser as User;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<DocumentSnapshot> voucherQueryList = <DocumentSnapshot>[];

  /// Define Map Data
  Map<String, dynamic> voucherMapData = Map<String, dynamic>();

  Map<int, int> calenderMap = {
    1: 31,
    2: 30,
    3: 31,
    4: 30,
    5: 31,
    6: 30,
    7: 31,
    8: 31,
    9: 30,
    10: 31,
    11: 30,
    12: 31,
  };
  final formatCurrency = new NumberFormat.currency(
    locale: "ms-MY",
    symbol: "",
    decimalDigits: 2,
  );

  bool isLoading = false;
  bool loaded = false;

  @override
  void initState() {
    print(firebaseUser.displayName);

    // getVoucherData();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (loaded == false) {
      print("Current Branch Cart Total Price: " +
          widget.branchTotalPrice.toString());
      getVoucherData();
      // FirebaseAuth.instance.currentUser().then((value) {
      //   print(value.displayName);
      //   print(value.uid);
      //   firebaseUser = value;
      //   getVoucherData();
      // });
      loaded = true;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // region UI
  Widget getVoucherUI(
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
    int i,
    bool isDisable,
  ) {
    double voucherHeight = _widgetSize.getResponsiveWidth(0.35, 0.35, 0.35);
    double voucherWidth = _widgetSize.getResponsiveWidth(0.96, 0.96, 0.96);

    /// Assign Data
    voucherMapData = voucherQueryList[i].data() as Map<String, dynamic>;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
        0,
        _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
        _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
      ),
      child: Stack(
        children: [
          Image.asset(
            'assets/voucher_base.png',
            width: voucherWidth,
            height: voucherHeight,
            fit: BoxFit.fill,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
              _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
              0,
              _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: voucherWidth * 0.6,
                  height: voucherHeight * 0.95,
                  // color: Colors.red,
                  padding: EdgeInsets.fromLTRB(
                    _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
                    _widgetSize.getResponsiveWidth(0.035, 0.035, 0.035),
                    _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Voucher_Name
                      if (voucherMapData['Voucher_Name'] != null)
                        Text(
                          voucherMapData['Voucher_Name'],
                          style: TextStyle(
                            fontSize: _deviceDetails.getNormalFontSize() + 3,
                            color: Theme.of(context).primaryColorLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                      /// Discount_Details
                      if (voucherMapData['Discount_Details'] != null)
                        Text(
                          '\n' + voucherMapData['Discount_Details'],
                          style: TextStyle(
                            fontSize: _deviceDetails.getNormalFontSize() - 3,
                            color: Theme.of(context).primaryColorLight,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  // color: Colors.red,
                  // width: voucherWidth * 0.4,
                  height: voucherHeight * 0.95,
                  padding: EdgeInsets.fromLTRB(
                    0,
                    _widgetSize.getResponsiveWidth(0.035, 0.035, 0.035),
                    _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// Voucher_Code
                      if (voucherMapData['Voucher_Code'] != null)
                        Flexible(
                          child: Text(
                            voucherMapData['Voucher_Code'],
                            style: TextStyle(
                              fontSize: _deviceDetails.getNormalFontSize(),
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      getDaysUI(
                        _deviceDetails,
                        DateTime.parse(
                          voucherMapData['Redeem_End_Time'],
                        ),
                      ),

                      /// Redeem Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).backgroundColor,
                            textStyle: TextStyle(
                              fontSize: _deviceDetails.getNormalFontSize() - 2,
                              fontWeight: FontWeight.w600,
                              color: isDisable == true
                                  ? Colors.grey
                                  : Theme.of(context).primaryColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(
                                color: Theme.of(context).backgroundColor,
                              ),
                            )),
                        onPressed: isDisable == true
                            ? null
                            : () {
                                collectVoucher(
                                    voucherQueryList[i], _deviceDetails);
                              },
                        child: isDisable == true
                            ? Text(
                                "Collected",
                                // style: TextStyle(
                                //   fontSize:
                                //       _deviceDetails.getNormalFontSize() - 2,
                                //   fontWeight: FontWeight.w600,
                                //   color: Theme.of(context).primaryColor,
                                // ),
                              )
                            : Text(
                                "Redeem",
                                // style: TextStyle(
                                //   fontSize:
                                //       _deviceDetails.getNormalFontSize() - 2,
                                //   fontWeight: FontWeight.w600,
                                //   color: Theme.of(context).primaryColor,
                                // ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getDaysUI(DeviceDetails _deviceDetails, DateTime date) {
    int target = calculateDifference(date);
    return Text(
      '(' + target.toString() + ' Days Left)',
      style: TextStyle(
        fontSize: _deviceDetails.getNormalFontSize() - 4,
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  List<Widget> noVoucherUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    BuildContext context,
  ) {
    List<Widget> pageContent = <Widget>[];

    pageContent.add(SizedBox(
      height: _widgetSize.getResponsiveWidth(0.2, 0.2, 0.2),
    ));

    pageContent.add(
      SizedBox(
        width: _widgetSize.getResponsiveWidth(0.4, 0.4, 0.4),
        child: Image.asset('assets/icon/logo.png'),
      ),
    );

    pageContent.add(SizedBox(
      height: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
    ));

    pageContent.add(
      Text(
        'No Voucher Available Now',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: _deviceDetails.getTitleFontSize() + 3,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    pageContent.add(SizedBox(
      height: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
    ));

    pageContent.add(
      Text(
        'Please Stay Tuned !',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: _deviceDetails.getNormalFontSize(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    return pageContent;
  }

  List<Widget> loadingPageUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    BuildContext context,
  ) {
    List<Widget> pageContent = <Widget>[];

    /// Spacing
    pageContent.add(SizedBox(
      height: _widgetSize.getResponsiveWidth(0.2, 0.2, 0.2),
    ));

    pageContent.add(CustomLoading());

    /// Spacing
    pageContent.add(SizedBox(
      height: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
    ));

    /// Loading
    pageContent.add(
      Text(
        'Loading your voucher',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: _deviceDetails.getTitleFontSize() + 3,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    /// Spacing
    pageContent.add(SizedBox(
      height: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
    ));

    return pageContent;
  }

  Widget voucherMainPage(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    if (voucherQueryList.length == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: noVoucherUI(_deviceDetails, _widgetSize, context),
      );
    } else {
      return ListView.builder(
        scrollDirection: Axis.vertical,
        physics: BouncingScrollPhysics(),
        itemCount: voucherQueryList.length,
        itemBuilder: (BuildContext context, int i) {
          /// First Voucher with title
          if (i == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
                    0,
                    _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
                  ),
                  child: Text(
                    "Please Select A Voucher",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: _deviceDetails.getTitleFontSize(),
                    ),
                  ),
                ),
                getVoucherUI(_widgetSize, _deviceDetails, i, false),
              ],
            );
          }

          /// Others
          else {
            return getVoucherUI(_widgetSize, _deviceDetails, i, false);
          }
        },
      );
    }
  }
  // endregion

  // region Function
  void setLoadingStatus(bool value) {
    isLoading = value;
    if (this.mounted) {
      setState(() {});
    }
  }

  /// Get Voucher Data
  void getVoucherData() async {
    setLoadingStatus(true);

    if (this.mounted) {
      isLoading = true;
      setState(() {});
    }

    QuerySnapshot voucherSnapshot;
    voucherSnapshot = await firestore
        .collection('Promotion_Voucher')
        .where("Discount_Apply_To", isEqualTo: "Store")
        .where(
          'Is_Register_New_Customer',
          isEqualTo: false,
        ) // Disable New Customer
        .get();

    if (voucherSnapshot.docs.length == 0) {
      setLoadingStatus(false);
    }

    if (voucherSnapshot.docs.length > 0) {
      for (int i = 0; i < voucherSnapshot.docs.length; ++i) {
        voucherMapData = voucherSnapshot.docs[i].data() as Map<String, dynamic>;

        print(voucherMapData['Voucher_Code'] + "************");

        /// if start time differences is > - 1 (can start REDEEM)
        DateTime redeemStartTime =
            DateTime.parse(voucherMapData['Redeem_Start_Time']);
        print(redeemStartTime);
        print(calculateDifference(redeemStartTime).toString());

        // if (calculateDifference(redeemStartTime) >
        //         -(calenderMap[DateTime.now().month]) &&
        //     calculateDifference(redeemStartTime) <= 0) {
        if (calculateDifference(redeemStartTime) <= 0) {
          print("Can Redeem");

          /// if end time differences is < 0 (not expired)
          DateTime redeemEndTime =
              DateTime.parse(voucherMapData['Redeem_End_Time']);
          print(DateTime.parse(voucherMapData['Redeem_End_Time']));
          print(calculateDifference(redeemEndTime).toString());
          if (calculateDifference(redeemEndTime) > -1) {
            print("Not Expired");

            /// Check if user collected the voucher
            checkVoucherIsCollected(voucherSnapshot.docs[i]).then((value) {
              if (value == false) {
                /// Add to List
                voucherQueryList.add(voucherSnapshot.docs[i]);
                if (i == voucherSnapshot.docs.length - 1) {
                  print("Voucher Query List Length: " +
                      voucherQueryList.length.toString());
                  setLoadingStatus(false);
                }

                if (this.mounted) {
                  setState(() {});
                }
              } else {
                setLoadingStatus(false);
              }
            });
          } else {
            setLoadingStatus(false);
          }
        } else {
          setLoadingStatus(false);
        }
      }
    } else {
      setLoadingStatus(false);
    }

    if (this.mounted) {
      isLoading = false;
      setState(() {});
    }
  }

  /// Calculate Difference of today and target day, result return days
  int calculateDifference(DateTime date) {
    DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  Future<bool> checkVoucherIsCollected(DocumentSnapshot voucherData) async {
    voucherMapData = voucherData.data() as Map<String, dynamic>;

    String voucherID = voucherMapData['Voucher_ID'];

    var doc = await firestore
        .collection("Customers")
        .doc(firebaseUser.uid)
        .collection('Voucher')
        .doc(voucherID)
        .get();
    return doc.exists;
  }

  /// Add Voucher to User SubCollection(Voucher)
  Future<void> collectVoucher(
    DocumentSnapshot voucherData,
    DeviceDetails _deviceDetails,
  ) async {
    /// Assign Data
    voucherMapData = voucherData.data() as Map<String, dynamic>;

    var date = new DateTime.now();
    String targetDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(date);
    String voucherID = voucherMapData['Voucher_ID'];
    double minOrder = double.parse(voucherMapData['Minimum_Orders'].toString());

    checkVoucherIsCollected(voucherData).then((value) async {
      if (widget.branchTotalPrice >= minOrder) {
        /// If voucher document not exist
        if (value == false) {
          print("=======================");
          print("Voucher Document Not Exist [$voucherID]");

          DateTime redeemStartTime =
              DateTime.parse(voucherMapData['Redeem_Start_Time']);
          print(DateTime.parse(voucherMapData['Redeem_Start_Time']));
          print(calculateDifference(redeemStartTime).toString());

          /// If voucher Start_Collect_Time is smaller than current time
          if (calculateDifference(redeemStartTime) < 1) {
            /// If voucher is ready to be collected
            /// Check is the voucher has reaches collect limit by comparing
            int voucherCollected = voucherMapData['Voucher_Collected'];
            int voucherQuantity = voucherMapData['Voucher_Quantity'];
            int voucherCollectableQuantity =
                voucherMapData['Voucher_Collectable_Quantity'];

            /// If(Voucher_Collected < Voucher_Quantity && Voucher_Collectable_Quantity > 0)
            if (voucherCollected < voucherQuantity &&
                voucherCollectableQuantity > 0) {
              /// Update target voucher data
              // -- Voucher_Collectable_Quantity - 1
              // -- Voucher_Collected + 1

              print("Should be voucherCollectableQuantity: " +
                  (voucherCollectableQuantity - 1).toString());
              print("Should be voucherCollected: " +
                  (voucherCollected + 1).toString());

              await firestore
                  .collection('Promotion_Voucher')
                  .doc(voucherID)
                  .update({
                "Voucher_Collectable_Quantity": voucherCollectableQuantity - 1,
                "Voucher_Collected": voucherCollected + 1,
              }).then((value) async {
                /// Add Voucher Date to User SubCollection (Voucher)
                await firestore
                    .collection("Customers")
                    .doc(firebaseUser.uid)
                    .collection('Voucher')
                    .doc(voucherMapData['Voucher_ID'])
                    .set({
                  'Collected_Time': targetDate,
                  'Is_Collected': true,
                  'Is_Redeem': false,
                  'Limited_Voucher_Quantity_Redeemed_Customer': voucherMapData[
                      'Limited_Voucher_Quantity_Redeemed_Customer'],
                  'Redeem_Quantity': 0,
                  'Redeem_Time': '',
                  'Voucher_ID': voucherMapData['Voucher_ID'],
                  'Voucher_Name': voucherMapData['Voucher_Name'],
                  'Voucher_Code': voucherMapData['Voucher_Code'],
                  'Discount_Details': voucherMapData['Discount_Details'],
                  'Redeem_End_Time': voucherMapData['Redeem_End_Time'],
                }).then((value) {
                  /// Voucher Data for Cart Voucher
                  VoucherData voucherResultData = VoucherData(
                    isActive: true,
                    discountDetails: voucherMapData['Discount_Details'],
                    limitedVoucherQuantityRedeemedCustomer: voucherMapData[
                        'Limited_Voucher_Quantity_Redeemed_Customer'],
                    redeemQuantity: 0,
                    voucherCode: voucherMapData['Voucher_Code'],
                    voucherId: voucherMapData['Voucher_ID'],
                    voucherName: voucherMapData['Voucher_Name'],
                    tempRedeemQty: 1,
                    minOrder: double.parse(
                        voucherMapData['Minimum_Orders'].toString()),
                    maxDiscount: voucherMapData['Maximum_Discount_Value'] !=
                            null
                        ? double.parse(
                            voucherMapData['Maximum_Discount_Value'].toString())
                        : 0,
                    redeemEndTime: voucherMapData['Redeem_End_Time'],
                    voucherValueType: voucherMapData['Voucher_Type'] == "Value"
                        ? VoucherValueType.Value
                        : VoucherValueType.Percentage,
                    voucherValue: voucherMapData['Voucher_Type'] == "Value"
                        ? double.parse(
                            voucherMapData['Voucher_Value'].toString())
                        : 0,
                    voucherPercentage: voucherMapData['Voucher_Type'] == "Value"
                        ? 0
                        : double.parse(
                            voucherMapData['Voucher_Percentage'].toString()),
                  );

                  returnVoucherResult(voucherResultData);
                });
              });
            } else {
              /// This voucher fully collected
              showSnackBar('This voucher is fully collected', context);
            }
          } else {
            /// This voucher is not ready to be collected
            showSnackBar('This voucher is not ready to be collected', context);
          }
        }

        /// Voucher Document Exist
        else {
          print("Voucher Document Exist [$voucherID]");
          showSnackBar("This Voucher has been collected!", context);
        }
      }

      /// Not reach minimum order
      else {
        showMessage(
          '',
          "Minimum order for this voucher is RM ${formatCurrency.format(minOrder).toString()}"
              "\n\nCurrent order is RM ${formatCurrency.format(widget.branchTotalPrice).toString()}",
          _deviceDetails,
          context,
        );
      }
    });
  }

  /// Return Voucher Result
  void returnVoucherResult(VoucherData voucherResultData) {
    Navigator.pop(context, voucherResultData);
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_sharp,
            color: Theme.of(context).primaryColor,
            size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          ),
        ),
        title: Text(
          'Get Voucher',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        shadowColor: Colors.grey,
        elevation: 3,
      ),
      body: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: isLoading == true
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: loadingPageUI(_deviceDetails, _widgetSize, context),
                )
              : voucherMainPage(_deviceDetails, _widgetSize),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }
}
