import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';

// final BottomNavigationBar navigationBar = navBarGlobalKey.currentWidget;

class CustomScrollablePanel extends StatelessWidget {
  final String title;
  final double paddingLeftRight;
  final double paddingTopBottom;
  final List<Widget>? customContainerList;
  final double eachItemHeight;
  final int position;

  const CustomScrollablePanel(
      {Key? key,
      this.title = '',
      this.paddingLeftRight = 0,
      this.paddingTopBottom = 0,
      this.eachItemHeight = 0,
      this.customContainerList,
      this.position = 0,
      })
      : super(key: key);

  int getPosition(){
    return this.position;
  }

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        paddingLeftRight,
        paddingTopBottom,
        paddingLeftRight,
        paddingTopBottom,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if(title != '')
          /// Section Title + Arrow
          SizedBox(
            width: _widgetSize.getResponsiveWidth(0.9,0.9,0.9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                /// Title
                Text(
                  title,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF444444)),
                ),

                // TODO Make this arrow supported for tablet
                /// Arrow Button
                InkWell(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black45,
                    ),
                  ),
                  onTap: () => null,
                ),
              ],
            ),
          ),

          if(title != '')
          /// Spacing
          SizedBox(height: _widgetSize.getResponsiveHeight(0.015,0.015,0.015)),

          /// Contents
          if(customContainerList!=null)
          SizedBox(
            width: _widgetSize.getResponsiveWidth(0.9,0.9,0.9),
            height: eachItemHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              itemCount: customContainerList?.length,
              itemBuilder: (BuildContext context, int i) {
                /// Each Content
                return Padding(
                  padding: EdgeInsets.only(
                    right: _widgetSize.getResponsiveWidth(0.05,0.05,0.05),
                  ),
                  child: customContainerList?[i],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
