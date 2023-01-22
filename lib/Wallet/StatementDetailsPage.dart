import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';

class StatementDetails extends StatelessWidget {
  final formatCurrency = new NumberFormat.currency(
    locale: "ms-MY",
    symbol: "",
    decimalDigits: 2,
  );

  final String? Statement_Amount;
  final String? Statement_Bank_Name;
  final String? Statement_DateTime;
  final String? Statement_Id;
  final String? Statement_Note;
  final String? Statement_Payment_Method;
  final String? Statement_Received_From;
  final String? Statement_Sent_To;
  final String? Statement_Type;
  final String? Statement_Sent_To_Name;
  final String? Statement_Received_From_Name;
  final String? Statement_Payment_ID;
  final String? Statement_Refund_ID;
  final String? Statement_Refund_Method;
  final List<String>? Statement_OrderID;

  StatementDetails({
    this.Statement_Amount,
    this.Statement_Bank_Name,
    this.Statement_DateTime,
    this.Statement_Id,
    this.Statement_Note,
    this.Statement_Payment_Method,
    this.Statement_Received_From,
    this.Statement_Sent_To,
    this.Statement_Type,
    this.Statement_Sent_To_Name,
    this.Statement_Received_From_Name,
    this.Statement_Payment_ID,
    this.Statement_Refund_ID,
    this.Statement_Refund_Method,
    this.Statement_OrderID,
  });

  /// region UI
  Widget getTitleTypeUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    BuildContext context,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Title
        Padding(
          padding: EdgeInsets.fromLTRB(
            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
            _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
            0,
            _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
          ),
          child: Text(
            Statement_Type as String,
            style: TextStyle(
                fontSize: _deviceDetails.getTitleFontSize(),
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
        ),

        /// Type Details
        ListTile(
          tileColor: Theme.of(context).shadowColor,
          contentPadding: EdgeInsets.fromLTRB(
            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
            0,
            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
            0,
          ),
          title: Text(
            getTypeString(Statement_Type),
            style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize(),
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
          trailing: returnAmountText(
            _deviceDetails,
            context,
          ),
        )
      ],
    );
  }

  Widget getTypeBetweenUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    BuildContext context,
  ) {
    return Container(
      width: _widgetSize.getResponsiveWidth(1, 1, 1),
      color: Theme.of(context).shadowColor,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              getEXTypeString(Statement_Type),
              style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),

            /// Top Up
            if (Statement_Type == "Top Up")
              Text(
                Statement_Payment_Method as String ,
                style: TextStyle(
                    fontSize: _deviceDetails.getNormalFontSize(),
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500),
              ),

            /// Send
            if (Statement_Type == "Send")
              Text(
                Statement_Sent_To_Name as String,
                style: TextStyle(
                    fontSize: _deviceDetails.getNormalFontSize(),
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500),
              ),

            /// Receive
            if (Statement_Type == "Receive")
              Text(
                Statement_Received_From_Name as String,
                style: TextStyle(
                    fontSize: _deviceDetails.getNormalFontSize(),
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500),
              ),

            /// Payment
            if (Statement_Type == "Payment")
              Text(
                "Payment",
                style: TextStyle(
                    fontSize: _deviceDetails.getNormalFontSize(),
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500),
              ),

            /// Top Up
            if (Statement_Type == "Refund")
              Text(
                Statement_Refund_Method as String,
                style: TextStyle(
                    fontSize: _deviceDetails.getNormalFontSize(),
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500),
              ),
          ],
        ),
      ),
    );
  }

  Widget getPaidBy(
    String data,
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    BuildContext context,
  ) {
    return Container(
      width: _widgetSize.getResponsiveWidth(1, 1, 1),
      color: Theme.of(context).shadowColor,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Paid By",
              style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              data != null ? data : "Something Goes Wrong",
              style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget getSplitRow(
    String title,
    String subTitle,
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    BuildContext context,
  ) {
    return Container(
      width: _widgetSize.getResponsiveWidth(1, 1, 1),
      color: Theme.of(context).shadowColor,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              subTitle,
              style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget getUpdownUI(
    String title,
    String subTitle,
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    BuildContext context,
  ) {
    return Container(
      width: _widgetSize.getResponsiveWidth(1, 1, 1),
      color: Theme.of(context).shadowColor,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title != null ? title : "Something goes Wrong",
              style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              subTitle != null ? subTitle : "Something goes Wrong",
              style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget getDateTimeUI(
    String data,
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    BuildContext context,
  ) {
    return Container(
      width: _widgetSize.getResponsiveWidth(1, 1, 1),
      color: Theme.of(context).shadowColor,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Date and Time",
              style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              data,
              style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget getTransactionIdUI(
    String data,
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    BuildContext context,
  ) {
    return Container(
      width: _widgetSize.getResponsiveWidth(1, 1, 1),
      color: Theme.of(context).shadowColor,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Transaction ID",
              style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              data,
              style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget getNoteUI(
    String data,
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    BuildContext context,
  ) {
    return Container(
      width: _widgetSize.getResponsiveWidth(1, 1, 1),
      color: Theme.of(context).shadowColor,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Note",
              style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              data,
              style: TextStyle(
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  /// endregion

  // region Return Value
  String getTypeString(var type) {
    if (type == "Payment") {
      return "Your fare";
    } else if (type == "Receive") {
      return "You've received";
    } else if (type == "Send") {
      return "You've sent";
    } else if (type == "Top Up") {
      return "You've topped up";
    } else if (type == "Refund") {
      return "You've been refunded";
    }
    return type;
  }

  String getEXTypeString(var type) {
    if (type == "Receive") {
      return "Received From";
    } else if (type == "Send") {
      return "Sent to";
    } else if (type == "Top Up") {
      return "Top up using";
    } else if (type == "Refund") {
      return "Refund Method";
    }
    return type;
  }

  Widget returnAmountText(
    DeviceDetails _deviceDetails,
    BuildContext context,
  ) {
    /// Top Up
    if (Statement_Type == "Top Up") {
      return Text(
        "MYR " +
            formatCurrency.format(double.parse(Statement_Amount as String)).toString(),
        style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: _deviceDetails.getTitleFontSize()),
      );
    }

    /// Send
    else if (Statement_Type == "Send") {
      return Text(
        "MYR -" +
            formatCurrency.format(double.parse(Statement_Amount as String)).toString(),
        style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: _deviceDetails.getTitleFontSize()),
      );
    }

    /// Receive
    else if (Statement_Type == "Receive") {
      return Text(
        "MYR " +
            formatCurrency.format(double.parse(Statement_Amount as String)).toString(),
        style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: _deviceDetails.getTitleFontSize()),
      );
    }

    /// Receive
    else if (Statement_Type == "Refund") {
      return Text(
        "MYR " +
            formatCurrency.format(double.parse(Statement_Amount as String)).toString(),
        style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: _deviceDetails.getTitleFontSize()),
      );
    }

    /// Payment
    else {
      return Text(
        "MYR -" +
            formatCurrency.format(double.parse(Statement_Amount as String)).toString(),
        style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: _deviceDetails.getTitleFontSize()),
      );
    }
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
          "Transaction Details",
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
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: getPageContent(
                _deviceDetails,
                _widgetSize,
                context,
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  List<Widget> getPageContent(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    BuildContext context,
  ) {
    List<Widget> pageContent = <Widget>[];

    /// Title & Type
    pageContent.add(getTitleTypeUI(
      _deviceDetails,
      _widgetSize,
      context,
    ));

    pageContent.add(SizedBox(
      height: _widgetSize.getResponsiveHeight(0.03, 0.03, 0.03),
    ));

    /// Received / Top Up
    if (Statement_Type != "Payment") {
      pageContent.add(getTypeBetweenUI(
        _deviceDetails,
        _widgetSize,
        context,
      ));
    }

    /// Paid by
    if (Statement_Payment_Method != '') {
      pageContent.add(getPaidBy(
        Statement_Payment_Method as String,
        _deviceDetails,
        _widgetSize,
        context,
      ));
    }

    /// Show Payment ID for Payment Type
    if (Statement_Type == 'Payment') {
      pageContent.add(getUpdownUI(
        "Payment ID",
        Statement_Payment_ID as String,
        _deviceDetails,
        _widgetSize,
        context,
      ));
    }

    /// Show Refund ID for Refund Type
    if (Statement_Type == 'Refund') {
      pageContent.add(getUpdownUI(
        "Refund ID",
        Statement_Refund_ID as String,
        _deviceDetails,
        _widgetSize,
        context,
      ));
    }

    /// Date and Time
    if (Statement_DateTime != "") {
      pageContent.add(getDateTimeUI(
        Statement_DateTime as String,
        _deviceDetails,
        _widgetSize,
        context,
      ));
    }

    /// Transaction ID
    if (Statement_Id != "") {
      pageContent.add(getTransactionIdUI(
        Statement_Id as String,
        _deviceDetails,
        _widgetSize,
        context,
      ));
    }

    /// Notes
    if (Statement_Note != "") {
      pageContent.add(getNoteUI(
        Statement_Note as String,
        _deviceDetails,
        _widgetSize,
        context,
      ));
    }

    /// Order ID
    if (Statement_OrderID != null) {
      if (Statement_OrderID!.length > 0) {
        /// Title
        pageContent.add(
          Container(
            width: _widgetSize.getResponsiveWidth(1, 1, 1),
            color: Theme.of(context).shadowColor,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
                _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                0,
              ),
              child: Text(
                'Order ID',
                style: TextStyle(
                    fontSize: _deviceDetails.getNormalFontSize(),
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
        for (int i = 0; i < Statement_OrderID!.length; ++i) {
          pageContent.add(
            Container(
              width: _widgetSize.getResponsiveWidth(1, 1, 1),
              color: Theme.of(context).shadowColor,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                  _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
                  _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                  i == Statement_OrderID!.length - 1
                      ? _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)
                      : 0,
                ),
                child: Text(
                  Statement_OrderID![i],
                  style: TextStyle(
                      fontSize: _deviceDetails.getNormalFontSize(),
                      color: Theme.of(context).highlightColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        }
      }
    }

    return pageContent;
  }
}
