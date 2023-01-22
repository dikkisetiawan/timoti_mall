import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timoti_project/Account/PurchaseHistory/Purchase-All.dart';
import 'package:timoti_project/Account/PurchaseHistory/Purchase-Cancelled.dart';
import 'package:timoti_project/Account/PurchaseHistory/Purchase-Refund.dart';
import 'package:timoti_project/Account/PurchaseHistory/Purchase-RequestCancelRefund.dart';
import 'package:timoti_project/Account/PurchaseHistory/Purchase-ToPay.dart';
import 'package:timoti_project/Account/PurchaseHistory/Purchase-ToRate.dart';
import 'package:timoti_project/Account/PurchaseHistory/Purchase-ToReceive.dart';
import 'package:timoti_project/Account/PurchaseHistory/Purchase-ToShip.dart';
import 'package:timoti_project/Data-Class/InitialTabArgument.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';
import 'package:timoti_project/Voucher-Page/Available-VoucherPage.dart';
import 'package:timoti_project/Voucher-Page/Collected-VoucherPage.dart';

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
