import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/Data-Class/CategoriesDataClass.dart';
import '/Home/Home-Category-Page.dart';
import '/Nav.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';
import '/StaticData.dart';
import 'package:page_transition/page_transition.dart';

class WebCategories extends StatefulWidget {
  final Color backgroundColor;
  final Color titleBgColor;
  final WidgetSizeCalculation widgetSize;
  final DeviceDetails deviceDetails;
  final BottomAppBarState bottomAppBarState;
  final int maxItem;
  final bool enableBorder;
  final Color contentColor;

  const WebCategories({
    Key? key,
    required this.backgroundColor,
    required this.titleBgColor,
    required this.widgetSize,
    required this.deviceDetails,
    required this.bottomAppBarState,
    required this.maxItem,
    required this.enableBorder,
    required this.contentColor,
  }) : super(key: key);

  @override
  _WebCategoriesState createState() => _WebCategoriesState();
}

class _WebCategoriesState extends State<WebCategories> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  int currentMaxCount = 0;

  @override
  void initState() {
    if (StaticData.categoryList.length == 0) {
      getData();
    } else {
      print("No need call categories data");
      // print("StaticData.categoryList Length: " + StaticData.categoryList.length.toString());
    }
    super.initState();
  }

  getData() async {
    print("Is Calling Categories Query");

    QuerySnapshot querySnapshot;

    querySnapshot = await firestore
        .collection('Product_Collections')
        .where("Visibility", isEqualTo: "Published")
        .where("is_published", isEqualTo: '1')
        // .orderBy('SortOrder', descending: false)
        .get();

    /// Define Temp Map Data
    Map<String, dynamic>? tempMapData = Map<String, dynamic>();

    print("Categories Length: " + querySnapshot.docs.length.toString());
    for (int i = 0; i < querySnapshot.docs.length; ++i) {
      /// Assign Data
      tempMapData = querySnapshot.docs[i].data() as Map<String, dynamic>;

      CategoriesData data = new CategoriesData(
        name: tempMapData["title"],
        id: tempMapData["id"],
        iconImage: tempMapData["image_url"],
      );
      StaticData.categoryList.add(data);

      /// Also add to Icon Only List
      if (tempMapData["image_url"] != null) {
        if (tempMapData["image_url"] != '') {
          CategoriesData data = new CategoriesData(
            name: tempMapData["title"],
            id: tempMapData["id"],
            iconImage: tempMapData["image_url"],
          );
          StaticData.iconOnlyList.add(data);
        }
      }
    }

    print("CategoryList length: " + StaticData.categoryList.length.toString());
    print("iconOnlyList length: " + StaticData.iconOnlyList.length.toString());

    /// Calculate Current Max Count For Grid Builder Indexing
    if (StaticData.iconOnlyList.length >= widget.maxItem) {
      currentMaxCount = widget.maxItem;
    } else {
      currentMaxCount = StaticData.iconOnlyList.length;
    }
    print("currentMaxCount: " + currentMaxCount.toString());
    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.all(
          Radius.circular(50),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: StaticData.categoryList.length,
        itemBuilder: (context, i) {
          if (i == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  tileColor: widget.titleBgColor,
                  contentPadding: EdgeInsets.fromLTRB(
                    widget.widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    0,
                    widget.widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    0,
                  ),
                  title: Center(
                    child: Text(
                      "Our Products",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: widget.deviceDetails.getTitleFontSize() - 3,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: widget.contentColor,
                    border: widget.enableBorder == true
                        ? Border(
                            bottom: BorderSide(
                              width: 0.6,
                              color: Theme.of(context).dividerColor,
                            ),
                          )
                        : null,
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.fromLTRB(
                      widget.widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                      0,
                      widget.widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                      0,
                    ),
                    title: Text(
                      StaticData.categoryList[i].name as String,
                      style: TextStyle(
                        fontSize: widget.deviceDetails.getNormalFontSize() - 3,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: CategoryPage(
                            bottomAppBarState: widget.bottomAppBarState,
                            userPosition: null,
                            categoryString:
                                StaticData.categoryList[i].id as String,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return Container(
            decoration: BoxDecoration(
              color: widget.contentColor,
              border: widget.enableBorder == true
                  ? Border(
                      bottom: BorderSide(
                        width: 0.6,
                        color: Theme.of(context).dividerColor,
                      ),
                    )
                  : null,
            ),
            child: ListTile(
              contentPadding: EdgeInsets.fromLTRB(
                widget.widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                0,
                widget.widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                0,
              ),
              title: Text(
                StaticData.categoryList[i].name as String,
                style: TextStyle(
                  fontSize: widget.deviceDetails.getNormalFontSize() - 3,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: CategoryPage(
                      bottomAppBarState: widget.bottomAppBarState,
                      userPosition: null,
                      categoryString: StaticData.categoryList[i].id as String,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
