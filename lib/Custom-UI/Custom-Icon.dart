import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';

class CustomIcon extends StatelessWidget {
  final String? imagePath;
  final Uint8List? imageBase64;
  final String? titleText;
  final String routeString;
  final Color textColor;
  final double textSize;
  final String urlLink;
  final WidgetSizeCalculation widgetSize;
  final DeviceDetails deviceDetails;

  const CustomIcon({
    Key? key,
    this.imagePath,
    this.imageBase64,
    this.titleText,
    required this.widgetSize,
    required this.deviceDetails,
    this.routeString = "",
    this.textColor = Colors.black,
    this.textSize = 0,
    this.urlLink = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildContainer(context);
  }

  Widget _buildContainer(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /// Icon Image
        if (urlLink == '')
          Expanded(
            flex: 8,
            child: Image(
              fit: BoxFit.contain,
              image: (imageBase64 == null
                  ? AssetImage(imagePath as String)
                  : MemoryImage(imageBase64 as Uint8List)) as ImageProvider<Object>,
            ),
          ),
        if (urlLink != '')
          Expanded(
            flex: 8,
            child: CachedNetworkImage(
              imageUrl: urlLink,
              fit: BoxFit.cover,
            ),
          ),

        SizedBox(height: 10),

        /// Text
        Expanded(
          flex: 4,
          child: AutoSizeText(
            titleText as String,
            maxLines: 2,
            style: TextStyle(
              color: textColor,
              fontSize: textSize != 0
                  ? textSize
                  : deviceDetails.getNormalFontSize(),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        )
        // Expanded(
        //   child: FittedBox(
        //     fit: BoxFit.contain,
        //     child: Wrap(
        //       crossAxisAlignment: WrapCrossAlignment.center,
        //       direction: Axis.vertical,
        //       children: [
        //         Center(
        //           child: Text(
        //             titleText as String,
        //             maxLines: 2,
        //             style: TextStyle(
        //               color: textColor,
        //               fontSize: textSize != 0
        //                   ? textSize
        //                   : deviceDetails.getNormalFontSize(),
        //             ),
        //             overflow: TextOverflow.ellipsis,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
