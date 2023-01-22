import 'package:cached_network_image/cached_network_image.dart';
// import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '/Data-Class/ProductVariant.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '../Screen-Size/WidgetSizeCalculation.dart';

class CustomListTilePrice extends StatelessWidget {
  final formatCurrency = new NumberFormat.currency(
    locale: "ms-MY",
    symbol: "",
    decimalDigits: 2,
  );

  final String? imagePath;
  final String? networkImagePath;

  final String title;
  final Widget? specialLine;
  final String finalPrice;
  final String? originalPrice;
  final double? rating;

  final double contentPaddingTop;
  final double contentPaddingBottom;
  final double contentPaddingLeft;
  final double contentPaddingRight;

  final bool spacing;
  final Widget? customButton;

  final bgColor;
  final Color fontColor;
  final titleColor;
  final int maxLine;

  final double circularBorderValue;
  final double shadowValue;
  final bool hiddenPrice;
  final ProductVariantType? productVariantFinal;
  final ProductVariant? selectedProductVariant;

  CustomListTilePrice({
    Key? key,
    this.imagePath,
    this.networkImagePath,
    this.title = '',
    this.specialLine,
    required this.finalPrice,
    this.originalPrice,
    this.spacing = false,
    this.rating,
    this.customButton,
    this.bgColor,
    this.titleColor = Colors.white,
    this.fontColor = Colors.white,
    this.maxLine = 0,
    this.circularBorderValue = 0,
    this.shadowValue = 8,
    this.contentPaddingTop = 0,
    this.contentPaddingBottom = 0,
    this.contentPaddingLeft = 0,
    this.contentPaddingRight = 0,
    this.hiddenPrice = false,
    this.productVariantFinal,
    this.selectedProductVariant,
  }) : super(key: key);

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
            // if (imagePath != null && imagePath != '')
            //   Expanded(
            //     flex: 3,
            //     child: AspectRatio(
            //       aspectRatio: 1,
            //       child: Image(
            //         image: FirebaseImage(
            //             "gs://travel-app-fc73b.appspot.com/$imagePath",
            //             shouldCache: true,
            //             cacheRefreshStrategy: CacheRefreshStrategy.NEVER),
            //         fit: BoxFit.cover,
            //       ),
            //     ),
            //   ),

            /// Image
            if (networkImagePath != null && networkImagePath != '')
              Expanded(
                flex: 3,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: networkImagePath as String,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            /// Content
            Expanded(
              flex: 7,
              child: Padding(
                padding: needSpacing()
                    ? const EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0)
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
                            /// Title
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: titleColor,
                                fontSize: _deviceDetails.getNormalFontSize(),
                              ),
                            ),

                            ///----------- Spacing
                            SizedBox(height: 5),

                            if (specialLine != null)

                              /// Special Line
                              Expanded(child: specialLine as Widget),

                            /// Final Price
                            Text(
                              "RM " + finalPrice,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: fontColor,
                                fontSize: _deviceDetails.getTitleFontSize() + 2,
                              ),
                            ),

                            SizedBox(height: 5),

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

                            /// Original Price
                            if (originalPrice != null)
                              Expanded(
                                child: Text(
                                  hiddenPrice == false
                                      ? "RM " + (originalPrice as String)
                                      : "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    fontWeight: FontWeight.w600,
                                    color: fontColor,
                                    fontSize:
                                        _deviceDetails.getNormalFontSize() - 2,
                                  ),
                                ),
                              ),

                            // ///----------- Spacing
                            // SizedBox(height: 5),

                            /// Rating
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (rating != null)

                                    /// Rating
                                    FittedBox(
                                      fit: BoxFit.fill,
                                      child: Row(
                                        children: [
                                          Text(
                                            rating.toString(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: _deviceDetails
                                                  .getNormalFontSize(),
                                            ),
                                          ),

                                          /// Spacing
                                          SizedBox(
                                            width:
                                                _widgetSize.getResponsiveWidth(
                                                    0.01, 0.01, 0.01),
                                          ),

                                          /// Star
                                          Material(
                                            color:
                                                Theme.of(context).primaryColor,
                                            shape: CircleBorder(),
                                            elevation: 3,
                                            shadowColor: Colors.grey,
                                            child: Center(
                                              child: Icon(
                                                Icons.star,
                                                color: Colors.white,
                                                size: _widgetSize
                                                    .getResponsiveWidth(
                                                        0.05, 0.05, 0.05),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),

                                  /// Custom button
                                  if (customButton != null)
                                    FittedBox(
                                        fit: BoxFit.contain,
                                        child: customButton),
                                ],
                              ),
                            ),
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
    if (spacing == false) {
      temp = false;
    }
    return temp;
  }
}
