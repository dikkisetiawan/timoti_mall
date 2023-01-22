import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '/Custom-UI/Custom-LoadingUI.dart';
import '/Data-Class/ProductDetailsArgument.dart';
import '/Home/HomePage.dart';
import '/Home/Product-Details-Page.dart';
import '/Nav.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';

class CategoryPage extends StatefulWidget {
  final Position? userPosition;
  final String appbarTitle;
  final String categoryString;
  final BottomAppBarState bottomAppBarState;

  CategoryPage({
    this.userPosition,
    this.appbarTitle = '',
    required this.categoryString,
    required this.bottomAppBarState,
  });

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final ScrollController _scrollController = ScrollController();
  bool hasProduct = true;
  String defaultImagePath = 'assets/product/1.jpg';

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  bool hasMore = true;
  DocumentSnapshot? lastDocument;
  List<DocumentSnapshot> products = [];

  final formatCurrency = new NumberFormat.currency(
    locale: "ms-MY",
    symbol: "",
    decimalDigits: 2,
  );

  bool loaded = false;
  String errorMessage = '';

  @override
  void initState() {
    getData((3 * 8), widget.categoryString);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // region UI
  Widget categoryDesign(
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
    double boxWidth,
    bool roundedEdge,
    Color containerColor,
    Color priceColor,
    String currency,
    bool contentPaddingEnabled,
    double viewport,
    Color containerBGColor,
  ) {
    return Container(
      color: Theme.of(context).backgroundColor,
      width: _widgetSize.getResponsiveWidth(1, 1, 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Content
          if (products.length != 0)
            Container(
              width: _widgetSize.getResponsiveWidth(1, 1, 1),
              // height: boxHeight, <--- Set the Grid Height
              child: GridView.builder(
                shrinkWrap: true,
                physics: new NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: viewport, // <-- View port of each child
                  crossAxisCount: 2, // <-- Set the Column No
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0, // <-- Spacing between each grid
                ),
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  /// Assign Data
                  Map<String, dynamic> productMapData =
                      products[index].data() as Map<String, dynamic>;

                  return Container(
                    color: containerBGColor,
                    padding: EdgeInsets.only(
                      top: _widgetSize.getResponsiveWidth(0.025, 0.025, 0.05),
                    ),
                    child: InkWell(
                      onTap: () {
                        if (productMapData["Product_ID"] != null) {
                          if (productMapData["Product_ID"] != "") {
                            /// Store Image URL
                            List<String> urlListData = [];
                            if (productMapData["Product_Images_Object"] !=
                                null) {
                              for (int i = 0;
                                  i <
                                      productMapData["Product_Images_Object"]
                                          .length;
                                  ++i) {
                                urlListData.add(
                                    productMapData["Product_Images_Object"][i]
                                        ["url"]);
                              }
                            }

                            ProductDetailsArgument arg = ProductDetailsArgument(
                              userPosition: widget.userPosition,
                              productBaseID: productMapData["Product_ID_Base"],
                              priceString: productMapData["Final_Price"],
                              productDescription:
                                  productMapData["Product_Description"],
                              productName: productMapData["Product_Name"],
                              urlList: urlListData,
                              bottomAppBarState: widget.bottomAppBarState,
                            );

                            Navigator.pushNamed(
                              context,
                              ProductDetailsPage.routeName,
                              arguments: arg,
                            );
                          }
                        }
                      },
                      child: Column(
                        children: [
                          /// No Image
                          if (productMapData["Product_Images_Object"] == null)
                            Container(
                              width: boxWidth,
                              // height: boxHeight * 0.6,
                              height: boxWidth,
                              decoration: BoxDecoration(
                                boxShadow: roundedEdge == true
                                    ? [
                                        BoxShadow(
                                          color: Colors.black,
                                          spreadRadius: 1,
                                          blurRadius: 10,
                                          offset: Offset(7,
                                              5), // changes position of shadow
                                        ),
                                      ]
                                    : null,
                                borderRadius: roundedEdge == true
                                    ? BorderRadius.only(
                                        topLeft: const Radius.circular(10.0),
                                        topRight: const Radius.circular(10.0),
                                      )
                                    : null,
                                image: DecorationImage(
                                  fit: BoxFit.contain,
                                  image: AssetImage(defaultImagePath),
                                ),
                              ),
                            ),

                          /// Has Image
                          if (productMapData["Product_Images_Object"] != null)
                            Container(
                              width: boxWidth,
                              // height: boxHeight * 0.65,
                              height: boxWidth,
                              child: CachedNetworkImage(
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey,
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.error,
                                        color: Theme.of(context).primaryColor,
                                        size: boxWidth / 2,
                                      ),
                                      Text(
                                        "Can't Load Image",
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                imageUrl:
                                    productMapData["Product_Images_Object"][0]
                                        ["url"],
                                fit: BoxFit.contain,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  // width: 80.0,
                                  // height: 80.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: roundedEdge == true
                                        ? [
                                            BoxShadow(
                                              color: Colors.black,
                                              spreadRadius: 1,
                                              blurRadius: 10,
                                              offset: Offset(7,
                                                  5), // changes position of shadow
                                            ),
                                          ]
                                        : null,
                                    borderRadius: roundedEdge == true
                                        ? BorderRadius.only(
                                            topLeft:
                                                const Radius.circular(10.0),
                                            topRight:
                                                const Radius.circular(10.0),
                                          )
                                        : null,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: imageProvider,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Spacing
                          SizedBox(height: 10),

                          /// Title and Text
                          Container(
                            width: boxWidth,
                            padding: contentPaddingEnabled == true
                                ? EdgeInsets.fromLTRB(
                                    _widgetSize.getResponsiveParentSize(
                                      0.07,
                                      _widgetSize.getResponsiveWidth(
                                          0.32, 0.32, 0.32),
                                    ),
                                    10,
                                    0,
                                    0,
                                  )
                                : null,
                            // height: boxWidth * 0.35,
                            decoration: BoxDecoration(
                              boxShadow: roundedEdge == true
                                  ? [
                                      BoxShadow(
                                        color: Colors.black,
                                        spreadRadius: 1,
                                        blurRadius: 10,
                                        offset: Offset(
                                            7, 5), // changes position of shadow
                                      ),
                                    ]
                                  : null,
                              color: containerColor,
                              borderRadius: roundedEdge == true
                                  ? BorderRadius.only(
                                      bottomLeft: const Radius.circular(10.0),
                                      bottomRight: const Radius.circular(10.0),
                                    )
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                /// Title
                                Align(
                                  alignment:
                                      productMapData["Product_Description"] !=
                                              ''
                                          ? Alignment.bottomLeft
                                          : Alignment.centerLeft,
                                  child: Text(
                                    productMapData["Product_Name"],
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize:
                                          _deviceDetails.getNormalFontSize(),
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),

                                SizedBox(height: 3),

                                // /// Content
                                // if (products[index]
                                //         .data["Product_Description"] !=
                                //     '')
                                //   Align(
                                //     alignment: Alignment.centerLeft,
                                //     child: Text(
                                //       products[index]
                                //           .data["Product_Description"],
                                //       // products[index]
                                //       //     .data["Product_ID"],
                                //       overflow: TextOverflow.ellipsis,
                                //       style: TextStyle(
                                //         fontSize:
                                //             _deviceDetails.getNormalFontSize() -
                                //                 1,
                                //         fontWeight: FontWeight.w400,
                                //         color: Colors.black,
                                //       ),
                                //     ),
                                //   ),
                                // if (products[index]
                                //         .data["Product_Description"] !=
                                //     '')
                                //   SizedBox(height: 3),

                                /// Price
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    currency +
                                        " " +
                                        formatCurrency
                                            .format(double.parse(
                                                productMapData["Final_Price"]))
                                            .toString(),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize:
                                          _deviceDetails.getNormalFontSize() -
                                              1,
                                      fontWeight: FontWeight.bold,
                                      color: priceColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )

          /// Loading
          else
            Container(
              width: _widgetSize.getResponsiveWidth(1, 1, 1),
              // height: boxHeight, <--- Set the Grid Height
              child: GridView.builder(
                // primary: false,
                shrinkWrap: true,
                physics: new NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 1, // <-- View port of each child
                  crossAxisCount: 2, // <-- Set the Column No
                  crossAxisSpacing: 0,
                ),
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.all(
                        _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),
                    child: FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: CustomLoading(),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
  // endregion

  // region Query
  getData(int documentLimit, String sectionDataString) async {
    if (!hasMore) {
      print('No More Data');
      setState(() {
        isLoading = false;
      });
      return;
    }
    if (isLoading) {
      return;
    }

    /// Begin Here_
    setState(() {
      isLoading = true;
    });

    QuerySnapshot querySnapshot;

    /// Get Fruits Category
    DocumentReference categoryRef =
        firestore.collection("Product_Collections").doc(sectionDataString);

    /// First Time Load
    if (lastDocument == null) {
      // querySnapshot = await firestore
      //     .collection('Products')
      //     .where("Product_Collections", arrayContains: "/Product_Collection/3")
      //     .limit(documentLimit)
      //     .get();
      print("First Load");
      print("documentLimit : " + documentLimit.toString());

      querySnapshot = await firestore
          .collection('Products')
          .where("Product_Is_Published", isEqualTo: "1")
          .where("Product_Collections", arrayContains: categoryRef)
          .orderBy('Product_Name', descending: false)
          .limit(documentLimit)
          .get();

      if (querySnapshot.docs.length == 0) {
        print('Category : ' + sectionDataString);
        print("No Product");
        setState(() {
          hasProduct = false;
          isLoading = false;
        });
        return;
      }
    }

    /// Load more data
    else {
      print("Not Gonna Run : " + documentLimit.toString());

      querySnapshot = await firestore
          .collection('Products')
          .where("Product_Is_Published", isEqualTo: "1")
          .where("Product_Collections", arrayContains: categoryRef)
          .orderBy('Product_Name', descending: false)
          .startAfterDocument(lastDocument as DocumentSnapshot)
          .limit(documentLimit)
          .get();
      // print(1);
    }

    print("=============================");
    print('Category : ' + sectionDataString);
    print('Query Category Length: ' + querySnapshot.docs.length.toString());
    if (querySnapshot.docs.length == 0) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    if (querySnapshot.docs.length < documentLimit) {
      hasMore = false;
    }

    /// Get last document
    lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];

    /// Assign Last Map Data
    Map<String, dynamic> lastDocMapData =
        lastDocument!.data() as Map<String, dynamic>;

    for (int i = 0; i < querySnapshot.docs.length; ++i) {
      if (lastDocMapData["Product_Is_Published"] != null) {
        if (lastDocMapData["Product_Is_Published"] == "1") {
          products.add(querySnapshot.docs[i]);
        }
      }
    }
    // products.addAll(querySnapshot.documents);

    /// Remove Duplicate
    final ids = products.map((e) {
      Map<String, dynamic> tempMapData = e.data() as Map<String, dynamic>;
      return tempMapData["Product_ID_Base"];
    }).toSet();

    products.retainWhere((x) {
      Map<String, dynamic> tempMapData = x.data() as Map<String, dynamic>;
      return ids.remove(tempMapData["Product_ID_Base"]);
    });

    if (this.mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_sharp,
            color: Theme.of(context).primaryColor,
            size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          ),
        ),
        title: Text(
          widget.appbarTitle,
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        shadowColor: Colors.grey,
        elevation: 3,
      ),
      body: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                getData((3 * 4), widget.categoryString);
              }
              return false;
            },
            child: SingleChildScrollView(
              child: hasProduct == true
                  ? Column(
                      children: [
                        categoryDesign(
                          _widgetSize,
                          _deviceDetails,
                          _widgetSize.getResponsiveWidth(0.47, 0.45, 0.45),
                          false,
                          Colors.transparent,
                          Colors.black,
                          "RM",
                          false,
                          0.8,
                          Theme.of(context).shadowColor,
                        ),
                        if (isLoading == true)
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                _widgetSize.getResponsiveWidth(
                                    0.48, 0.48, 0.48),
                                0,
                                _widgetSize.getResponsiveWidth(
                                    0.45, 0.45, 0.45),
                                0),
                            child: FittedBox(child: CustomLoading()),
                          ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                            height: _widgetSize.getResponsiveHeight(
                                0.15, 0.15, 0.15)),
                        Icon(
                          Icons.error,
                          color: Colors.grey,
                          size:
                              _widgetSize.getResponsiveWidth(0.25, 0.25, 0.25),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                              _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                              0),
                          child: Text(
                            "Oops, No products found in this ${widget.appbarTitle}!",
                            style: TextStyle(
                              fontSize: _deviceDetails.getTitleFontSize(),
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }
}
