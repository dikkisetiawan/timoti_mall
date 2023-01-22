import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/Custom-UI/Custom-LoadingUI.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '../Screen-Size/WidgetSizeCalculation.dart';

class CustomGridPanel extends StatelessWidget {
  final String? title;
  final double gridWidth;
  final double gridOverallPadding;
  final double gridCBottomPadding;
  final double gridCMiddlePadding;
  final double gridCHeightAspect;
  final int noOfCol;
  final List<Widget>? allItemList;
  final Widget? customSectionButton;
  final Widget? customBottomButton;
  final int defaultLength;
  final Color bgColor;

  const CustomGridPanel({
    Key? key,
    this.title,
    this.gridWidth = 0,
    this.gridOverallPadding = 0,
    this.gridCBottomPadding = 0,
    this.gridCMiddlePadding = 0,
    this.gridCHeightAspect = 0,
    this.noOfCol = 0,
    this.allItemList,
    this.customSectionButton,
    this.customBottomButton,
    this.defaultLength = 0,
    this.bgColor = Colors.transparent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Wrap(
      direction: Axis.vertical,
      children: <Widget>[
        /// Section Title & Custom Section Button
        if (title != null && title != '')
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              /// Title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title as String,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: _deviceDetails.getTitleFontSize() + 3,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF444444)),
                ),
              ),

              /// Custom Section Button
              if (customSectionButton != null) customSectionButton as Widget,
            ],
          ),

        if (title != null && title != '')
          SizedBox(
              height: _widgetSize.getResponsiveHeight(0.015, 0.015, 0.015)),

        /// Grid Content
        Container(
          color: bgColor,
          width: gridWidth != null
              ? gridWidth
              : _widgetSize.getResponsiveWidth(0.9, 0.9, 0.9),
          constraints: BoxConstraints(
            maxWidth: gridWidth != null
                ? gridWidth
                : _widgetSize.getResponsiveWidth(0.9, 0.9, 0.9),
          ),
          child: gridBuilder(
            gridOverallPadding != null ? gridOverallPadding : 0.005,
            gridCMiddlePadding,
            gridCBottomPadding,
            gridCHeightAspect,
            context,
            _widgetSize,
          ),
        ),

        /// Custom Bottom Button
        if (customBottomButton != null) customBottomButton as Widget,

        if (title != null && title != '')
          SizedBox(
              height: _widgetSize.getResponsiveHeight(0.025, 0.025, 0.025)),
      ],
    );
  }

  int getNoOfCol() {
    int temp = noOfCol;

    if (temp < 1) {
      temp = 1;
    }
    return temp;
  }

  /// Grid Builder
  Widget gridBuilder(
    double overallPadding,
    double contentMiddlePadding,
    double contentBottomPadding,
    double contentHeight,
    context,
    WidgetSizeCalculation _widgetSize,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: new NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: contentHeight,
        crossAxisCount: getNoOfCol(),
        crossAxisSpacing: _widgetSize.getResponsiveWidth(
            contentMiddlePadding, contentMiddlePadding, contentMiddlePadding),
      ),
      itemCount: defaultLength == 0 ? allItemList?.length : defaultLength,
      itemBuilder: (_, i) {
        if (allItemList != null) {
          if (allItemList!.length > 0) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                0,
                0,
                0,
                _widgetSize.getResponsiveWidth(contentBottomPadding,
                    contentBottomPadding, contentBottomPadding),
              ),
              child: allItemList?[i],
            );
          } else {
            return Center(child: CustomLoading());
          }
        } else {
          return Center(child: CustomLoading());
        }
      },
      padding: EdgeInsets.all(
        _widgetSize.getResponsiveWidth(
            overallPadding, overallPadding, overallPadding),
      ),
    );
  }
}
