import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/Data-Class/BranchShippingClass.dart';
import '/Data-Class/ShippingDataClass.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';
import '/Screen-Size/ui-utils.dart';
import '/enums/device-screen-type.dart';
import '/Functions/Messager.dart';

class ShippingOptionPage extends StatelessWidget {
  static const routeName = '/ShippingOptionPage';

  final String branchName;
  final List<ShippingData> shippingDataList;
  final formatCurrency = new NumberFormat.currency(
    locale: "ms-MY",
    symbol: "",
    decimalDigits: 2,
  );

  ShippingOptionPage({
    required this.branchName,
    required this.shippingDataList,
  });

  // region UI
  /// Custom App bar
  PreferredSize _getCustomAppBar(
    String title,
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
    BuildContext context,
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

  /// Shipping method ui
  Widget getShippingMethodUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    BuildContext context,
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
          "Please Select 1 Shipping Option",
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
    ShippingData shippingData,
    BuildContext context,
  ) {
    var mediaQuery = MediaQuery.of(context);

    return InkWell(
      onTap: () {
        if (shippingData.isActive == true) {
          Navigator.pop(
            context,
            BranchShippingOption(
              branchName: branchName,
              shippingData: shippingData,
            ),
          );
        } else {
          showMessage(
            "",
            "This Shipping Option is Not Available Yet",
            _deviceDetails,
            context,
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: shippingData.isActive == true
              ? Theme.of(context).shadowColor
              : Colors.black45,
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
          contentPadding: EdgeInsets.fromLTRB(
            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
            _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
            _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
          ),
          trailing: shippingData.isActive == true
              ? Text(
                  'RM ${formatCurrency.format(shippingData.shippingPrice)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: _deviceDetails.getNormalFontSize(),
                    color: Theme.of(context).primaryColor,
                  ),
                )
              : Text(
                  'Not Available Yet',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: _deviceDetails.getNormalFontSize(),
                    color: Colors.white,
                  ),
                ),
          subtitle: shippingData.isActive == true
              ? Text(
                  shippingData.description,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: _deviceDetails.getNormalFontSize() - 2,
                    color: Theme.of(context).primaryColor,
                    height: 1.5,
                  ),
                )
              : Text(
                  shippingData.description,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: _deviceDetails.getNormalFontSize() - 2,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
          title: shippingData.isActive == true
              ? Text(
                  shippingData.shippingName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: _deviceDetails.getNormalFontSize(),
                    color: Theme.of(context).primaryColor,
                  ),
                )
              : Text(
                  shippingData.shippingName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: _deviceDetails.getNormalFontSize(),
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
// endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Scaffold(
      appBar: _getCustomAppBar(
        "Shipping Option",
        _widgetSize,
        _deviceDetails,
        context,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: getPageContent(
                  _deviceDetails,
                  _widgetSize,
                  context,
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
    BuildContext context,
  ) {
    List<Widget> pageContent = [];

    /// Payment Method UI
    pageContent.add(getShippingMethodUI(_deviceDetails, _widgetSize, context));

    for (int i = 0; i < shippingDataList.length; ++i) {
      pageContent.add(
        getSelectedMethodUI(
          _deviceDetails,
          _widgetSize,
          shippingDataList[i],
          context,
        ),
      );
    }

    return pageContent;
  }
}
