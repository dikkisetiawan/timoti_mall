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

class PurchaseHistoryMain extends StatefulWidget {
  static const routeName = '/Purchase-Main-Page';

  @override
  _PurchaseHistoryMain createState() => _PurchaseHistoryMain();
}

class _PurchaseHistoryMain extends State<PurchaseHistoryMain>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  bool loaded = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (loaded == false) {
      InitialTabArgument data = ModalRoute.of(context)?.settings.arguments as InitialTabArgument;
      tabController = new TabController(
          vsync: this, length: 8, initialIndex: data.tabIndex);
      loaded = true;
    }

    super.didChangeDependencies();
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

    final InitialTabArgument data = ModalRoute.of(context)?.settings.arguments as InitialTabArgument;

    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          initialIndex: data.tabIndex,
          length: 8,
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
                "My Orders",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: _deviceDetails.getTitleFontSize() + 2,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              backgroundColor: Theme.of(context).backgroundColor,
              bottom: TabBar(
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
                  /// All
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: FittedBox(
                        child: Text(
                          "All",
                          style: tabTextStyle,
                        ),
                      ),
                    ),
                  ),

                  /// Pay
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: FittedBox(
                        child: Text(
                          "To Pay",
                          style: tabTextStyle,
                        ),
                      ),
                    ),
                  ),

                  /// Ship
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: FittedBox(
                          child: Text("To Ship", style: tabTextStyle)),
                    ),
                  ),

                  /// Receive
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: FittedBox(
                          child: Text("To Receive", style: tabTextStyle)),
                    ),
                  ),

                  /// Completed
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: FittedBox(
                          child: Text("Completed", style: tabTextStyle)),
                    ),
                  ),

                  /// Pending Cancel / Refund
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: FittedBox(
                          child: Text("Cancel / Refund Request",
                              style: tabTextStyle)),
                    ),
                  ),

                  /// Cancelled
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: FittedBox(
                          child: Text("Cancelled", style: tabTextStyle)),
                    ),
                  ),

                  /// Refund
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: FittedBox(
                          child: Text("Return Refund", style: tabTextStyle)),
                    ),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              controller: tabController,
              children: [
                AllPage(),
                ToPayPage(),
                ToShipPage(),
                ToReceivePage(),
                ToRatePage(),
                RequestCancelRefundPage(),
                CancelledPage(),
                RefundPage(),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }
}
