import 'package:flutter/material.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';

class PaymentFailedPage extends StatelessWidget {
  final List<String> orderIDs;
  
  const PaymentFailedPage({
    Key? key,
    required this.orderIDs,
  }) : super(key: key);

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
          'Payment Failed',
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: getPageContent(
              _deviceDetails,
              _widgetSize,
              context,
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

    pageContent.add(
      SizedBox(
        width: _widgetSize.getResponsiveWidth(0.4, 0.4, 0.4),
        child: Image.asset('assets/icon/logo.png'),
      ),
    );

    pageContent.add(
      SizedBox(height: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),
    );


    /// Payment Failed Title
    pageContent.add(
      Padding(
        padding: EdgeInsets.only(bottom: 8.0),
        child: Text(
          'Payment Failed',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: _deviceDetails.getTitleFontSize() + 5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    /// Please Try Again Title
    pageContent.add(
      Padding(
        padding: EdgeInsets.only(bottom: 8.0),
        child: Text(
         'Please try again later',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: _deviceDetails.getNormalFontSize(),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
    // /// Here is Order title
    // pageContent.add(
    //   Padding(
    //     padding: EdgeInsets.only(bottom: 8.0),
    //     child: Text(
    //       orderIDs.length == 1 ? 'Here is your Order ID' : 'Here are your Order ID(s)',
    //       style: TextStyle(
    //         color: Theme.of(context).primaryColor,
    //         fontSize: _deviceDetails.getNormalFontSize(),
    //         fontWeight: FontWeight.w500,
    //       ),
    //     ),
    //   ),
    // );
    //
    // /// Print Order IDs
    // orderIDs.forEach((id) {
    //   pageContent.add(
    //     Text(
    //       id,
    //       style: TextStyle(
    //         color: Theme.of(context).primaryColor,
    //         fontSize: _deviceDetails.getNormalFontSize(),
    //         fontWeight: FontWeight.w400,
    //         decoration: TextDecoration.underline,
    //       ),
    //     ),
    //   );
    // });

    pageContent.add(
      SizedBox(height: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),
    );

    /// Okay Button
    pageContent.add(
      SizedBox(
        width: _widgetSize.getResponsiveWidth(0.3, 0.3, 0.3),
        child: TextButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            backgroundColor:
                MaterialStateProperty.all(Theme.of(context).highlightColor),
            elevation: MaterialStateProperty.all(5),
            shadowColor: MaterialStateProperty.all(Colors.red),
          ),
          onPressed: () => Navigator.pop(context),
          child: Center(
            child: Text(
              "Ok",
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).primaryColor,
                  fontSize: _deviceDetails.getNormalFontSize()),
            ),
          ),
        ),
      ),
    );

    return pageContent;
  }
}
