import 'package:cached_network_image/cached_network_image.dart';
// import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/material.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '/Screen-Size/ui-utils.dart';
import '/enums/device-screen-type.dart';
import '../Screen-Size/WidgetSizeCalculation.dart';

class CustomContainerEx extends StatelessWidget {
  final String imagePath;
  final String directImagePath;
  final String titleText;
  final String contentText;
  final double containerWidth;
  final String routeString;
  final double shadowValue;
  final double imageAspectRatio;
  final bool whitePanel;
  final Color textColor;
  final bool darkEdges;
  final Color shadowColor;
  final int position;
  final List<Widget>? customContainerList;

  const CustomContainerEx({
    Key? key,
    this.imagePath = '',
    this.directImagePath = '',
    this.titleText = '',
    this.contentText = '',
    this.containerWidth = 0,
    this.routeString = "",
    this.shadowValue = 6,
    this.imageAspectRatio = 5,
    this.whitePanel = true,
    this.textColor = Colors.black,
    this.darkEdges = false,
    this.shadowColor = Colors.black,
    this.position = 0,
    this.customContainerList,
  }) : super(key: key);

  int getPosition() {
    return this.position;
  }

  @override
  Widget build(BuildContext context) {
    return _buildContainer(context);
  }

  Widget _buildContainer(context) {
    var mediaQuery = MediaQuery.of(context);

    //print(imagePath.toString());

    return Padding(
      padding: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
          ? EdgeInsets.fromLTRB(0, 0, 0, 10)
          : EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: SizedBox(
        width: containerWidth,
        child: Material(
          elevation: shadowValue,
          shadowColor: shadowColor,
          borderRadius: BorderRadius.circular(15.0),
          child: InkWell(
            onTap: () {
              // if(routeString == HomeDestinationsPage.routeName){
              //   HomeDestinationsArgument argument = HomeDestinationsArgument(title: titleText, destinationsList: customContainerList);
              //   Navigator.pushNamed(context, routeString, arguments: argument);
              // }
            },
            splashColor: Colors.black,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: getContent(context)),
          ),
        ),
      ),
    );
  }

  Widget getContent(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails deviceDetails = DeviceDetails(context);
    var mediaQuery = MediaQuery.of(context);

    double _normalContainerWidth =
        _widgetSize.getResponsiveWidth(0.45, 0.45, 0.45);

    /// Spacing
    double _singleContentSpacing =
        _widgetSize.getResponsiveParentSize(0.08, _normalContainerWidth);
    double _spacing =
        _widgetSize.getResponsiveParentSize(0.07, _normalContainerWidth);

    /// For Expand Container
    double _expandContainerWidth =
        _widgetSize.getResponsiveWidth(0.95, 0.95, 0.95);
    double _textWidth =
        _widgetSize.getResponsiveParentSize(0.5, _expandContainerWidth);

    /// Normal Container
    if (whitePanel == true) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          if (imagePath != null && directImagePath == null)

            /// Image
            Expanded(
              flex: (contentText == null || contentText == "") ? 8 : 7,
              child: AspectRatio(
                aspectRatio: imageAspectRatio,
                child: CachedNetworkImage(
                  imageUrl: imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          if (directImagePath != null && imagePath == null)

            /// Image
            Expanded(
              flex: (contentText == null || contentText == "") ? 8 : 7,
              child: FittedBox(
                fit: BoxFit.fill,
                child: Image.asset(directImagePath),
                //AspectRatio(
                //                 aspectRatio: imageAspectRatio,
                // child: Image(
                //   image: FirebaseImage(
                //     "gs://travel-app-fc73b.appspot.com/$directImagePath",
                //     shouldCache: true,
                //     cacheRefreshStrategy: CacheRefreshStrategy.NEVER,
                //   ),
                //   fit: BoxFit.cover,
                // ),
              ),
            ),

          /// Title and Text
          if ((titleText != null && titleText != "") ||
              (contentText != null && contentText != ""))
            Expanded(
              flex: (contentText == null || contentText == "") ? 2 : 3,
              child: Container(
                color: Colors.white,
                width: double.infinity,
                constraints: BoxConstraints(maxWidth: double.infinity),
                child: Padding(
                  padding: (contentText == null || contentText == "")
                      ? EdgeInsets.fromLTRB(
                          _singleContentSpacing,
                          0,
                          0,
                          0,
                        )
                      : EdgeInsets.fromLTRB(
                          _spacing,
                          0,
                          0,
                          0,
                        ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      /// Title
                      if (titleText != null && titleText != "")
                        Expanded(
                          child: Align(
                            alignment: ((titleText != null &&
                                        titleText != "") &&
                                    (contentText != null && contentText != ""))
                                ? Alignment.bottomLeft
                                : Alignment.centerLeft,
                            child: Text(
                              titleText,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: deviceDetails.getTitleFontSize() - 1,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),

                      if (contentText != null && contentText != "")
                        SizedBox(
                            height: (getDeviceType(mediaQuery) ==
                                    DeviceScreenType.Mobile
                                ? 3
                                : 10)),

                      /// Content
                      if (contentText != null && contentText != "")
                        Expanded(
                          child: Align(
                            alignment: ((titleText != null &&
                                        titleText != "") &&
                                    (contentText != null && contentText != ""))
                                ? Alignment.topLeft
                                : Alignment.centerLeft,
                            child: Text(
                              contentText,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: deviceDetails.getNormalFontSize() - 1,
                                fontWeight: FontWeight.w400,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    }

    /// Expanded Container
    else if (whitePanel == false) {
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (directImagePath != null && imagePath == null)

            /// Background Image
            // AspectRatio(
            //   aspectRatio: imageAspectRatio,
            //   child: Image(
            //     image: FirebaseImage(
            //         "gs://travel-app-fc73b.appspot.com/$directImagePath",
            //         shouldCache: true,
            //         cacheRefreshStrategy: CacheRefreshStrategy.NEVER),
            //     fit: BoxFit.cover,
            //   ),
            //   // child: CachedNetworkImage(
            //   //   imageUrl: imagePath,
            //   //   fit: BoxFit.cover,
            //   // ),
            // ),

            if (imagePath != null && directImagePath == null)

              /// Background Image
              AspectRatio(
                aspectRatio: imageAspectRatio,
                child: CachedNetworkImage(
                  imageUrl: imagePath,
                  fit: BoxFit.cover,
                ),
              ),

          if (darkEdges == true)

            /// Dark edges
            Opacity(
              opacity: 0.4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color(0x00000000),
                      const Color(0xCC000000),
                    ],
                  ),
                ),
              ),
            ),

          if (darkEdges == true)

            /// Dark edges
            Opacity(
              opacity: 0.6,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0x00000000),
                      const Color(0xCC000000),
                    ],
                  ),
                ),
              ),
            ),

          /// Title and Text
          if ((titleText != null && titleText != "") ||
              (contentText != null && contentText != ""))
            Padding(
              padding: EdgeInsets.fromLTRB(
                0,
                0,
                _spacing,
                0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: Container(),
                  ),

                  /// Title
                  if (titleText != null && titleText != "")
                    Expanded(
                      child: Container(
                        width: _textWidth,
                        child: Align(
                          alignment: ((titleText != null && titleText != "") &&
                                  (contentText != null && contentText != ""))
                              ? Alignment.bottomRight
                              : Alignment.centerRight,
                          child: Text(
                            titleText,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: deviceDetails.getTitleFontSize() + 6,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 5,
                  ),

                  /// Content
                  if (contentText != null && contentText != "")
                    Expanded(
                      child: Container(
                        width: _textWidth,
                        child: Align(
                          alignment: ((titleText != null && titleText != "") &&
                                  (contentText != null && contentText != ""))
                              ? Alignment.topRight
                              : Alignment.centerRight,
                          child: Text(
                            contentText,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                letterSpacing: 2,
                                fontSize: deviceDetails.getTitleFontSize() + 5,
                                color: textColor,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      );
    }

    return Container();
  }
}
