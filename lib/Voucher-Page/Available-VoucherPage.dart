import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/Custom-UI/Custom-LoadingUI.dart';
import '/Functions/Messager.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';

/// Show Available Voucher Page
class AvailableVoucherPage extends StatefulWidget {
  @override
  _AvailableVoucherPageState createState() => _AvailableVoucherPageState();
}

class _AvailableVoucherPageState extends State<AvailableVoucherPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  User firebaseUser = FirebaseAuth.instance.currentUser as User;
  List<DocumentSnapshot> voucherQueryList = <DocumentSnapshot>[];

  /// Define Voucher Map Data
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

  bool isLoading = false;

  @override
  void initState() {
    // print(firebaseUser.displayName);

    getVoucherData();
    super.initState();
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
                        DateTime.parse(voucherMapData['Redeem_End_Time']),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(
                                color: Theme.of(context).backgroundColor,
                              ),
                            ),
                            backgroundColor: Colors.red,
                            textStyle: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDisable == true
                                    ? Colors.grey
                                    : Theme.of(context).primaryColor,
                                fontSize: _deviceDetails.getNormalFontSize())),
                        onPressed: () {
                          isDisable == true
                              ? null
                              : () {
                                  collectVoucher(voucherQueryList[i]);
                                  if (this.mounted) {
                                    setState(() {
                                      // if (successValidate() == true) {
                                      //   linkPassword(context, _deviceDetails);
                                      // }
                                    });
                                  }
                                };
                        },
                        child: isDisable == true
                            ? Text(
                                "Collected",
                                style: TextStyle(
                                  fontSize:
                                      _deviceDetails.getNormalFontSize() - 2,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                ),
                              )
                            : Text(
                                "Redeem",
                                style: TextStyle(
                                  fontSize:
                                      _deviceDetails.getNormalFontSize() - 2,
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
          color: Colors.grey,
          fontSize: _deviceDetails.getNormalFontSize(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    return pageContent;
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

    QuerySnapshot voucherSnapshot;
    voucherSnapshot = await firestore
        .collection('Promotion_Voucher')
        .where("Discount_Apply_To", isEqualTo: "Store")
        .where(
          'Is_Register_New_Customer',
          isEqualTo: false,
        ) // Disable New Customer
        .get();

    /// Define Temp Map Data
    Map<String, dynamic> tempMapData = Map<String, dynamic>();

    if (voucherSnapshot.docs.length == 0) {
      setLoadingStatus(false);
    }

    for (int i = 0; i < voucherSnapshot.docs.length; ++i) {
      /// Assign Data
      tempMapData = voucherSnapshot.docs[i].data() as Map<String, dynamic>;

      print(tempMapData['Voucher_Code'] + "************");

      /// if start time differences is > - 1 (can start collect)
      DateTime collectStartTime =
          DateTime.parse(tempMapData['Voucher_Start_Collect_Time']);
      print(collectStartTime);
      print(calculateDifference(collectStartTime).toString());

      if (calculateDifference(collectStartTime) <= 0) {
        print("Can Redeem");

        /// if end time differences is < 0 (not expired)
        DateTime redeemEndTime = DateTime.parse(tempMapData['Redeem_End_Time']);
        print(DateTime.parse(tempMapData['Redeem_End_Time']));
        print(calculateDifference(redeemEndTime).toString());
        if (calculateDifference(redeemEndTime) > -1) {
          print("Not Expired");

          /// Check if user collected the voucher
          checkVoucherIsCollected(voucherSnapshot.docs[i]).then((value) {
            if (value == false) {
              /// Add to List
              voucherQueryList.add(voucherSnapshot.docs[i]);
              if (i == voucherSnapshot.docs.length - 1) {
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

    if (this.mounted) {
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
    /// Define Temp Map Data
    Map<String, dynamic> tempMapData = Map<String, dynamic>();

    /// Assign Data
    tempMapData = voucherData.data() as Map<String, dynamic>;

    String voucherID = tempMapData['Voucher_ID'];

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
    /// Define Temp Map Data
    Map<String, dynamic> tempMapData = Map<String, dynamic>();

    /// Assign Data
    tempMapData = voucherData.data() as Map<String, dynamic>;

    var date = new DateTime.now();
    String targetDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(date);
    String voucherID = tempMapData['Voucher_ID'];

    checkVoucherIsCollected(voucherData).then((value) async {
      /// If voucher document not exist
      if (value == false) {
        print("=======================");
        print("Voucher Document Not Exist [$voucherID]");

        DateTime collectStartTime =
            DateTime.parse(tempMapData['Voucher_Start_Collect_Time']);
        print(DateTime.parse(tempMapData['Voucher_Start_Collect_Time']));
        print(calculateDifference(collectStartTime).toString());

        /// If voucher Start_Collect_Time is smaller than current time
        if (calculateDifference(collectStartTime) < 1) {
          /// If voucher is ready to be collected
          /// Check is the voucher has reaches collect limit by comparing
          int voucherCollected = tempMapData['Voucher_Collected'];
          int voucherQuantity = tempMapData['Voucher_Quantity'];
          int voucherCollectableQuantity =
              tempMapData['Voucher_Collectable_Quantity'];

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
                  .doc(tempMapData['Voucher_ID'])
                  .set({
                'Collected_Time': targetDate,
                'Is_Collected': true,
                'Is_Redeem': false,
                'Limited_Voucher_Quantity_Redeemed_Customer':
                    tempMapData['Limited_Voucher_Quantity_Redeemed_Customer'],
                'Redeem_Quantity': 0,
                'Redeem_Time': '',
                'Voucher_ID': tempMapData['Voucher_ID'],
                'Voucher_Name': tempMapData['Voucher_Name'],
                'Voucher_Code': tempMapData['Voucher_Code'],
                'Discount_Details': tempMapData['Discount_Details'],
                'Redeem_End_Time': tempMapData['Redeem_End_Time'],
              }).then((value) {
                if (this.mounted) {
                  setState(() {});
                }
                showSnackBar(
                  "Collected Voucher ${tempMapData['Voucher_Code']}",
                  context,
                );
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
      body: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: isLoading == true
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      "Loading...",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    CustomLoading(),
                  ],
                )
              : voucherQueryList.length == 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children:
                          noVoucherUI(_deviceDetails, _widgetSize, context),
                    )
                  : ListView.builder(
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
                                  _widgetSize.getResponsiveWidth(
                                      0.05, 0.05, 0.05),
                                  _widgetSize.getResponsiveWidth(
                                      0.02, 0.02, 0.02),
                                  0,
                                  _widgetSize.getResponsiveWidth(
                                      0.02, 0.02, 0.02),
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
                              getVoucherUI(
                                  _widgetSize, _deviceDetails, i, false),
                            ],
                          );
                        }

                        /// Others
                        else {
                          return getVoucherUI(
                              _widgetSize, _deviceDetails, i, false);
                        }
                      },
                    ),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }
}
