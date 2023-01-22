import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/Account/PurchaseHistory/Purchase-All.dart';
import '/Account/PurchaseHistory/Purchase-Cancelled.dart';
import '/Account/PurchaseHistory/Purchase-Refund.dart';
import '/Account/PurchaseHistory/Purchase-RequestCancelRefund.dart';
import '/Account/PurchaseHistory/Purchase-ToPay.dart';
import '/Account/PurchaseHistory/Purchase-ToRate.dart';
import '/Account/PurchaseHistory/Purchase-ToReceive.dart';
import '/Account/PurchaseHistory/Purchase-ToShip.dart';
import '/Data-Class/InitialTabArgument.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';
import '/Voucher-Page/Available-VoucherPage.dart';
import '/Voucher-Page/Collected-VoucherPage.dart';

class VoucherMain extends StatefulWidget {
  @override
  _VoucherMain createState() => _VoucherMain();
}

class _VoucherMain extends State<VoucherMain>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  bool loaded = false;
  @override
  void initState() {
    tabController = new TabController(vsync: this, length: 2, initialIndex: 0);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void changeTab(int targetValue) {
    tabController.animateTo(targetValue);
  }

  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    TextStyle tabTextStyle = TextStyle(
      fontSize: _deviceDetails.getNormalFontSize(),
    );

    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          initialIndex: 0,
          length: 2,
          child: Scaffold(
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
                "Vouchers",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: _deviceDetails.getTitleFontSize() + 2,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              backgroundColor: Theme.of(context).backgroundColor,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(40),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    isScrollable: true,
                    controller: tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    unselectedLabelColor: Theme.of(context).primaryColor,
                    labelColor: Theme.of(context).highlightColor,
                    indicator: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).highlightColor,
                          width: 2.0,
                        ),
                      ),
                    ),
                    tabs: [
                      /// Available Voucher
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: FittedBox(
                            child: Text(
                              "Available Voucher",
                              style: tabTextStyle,
                            ),
                          ),
                        ),
                      ),

                      /// My Voucher
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: FittedBox(
                            child: Text(
                              "My Voucher",
                              style: tabTextStyle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: TabBarView(
              controller: tabController,
              children: [
                AvailableVoucherPage(),
                CollectedVoucherPage(),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }
}
