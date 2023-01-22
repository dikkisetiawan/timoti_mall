import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:timoti_project/Custom-UI/Custom-LoadingUI.dart';
import 'package:timoti_project/Data-Class/ProductDetailsArgument.dart';
import 'package:timoti_project/Home/Product-Details-Page.dart';
import 'package:timoti_project/Nav.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class SearchingPage extends StatelessWidget {
  final Position? userPosition;
  final BottomAppBarState bottomAppBarState;

  SearchingPage({
    this.userPosition,
    required this.bottomAppBarState,
  });

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            /// Recommendation
            RecommendResult(
              deviceDetails: _deviceDetails,
              widgetSize: _widgetSize,
              userPosition: userPosition,
              bottomAppBarState: bottomAppBarState,
            ),

            /// Search Bar
            SearchField(
              widgetSize: _widgetSize,
              deviceDetails: _deviceDetails,
              userPosition: userPosition,
              bottomAppBarState: bottomAppBarState,
            )
            // SearchSuggest(),
          ],
        ),
      ),
    );
  }
}

// region Recommend Result
class RecommendResult extends StatefulWidget {
  final WidgetSizeCalculation widgetSize;
  final DeviceDetails deviceDetails;
  final Position? userPosition;
  final BottomAppBarState bottomAppBarState;

  RecommendResult({
    required this.widgetSize,
    required this.deviceDetails,
    this.userPosition,
    required this.bottomAppBarState,
  });

  @override
  _RecommendResultState createState() => _RecommendResultState();
}

class _RecommendResultState extends State<RecommendResult> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final formatCurrency = new NumberFormat.currency(
    locale: "ms-MY",
    symbol: "",
    decimalDigits: 2,
  );
  List<ProductDetailsArgument> productList = [];
  String sectionTitle = '';
  bool loading = false;

  void initState() {
    getSectionData();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // region UI
  Widget chipUI(ProductDetailsArgument data) {
    return ActionChip(
      elevation: 8.0,
      padding: EdgeInsets.all(5.0),
      label: Text(
        data.productName,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: widget.deviceDetails.getNormalFontSize(),
          fontWeight: FontWeight.w400,
        ),
      ),
      onPressed: () {
        Navigator.pushNamed(
          context,
          ProductDetailsPage.routeName,
          arguments: data,
        );
      },
      backgroundColor: Theme.of(context).primaryColorLight,
      shape: StadiumBorder(
        side: BorderSide(
          width: 0.6,
          color: Theme.of(context).dividerColor,
        ),
      ),
    );
  }

  List<Widget> getAllChip() {
    List<Widget> chipList = [];

    for (int i = 0; i < productList.length; ++i) {
        if (productList[i].productName != '') {
          chipList.add(chipUI(productList[i]));
        }
    }

    return chipList;
  }
  // endregion

  // region Query
  /// Get Section Data
  getSectionData() async {
    if (this.mounted) {
      loading = true;
      setState(() {});
    }
    print("***************************");
    print("Is Calling Search Section Query");

    QuerySnapshot querySnapshot;

    querySnapshot = await firestore
        .collection('Section')
        .where("Enable_Section", isEqualTo: true)
        .where("Display", isEqualTo: 'search')
        .get();

    print("Section Length: " + querySnapshot.docs.length.toString());

    DocumentSnapshot currentSection = querySnapshot.docs[0];

    /// Define Current Section Map Data
    Map<String, dynamic> currentSectionMapData = Map<String, dynamic>();

    /// Assign Data
    currentSectionMapData = currentSection.data() as Map<String, dynamic>;

    /// Define Product Map Data
    Map<String, dynamic> productMapData = Map<String, dynamic>();

    sectionTitle = currentSectionMapData['Section_Name'];

    if (currentSectionMapData["Product_ID"] != null) {
      /// Loop each section product
      for (int j = 0; j < currentSectionMapData["Product_ID"].length; ++j) {
        QuerySnapshot productSnapshot;

        /// This Query will return 1 document
        productSnapshot = await firestore
            .collection('Products')
            .where("Product_ID",
                isEqualTo: currentSectionMapData["Product_ID"][j])
            .where("Product_Is_Published", isEqualTo: "1")
            .where("Product_Visibility", isEqualTo: "Published")
            .get();

        if (productSnapshot.docs.length > 0) {
          /// Check if data exist
          if (productSnapshot.docs[0].exists == true) {
            // print(
            //   "[${currentSectionMapData["Section_Name"]}] Has Product: " +
            //       currentSectionMapData["Product_ID"][j],
            // );
            DocumentSnapshot productData = productSnapshot.docs[0];

            /// Assign Data
            productMapData = productData.data() as Map<String, dynamic>;

            // region Product Data
            /// Product Image
            List<String> urlListData = <String>[];

            if (productMapData["Product_Images_Object"] != null) {
              for (int index = 0;
                  index < productMapData["Product_Images_Object"].length;
                  ++index) {
                urlListData
                    .add(productMapData["Product_Images_Object"][index]["url"]);
              }

              // print(urlListData[0]);
            }

            ProductDetailsArgument data = new ProductDetailsArgument(
              urlList: urlListData,
              priceString: productMapData["Final_Price"],
              productBaseID: productMapData['Product_ID_Base'],
              productDescription: productMapData["Product_Description"],
              productName: productMapData["Product_Name"],
              userPosition: widget.userPosition,
              bottomAppBarState: widget.bottomAppBarState,
            );

            /// Add to Product List
            productList.add(data);
            // endregion
          }
        }
      }
    }

    if (this.mounted) {
      loading = false;
      setState(() {});
    }
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          widget.widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          0,
          widget.widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          0,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  height: widget.widgetSize.getResponsiveHeight(0.1, 0.1, 0.1)),
              if (productList.length > 0)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    0,
                    widget.widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
                    0,
                    widget.widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
                  ),
                  child: Text(
                    sectionTitle != null ? sectionTitle : "Recommended",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: widget.deviceDetails.getTitleFontSize(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (productList.length > 0)
                Wrap(
                  spacing: 10.0,
                  runSpacing: 6.0,
                  children: getAllChip(),
                ),
              if (loading == true)
                Center(
                  child: CustomLoading(),
                ),
              SizedBox(
                  height: widget.widgetSize.getResponsiveHeight(0.1, 0.1, 0.1)),
            ],
          ),
        ),
      ),
    );
  }
}
// endregion

// region Search field
class SearchField extends StatefulWidget {
  final WidgetSizeCalculation widgetSize;
  final DeviceDetails deviceDetails;
  final Position? userPosition;
  final BottomAppBarState bottomAppBarState;

  SearchField({
    required  this.widgetSize,
    required this.deviceDetails,
    this.userPosition,
    required this.bottomAppBarState,
  });

  @override
  _SearchFieldState createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final ScrollController _scrollController = ScrollController();
  final formatCurrency = new NumberFormat.currency(
    locale: "ms-MY",
    symbol: "",
    decimalDigits: 2,
  );
  FloatingSearchBarController? searchController;
  List<DocumentSnapshot> searchResult = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  bool hasMore = true;
  DocumentSnapshot? lastDocument;
  int documentLimit = 25;
  String searchKey = '';

  @override
  void initState() {
    searchController = FloatingSearchBarController();
    super.initState();
  }

  @override
  void dispose() {
    searchController?.dispose();
    super.dispose();
  }

  /// Use this
  Widget buildResult() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Material(
        child: searchResult.length == 0
            ? ListTile(
                tileColor: Theme.of(context).primaryColorLight,
                title: Text(
                  'No Result Found',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                controller: _scrollController,
                itemCount: searchResult.length,
                itemBuilder: (context, index) {
                  /// Assign Data
                  Map<String, dynamic> searchResultMapData = searchResult[index].data() as Map<String, dynamic>;

                  if (index == searchResult.length - 1) {
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.black,
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: ListTile(
                            onTap: () {
                              /// Product Image
                              List<String> urlListData = <String>[];

                              if (searchResultMapData["Product_Images_Object"] !=
                                  null) {
                                for (int index = 0;
                                    index <
                                        searchResultMapData["Product_Images_Object"]
                                            .length;
                                    ++index) {
                                  urlListData.add(searchResultMapData["Product_Images_Object"][index]
                                      ["url"]);
                                }

                                // print(urlListData[0]);
                              }

                              ProductDetailsArgument data =
                                  new ProductDetailsArgument(
                                urlList: urlListData,
                                    priceString: searchResultMapData["Final_Price"],
                                productBaseID:
                                    searchResultMapData['Product_ID_Base'],
                                productDescription: searchResultMapData["Product_Description"],
                                productName:
                                    searchResultMapData["Product_Name"],
                                userPosition: widget.userPosition,
                                bottomAppBarState: widget.bottomAppBarState,
                              );

                              Navigator.pushNamed(
                                context,
                                ProductDetailsPage.routeName,
                                arguments: data,
                              );
                            },
                            tileColor: Theme.of(context).primaryColorLight,
                            contentPadding: EdgeInsets.fromLTRB(
                              widget.widgetSize
                                  .getResponsiveWidth(0.05, 0.05, 0.05),
                              0,
                              widget.widgetSize
                                  .getResponsiveWidth(0.05, 0.05, 0.05),
                              0,
                            ),
                            title: Text(
                              searchResultMapData["Product_Name"],
                              style: TextStyle(
                                fontSize:
                                    widget.deviceDetails.getNormalFontSize(),
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              "RM " +
                                  formatCurrency
                                      .format(double.parse(searchResultMapData["Final_Price"]))
                                      .toString(),
                              style: TextStyle(
                                fontSize:
                                    widget.deviceDetails.getNormalFontSize(),
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        CustomLoading(),
                      ],
                    );
                  }
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: ListTile(
                      onTap: () {
                        /// Product Image
                        List<String> urlListData = <String>[];

                        if (searchResultMapData["Product_Images_Object"] !=
                            null) {
                          for (int index = 0;
                              index <
                                  searchResultMapData["Product_Images_Object"]
                                      .length;
                              ++index) {
                            urlListData.add(searchResultMapData["Product_Images_Object"][index]["url"]);
                          }

                          // print(urlListData[0]);
                        }

                        ProductDetailsArgument data =
                            new ProductDetailsArgument(
                          urlList: urlListData,
                          priceString: searchResultMapData["Final_Price"],
                          productBaseID:
                              searchResultMapData['Product_ID_Base'],
                          productDescription:
                              searchResultMapData["Product_Description"],
                          productName: searchResultMapData["Product_Name"],
                          userPosition: widget.userPosition,
                          bottomAppBarState: widget.bottomAppBarState,
                        );

                        Navigator.pushNamed(
                          context,
                          ProductDetailsPage.routeName,
                          arguments: data,
                        );
                      },
                      tileColor: Theme.of(context).primaryColorLight,
                      contentPadding: EdgeInsets.fromLTRB(
                        widget.widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                        0,
                        widget.widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                        0,
                      ),
                      title: Text(
                        searchResultMapData["Product_Name"],
                        style: TextStyle(
                          fontSize: widget.deviceDetails.getNormalFontSize(),
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        "RM " +
                            formatCurrency
                                .format(double.parse(
                                    searchResultMapData["Final_Price"]))
                                .toString(),
                        style: TextStyle(
                          fontSize: widget.deviceDetails.getNormalFontSize(),
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  // region Query
  getData(String searchKey) async {
    if (isLoading) {
      return;
    }
    searchResult.clear();

    /// Begin Here_
    setState(() {
      isLoading = true;
    });

    QuerySnapshot querySnapshot;
    try {
      print("****** Calling Search Query First Time");
      querySnapshot = await FirebaseFirestore.instance
          .collection('Products')
          .orderBy('Product_Name')
          .startAt([searchKey])
          .endAt([searchKey + '\uf8ff'])
          .limit(documentLimit)
          .get();
    } catch (error) {
      print("===== Has Error ======");
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (querySnapshot.docs.length > 0) {
      print("Has Data");

      /// Get last document
      lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];

      /// Define Query Map Data
      Map<String, dynamic> querySnapshotMapData = Map<String, dynamic>();

      for (int i = 0; i < querySnapshot.docs.length; ++i) {
        /// Assign Data
        querySnapshotMapData = querySnapshot.docs[i].data() as Map<String, dynamic>;

        if (querySnapshotMapData["Product_Is_Published"] != null) {
          if (querySnapshotMapData["Product_Is_Published"] == "1") {
            searchResult.add(querySnapshot.docs[i]);
          }
        }
      }
      // products.addAll(querySnapshot.documents);

      /// Define Map Data
      Map<String, dynamic> tempMapData = Map<String, dynamic>();

      /// Remove Duplicate
      final ids = searchResult.map((e){

        /// Assign Data
        tempMapData = e.data() as Map<String, dynamic>;

        return tempMapData["Product_ID_Base"];
      }).toSet();
      searchResult.retainWhere((x){
        /// Assign Data
        tempMapData = x.data() as Map<String, dynamic>;

        return ids.remove(tempMapData["Product_ID_Base"]);
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  getLoadMoreData(String searchKey) async {
    print("Ready to call data");
    if (!hasMore) {
      print('No More Data');
      setState(() {
        isLoading = false;
      });
      return;
    }
    if (isLoading) {
      print("Is loading");
      return;
    }

    print("Actually called data");

    /// Begin Here_
    setState(() {
      isLoading = true;
    });

    late QuerySnapshot querySnapshot;

    try {
      if (lastDocument != null) {
        querySnapshot = await firestore
            .collection('Products')
            .orderBy('Product_Name')
            .startAfterDocument(lastDocument as DocumentSnapshot)
            // .startAt([searchKey])
            // .endAt([searchKey + '\uf8ff'])
            .limit(documentLimit)
            .get();
      }
    } catch (error) {
      print("===== Has Error ======");
      print("Error Message: " + error.toString());
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (querySnapshot != null) {
      if (querySnapshot.docs.length == 0) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      if (querySnapshot.docs.length < documentLimit) {
        hasMore = false;
      }
    } else {
      /// Return Document is null
      if (this.mounted) {
        print("Document is Null");
        isLoading = false;
        hasMore = false;
        setState(() {});
        return;
      }
    }

    if (querySnapshot.docs.length > 0) {
      /// Get last document
      lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
      /// Define Query Map Data
      Map<String, dynamic> querySnapshotMapData = Map<String, dynamic>();

      for (int i = 0; i < querySnapshot.docs.length; ++i) {
        /// Assign Data
        querySnapshotMapData = querySnapshot.docs[i].data() as Map<String, dynamic>;
        if (querySnapshotMapData["Product_Is_Published"] != null) {
          if (querySnapshotMapData["Product_Is_Published"] == "1") {
            searchResult.add(querySnapshot.docs[i]);
          }
        }
      }
      // products.addAll(querySnapshot.documents);

      /// Define Map Data
      Map<String, dynamic> tempMapData = Map<String, dynamic>();

      /// Remove Duplicate
      final ids = searchResult.map((e){

        /// Assign Data
        tempMapData = e.data() as Map<String, dynamic>;

        return tempMapData["Product_ID_Base"];
      }).toSet();
      searchResult.retainWhere((x){
        /// Assign Data
        tempMapData = x.data() as Map<String, dynamic>;

        return ids.remove(tempMapData["Product_ID_Base"]);
      });
    }

    setState(() {
      isLoading = false;
    });
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          print("(Load More) Search Key: " + searchKey);
          getLoadMoreData(searchKey);
        }
        return false;
      },
      child: FloatingSearchBar(
        backgroundColor: Theme.of(context).primaryColorLight,
        hintStyle: TextStyle(color: Theme.of(context).primaryColor),
        scrollController: _scrollController,
        iconColor: Theme.of(context).primaryColor,
        queryStyle: TextStyle(color: Theme.of(context).primaryColor),
        height: widget.widgetSize.getResponsiveHeight(0.07, 0.07, 0.07),
        hint: "Search your products here",
        controller: searchController,
        transitionCurve: Curves.easeInOutCubic,
        onQueryChanged: (query) {
          searchKey = query.inCaps;
          searchController?.query = searchKey;
          print("Search Key: " + searchKey);
          if (searchKey != "") {
            getData(searchKey);
          } else {
            if (this.mounted) {
              searchResult.clear();
              setState(() {});
            }
          }
          // searchKey = query;
          // FirebaseFirestore.instance
          //     .collection('Products')
          //     .orderBy('Product_Name')
          //     .startAt([searchKey])
          //     .endAt([searchKey + '\uf8ff'])
          //     .limit(10)
          //     .get()
          //     .then((snapshot) {
          //   if(this.mounted){
          //     setState(() {
          //       searchResult = snapshot.documents;
          //     });
          //   }
          // });
        },
        transition: CircularFloatingSearchBarTransition(),
        physics: const BouncingScrollPhysics(),
        builder: (context, _) => buildResult(),
      ),
    );
  }
}
// endregion

extension CapExtension on String {
  String get inCaps =>
      this.length > 0 ? '${this[0].toUpperCase()}${this.substring(1)}' : '';
  String get allInCaps => this.toUpperCase();
  String get capitalizeFirstofEach => this
      .replaceAll(RegExp(' +'), ' ')
      .split(" ")
      .map((str) => str.inCaps)
      .join(" ");
}
