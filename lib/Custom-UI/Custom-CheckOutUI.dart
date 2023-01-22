import 'package:cached_network_image/cached_network_image.dart';
// import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '/Core/DateTime-Calculator.dart';
import '/Data-Class/ProductVariant.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '../Screen-Size/WidgetSizeCalculation.dart';

class CustomCheckOutUI extends StatelessWidget {
  final String imagePath;
  final String networkImagePath;

  final String title;
  final Widget? specialLine;
  final String finalPrice;
  final String originalPrice;

  final double contentPaddingTop;
  final double contentPaddingBottom;
  final double contentPaddingLeft;
  final double contentPaddingRight;

  final bool spacing;
  final Widget? customButton;

  final bgColor;
  final fontColor;
  final titleColor;
  final int maxLine;

  final double circularBorderValue;
  final double shadowValue;
  final bool hiddenPrice;
  final int quantity;
  final ProductVariantType? productVariantFinal;
  final ProductVariant? selectedProductVariant;

  CustomCheckOutUI({
    Key? key,
    this.imagePath = '',
    this.networkImagePath = '',
    this.title = '',
    this.specialLine,
    this.finalPrice = '',
    this.originalPrice = '',
    this.spacing = true,
    this.customButton,
    this.bgColor,
    this.titleColor = Colors.white,
    this.fontColor = Colors.white,
    this.maxLine = 2,
    this.circularBorderValue = 0,
    this.shadowValue = 8,
    this.contentPaddingTop = 0,
    this.contentPaddingBottom = 0,
    this.contentPaddingLeft = 0,
    this.contentPaddingRight = 0,
    this.hiddenPrice = false,
    this.quantity = 1,
    this.productVariantFinal,
    this.selectedProductVariant,
  }) : super(key: key);

  DateTimeCalculator _dateTimeCalculator = new DateTimeCalculator();

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Material(
      shadowColor: Colors.grey,
      elevation: shadowValue,
      color: bgColor,
      borderRadius: BorderRadius.circular(circularBorderValue),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(circularBorderValue),
          color: bgColor,
        ),
        padding: EdgeInsets.fromLTRB(
          contentPaddingLeft,
          contentPaddingTop,
          contentPaddingRight,
          contentPaddingBottom,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            /// Image
            if (imagePath != null && imagePath != '')
              // Expanded(
              //   flex: 3,
              //   child: AspectRatio(
              //     aspectRatio: 1,
              //     child: Image(
              //       image: FirebaseImage(
              //           "gs://travel-app-fc73b.appspot.com/$imagePath",
              //           shouldCache: true,
              //           cacheRefreshStrategy: CacheRefreshStrategy.NEVER),
              //       fit: BoxFit.cover,
              //     ),
              //   ),
              // ),

              /// Image
              if (networkImagePath != null && networkImagePath != '')
                Expanded(
                  flex: 3,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CachedNetworkImage(
                      imageUrl: networkImagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

            /// Content
            Expanded(
              flex: 7,
              child: Padding(
                padding: needSpacing()
                    ? const EdgeInsets.fromLTRB(20.0, 0.0, 0, 0.0)
                    : const EdgeInsets.fromLTRB(0, 0.0, 2.0, 0.0),
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            /// Title and Quantity
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                /// Title
                                Expanded(
                                  flex: 9,
                                  child: Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: titleColor,
                                      fontSize:
                                          _deviceDetails.getNormalFontSize(),
                                    ),
                                  ),
                                ),

                                /// Quantity
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    "x $quantity",
                                    maxLines: 1,
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).primaryColor,
                                      fontSize:
                                          _deviceDetails.getTitleFontSize(),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            ///----------- Spacing
                            SizedBox(height: 5),

                            if (specialLine != null)

                              /// Special Line
                              Expanded(child: specialLine as Widget),

                            /// Selected Product Variant (Type + Selected Variant Name)
                            if (productVariantFinal != null &&
                                selectedProductVariant != null)
                              Text(
                                productVariantFinal!
                                        .Product_Variant_Types_name +
                                    ": " +
                                    selectedProductVariant!
                                        .Product_Variant_Options_name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: titleColor,
                                  fontSize:
                                      _deviceDetails.getNormalFontSize() - 2,
                                ),
                              ),

                            /// Final Price
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(height: 5),

                                // Price
                                Text(
                                  "RM " + finalPrice,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: fontColor,
                                    fontSize: _deviceDetails.getTitleFontSize(),
                                  ),
                                ),
                              ],
                            ),

                            if (customButton != null) customButton as Widget,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  bool needToResize() {
    bool temp = false;
    if (customButton == null && (imagePath == null || imagePath == '')) {
      temp = true;
    }
    return temp;
  }

  bool needSpacing() {
    bool temp = true;
    if (spacing == null || spacing == false) {
      temp = false;
    }
    return temp;
  }
}
