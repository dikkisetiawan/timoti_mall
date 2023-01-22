import 'package:flutter/material.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';

class CustomDefaultAppBar extends StatelessWidget with PreferredSizeWidget{
  final String appbarTitle;
  final WidgetSizeCalculation widgetSize;
  final VoidCallback onTapFunction;

  const CustomDefaultAppBar({
    Key? key,
    required this.appbarTitle,
    required this.widgetSize,
    required this.onTapFunction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: InkWell(
        onTap: onTapFunction,
        child: Icon(
          Icons.arrow_back_ios_sharp,
          color: Theme.of(context).primaryColor,
          size: widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        ),
      ),
      title: Text(
        appbarTitle,
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      shadowColor: Colors.grey,
      elevation: 3,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
