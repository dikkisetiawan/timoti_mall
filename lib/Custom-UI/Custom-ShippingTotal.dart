import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';

class CustomShippingTotal extends StatelessWidget {
  final WidgetSizeCalculation widgetSize;
  final DeviceDetails deviceDetails;
  final NumberFormat formatCurrency;

  final String? totalPrice;
  final String? shippingPrice;
  final int? totalOrderLength;
  final String? totalDiscount;
  final String? subtotal;

  const CustomShippingTotal({
    Key? key,
    required this.widgetSize,
    required this.deviceDetails,
    required this.formatCurrency,
    this.totalPrice,
    this.shippingPrice,
    this.totalOrderLength,
    this.subtotal,
    this.totalDiscount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widgetSize.getResponsiveWidth(1, 1, 1),
      decoration: BoxDecoration(
        color: Theme.of(context).shadowColor,
        border: Border(
          bottom: BorderSide(
            width: 0.7,
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
        widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          /// Subtotal
          if (subtotal != null && subtotal != '' && subtotal != totalPrice)
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: SizedBox(
                width: widgetSize.getResponsiveWidth(0.55, 0.55, 0.55),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// Total Discount
                    Expanded(
                      child: Text(
                        "Subtotal",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: deviceDetails.getNormalFontSize(),
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Text(
                        "RM " +
                            formatCurrency
                                .format(double.parse(subtotal as String))
                                .toString(),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: deviceDetails.getNormalFontSize(),
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          /// Shipping Price
          Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: SizedBox(
              width: widgetSize.getResponsiveWidth(0.55, 0.55, 0.55),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Shipping
                  Expanded(
                    child: Text(
                      "Shipping",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: deviceDetails.getNormalFontSize(),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),

                  /// Shipping Price
                  if (shippingPrice != null && shippingPrice != '')
                    Expanded(
                      child: Text(
                        "RM " +
                            formatCurrency
                                .format(double.parse(shippingPrice as String))
                                .toString(),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: deviceDetails.getNormalFontSize(),
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  if (shippingPrice == null || shippingPrice == '')
                    Expanded(
                      child: Text(
                        "RM " + formatCurrency.format(0).toString(),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: deviceDetails.getNormalFontSize(),
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          /// Total Discount
          if (totalDiscount != '0')
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: SizedBox(
                width: widgetSize.getResponsiveWidth(0.55, 0.55, 0.55),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// Total Discount
                    Expanded(
                      child: Text(
                        "Total Discount",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: deviceDetails.getNormalFontSize(),
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Text(
                        "-RM " +
                            formatCurrency
                                .format(double.parse(totalDiscount as String))
                                .toString(),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: deviceDetails.getNormalFontSize(),
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          /// Total Price
          SizedBox(
            width: widgetSize.getResponsiveWidth(0.55, 0.55, 0.55),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Total Item
                Expanded(
                  child: Text(
                    "Total Items (${totalOrderLength.toString()})",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: deviceDetails.getNormalFontSize(),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),

                /// Total Price
                if (totalPrice != null && totalPrice != '')
                  Expanded(
                    child: Text(
                      "RM " +
                          formatCurrency
                              .format(double.parse(totalPrice as String))
                              .toString(),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: deviceDetails.getTitleFontSize(),
                        color: Theme.of(context).highlightColor,
                      ),
                    ),
                  ),
                if (totalPrice == null || totalPrice == '')
                  Expanded(
                    child: Text(
                      "RM " + formatCurrency.format(0).toString(),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: deviceDetails.getTitleFontSize(),
                        color: Theme.of(context).highlightColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
