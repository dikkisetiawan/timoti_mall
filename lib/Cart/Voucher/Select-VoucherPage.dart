import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timoti_project/Custom-UI/Custom-LoadingUI.dart';
import 'package:timoti_project/Data-Class/ToggleableItemClass.dart';
import 'package:timoti_project/Data-Class/VoucherDataClass.dart';
import 'package:timoti_project/Functions/Messager.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';
import 'package:timoti_project/enums/VoucherType.dart';

/// Show Collected Voucher and Select Page
class SelectCollectedVoucherPage extends StatefulWidget {
  final String branchName;
  final Map<String, List<ToggleableItemClass>> productsMap;
  final double branchTotalPrice;

  SelectCollectedVoucherPage({
    required this.branchName,
    required this.productsMap,
    required this.branchTotalPrice,
  });

  @override
  _SelectCollectedVoucherPageState createState() =>
      _SelectCollectedVoucherPageState();
}

class _SelectCollectedVoucherPageState
    extends State<SelectCollectedVoucherPage> {
  /// Firebase
  User firebaseUser = FirebaseAuth.instance.currentUser as User;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // List<DocumentSnapshot> voucherQueryList = <DocumentSnapshot>[];
  List<VoucherData> voucherList = <VoucherData>[];

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

  bool loaded = false;
  final formatCurrency = new NumberFormat.currency(
    locale: "ms-MY",
    symbol: "",
    decimalDigits: 2,
  );

  bool isLoading = false;

  @override
  void initState() {
    // print(firebaseUser.displayName);
    //
    // print("Current Branch Cart Total Price: " +
    //     widget.branchTotalPrice.toString());

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (loaded == false) {
      /// Get User Data
      firebaseUser = FirebaseAuth.instance.currentUser as User;
      // print(firebaseUser.displayName);

      getCollectedVoucherData();
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
    bool isCollected,
  ) {
    double voucherHeight = _widgetSize.getResponsiveWidth(0.35, 0.35, 0.35);
    double voucherWidth = _widgetSize.getResponsiveWidth(0.96, 0.96, 0.96);

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
                      if (voucherList[i].voucherName != null)
                        Text(
                          voucherList[i].voucherName,
                          style: TextStyle(
                            fontSize: _deviceDetails.getNormalFontSize() + 3,
                            color: Theme.of(context).primaryColorLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                      /// Discount_Details
                      if (voucherList[i].discountDetails != null)
                        Text(
                          '\n' + voucherList[i].discountDetails,
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
                      if (voucherList[i].voucherCode != null)
                        Flexible(
                          child: Text(
                            voucherList[i].voucherCode,
                            style: TextStyle(
                              fontSize: _deviceDetails.getNormalFontSize(),
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                      /// Days Left
                      getDaysUI(
                        _deviceDetails,
                        DateTime.parse(voucherList[i].redeemEndTime),
                      ),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).backgroundColor,
                            textStyle: TextStyle(
                              fontSize: _deviceDetails.getNormalFontSize() - 2,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(
                                color: Theme.of(context).backgroundColor,
                              ),
                            )),
                        onPressed: isCollected == true
                            ? null
                            : () {
                                tempRedeemVoucher(
                                  voucherList[i],
                                  _deviceDetails,
                                );
                              },
                        child: Text(
                          "Use Now",
                          style: TextStyle(
                            fontSize: _deviceDetails.getNormalFontSize() - 2,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
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

    /// Spacing
    pageContent.add(SizedBox(
      height: _widgetSize.getResponsiveWidth(0.2, 0.2, 0.2),
    ));

    /// Logo
    pageContent.add(
      SizedBox(
        width: _widgetSize.getResponsiveWidth(0.4, 0.4, 0.4),
        child: Image.asset('assets/icon/logo.png'),
      ),
    );

    /// Spacing
    pageContent.add(SizedBox(
      height: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
    ));

    /// Title
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

    /// Spacing
    pageContent.add(SizedBox(
      height: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
    ));

    /// Subtitle
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
    if (voucherList.length == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: noVoucherUI(_deviceDetails, _widgetSize, context),
      );
    } else {
      return Stack(
        children: [
          ListView.builder(
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            itemCount: voucherList.length,
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
                        "Please Select A Voucher for ${widget.branchName}",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: _deviceDetails.getTitleFontSize(),
                        ),
                      ),
                    ),
                    getVoucherUI(
                      _widgetSize,
                      _deviceDetails,
                      i,
                      false,
                    ),
                  ],
                );
              }

              /// Others
              else {
                return getVoucherUI(_widgetSize, _deviceDetails, i, false);
              }
            },
          ),

          /// Remove Voucher
          if (widget.productsMap[widget.branchName]?[0].voucherData != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: SizedBox(
                width: _widgetSize.getResponsiveWidth(0.9, 0.9, 0.9),
                height: _widgetSize.getResponsiveHeight(0.07, 0.07, 0.07),
                child: Center(
                  child: Builder(
                    builder: (BuildContext context) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              // side: BorderSide(color: Theme.of(context).primaryColor),
                            ),
                            backgroundColor: Colors.red,
                            textStyle: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).backgroundColor,
                                fontSize: _deviceDetails.getNormalFontSize())),
                        onPressed: () {
                          // widget.productsMap[widget.branchName][0]
                          //     .voucherData = null;
                          // returnVoucherResult(widget.productsMap);

                          VoucherData tempData =
                              VoucherData(shouldRemove: true);
                          returnVoucherResultEX(tempData);
                        },
                        child: Center(
                          child: Text(
                            "Remove Voucher",
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      );
    }
  }
  // endregion

  // region Function
  /// Show collected Voucher Data
  void getCollectedVoucherData() async {
    if (this.mounted) {
      isLoading = true;
      setState(() {});
    }

    if (firebaseUser == null) {
      print("Cant find user");
      if (this.mounted) {
        isLoading = false;
        setState(() {});
      }
      return;
    }
    QuerySnapshot voucherSnapshot;
    voucherSnapshot = await firestore
        .collection('Customers')
        .doc(firebaseUser.uid)
        .collection('Voucher')
        .get();

    DocumentSnapshot currentVoucherSnapshot;
    String voucherID = '';
    VoucherData voucherData = VoucherData();

    if (voucherSnapshot.docs.length > 0) {
      print("=== Voucher Data ===========");

      /// Define Map Data
      Map<String, dynamic> voucherSnapshotData = Map<String, dynamic>();
      Map<String, dynamic> currentVoucherData = Map<String, dynamic>();

      for (int i = 0; i < voucherSnapshot.docs.length; ++i) {
        /// Assign Data
        voucherSnapshotData =
            voucherSnapshot.docs[i].data() as Map<String, dynamic>;

        voucherID = voucherSnapshot.docs[i].id;

        /// Get current Voucher Details in Promotion Voucher
        currentVoucherSnapshot = await firestore
            .collection('Promotion_Voucher')
            .doc(voucherID)
            .get();

        /// Check Voucher Is fully redeemed or not
        if (voucherSnapshotData["Redeem_Quantity"] <
            voucherSnapshotData["Limited_Voucher_Quantity_Redeemed_Customer"]) {
          /// Check Current Voucher Existed or not
          if (currentVoucherSnapshot.exists == true) {
            print("Voucher [$voucherID] exist!");

            /// Assign Data
            currentVoucherData =
                currentVoucherSnapshot.data() as Map<String, dynamic>;

            /// Check if voucher can be redeem or not
            /// if start time differences is > - 1 (can start redeem)

            DateTime redeemStartTime =
                DateTime.parse(currentVoucherData['Redeem_Start_Time']);
            // DateTime redeemStartTime = DateTime.parse('2022-04-18 18:21:54');

            print('Redeem start time ' + redeemStartTime.toString());
            print("Today Date: " + DateTime.now().toString());
            print('Difference in Day: ' +
                calculateDifference(redeemStartTime).toString());
            print(calculateDifference(redeemStartTime).toString() + " <= 0");

            if (calculateDifference(redeemStartTime) <= 0) {
              print("Can Redeem");

              /// if end time differences is < 0 (not expired)
              DateTime redeemEndTime =
                  DateTime.parse(currentVoucherData['Redeem_End_Time']);
              print("End time: " +
                  DateTime.parse(currentVoucherData['Redeem_End_Time'])
                      .toString());
              print(calculateDifference(redeemEndTime).toString());
              if (calculateDifference(redeemEndTime) > -1) {
                print("This Voucher Not Expired");

                /// Add to List
                voucherData = VoucherData(
                  isActive: true,
                  discountDetails: currentVoucherData['Discount_Details'],
                  limitedVoucherQuantityRedeemedCustomer: int.parse(
                      currentVoucherData[
                              'Limited_Voucher_Quantity_Redeemed_Customer']
                          .toString()),
                  redeemQuantity: 0,
                  voucherCode: currentVoucherData['Voucher_Code'],
                  voucherId: currentVoucherData['Voucher_ID'],
                  voucherName: currentVoucherData['Voucher_Name'],
                  tempRedeemQty: 0,
                  minOrder: double.parse(
                      currentVoucherData['Minimum_Orders'].toString()),
                  maxDiscount:
                      currentVoucherData['Maximum_Discount_Value'] != null
                          ? double.parse(
                              currentVoucherData['Maximum_Discount_Value']
                                  .toString())
                          : 0,
                  redeemEndTime: currentVoucherData['Redeem_End_Time'],
                  voucherValueType:
                      currentVoucherData['Voucher_Type'] == "Value"
                          ? VoucherValueType.Value
                          : VoucherValueType.Percentage,
                  voucherValue: currentVoucherData['Voucher_Type'] == "Value"
                      ? double.parse(
                          currentVoucherData['Voucher_Value'].toString())
                      : 0,
                  voucherPercentage: currentVoucherData['Voucher_Type'] ==
                          "Value"
                      ? 0
                      : double.parse(
                          currentVoucherData['Voucher_Percentage'].toString()),
                );

                print("Limit: " +
                    voucherData.limitedVoucherQuantityRedeemedCustomer
                        .toString());
                print(
                    "Voucher Type: " + voucherData.voucherValueType.toString());
                print("Value: " + voucherData.voucherValue.toString());
                print(
                    "Percentage: " + voucherData.voucherPercentage.toString());

                voucherList.add(voucherData);
                print("Added: " + voucherID + ' to list');
              }
            } else {
              print("Cannot Redeem");
            }
          }

          /// Voucher Not exist
          else {
            showSnackBar("Voucher [$voucherID] does not exist!", context);
          }
        } else {
          print("Voucher [$voucherID] fully redeemed");
        }

        print("===================");

        if (i == voucherSnapshot.docs.length - 1) {
          if (this.mounted) {
            isLoading = false;
            setState(() {});
          }
        }
      }
    } else {
      if (this.mounted) {
        isLoading = false;
        setState(() {});
      }
    }
  }

  // region Temp Redeem Voucher
  /// Temporary Redeem Voucher
  void tempRedeemVoucher(
    VoucherData data,
    DeviceDetails _deviceDetails,
  ) async {
    String selectedVoucherID = data.voucherId;
    int voucherLimit = data.limitedVoucherQuantityRedeemedCustomer;
    double minOrder = data.minOrder;

    print("Current Branch Cart Total Price: " +
        widget.branchTotalPrice.toString());

    /// Check if current order >= voucher minimum order
    if (widget.branchTotalPrice >= minOrder) {
      /// Check current branch have voucher or not
      if (widget.productsMap[widget.branchName]?[0].voucherData != null) {
        /// Check if current voucher is already applied
        if (widget.productsMap[widget.branchName]?[0].voucherData!.voucherId ==
            selectedVoucherID) {
          print("Same Voucher Already Applied");

          /// if already applied, just return
          // returnVoucherResult(widget.productsMap);

          /// Voucher Data for Cart Voucher
          VoucherData voucherResultData = VoucherData(
            isActive: true,
            discountDetails: data.discountDetails,
            limitedVoucherQuantityRedeemedCustomer:
                data.limitedVoucherQuantityRedeemedCustomer,
            redeemQuantity: 0,
            voucherCode: data.voucherCode,
            voucherId: data.voucherId,
            voucherName: data.voucherName,
            tempRedeemQty: 1,
            minOrder: data.minOrder,
            redeemEndTime: data.redeemEndTime,
            voucherValueType: data.voucherValueType,
            voucherValue: data.voucherValue,
            voucherPercentage: data.voucherPercentage,
            maxDiscount: data.maxDiscount,
          );
          returnVoucherResultEX(voucherResultData);
        }
      } else {
        /// Check if voucher limit redeem > 1
        if (voucherLimit > 1) {
          print("Voucher Limit Redeem > 1");

          int i = 0;
          int length = widget.productsMap.length;
          int checkRedeemQTY = 0; // For temporary check for voucher redeem qty

          /// Loop and find other branch have same voucher code or no
          widget.productsMap.forEach((branchName, value) {
            /// Get Each branch if(voucherCode == voucherID)
            if (widget.productsMap[branchName]?[0].voucherData != null) {
              if (widget.productsMap[branchName]?[0].voucherData!.voucherId ==
                  selectedVoucherID) {
                /// if founded, checkRedeemQTY += 1
                checkRedeemQTY += 1;
              }
            }

            /// if reach last branch
            if (i == length - 1) {
              /// finalRedeemQTY = checkRedeemQTY + 1(current voucher)
              int finalRedeemQTY = checkRedeemQTY + 1;

              /// Check if finalRedeemQTY <= check voucher Limited_Voucher_Quantity_Redeemed_Customer
              if (finalRedeemQTY <= voucherLimit) {
                print("Voucher is within redeem limit");

                /// Voucher Data for Cart Voucher
                VoucherData voucherResultData = VoucherData(
                  isActive: true,
                  discountDetails: data.discountDetails,
                  limitedVoucherQuantityRedeemedCustomer:
                      data.limitedVoucherQuantityRedeemedCustomer,
                  redeemQuantity: 0,
                  voucherCode: data.voucherCode,
                  voucherId: data.voucherId,
                  voucherName: data.voucherName,
                  tempRedeemQty: 1,
                  minOrder: data.minOrder,
                  maxDiscount: data.maxDiscount,
                  redeemEndTime: data.redeemEndTime,
                  voucherValueType: data.voucherValueType,
                  voucherValue: data.voucherValue,
                  voucherPercentage: data.voucherPercentage,
                );

                returnVoucherResultEX(voucherResultData);

                // /// Apply voucher on current branch
                // widget.productsMap[branchName][0].voucherData = voucherResultData;
                //
                // returnVoucherResult(widget.productsMap);
              } else {
                /// if NO, show error message
                showMessage(
                  '',
                  'You have reached maximum redeemable quantity for this voucher.',
                  _deviceDetails,
                  context,
                );
              }
            }
            ++i;
          });
        }

        /// Voucher Limit Redeem == 1
        else {
          print("Voucher Limit Redeem == 1");

          int i = 0;
          int length = widget.productsMap.length;
          bool foundVoucher = false;

          /// Loop to find other branch have this voucher or not
          widget.productsMap.forEach((branchName, value) {
            /// Found same voucher id from other branch
            if (widget.productsMap[branchName]?[0].voucherData != null) {
              if (widget.productsMap[branchName]?[0].voucherData!.voucherId ==
                  selectedVoucherID) {
                foundVoucher = true;

                /// if have cant select voucher
                showMessage(
                  '',
                  "You have use this voucher applied in $branchName.",
                  _deviceDetails,
                  context,
                );
              }
            }

            /// if reach last branch
            if (i == length - 1) {
              /// if DONT HAVE just apply
              if (foundVoucher == false) {
                print("No Branches have this voucher");

                /// Voucher Data for Cart Voucher
                VoucherData voucherResultData = VoucherData(
                  isActive: true,
                  discountDetails: data.discountDetails,
                  limitedVoucherQuantityRedeemedCustomer:
                      data.limitedVoucherQuantityRedeemedCustomer,
                  redeemQuantity: 0,
                  voucherCode: data.voucherCode,
                  voucherId: data.voucherId,
                  voucherName: data.voucherName,
                  tempRedeemQty: 1,
                  minOrder: data.minOrder,
                  redeemEndTime: data.redeemEndTime,
                  voucherValueType: data.voucherValueType,
                  voucherValue: data.voucherValue,
                  voucherPercentage: data.voucherPercentage,
                  maxDiscount: data.maxDiscount,
                );
                returnVoucherResultEX(voucherResultData);

                /// Apply voucher on current branch
                // widget.productsMap[branchName][0].voucherData = voucherResultData;
                // returnVoucherResult(widget.productsMap);
              }
            }
            ++i;
          });
        }
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
  }

  /// Return Voucher Result
  void returnVoucherResult(Map<String, List<ToggleableItemClass>> finalMap) {
    Navigator.pop(context, finalMap);
  }

  /// Return Voucher Result
  void returnVoucherResultEX(VoucherData data) {
    Navigator.pop(context, data);
  }
  // endregion

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
  Future<void> collectVoucher(DocumentSnapshot voucherData) async {
    voucherMapData = voucherData.data() as Map<String, dynamic>;

    var date = new DateTime.now();
    String targetDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(date);
    String voucherID = voucherMapData['Voucher_ID'];

    checkVoucherIsCollected(voucherData).then((value) async {
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
              }).then((value) {
                if (this.mounted) {
                  setState(() {});
                }
                showSnackBar(
                    "Collected Voucher ${voucherMapData['Voucher_Code']}",
                    context);
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
    });
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
          'Select A Voucher for ${widget.branchName}',
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
