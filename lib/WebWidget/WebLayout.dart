import 'package:flutter/material.dart';
import '/Nav.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';
import '/WebWidget/WebAppbar.dart';
import '/WebWidget/WebCategories.dart';

class WebDesktopLayout extends StatefulWidget {
  /// Main Content UI
  final Widget content;
  final BottomAppBarState bottomAppBarState;
  final WidgetSizeCalculation widgetSize;
  final DeviceDetails deviceDetails;
  final bool noCategories;

  const WebDesktopLayout({
    Key? key,
    required this.content,
    required this.bottomAppBarState,
    required this.widgetSize,
    required this.deviceDetails,
    required this.noCategories,
  }) : super(key: key);

  @override
  _WebDesktopLayoutState createState() => _WebDesktopLayoutState();
}

class _WebDesktopLayoutState extends State<WebDesktopLayout> {
  @override
  Widget build(BuildContext context) {
    SizedBox spacing = SizedBox(
      width: widget.widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
    );

    return Column(
      children: [
        WebAppbar(
          bottomAppBarState: widget.bottomAppBarState,
        ),
        Expanded(
          child: widget.noCategories == true
              ? widget.content
              : Padding(
                  padding: EdgeInsets.fromLTRB(
                    0,
                    widget.widgetSize.getResponsiveHeight(0.1, 0.1, 0.1),
                    0,
                    widget.widgetSize.getResponsiveHeight(0.05, 0.05, 0.05),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      spacing,

                      /// Categories
                      Expanded(
                        flex: 2,
                        child: WebCategories(
                          backgroundColor: Colors.transparent,
                          contentColor: Theme.of(context).shadowColor,
                          enableBorder: true,
                          maxItem: 4,
                          titleBgColor: Theme.of(context).cardColor,
                          bottomAppBarState: widget.bottomAppBarState,
                          widgetSize: widget.widgetSize,
                          deviceDetails: widget.deviceDetails,
                        ),
                      ),
                      SizedBox(width: 30),

                      /// Content
                      Expanded(
                        flex: 6,
                        child: widget.content,
                      ),

                      spacing,
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
