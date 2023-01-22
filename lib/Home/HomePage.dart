import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '/Core/auth.dart';
import '/Custom-UI/Custom-Icon.dart';
import '/Custom-UI/Custom-LoadingUI.dart';
import '/Data-Class/CategoriesDataClass.dart';
import '/Data-Class/CommentClass.dart';
import '/Data-Class/ProductDetailsArgument.dart';
import '/Data-Class/SlideshowImageClass.dart';
import '/Functions/Messager.dart';
import '/Home/Home-Category-Page.dart';
import '/Home/Product-Details-Page.dart';
import '/Home/Search/SearchingPage.dart';
import '/Home/SelectAddress/SelectAddress-Main.dart';
import '/Home/SelectAddress/SelectMapResult.dart';
import '/Nav.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';
import '/Screen-Size/ui-utils.dart';
import '/StaticData.dart';
import '/WebWidget/WebDrawer.dart';
import '/enums/device-screen-type.dart';
import 'package:new_version/new_version.dart';
import 'package:page_transition/page_transition.dart';
import 'dart:math';
import '/WebWidget/WebLayout.dart';

class HomePage extends StatefulWidget {
  static const routeName = "/HomePage";
  final BottomAppBarState bottomAppBarState;

  const HomePage({Key? key, required this.bottomAppBarState}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final formatCurrency = new NumberFormat.currency(
    locale: "ms-MY",
    symbol: "",
    decimalDigits: 2,
  );
  String defaultImagePath = 'assets/product/1.jpg';

  bool isLoading = false;
  bool hasMore = true;
  List<DocumentSnapshot> products = [];
  List<ProductSection> sectionList = [];

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? firebaseUser = FirebaseAuth.instance.currentUser;

  /// Address
  String addressString = '';
  Position? userPosition;

  bool sectionIsLoading = false;

  /// For Random Document
  int lowestPBase = 1;
  int highestPBase = 1500;
  List<DocumentSnapshot> randomProducts = [];
  Map<String, bool> randomProductsMap = Map<String, bool>();
  Map<String, dynamic>? randomProductsMapDATA = Map<String, dynamic>();
  bool randomIsLoading = false;

  int maxRandomCount = 36;

  List<SlideshowImageClass> slideshowImageList = [];
  List<CommentClass> commentList = [];
  String welcomeMessage = '';

  @override
  void initState() {
    // final newVersion = NewVersion(
    //   iOSId: '',
    //   androidId: 'com.mrfarmergrocery.mrfarmerapp',
    // );
    // newVersion.showAlertIfNecessary(context: context);

    /// Detect Guest Login
    if (firebaseUser != null) {
      if (firebaseUser?.isAnonymous == true) {
        print("*** User is Guest Login");
        welcomeMessage = "Guest";
      } else {
        print("*** Normal Login");
        if (firebaseUser?.displayName != null) {
          welcomeMessage = (firebaseUser!.displayName as String);
        } else {
          welcomeMessage = "User";
        }
      }
      StaticData().updateCartQuantity(firebaseUser, firestore);
      getSectionData();
      getSlideshowData(); // <- Slideshow
      // getCommentsData(); // <- Comment
    } else {
      /// Auto Sign in as Guest for Web
      FirebaseAuth.instance.signInAnonymously().then((value) {
        welcomeMessage = "Guest";
        getSectionData();
        getSlideshowData(); // <- Slideshow
        // getCommentsData(); // <- Comment
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // region UI
  /// Custom App bar
  Widget _getCustomAppBarSliver(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    BuildContext context,
  ) {
    return SafeArea(
      child: Container(
        height: _widgetSize.getResponsiveHeight(0.072, 0.09, 0.072),
        color: Theme.of(context).cardColor,
        padding: EdgeInsets.fromLTRB(
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          0,
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Spacing
            SizedBox(
              height: 20,
            ),

            /// Welcome Message
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // /// QR Code Icon
                  // SizedBox(
                  //   width: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                  //       ? _widgetSize.getResponsiveWidth(0.07,0.07,0.07)
                  //       : _widgetSize.getResponsiveWidth(0.06),
                  //   child: Material(
                  //     color: Colors.transparent,
                  //     child: InkWell(
                  //       onTap: () {
                  //         QrCodePageArgument arg = QrCodePageArgument();
                  //         arg.link = "Test";
                  //         Navigator.pushNamed(context, QrCodePage.routeName,
                  //             arguments: arg);
                  //       },
                  //       child: Image(
                  //         image: AssetImage('assets/icon/scan.png'),
                  //         color: Theme.of(context).backgroundColor,
                  //         fit: BoxFit.contain,
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  SizedBox(
                    width: 5,
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Deliver Address
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: AutoSizeText(
                              "Welcome to Timoti",
                              style: TextStyle(
                                fontSize:
                                    _deviceDetails.getNormalFontSize() - 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: AutoSizeText(
                              welcomeMessage != "" ? welcomeMessage : "User",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: _deviceDetails.getNormalFontSize(),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
                      ),

                      /// Map
                      FittedBox(
                        child: InkWell(
                          onTap: () async {
                            if (FirebaseAuth
                                    .instance.currentUser?.isAnonymous ==
                                false) {
                              SelectMapResult result = await Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: SelectAddressMainPage(),
                                ),
                              );

                              if (result != null) {
                                setState(() {
                                  addressString = result.address;
                                  userPosition = Position(
                                    accuracy: 0,
                                    altitude: 0,
                                    heading: 0,
                                    speed: 0,
                                    speedAccuracy: 0,
                                    isMocked: false,
                                    timestamp: DateTime.now(),
                                    latitude: result.latLng!.latitude,
                                    longitude: result.latLng!.longitude,
                                  );

                                  print("Result Lat: " +
                                      result.latLng!.latitude.toString());
                                  print("Result Long: " +
                                      result.latLng!.longitude.toString());
                                });
                              }
                            } else {
                              showLoginMessage(0, 15, context);
                            }
                          },
                          child: Icon(
                            Icons.map_outlined,
                            color: Theme.of(context).primaryColor,
                            size: _widgetSize.getResponsiveWidth(
                              0.05,
                              0.05,
                              0.07,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Custom Search bar
  Widget _getCustomSearchBar(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    BuildContext context,
  ) {
    return SafeArea(
      child: Container(
        height: _widgetSize.getResponsiveHeight(
            0.07, 0.07, 0.07), // <--- Same With Silver App Bar Define Size
        color: Theme.of(context).cardColor,
        padding: EdgeInsets.fromLTRB(
          _widgetSize.getResponsiveWidth(0.025, 0.025, 0.025),
          _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
          _widgetSize.getResponsiveWidth(0.025, 0.025, 0.025),
          _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: SearchingPage(
                  userPosition: userPosition,
                  bottomAppBarState: widget.bottomAppBarState,
                ),
              ),
            );
          },

          /// Search bar
          child: Container(
            // width: _widgetSize.getResponsiveWidth(0.90, 0.90, 0.90),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight,
              // border: Border.all(
              //   color: Theme.of(context).dividerColor,
              //   width: 0.8,
              // ),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            padding: EdgeInsets.only(
              left: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_sharp,
                  color: Colors.black,
                ),
                SizedBox(width: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Search for products",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Grid Based Random
  Widget randomDesign(
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
    double boxWidth,
  ) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03)),
      child: Container(
        color: Theme.of(context).shadowColor,
        width: _widgetSize.getResponsiveWidth(1, 1, 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                color: Theme.of(context).shadowColor,
                width: _widgetSize.getResponsiveWidth(1, 1, 1),
                padding: EdgeInsets.fromLTRB(
                    _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),
                child: Text(
                  'Recommended',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: _deviceDetails.getTitleFontSize(),
                  ),
                ),
              ),
            ),

            /// Content
            if (randomProducts.length != 0)
              Container(
                width: _widgetSize.getResponsiveWidth(1, 1, 1),
                // height: boxHeight, <--- Set the Grid Height
                child: GridView.builder(
                  // primary: false,
                  shrinkWrap: true,
                  physics: new NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 0.9, // <-- View port of each child
                    crossAxisCount: 2, // <-- Set the Column No
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 15,
                  ),
                  controller: _scrollController,
                  scrollDirection: Axis.vertical,
                  itemCount: randomProducts.length,
                  itemBuilder: (context, index) {
                    /// Assign Data
                    randomProductsMapDATA =
                        randomProducts[index].data() as Map<String, dynamic>;

                    return InkWell(
                      onTap: () {
                        if (randomProductsMapDATA?["Product_ID"] != null) {
                          if (randomProductsMapDATA?["Product_ID"] != "") {
                            /// Store Image URL
                            List<String> urlListData = [];
                            if (randomProductsMapDATA?[
                                    "Product_Images_Object"] !=
                                null) {
                              for (int i = 0;
                                  i <
                                      randomProductsMapDATA?[
                                              "Product_Images_Object"]
                                          .length;
                                  ++i) {
                                urlListData.add(randomProductsMapDATA?[
                                    "Product_Images_Object"][i]["url"]);
                              }
                            }

                            ProductDetailsArgument arg = ProductDetailsArgument(
                              userPosition: userPosition,
                              productBaseID:
                                  randomProductsMapDATA?["Product_ID_Base"],
                              priceString:
                                  randomProductsMapDATA?["Final_Price"],
                              productDescription:
                                  randomProductsMapDATA?["Product_Description"],
                              productName:
                                  randomProductsMapDATA?["Product_Name"],
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
                          if (randomProductsMapDATA?["Product_Images_Object"] ==
                              null)
                            Container(
                              width: boxWidth,
                              // height: boxHeight * 0.6,
                              height: boxWidth,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black,
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: Offset(
                                        7, 5), // changes position of shadow
                                  ),
                                ],
                                image: DecorationImage(
                                  fit: BoxFit.contain,
                                  image: AssetImage(defaultImagePath),
                                ),
                                borderRadius: new BorderRadius.only(
                                  topLeft: const Radius.circular(10.0),
                                  topRight: const Radius.circular(10.0),
                                ),
                              ),
                            ),

                          /// Has Image
                          if (randomProductsMapDATA?["Product_Images_Object"] !=
                              null)
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
                                imageUrl: randomProductsMapDATA?[
                                    "Product_Images_Object"][0]["url"],
                                fit: BoxFit.contain,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  // width: 80.0,
                                  // height: 80.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black,
                                        spreadRadius: 1,
                                        blurRadius: 10,
                                        offset: Offset(
                                            7, 5), // changes position of shadow
                                      ),
                                    ],
                                    borderRadius: new BorderRadius.only(
                                      topLeft: const Radius.circular(10.0),
                                      topRight: const Radius.circular(10.0),
                                    ),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: imageProvider,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          /// Title and Text
                          Container(
                            width: boxWidth,
                            padding: EdgeInsets.fromLTRB(
                              _widgetSize.getResponsiveParentSize(
                                0.07,
                                _widgetSize.getResponsiveWidth(
                                    0.32, 0.32, 0.32),
                              ),
                              0,
                              0,
                              0,
                            ),
                            // height: boxWidth * 0.35,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: Offset(
                                      7, 5), // changes position of shadow
                                ),
                              ],
                              color: Theme.of(context).primaryColor,
                              borderRadius: new BorderRadius.only(
                                bottomLeft: const Radius.circular(10.0),
                                bottomRight: const Radius.circular(10.0),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                /// Title
                                Align(
                                  alignment: randomProductsMapDATA?[
                                              "Product_Description"] !=
                                          ''
                                      ? Alignment.bottomLeft
                                      : Alignment.centerLeft,
                                  child: Text(
                                    randomProductsMapDATA?["Product_Name"],
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

                                /// Price
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    formatCurrency
                                        .format(double.parse(
                                            randomProductsMapDATA?[
                                                "Final_Price"]))
                                        .toString(),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize:
                                          _deviceDetails.getNormalFontSize() -
                                              1,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),

                                SizedBox(height: 5),
                              ],
                            ),
                          ),
                        ],
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

            /// Spacing
            SizedBox(
              height: _widgetSize.getResponsiveHeight(0.02, 0.02, 0.02),
            ),

            if (randomProducts.length >= maxRandomCount)
              Container(
                color: Theme.of(context).shadowColor,
                width: _widgetSize.getResponsiveWidth(1, 1, 1),
                padding: EdgeInsets.fromLTRB(
                    _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),
                child: Center(
                  child: Text(
                    "--- You've reached the end ---",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: _deviceDetails.getNormalFontSize(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Section UI
  Widget getSectionUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    var mediaQuery,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          if (sectionList[i].designType == '1') {
            return DesignTypeOneEx(
              boxWidth: _widgetSize.getResponsiveWidth(
                0.27,
                0.17,
                0.12,
              ),
              boxHeight: _widgetSize.getResponsiveWidth(
                0.27,
                0.17,
                0.12,
              ),
              mediaQuery: mediaQuery,
              sectionTitle: sectionList[i].title,
              productDataList: sectionList[i].productDataList,
              branchSize: 3,
              documentLimit: 5,
              sectionDataString: '11',
              formatCurrency: formatCurrency,
              userPosition: userPosition,
              scrollController: _scrollController,
              defaultImagePath: defaultImagePath,
              widgetSize: _widgetSize,
              deviceDetails: _deviceDetails,
              enableShadow: false,
              bgColor:
                  i == 0 ? Color(0xFFE20016) : Theme.of(context).shadowColor,
              sectionTitleColor: i == 0 ? Colors.white : Colors.black,
              contentBGcolor: i == 0 ? Color(0xFFE20016) : Colors.white,
              contentColor: Colors.white,
              subContentColor: i == 0 ? Colors.white : Colors.black,
              roundedContent: false,
              hasUnderline: i == 0 ? false : true,
            );
          }

          /// Design Type 2
          else if (sectionList[i].designType == '2') {
            return DesignTypeWithContent(
              contentIsPrice: false,
              boxWidth: _widgetSize.getResponsiveWidth(
                0.27,
                0.17,
                0.12,
              ),
              boxHeight: _widgetSize.getResponsiveWidth(
                0.35,
                0.22,
                0.17,
              ),
              mediaQuery: mediaQuery,
              sectionTitle: sectionList[i].title,
              productDataList: sectionList[i].productDataList,
              branchSize: 3,
              documentLimit: 5,
              sectionDataString: '2',
              formatCurrency: formatCurrency,
              userPosition: userPosition,
              scrollController: _scrollController,
              defaultImagePath: defaultImagePath,
              widgetSize: _widgetSize,
              deviceDetails: _deviceDetails,
              enableShadow: false,
              bgColor:
                  i == 0 ? Color(0xFFE20016) : Theme.of(context).shadowColor,
              sectionTitleColor: i == 0 ? Colors.white : Colors.black,
              contentBGcolor: i == 0 ? Color(0xFFE20016) : Colors.white,
              contentColor: i == 0 ? Colors.white : Colors.black,
              subContentColor: i == 0 ? Colors.white : Colors.black,
              roundedContent: false,
              hasUnderline: i == 0 ? false : true,
              sectionIndex: i,
            );
          }

          /// Design Type 3
          else if (sectionList[i].designType == '3') {
            if (getDeviceType(mediaQuery) != DeviceScreenType.Desktop) {
              return DesignTypeWithContent(
                contentIsPrice: true,
                boxWidth: _widgetSize.getResponsiveWidth(
                  0.27,
                  0.15,
                  0.12,
                ),
                boxHeight: _widgetSize.getResponsiveWidth(
                  0.43,
                  0.3,
                  0.25,
                ),
                mediaQuery: mediaQuery,
                sectionTitle: sectionList[i].title,
                productDataList: sectionList[i].productDataList,
                branchSize: 3,
                documentLimit: 5,
                sectionDataString: '2',
                formatCurrency: formatCurrency,
                userPosition: userPosition,
                scrollController: _scrollController,
                defaultImagePath: defaultImagePath,
                widgetSize: _widgetSize,
                deviceDetails: _deviceDetails,
                enableShadow: false,
                bgColor:
                    i == 0 ? Color(0xFFE20016) : Theme.of(context).shadowColor,
                contentBGcolor: i == 0 ? Color(0xFFE20016) : Colors.white,
                sectionTitleColor: i == 0 ? Colors.white : Colors.black,
                contentColor: i == 0 ? Colors.white : Colors.black,
                subContentColor: i == 0 ? Colors.white : Colors.black,
                roundedContent: false,
                hasUnderline: i == 0 ? false : true,
                sectionIndex: i,
              );
            } else {
              return DesktopDesignTypeWithContent(
                contentIsPrice: true,
                boxWidth: _widgetSize.getResponsiveWidth(
                  0.27,
                  0.15,
                  0.12,
                ),
                boxHeight: _widgetSize.getResponsiveWidth(
                  0.43,
                  0.3,
                  0.25,
                ),
                mediaQuery: mediaQuery,
                sectionTitle: sectionList[i].title,
                productDataList: sectionList[i].productDataList,
                branchSize: 3,
                documentLimit: 5,
                sectionDataString: '2',
                formatCurrency: formatCurrency,
                userPosition: userPosition,
                scrollController: _scrollController,
                defaultImagePath: defaultImagePath,
                widgetSize: _widgetSize,
                deviceDetails: _deviceDetails,
                enableShadow: false,
                bgColor: i == 0 ? Colors.black : Theme.of(context).shadowColor,
                contentBGcolor: i == 0 ? Colors.black : Colors.white,
                sectionTitleColor: i == 0 ? Colors.orange : Colors.orange,
                contentColor: i == 0 ? Colors.white : Colors.black,
                subContentColor: i == 0 ? Colors.orange : Colors.black,
                roundedContent: false,
                hasUnderline: i == 0 ? false : true,
                sectionIndex: i,
              );
            }
          }

          return SizedBox();
        },
        childCount: sectionList.length,
      ),
    );
  }

  /// Slideshow Image
  Widget getSlideshowImage(
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
  ) {
    double boxHeight = _widgetSize.getResponsiveHeight(0.27, 0.4, 0.6);
    return SizedBox(
      width: _widgetSize.getResponsiveWidth(1, 1, 1),
      height: boxHeight,
      child: Swiper(
        pagination: SwiperPagination(),
        itemCount: slideshowImageList.length,
        autoplay: true,
        controller: SwiperController(),
        loop: false,
        viewportFraction: 1,
        itemBuilder: (BuildContext context, int i) {
          return SizedBox(
            width: _widgetSize.getResponsiveWidth(1, 1, 1),
            height: boxHeight,
            child: FittedBox(
              fit: BoxFit.fill,
              child: CachedNetworkImage(
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey,
                  child: Column(
                    children: [
                      Icon(
                        Icons.error,
                        color: Theme.of(context).primaryColor,
                        size: _widgetSize.getResponsiveWidth(1, 1, 1) / 2,
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
                imageUrl: slideshowImageList[i].image_url != null
                    ? slideshowImageList[i].image_url.toString()
                    : 'https://st3.depositphotos.com/23594922/31822/v/600/depositphotos_318221368-stock-illustration-missing-picture-page-for-website.jpg',
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
  // endregion

  // region Query
  /// Get Section Data
  void getSectionData() async {
    if (this.mounted) {
      sectionIsLoading = true;
      setState(() {});
    }
    print("***************************");
    print("Is Calling Section Query");

    QuerySnapshot querySnapshot;

    querySnapshot = await firestore
        .collection('Section')
        .where("Enable_Section", isEqualTo: true)
        .where("Display", isEqualTo: 'home')
        .orderBy('Position', descending: false)
        .get();

    print("Section Length: " + querySnapshot.docs.length.toString());

    if (querySnapshot.docs.length == 0) {
      if (this.mounted) {
        sectionIsLoading = false;
        setState(() {});
        return;
      }
    }

    /// Define Temp Map Data
    Map<String, dynamic>? tempMapData = Map<String, dynamic>();

    /// Define Temp Map Data
    Map<String, dynamic>? productTMPMapData = Map<String, dynamic>();

    for (int i = 0; i < querySnapshot.docs.length; ++i) {
      DocumentSnapshot currentSection = querySnapshot.docs[i];

      /// Assign Data
      tempMapData = currentSection.data() as Map<String, dynamic>;

      if (tempMapData['Deleted_Status'] != 'Deleted') {
        if (tempMapData["Product_ID"] != null) {
          List<ProductDetailsArgument> productList = [];

          /// Loop each section product
          for (int j = 0; j < tempMapData["Product_ID"].length; ++j) {
            QuerySnapshot productSnapshot;

            /// This Query will return 1 document
            productSnapshot = await firestore
                .collection('Products')
                .where("Product_ID", isEqualTo: tempMapData["Product_ID"][j])
                .where("Product_Is_Published", isEqualTo: "1")
                .where("Product_Visibility", isEqualTo: "Published")
                .get();

            if (productSnapshot.docs.length > 0) {
              /// Check if data exist
              if (productSnapshot.docs[0].exists == true) {
                print(
                  "[${tempMapData["Section_Name"]}] Has Product: " +
                      tempMapData["Product_ID"][j],
                );
                DocumentSnapshot productData = productSnapshot.docs[0];

                /// Assign Data
                productTMPMapData = productData.data() as Map<String, dynamic>;

                // region Product Data
                /// Product Image
                List<String> urlListData = <String>[];

                if (productTMPMapData["Product_Images_Object"] != null) {
                  for (int index = 0;
                      index < productTMPMapData["Product_Images_Object"].length;
                      ++index) {
                    urlListData.add(productTMPMapData["Product_Images_Object"]
                        [index]["url"]);
                  }

                  print(urlListData[0]);
                }

                ProductDetailsArgument data = new ProductDetailsArgument(
                  urlList: urlListData,
                  priceString: productTMPMapData["Final_Price"],
                  productBaseID: productTMPMapData['Product_ID_Base'],
                  productDescription: productTMPMapData["Product_Description"],
                  productDescriptionHTML:
                      productTMPMapData["Product_Body_HTML"],
                  productName: productTMPMapData["Product_Name"],
                  userPosition: userPosition,
                  bottomAppBarState: widget.bottomAppBarState,
                );

                /// Add to Product List
                productList.add(data);
                // endregion
              }
            }

            /// Reach Last Index of Product
            if (j == tempMapData["Product_ID"].length - 1) {
              ProductSection sectionData = ProductSection(
                title: tempMapData["Section_Name"],
                productDataList: productList,
                designType: tempMapData["Design_Type"] != null
                    ? tempMapData["Design_Type"]
                    : "2",
              );

              if (productList != null) {
                if (productList.length > 0) {
                  /// Add to Section List
                  sectionList.add(sectionData);
                  print("Added Section: " + currentSection.id.toString());
                }
              }
            }
          }
        }
      }
    }

    if (this.mounted) {
      sectionIsLoading = false;
      setState(() {});
    }
  }

  // region Get Random Document
  /// For Random Number
  String getRandomGeneratedIdEx() {
    Random random = new Random();

    /// Randomize the number for first time
    int randomNumber = random.nextInt(highestPBase) + lowestPBase;
    // print("Highest: " + highestPBase.toString());
    // print("Lowest: " + lowestPBase.toString());
    return randomNumber.toString();
  }

  /// Get Init Random Data
  void getInitRandomData(int targetLength) async {
    /// Create a temporary List
    List<DocumentSnapshot> tempRandomProducts = <DocumentSnapshot>[];

    /// Define Temp Map Data
    Map<String, dynamic>? tempMapData = Map<String, dynamic>();

    /// If empty or smaller = Call again
    while (tempRandomProducts.length < targetLength) {
      /// Generate index
      String _randomIndex = getRandomGeneratedIdEx();

      print("Random index: " + _randomIndex);
      if (!randomProductsMap.containsKey(_randomIndex)) {
        /// Get 1 document
        QuerySnapshot querySnapshot = await firestore
            .collection('Products')
            .where("Product_Is_Published", isEqualTo: "1")
            .where("Product_Visibility", isEqualTo: "Published")
            // .where('Product_ID_Base', isEqualTo: _randomIndex)
            .where('Product_ID_Base', isGreaterThanOrEqualTo: _randomIndex)
            .orderBy('Product_ID_Base', descending: false)
            .limit(1)
            .get();

        if (querySnapshot.docs.length > 0) {
          DocumentSnapshot targetDoc = querySnapshot.docs[0];

          /// Assign Data
          tempMapData = targetDoc.data() as Map<String, dynamic>;

          String targetBase = tempMapData['Product_ID_Base'];

          /// Ensure Product is not recipe
          if (tempMapData['Product_Sub_Items'] == null) {
            if (!randomProductsMap.containsKey(targetBase)) {
              tempRandomProducts.add(targetDoc);
            }

            /// Add to the random index
            Map<String, bool> temp = {
              targetBase: true,
            };
            randomProductsMap.addAll(temp);
          }
        }
      } else {
        /// Add to the random index
        Map<String, bool> temp = {
          _randomIndex: true,
        };
        randomProductsMap.addAll(temp);
      }
    }

    print("***** Random Product **************");

    /// Define Temp Map Data
    Map<String, dynamic>? tempRPapData = Map<String, dynamic>();

    /// Add temp to actual random product list
    for (int i = 0; i < tempRandomProducts.length; ++i) {
      /// Assign Data
      tempRPapData = tempRandomProducts[i].data() as Map<String, dynamic>;

      print("Random Product[${tempRPapData['Product_ID_Base']}]");
      randomProducts.add(tempRandomProducts[i]);
    }

    if (this.mounted) {
      setState(() {
        randomIsLoading = false;
      });
    }
  }

  /// Get Random Data
  void getRandomData(int targetLength) async {
    if (randomProducts.length >= maxRandomCount) {
      print("Reached Max");
      return;
    }

    if (randomIsLoading) {
      return;
    }

    /// Begin Here
    if (this.mounted) {
      setState(() {
        randomIsLoading = true;
      });
    }

    /// Create a temporary List
    List<DocumentSnapshot> tempRandomProducts = <DocumentSnapshot>[];

    /// Define Temp Map Data
    Map<String, dynamic>? tempMapData = Map<String, dynamic>();

    /// If empty or smaller = Call again
    while (tempRandomProducts.length < targetLength) {
      /// Generate index
      String _randomIndex = getRandomGeneratedIdEx();

      // print("Random index: " + _randomIndex);
      if (!randomProductsMap.containsKey(_randomIndex)) {
        /// Get 1 document
        QuerySnapshot querySnapshot = await firestore
            .collection('Products')
            .where("Product_Is_Published", isEqualTo: "1")
            .where("Product_Visibility", isEqualTo: "Published")
            // .where('Product_ID_Base', isEqualTo: _randomIndex)
            .where('Product_ID_Base', isGreaterThanOrEqualTo: _randomIndex)
            .orderBy('Product_ID_Base', descending: false)
            .limit(1)
            .get();

        if (querySnapshot.docs.length > 0) {
          DocumentSnapshot targetDoc = querySnapshot.docs[0];

          /// Assign Data
          tempMapData = targetDoc.data() as Map<String, dynamic>;
          String targetBase = tempMapData['Product_ID_Base'];

          /// Ensure Product is not recipe
          if (tempMapData['Product_Sub_Items'] == null) {
            if (!randomProductsMap.containsKey(targetBase)) {
              tempRandomProducts.add(targetDoc);
            }

            /// Add to the random index
            Map<String, bool> temp = {
              targetBase: true,
            };
            randomProductsMap.addAll(temp);
          }
        }
      } else {
        /// Add to the random index
        Map<String, bool> temp = {
          _randomIndex: true,
        };
        randomProductsMap.addAll(temp);
      }
    }

    print("***** Random Product **************");

    /// Define Temp Map Data
    Map<String, dynamic>? tempRPapData = Map<String, dynamic>();

    /// Add temp to actual random product list
    for (int i = 0; i < tempRandomProducts.length; ++i) {
      /// Assign Data
      tempRPapData = tempRandomProducts[i].data() as Map<String, dynamic>;
      print("Random Product Added[${tempRPapData['Product_ID_Base']}]");
      randomProducts.add(tempRandomProducts[i]);
    }

    if (this.mounted) {
      setState(() {
        randomIsLoading = false;
      });
    }
  }
  // endregion

  /// Get Slideshow Data
  void getSlideshowData() async {
    print("Get Slideshow Image ================");
    DocumentSnapshot document;
    document =
        await firestore.collection('TemplateDesignCustomize').doc('Web').get();

    /// Define Map Data
    Map<String, dynamic> data = Map<String, dynamic>();

    /// Assign Data
    data = document.data() as Map<String, dynamic>;

    /// - If data found
    if (data["Image"] != null) {
      print("Has Slideshow Image ================");
      if (data["Image"].length > 0) {
        SlideshowImageClass temp = SlideshowImageClass();
        for (int i = 0; i < data["Image"].length; ++i) {
          temp = SlideshowImageClass(
            id: data['Image'][i]['id'],
            image_url: data['Image'][i]['image_url'],
            redirection: data['Image'][i]['redirection'],
          );
          slideshowImageList.add(temp);

          if (slideshowImageList[i].id != null) {
            print(
              "SlideshowImage [${slideshowImageList[i].id.toString()}]: " +
                  slideshowImageList[i].image_url.toString(),
            );
          }
          if (i == data["Image"].length - 1) {
            if (this.mounted) {
              setState(() {});
            }
          }
        }
      }
    } else {
      print("No Slideshow Image Found");
    }
  }

  /// Get Comments Data
  void getCommentsData() async {
    DocumentSnapshot document;
    document =
        await firestore.collection('TemplateDesignCustomize').doc('Web').get();

    /// Define Map Data
    Map<String, dynamic> data = Map<String, dynamic>();

    /// Assign Data
    data = document.data() as Map<String, dynamic>;

    /// - If data found
    if (data["Comments"] != null) {
      print("Has Comments ===================");
      if (data["Comments"].length > 0) {
        CommentClass temp = CommentClass();
        for (int i = 0; i < data["Comments"].length; ++i) {
          temp = CommentClass(
            id: data['Comments'][i]['id'],
            image_url: data['Comments'][i]['image_url'],
            name: data['Comments'][i]['name'],
            rating: data['Comments'][i]['rating'],
            title: data['Comments'][i]['title'],
            value: data['Comments'][i]['value'],
          );
          commentList.add(temp);

          if (commentList[i].id != null) {
            print(
              "Comment [${commentList[i].id.toString()}]: " +
                  commentList[i].value.toString(),
            );
          }

          if (i == data["Comments"].length - 1) {
            setState(() {});
          }
        }
      }
    } else {
      print("No Comments Found");
    }
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);
    var mediaQuery = MediaQuery.of(context);

    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.red,
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       PageTransition(
      //         type: PageTransitionType.rightToLeft,
      //         child: CartPage(
      //           bottomAppBarState: widget.bottomAppBarState,
      //         ),
      //       ),
      //     );
      //   },
      //   child: Stack(
      //     children: <Widget>[
      //       Align(
      //         alignment: Alignment.center,
      //         child: Icon(
      //           Icons.shopping_cart,
      //           color: Theme.of(context).primaryColorLight,
      //         ),
      //       ),
      //
      //       /// Cart Quantity
      //       if (StaticData.cartQuantity > 0 && StaticData.cartQuantity < 100)
      //         Positioned(
      //           right: 0,
      //           // bottom: 5,
      //           child: Material(
      //             elevation: 20,
      //             shadowColor: Colors.black,
      //             borderRadius: BorderRadius.circular(6),
      //             child: Container(
      //               padding: EdgeInsets.all(1),
      //               decoration: new BoxDecoration(
      //                 border: Border.all(
      //                   color: Theme.of(context).primaryColorLight,
      //                   width: 1.2,
      //                 ),
      //                 color: Colors.red,
      //                 borderRadius: BorderRadius.circular(6),
      //               ),
      //               constraints: BoxConstraints(
      //                 minWidth: 12,
      //                 minHeight: 12,
      //               ),
      //               child: Padding(
      //                 padding: EdgeInsets.fromLTRB(2.0, 0, 2, 0),
      //                 child: Text(
      //                   '${StaticData.cartQuantity.toString()}',
      //                   // '${cartQuantity.toString()}',
      //                   style: new TextStyle(
      //                     color: Theme.of(context).primaryColorLight,
      //                     fontSize: _deviceDetails.getNormalFontSize() - 2,
      //                     fontWeight: FontWeight.w600,
      //                   ),
      //                   textAlign: TextAlign.center,
      //                 ),
      //               ),
      //             ),
      //           ),
      //         ),
      //       if (StaticData.cartQuantity >= 100)
      //         Positioned(
      //           right: 0,
      //           // bottom: 5,
      //           child: Material(
      //             elevation: 20,
      //             shadowColor: Colors.black,
      //             borderRadius: BorderRadius.circular(6),
      //             child: new Container(
      //               padding: EdgeInsets.all(1),
      //               decoration: new BoxDecoration(
      //                 border: Border.all(
      //                   color: Theme.of(context).primaryColorLight,
      //                   width: 1.2,
      //                 ),
      //                 color: Colors.red,
      //                 borderRadius: BorderRadius.circular(6),
      //               ),
      //               constraints: BoxConstraints(
      //                 minWidth: 12,
      //                 minHeight: 12,
      //               ),
      //               child: Padding(
      //                 padding: EdgeInsets.fromLTRB(2.0, 0, 2, 0),
      //                 child: Text(
      //                   "99+",
      //                   style: TextStyle(
      //                     color: Theme.of(context).primaryColorLight,
      //                     fontSize: _deviceDetails.getNormalFontSize() - 2,
      //                     fontWeight: FontWeight.w600,
      //                   ),
      //                   textAlign: TextAlign.center,
      //                 ),
      //               ),
      //             ),
      //           ),
      //         )
      //     ],
      //   ),
      // ),
      backgroundColor: Theme.of(context).backgroundColor,
      drawer: kIsWeb == true
          ? WebDrawer(
              bottomAppBarState: widget.bottomAppBarState,
            )
          : null,
      body: getDeviceType(mediaQuery) == DeviceScreenType.Desktop
          ?

          /// Desktop
          WebDesktopLayout(
              noCategories: true,
              content: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  /// Slide Show Image
                  if (slideshowImageList.length > 0)
                    SliverToBoxAdapter(
                      child: getSlideshowImage(_widgetSize, _deviceDetails),
                    ),

                  /// Spacing
                  //if (slideshowImageList.length > 0)
                  //SliverToBoxAdapter(child: SizedBox(height: 10)),

                  /// Section UI
                  getSectionUI(_deviceDetails, _widgetSize, mediaQuery),

                  /// If Section is Loading
                  if (sectionIsLoading == true)
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                              0,
                              0,
                              _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
                            ),
                            child: Container(
                              width:
                                  _widgetSize.getResponsiveWidth(0.3, 0.3, 0.3),
                              height: _widgetSize.getResponsiveHeight(
                                  0.05, 0.05, 0.05),
                              color: Theme.of(context).shadowColor,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                              0,
                              0,
                              _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
                            ),
                            child: Container(
                              width:
                                  _widgetSize.getResponsiveWidth(0.9, 0.9, 0.9),
                              height: _widgetSize.getResponsiveHeight(
                                  0.1, 0.1, 0.1),
                              color: Theme.of(context).shadowColor,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                              0,
                              0,
                              _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
                            ),
                            child: Container(
                              width:
                                  _widgetSize.getResponsiveWidth(0.3, 0.3, 0.3),
                              height: _widgetSize.getResponsiveHeight(
                                  0.05, 0.05, 0.05),
                              color: Theme.of(context).shadowColor,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                              0,
                              0,
                              _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
                            ),
                            child: Container(
                              width:
                                  _widgetSize.getResponsiveWidth(0.9, 0.9, 0.9),
                              height: _widgetSize.getResponsiveHeight(
                                  0.1, 0.1, 0.1),
                              color: Theme.of(context).shadowColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                  /// Comment UI
                  if (commentList.length > 0)
                    SliverToBoxAdapter(
                      child: CommentUI(
                        sectionTitle: 'Testimonal'.toUpperCase(),
                        dataList: commentList,
                        scrollController: _scrollController,
                        defaultImagePath: defaultImagePath,
                        widgetSize: _widgetSize,
                        deviceDetails: _deviceDetails,
                        boxWidth: _widgetSize.getResponsiveWidth(
                          0.27,
                          0.17,
                          0.12,
                        ),
                        boxHeight: _widgetSize.getResponsiveWidth(
                          0.32,
                          0.22,
                          0.17,
                        ),
                        enableShadow: true,
                        bgColor: Theme.of(context).shadowColor,
                        contentBGcolor: Colors.white,
                        sectionTitleColor: Theme.of(context).highlightColor,
                        contentColor: Colors.black,
                        subContentColor: Colors.black,
                        roundedContent: false,
                      ),
                    ),

                  ///Footer
                  getFooterUI(_widgetSize, _deviceDetails),
                ],
              ),
              bottomAppBarState: widget.bottomAppBarState,
              widgetSize: _widgetSize,
              deviceDetails: _deviceDetails,
            )
          :

          /// Other Device
          SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                  minWidth: MediaQuery.of(context).size.width,
                ),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                      getRandomData(2);
                    }
                    return false;
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    // slivers: getContentUI(_deviceDetails, _widgetSize),
                    slivers: [
                      /// App Bar
                      SliverToBoxAdapter(
                        child: _getCustomAppBarSliver(
                          _deviceDetails,
                          _widgetSize,
                          context,
                        ),
                      ),

                      /// Search Bar
                      SliverAppBar(
                        snap: true,
                        floating: true,
                        pinned: true,
                        toolbarHeight:
                            _widgetSize.getResponsiveHeight(0.07, 0.07, 0.07),
                        expandedHeight:
                            _widgetSize.getResponsiveHeight(0.07, 0.07, 0.07),
                        flexibleSpace: _getCustomSearchBar(
                          _deviceDetails,
                          _widgetSize,
                          context,
                        ),
                        automaticallyImplyLeading: false,

                        /// Your Search Bar UI
                      ),

                      /// Point and Wallet UI
                      SliverToBoxAdapter(
                        child: HomeProfileWalletUI(
                          deviceDetails: _deviceDetails,
                          widgetSize: _widgetSize,
                          formatCurrency: formatCurrency,
                        ),
                      ),

                      /// Categories UI
                      SliverToBoxAdapter(
                        child: CategoriesEXUI(
                          column: 4,
                          maxItem: 4,
                          enableMoreIcon: false,
                          viewPort: 1,
                          backgroundColor: Theme.of(context).shadowColor,
                          deviceDetails: _deviceDetails,
                          widgetSize: _widgetSize,
                          userPosition: userPosition,
                          bottomAppBarState: widget.bottomAppBarState,
                        ),
                      ),

                      SliverToBoxAdapter(child: SizedBox(height: 10)),

                      /// Section UI
                      getSectionUI(_deviceDetails, _widgetSize, mediaQuery),

                      /// If Section is Loading
                      if (sectionIsLoading == true)
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  _widgetSize.getResponsiveWidth(
                                      0.05, 0.05, 0.05),
                                  0,
                                  0,
                                  _widgetSize.getResponsiveWidth(
                                      0.03, 0.03, 0.03),
                                ),
                                child: Container(
                                  width: _widgetSize.getResponsiveWidth(
                                      0.3, 0.3, 0.3),
                                  height: _widgetSize.getResponsiveHeight(
                                      0.05, 0.05, 0.05),
                                  color: Theme.of(context).shadowColor,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  _widgetSize.getResponsiveWidth(
                                      0.05, 0.05, 0.05),
                                  0,
                                  0,
                                  _widgetSize.getResponsiveWidth(
                                      0.03, 0.03, 0.03),
                                ),
                                child: Container(
                                  width: _widgetSize.getResponsiveWidth(
                                      0.9, 0.9, 0.9),
                                  height: _widgetSize.getResponsiveHeight(
                                      0.1, 0.1, 0.1),
                                  color: Theme.of(context).shadowColor,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  _widgetSize.getResponsiveWidth(
                                      0.05, 0.05, 0.05),
                                  0,
                                  0,
                                  _widgetSize.getResponsiveWidth(
                                      0.03, 0.03, 0.03),
                                ),
                                child: Container(
                                  width: _widgetSize.getResponsiveWidth(
                                      0.3, 0.3, 0.3),
                                  height: _widgetSize.getResponsiveHeight(
                                      0.05, 0.05, 0.05),
                                  color: Theme.of(context).shadowColor,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  _widgetSize.getResponsiveWidth(
                                      0.05, 0.05, 0.05),
                                  0,
                                  0,
                                  _widgetSize.getResponsiveWidth(
                                      0.03, 0.03, 0.03),
                                ),
                                child: Container(
                                  width: _widgetSize.getResponsiveWidth(
                                      0.9, 0.9, 0.9),
                                  height: _widgetSize.getResponsiveHeight(
                                      0.1, 0.1, 0.1),
                                  color: Theme.of(context).shadowColor,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  _widgetSize.getResponsiveWidth(
                                      0.05, 0.05, 0.05),
                                  0,
                                  0,
                                  _widgetSize.getResponsiveWidth(
                                      0.03, 0.03, 0.03),
                                ),
                                child: Container(
                                  width: _widgetSize.getResponsiveWidth(
                                      0.3, 0.3, 0.3),
                                  height: _widgetSize.getResponsiveHeight(
                                      0.05, 0.05, 0.05),
                                  color: Theme.of(context).shadowColor,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  _widgetSize.getResponsiveWidth(
                                      0.05, 0.05, 0.05),
                                  0,
                                  0,
                                  _widgetSize.getResponsiveWidth(
                                      0.03, 0.03, 0.03),
                                ),
                                child: Container(
                                  width: _widgetSize.getResponsiveWidth(
                                      0.9, 0.9, 0.9),
                                  height: _widgetSize.getResponsiveHeight(
                                      0.1, 0.1, 0.1),
                                  color: Theme.of(context).shadowColor,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  _widgetSize.getResponsiveWidth(
                                      0.05, 0.05, 0.05),
                                  0,
                                  0,
                                  _widgetSize.getResponsiveWidth(
                                      0.03, 0.03, 0.03),
                                ),
                                child: Container(
                                  width: _widgetSize.getResponsiveWidth(
                                      0.3, 0.3, 0.3),
                                  height: _widgetSize.getResponsiveHeight(
                                      0.05, 0.05, 0.05),
                                  color: Theme.of(context).shadowColor,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  _widgetSize.getResponsiveWidth(
                                      0.05, 0.05, 0.05),
                                  0,
                                  0,
                                  _widgetSize.getResponsiveWidth(
                                      0.03, 0.03, 0.03),
                                ),
                                child: Container(
                                  width: _widgetSize.getResponsiveWidth(
                                      0.9, 0.9, 0.9),
                                  height: _widgetSize.getResponsiveHeight(
                                      0.1, 0.1, 0.1),
                                  color: Theme.of(context).shadowColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                      SliverToBoxAdapter(
                        child: Container(
                          color: Color(0xFFE20016),
                          width: _widgetSize.getResponsiveWidth(1, 1, 1),
                          padding: EdgeInsets.fromLTRB(
                            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                            10,
                            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                            10,
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'TIMOTI(M)Sdn.Bhd. (1299024-U) \n\nNo. 20B, Jalan Psj 1/31, 46000 Selangor, Petaling Jaya, Malaysia',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      /// Random Products
                      // if (randomProducts.length > 0)
                      //   SliverToBoxAdapter(
                      //     child: randomDesign(
                      //       _widgetSize,
                      //       _deviceDetails,
                      //       _widgetSize.getResponsiveWidth(0.45, 0.45, 0.45),
                      //     ),
                      //   ),
                      //
                      // /// If random data is loading
                      // if (randomIsLoading == true)
                      //   SliverToBoxAdapter(
                      //     child: Padding(
                      //       padding: EdgeInsets.fromLTRB(
                      //           _widgetSize.getResponsiveWidth(0.48, 0.48, 0.48),
                      //           0,
                      //           _widgetSize.getResponsiveWidth(0.45, 0.45, 0.45),
                      //           0),
                      //       child: FittedBox(child: CustomLoading()),
                      //     ),
                      //   ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

// region Point And Wallet UI
class HomeProfileWalletUI extends StatefulWidget {
  final WidgetSizeCalculation widgetSize;
  final DeviceDetails deviceDetails;
  final NumberFormat formatCurrency;

  HomeProfileWalletUI({
    required this.widgetSize,
    required this.deviceDetails,
    required this.formatCurrency,
  });

  @override
  _HomeProfileWalletUIState createState() => _HomeProfileWalletUIState();
}

class _HomeProfileWalletUIState extends State<HomeProfileWalletUI> {
  String pointString = '0';
  String walletAmount = "0";

  void initState() {
    getWalletAmountInit();
    super.initState();
  }

  Widget getPointWalletUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    var mediaQuery,
  ) {
    BorderSide borderSide = BorderSide(
      width: getDeviceType(mediaQuery) == DeviceScreenType.Mobile ? 0.7 : 0.8,
      color: Theme.of(context).dividerColor,
    );
    SizedBox spacing = SizedBox(height: 10);
    double iconSize = _widgetSize.getResponsiveWidth(0.07, 0.07, 0);

    return SizedBox(
      // height: _widgetSize.getResponsiveHeight(0.08, 0.08, 0.05),
      width: _widgetSize.getResponsiveWidth(1, 1, 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          /// Point text
          Expanded(
            child: Ink(
              decoration: BoxDecoration(
                color: Theme.of(context).shadowColor,
                border: Border(
                  top: borderSide,
                  right: borderSide,
                  bottom: borderSide,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Spacing top
                  spacing,

                  /// Point Icon + Text
                  Row(
                    children: [
                      /// Point Icon,
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          _widgetSize.getResponsiveWidth(0.1, 0.1, 0),
                          0,
                          8,
                          0,
                        ),
                        child: Icon(
                          Icons.stars,
                          color: Colors.black,
                          size: iconSize,
                        ),
                      ),

                      /// Point Text
                      AutoSizeText(
                        pointString != ''
                            ? pointString + " Points"
                            : "0 Points",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: getDeviceType(mediaQuery) ==
                                  DeviceScreenType.Mobile
                              ? _deviceDetails.getNormalFontSize()
                              : _deviceDetails.getNormalFontSize(),
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),

                  /// Spacing bottom
                  spacing,
                ],
              ),
            ),
          ),

          /// Wallet Balance text
          Expanded(
            child: Ink(
              decoration: BoxDecoration(
                color: Theme.of(context).shadowColor,
                border: Border(
                  top: borderSide,
                  bottom: borderSide,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Spacing top
                  spacing,

                  /// Wallet icon + text
                  Row(
                    children: [
                      /// Wallet icon
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          _widgetSize.getResponsiveWidth(0.1, 0.1, 0),
                          0,
                          8,
                          0,
                        ),
                        child: Icon(
                          Icons.attach_money,
                          color: Colors.black,
                          size: iconSize,
                        ),
                      ),

                      /// Wallet Balance
                      AutoSizeText(
                        walletAmount != null
                            ? widget.formatCurrency
                                .format(double.parse(walletAmount))
                                .toString()
                            : 0.toStringAsFixed(2),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: getDeviceType(mediaQuery) ==
                                  DeviceScreenType.Mobile
                              ? _deviceDetails.getNormalFontSize()
                              : _deviceDetails.getNormalFontSize(),
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),

                  /// Spacing bottom
                  spacing,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get Wallet Amount In Real Time Update
  void getWalletAmountInit() async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      walletAmount = "0.00";
      if (this.mounted) {
        setState(() {});
      }
    } else {
      /// Guest
      if (firebaseUser.isAnonymous == true) {
        walletAmount = "0.00";
        if (this.mounted) {
          setState(() {});
        }
      }

      /// Non Guest
      else {
        /// Define Temp Map Data
        Map<String, dynamic>? tempMapData = Map<String, dynamic>();

        FirebaseFirestore.instance
            .collection("Customers")
            .doc(firebaseUser.uid)
            .snapshots()
            .listen((value) {
          /// Assign Data
          tempMapData = value.data() as Map<String, dynamic>;

          if (tempMapData?["walletAmount"] != null) {
            if (tempMapData?["walletAmount"] != '') {
              walletAmount = tempMapData?["walletAmount"];
              if (this.mounted) {
                setState(() {});
              }
            }
          } else {
            walletAmount = '0';
            if (this.mounted) {
              setState(() {});
            }
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);

    return getPointWalletUI(
      widget.deviceDetails,
      widget.widgetSize,
      mediaQuery,
    );
  }
}
// endregion

// region Categories UI
class CategoriesEXUI extends StatefulWidget {
  final WidgetSizeCalculation widgetSize;
  final DeviceDetails deviceDetails;
  final Position? userPosition;
  final int column;
  final int maxItem;
  final BottomAppBarState bottomAppBarState;
  final bool enableMoreIcon;
  final Color? backgroundColor;
  final double viewPort;

  CategoriesEXUI({
    required this.widgetSize,
    required this.deviceDetails,
    this.userPosition,
    required this.column,
    required this.maxItem,
    required this.bottomAppBarState,
    required this.enableMoreIcon,
    this.backgroundColor,
    required this.viewPort,
  });

  @override
  _CategoriesEXUIState createState() => _CategoriesEXUIState();
}

class _CategoriesEXUIState extends State<CategoriesEXUI> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  int currentMaxCount = 0;
  bool loaded = false;

  @override
  void initState() {
    if (StaticData.categoryList.length == 0) {
      getData();
    } else {
      print("No need call data");
      print("StaticData.iconOnlyList Length: " +
          StaticData.iconOnlyList.length.toString());
      calculateMaxCount();
    }
    super.initState();
  }

  /// Bottom Sheet UI
  void bottomSheetUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          height: _widgetSize.getResponsiveHeight(0.6, 0.6, 0.6),
          width: _widgetSize.getResponsiveWidth(1, 1, 1),
          color: Theme.of(context).backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: StaticData.categoryList.length,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                          _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
                          0,
                          _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
                        ),
                        child: Text(
                          "All Categories",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: _deviceDetails.getTitleFontSize(),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).shadowColor,
                          border: Border(
                            bottom: BorderSide(
                              width: 0.6,
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.fromLTRB(
                            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                            0,
                            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                            0,
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Theme.of(context).primaryColor,
                            size: _widgetSize.getResponsiveWidth(
                                0.05, 0.05, 0.05),
                          ),
                          title: Text(
                            StaticData.categoryList[i].name as String,
                            style: TextStyle(
                              fontSize: _deviceDetails.getNormalFontSize(),
                              fontWeight: FontWeight.w600,
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
                                  userPosition: widget.userPosition,
                                  appbarTitle:
                                      StaticData.categoryList[i].name as String,
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
                    color: Theme.of(context).shadowColor,
                    border: Border(
                      bottom: BorderSide(
                        width: 0.6,
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.fromLTRB(
                      _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                      0,
                      _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                      0,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).primaryColor,
                      size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                    ),
                    title: Text(
                      StaticData.categoryList[i].name as String,
                      style: TextStyle(
                        fontSize: _deviceDetails.getNormalFontSize(),
                        fontWeight: FontWeight.w600,
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
                            userPosition: widget.userPosition,
                            appbarTitle:
                                StaticData.categoryList[i].name as String,
                            categoryString:
                                StaticData.categoryList[i].id as String,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // region Query
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

    calculateMaxCount();

    if (this.mounted) {
      setState(() {});
    }
  }
  // endregion

  /// Calculate Current Max Count For Grid Builder Indexing
  void calculateMaxCount() {
    if (StaticData.iconOnlyList.length >= widget.maxItem) {
      currentMaxCount = widget.maxItem;
    } else {
      currentMaxCount = StaticData.iconOnlyList.length;
    }
    print("currentMaxCount: " + currentMaxCount.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          widget.widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          widget.widgetSize.getResponsiveWidth(0.01, 0.01, 0.01),
          widget.widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          3,
        ),
        child: GridView.builder(
          shrinkWrap: true,
          physics: new NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: widget.viewPort, // <-- View port of each child
            crossAxisCount: widget.column, // <-- No of Column
            crossAxisSpacing: widget.widgetSize
                .getResponsiveWidth(0.03, 0.03, 0.03), // <-- Cross Axis Spacing
            mainAxisSpacing: widget.widgetSize
                .getResponsiveWidth(0.03, 0.03, 0.03), // <-- Main Axis Spacing
          ),
          itemCount: widget.enableMoreIcon == true
              ? currentMaxCount + 1
              : StaticData.iconOnlyList.length,
          itemBuilder: (_, i) {
            /// If have error uncomment this to check
            // return Text(
            //   iconOnlyList[0].name as String,
            //   style: TextStyle(color: Colors.black),
            // );

            if (i < currentMaxCount) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: CategoryPage(
                        userPosition: widget.userPosition,
                        appbarTitle: StaticData.iconOnlyList[i].name as String,
                        categoryString: StaticData.iconOnlyList[i].id as String,
                        bottomAppBarState: widget.bottomAppBarState,
                      ),
                    ),
                  );
                },
                child: CustomIcon(
                  deviceDetails: widget.deviceDetails,
                  widgetSize: widget.widgetSize,
                  urlLink: StaticData.iconOnlyList[i].iconImage as String,
                  titleText: StaticData.iconOnlyList[i].name,
                  textColor: Theme.of(context).primaryColor,
                ),
              );
            } else {
              if (widget.enableMoreIcon == true) {
                return InkWell(
                  onTap: () {
                    bottomSheetUI(widget.deviceDetails, widget.widgetSize);
                  },
                  child: CustomIcon(
                    deviceDetails: widget.deviceDetails,
                    widgetSize: widget.widgetSize,
                    imagePath: 'assets/icon/more.png',
                    titleText: 'More',
                    textColor: Theme.of(context).primaryColor,
                  ),
                );
              }
            }
            return SizedBox();
          },
        ),
      ),
    );
  }
}
// endregion

// region Design Type One
class DesignTypeOne extends StatefulWidget {
  final ScrollController scrollController;
  final WidgetSizeCalculation widgetSize;
  final DeviceDetails deviceDetails;
  final double boxWidth;
  final NumberFormat formatCurrency;
  final Position? userPosition;
  final String sectionTitle;
  final String defaultImagePath;
  final String sectionDataString;
  final int documentLimit;
  final int branchSize;
  final List<ProductDetailsArgument> productDataList;
  final bool enableShadow;
  final Color bgColor;
  final Color sectionTitleColor;
  final Color contentColor;
  final Color subContentColor;
  final bool roundedContent;

  DesignTypeOne({
    required this.scrollController,
    required this.widgetSize,
    required this.deviceDetails,
    required this.boxWidth,
    required this.formatCurrency,
    required this.userPosition,
    required this.sectionTitle,
    required this.defaultImagePath,
    required this.sectionDataString,
    required this.documentLimit,
    required this.branchSize,
    required this.productDataList,
    required this.enableShadow,
    required this.bgColor,
    required this.sectionTitleColor,
    required this.contentColor,
    required this.subContentColor,
    required this.roundedContent,
  });

  @override
  _DesignTypeOne createState() => _DesignTypeOne();
}

class _DesignTypeOne extends State<DesignTypeOne> {
  List<DocumentSnapshot> products = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    // if (widget.documentLimit != 0 && widget.branchSize != 0) {
    //   int targetLimit = widget.documentLimit * widget.branchSize;
    //   getData(targetLimit);
    // }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Use this one
  Widget designTypeOneUIEx(
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
  ) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03)),
      child: Container(
        color: widget.bgColor,
        width: _widgetSize.getResponsiveWidth(1, 1, 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Padding(
              padding: EdgeInsets.fromLTRB(
                0,
                _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
                0,
                _widgetSize.getResponsiveWidth(0.02, 0.02, 0.01),
              ),
              child: Text(
                widget.sectionTitle,
                style: TextStyle(
                  letterSpacing: 1.2,
                  color: widget.sectionTitleColor,
                  fontWeight: FontWeight.w400,
                  fontSize: _deviceDetails.getTitleFontSize(),
                ),
              ),
            ),

            /// Underline
            Center(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: _widgetSize.getResponsiveWidth(0.02, 0.02, 0.01),
                ),
                child: UnderlineWidget(),
              ),
            ),

            /// Content
            if (widget.productDataList.length != 0)
              Padding(
                padding: EdgeInsets.only(
                    left: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),
                child: Container(
                  width: _widgetSize.getResponsiveWidth(0.9, 0.9, 0.9),
                  height: widget.boxWidth,
                  child: ListView.builder(
                    shrinkWrap: true,
                    controller: widget.scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.productDataList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                            right: _widgetSize.getResponsiveWidth(
                                0.05, 0.05, 0.05)),
                        child: SizedBox(
                          width: widget.boxWidth,
                          height: widget.boxWidth,
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                ProductDetailsPage.routeName,
                                arguments: widget.productDataList[index],
                              );
                            },
                            child: widget
                                        .productDataList[index].urlList.length <
                                    1
                                ?

                                /// No Image
                                Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black,
                                          spreadRadius: 1,
                                          blurRadius: 6,
                                          offset: Offset(
                                            7,
                                            2,
                                          ), // changes position of shadow
                                        ),
                                      ],
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      image: DecorationImage(
                                        image:
                                            AssetImage(widget.defaultImagePath),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        /// Spacing
                                        SizedBox(
                                          height:
                                              _widgetSize.getResponsiveWidth(
                                                  0.03, 0.03, 0.03),
                                        ),

                                        /// Content
                                        Container(
                                          color: Colors.red,
                                          width: widget.boxWidth / 1.3,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: _widgetSize
                                                    .getResponsiveWidth(
                                                        0.01, 0.01, 0.01)),
                                            child: Text(
                                              widget.productDataList[index]
                                                  .productName,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: _deviceDetails
                                                        .getNormalFontSize() -
                                                    3,
                                                fontWeight: FontWeight.w700,
                                                color: Theme.of(context)
                                                    .backgroundColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                :

                                /// Has Image
                                CachedNetworkImage(
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black,
                                            spreadRadius: 1,
                                            blurRadius: 6,
                                            offset: Offset(
                                              7,
                                              2,
                                            ), // changes position of shadow
                                          ),
                                        ],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.error,
                                            color:
                                                Theme.of(context).primaryColor,
                                            size: widget.boxWidth / 2,
                                          ),
                                          Text(
                                            "Can't Load Image",
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    imageUrl: widget
                                        .productDataList[index].urlList[0],
                                    fit: BoxFit.cover,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        boxShadow: widget.enableShadow == true
                                            ? [
                                                BoxShadow(
                                                  color: Colors.grey,
                                                  spreadRadius: 1,
                                                  blurRadius: 7,
                                                  offset: Offset(
                                                    2,
                                                    10,
                                                  ), // changes position of shadow
                                                ),
                                              ]
                                            : null,
                                        borderRadius:
                                            widget.roundedContent == true
                                                ? BorderRadius.all(
                                                    Radius.circular(20))
                                                : null,
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: imageProvider,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          /// Spacing
                                          SizedBox(
                                            height:
                                                _widgetSize.getResponsiveWidth(
                                                    0.03, 0.03, 0.03),
                                          ),

                                          /// Content
                                          Container(
                                            color: Colors.black,
                                            width: widget.boxWidth / 1.3,
                                            // height: boxWidth / 2.4,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: _widgetSize
                                                      .getResponsiveWidth(
                                                          0.03, 0.03, 0.03)),
                                              child: Text(
                                                widget.productDataList[index]
                                                    .productName,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: _deviceDetails
                                                      .getNormalFontSize(),
                                                  fontWeight: FontWeight.w700,
                                                  color: widget.contentColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )

            /// Loading
            else
              Padding(
                padding: EdgeInsets.only(
                    left: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),
                child: Container(
                  width: _widgetSize.getResponsiveWidth(0.9, 0.9, 0.9),
                  height: widget.boxWidth,
                  child: ListView.builder(
                    shrinkWrap: true,
                    controller: widget.scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                            right: _widgetSize.getResponsiveWidth(
                                0.05, 0.05, 0.05)),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CustomLoading(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            /// Spacing
            SizedBox(
              height: _widgetSize.getResponsiveHeight(0.02, 0.02, 0.02),
            ),
          ],
        ),
      ),
    );
  }

  // region Query
  getData(int documentLimit) async {
    print("Is Calling Type One Query");

    QuerySnapshot querySnapshot;

    /// Get Daily Product Category
    DocumentReference categoryRef = firestore
        .collection("Product_Collections")
        .doc(widget.sectionDataString);
    querySnapshot = await firestore
        .collection('Products')
        .where("Product_Is_Published", isEqualTo: "1")
        .where("Product_Collections", arrayContains: categoryRef)
        .orderBy('Product_Name', descending: false)
        .limit(documentLimit)
        .get();

    /// Define Temp Map Data
    Map<String, dynamic>? tempMapData = Map<String, dynamic>();

    for (int i = 0; i < querySnapshot.docs.length; ++i) {
      /// Assign Data
      tempMapData = querySnapshot.docs[i].data() as Map<String, dynamic>;

      if (tempMapData["Product_Is_Published"] != null) {
        if (tempMapData["Product_Is_Published"] == "1") {
          products.add(querySnapshot.docs[i]);
        }
      }
    }
    // todayProducts.addAll(querySnapshot.documents);
    final ids = products.map((e) {
      /// Define Temp Map Data
      Map<String, dynamic>? tempRPapData = Map<String, dynamic>();

      /// Assign Data
      tempRPapData = e.data() as Map<String, dynamic>;

      return tempRPapData["Product_ID_Base"];
    }).toSet();
    products.retainWhere((x) {
      /// Define Temp Map Data
      Map<String, dynamic>? tempRPapData = Map<String, dynamic>();

      /// Assign Data
      tempRPapData = x.data() as Map<String, dynamic>;
      return ids.remove(tempRPapData["Product_ID_Base"]);
    });

    if (this.mounted) {
      print("Called Length: " + products.length.toString());
      setState(() {});
    }
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    return designTypeOneUIEx(widget.widgetSize, widget.deviceDetails);
  }
}

/// Latest
class DesignTypeOneEx extends StatelessWidget {
  final bool hasUnderline;

  final ScrollController scrollController;
  final WidgetSizeCalculation widgetSize;
  final DeviceDetails deviceDetails;

  final double boxWidth;
  final double boxHeight;

  final NumberFormat formatCurrency;
  final Position? userPosition;
  final String sectionTitle;
  final String defaultImagePath;
  final String sectionDataString;
  final int documentLimit;
  final int branchSize;

  final List<ProductDetailsArgument> productDataList;
  final bool enableShadow;
  final Color bgColor;
  final Color sectionTitleColor;
  final Color contentColor;
  final Color subContentColor;
  final bool roundedContent;
  final Color contentBGcolor;
  final dynamic mediaQuery;

  DesignTypeOneEx({
    required this.hasUnderline,
    required this.scrollController,
    required this.widgetSize,
    required this.deviceDetails,
    required this.boxWidth,
    required this.boxHeight,
    required this.formatCurrency,
    this.userPosition,
    required this.sectionTitle,
    required this.defaultImagePath,
    required this.sectionDataString,
    required this.documentLimit,
    required this.branchSize,
    required this.productDataList,
    required this.enableShadow,
    required this.bgColor,
    required this.sectionTitleColor,
    required this.contentColor,
    required this.subContentColor,
    required this.roundedContent,
    required this.contentBGcolor,
    required this.mediaQuery,
  });

  @override
  Widget build(BuildContext context) {
    return SectionDesign(
      hasUnderline: hasUnderline,
      content: productDataList.length > 0
          ?

          /// Content
          Container(
              width: widgetSize.getResponsiveWidth(1, 1, 1),
              height: boxHeight,
              child: Center(
                child: ListView.builder(
                  shrinkWrap: true,
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: productDataList.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          widgetSize.getResponsiveWidth(0.05, 0.02, 0.02),
                          10,
                          0,
                          10,
                        ),
                        child: Container(
                          width: boxWidth,
                          height: boxWidth,
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                ProductDetailsPage.routeName,
                                arguments: productDataList[index],
                              );
                            },
                            child: productDataList[index].urlList.length < 1
                                ?

                                /// No Image
                                Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black,
                                          spreadRadius: 1,
                                          blurRadius: 6,
                                          offset: Offset(
                                            7,
                                            2,
                                          ), // changes position of shadow
                                        ),
                                      ],
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      image: DecorationImage(
                                        image: AssetImage(defaultImagePath),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        /// Spacing
                                        SizedBox(
                                          height: widgetSize.getResponsiveWidth(
                                              0.03, 0.03, 0.03),
                                        ),

                                        /// Content
                                        Container(
                                          color: contentBGcolor,
                                          width: boxWidth / 1.3,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: widgetSize
                                                    .getResponsiveWidth(
                                                        0.01, 0.01, 0.01)),
                                            child: Text(
                                              productDataList[index]
                                                  .productName,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: deviceDetails
                                                        .getNormalFontSize() -
                                                    3,
                                                fontWeight: FontWeight.w700,
                                                color: Theme.of(context)
                                                    .backgroundColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                :

                                /// Has Image
                                CachedNetworkImage(
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black,
                                            spreadRadius: 1,
                                            blurRadius: 6,
                                            offset: Offset(
                                              7,
                                              2,
                                            ), // changes position of shadow
                                          ),
                                        ],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.error,
                                            color:
                                                Theme.of(context).primaryColor,
                                            size: boxWidth / 2,
                                          ),
                                          Text(
                                            "Can't Load Image",
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    imageUrl: productDataList[index].urlList[0],
                                    fit: BoxFit.cover,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        boxShadow: enableShadow == true
                                            ? [
                                                BoxShadow(
                                                  color: Colors.grey,
                                                  spreadRadius: 0.5,
                                                  blurRadius: 5,
                                                  offset: Offset(
                                                    2,
                                                    10,
                                                  ), // changes position of shadow
                                                ),
                                              ]
                                            : null,
                                        borderRadius: roundedContent == true
                                            ? BorderRadius.all(
                                                Radius.circular(20))
                                            : null,
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: imageProvider,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          /// Spacing
                                          SizedBox(
                                            height: 10,
                                          ),

                                          /// Content
                                          Container(
                                            color: Colors.black,
                                            width: boxWidth / 1.3,
                                            // height: boxWidth / 2.4,
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.only(left: 10),
                                              child: Text(
                                                productDataList[index]
                                                    .productName,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: deviceDetails
                                                      .getNormalFontSize(),
                                                  fontWeight: FontWeight.w700,
                                                  color: contentColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          :

          /// Loading
          Padding(
              padding: EdgeInsets.only(
                  left: widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),
              child: Container(
                width: widgetSize.getResponsiveWidth(0.9, 0.9, 0.9),
                child: ListView.builder(
                  shrinkWrap: true,
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                          right:
                              widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),
                      child: FittedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: CustomLoading(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
      bgColor: bgColor,
      widgetSize: widgetSize,
      deviceDetails: deviceDetails,
      sectionTitle: sectionTitle,
      sectionTitleColor: sectionTitleColor,
    );
  }
}
// endregion

// region Design Type With Content
class DesignTypeWithContent extends StatelessWidget {
  final bool hasUnderline;
  final bool contentIsPrice;

  final ScrollController scrollController;
  final WidgetSizeCalculation widgetSize;
  final DeviceDetails deviceDetails;

  final double boxWidth;
  final double boxHeight;

  final NumberFormat formatCurrency;
  final Position? userPosition;
  final String sectionTitle;
  final String defaultImagePath;
  final String sectionDataString;
  final int documentLimit;
  final int branchSize;

  final List<ProductDetailsArgument> productDataList;
  final bool enableShadow;
  final Color bgColor;
  final Color sectionTitleColor;
  final Color contentColor;
  final Color subContentColor;
  final bool roundedContent;
  final Color contentBGcolor;
  final dynamic mediaQuery;
  final int sectionIndex;

  DesignTypeWithContent({
    required this.hasUnderline,
    required this.contentIsPrice,
    required this.scrollController,
    required this.widgetSize,
    required this.deviceDetails,
    required this.boxWidth,
    required this.boxHeight,
    required this.formatCurrency,
    this.userPosition,
    required this.sectionTitle,
    required this.defaultImagePath,
    required this.sectionDataString,
    required this.documentLimit,
    required this.branchSize,
    required this.productDataList,
    required this.enableShadow,
    required this.bgColor,
    required this.sectionTitleColor,
    required this.contentColor,
    required this.subContentColor,
    required this.roundedContent,
    required this.contentBGcolor,
    required this.mediaQuery,
    required this.sectionIndex,
  });

  List<Widget> getContentUI(BuildContext context) {
    List<Widget> contentList = [];

    for (int i = 0; i < productDataList.length; ++i) {
      contentList.add(
        Padding(
          padding: EdgeInsets.only(
            left: i == 0
                ? widgetSize.getResponsiveWidth(0.05, 0.05, 0.02)
                : widgetSize.getResponsiveWidth(0.03, 0.05, 0.02),
          ),
          child: Center(
            child: Container(
              width: boxWidth,
              decoration: BoxDecoration(
                boxShadow: enableShadow == true
                    ? [
                        BoxShadow(
                            blurRadius: 3,
                            color: Colors.grey,
                            spreadRadius: 0.5)
                      ]
                    : null,
                color: contentBGcolor,
                borderRadius: roundedContent == true
                    ? new BorderRadius.only(
                        bottomLeft: const Radius.circular(10.0),
                        bottomRight: const Radius.circular(10.0),
                      )
                    : null,
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    ProductDetailsPage.routeName,
                    arguments: productDataList[i],
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// Image
                    DesignTypeImage(
                      boxWidth: boxWidth,
                      flexSize: 6,
                      isCircle: false,
                      targetImageUrl: productDataList[i].urlList[0],
                    ),

                    // Spacing
                    SizedBox(height: 10),

                    /// Title
                    Align(
                      alignment: productDataList[i].productName != ''
                          ? Alignment.bottomLeft
                          : Alignment.centerLeft,
                      child: AutoSizeText(
                        productDataList[i].productName,
                        overflow: TextOverflow.ellipsis,
                        maxLines:
                            getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                                ? 1
                                : 2,
                        minFontSize: deviceDetails.getNormalFontSize() - 2,
                        style: TextStyle(
                          fontSize: deviceDetails.getNormalFontSize(),
                          fontWeight: FontWeight.w600,
                          color: contentColor,
                        ),
                      ),
                    ),

                    /// Content
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: AutoSizeText(
                          contentIsPrice == true
                              ?
                              // Price
                              'RM ' +
                                  formatCurrency.format(
                                    double.parse(
                                      productDataList[i].priceString,
                                    ),
                                  )
                              :
                              // Description
                              productDataList[i].productDescription != ''
                                  ? productDataList[i].productDescription
                                  : '',
                          maxLines: 1,
                          minFontSize: deviceDetails.getNormalFontSize(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: deviceDetails.getNormalFontSize() - 3,
                            fontWeight: FontWeight.w700,
                            color: subContentColor,
                          ),
                        ),
                      ),
                    ),

                    // Spacing
                    SizedBox(height: 10, width: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return contentList;
  }

  @override
  Widget build(BuildContext context) {
    return SectionDesign(
      hasUnderline: hasUnderline,
      content: productDataList.length > 0
          ?
          // Content (New Ver)
          Container(
              width: widgetSize.getResponsiveWidth(1, 1, 1),
              // height: boxHeight,
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  // padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  child: Row(
                    children: getContentUI(context),
                  ),
                ),
              ),
            )

          /// Content (Old Ver)
          // Container(
          //     width: widgetSize.getResponsiveWidth(1, 1, 1),
          //     height: boxHeight,
          //     child: Center(
          //       child: ListView.builder(
          //         shrinkWrap: true,
          //         controller: scrollController,
          //         scrollDirection: Axis.horizontal,
          //         itemCount: productDataList.length,
          //         itemBuilder: (context, index) {
          //           return Padding(
          //             padding: EdgeInsets.only(
          //               left: index == 0
          //                   ? widgetSize.getResponsiveWidth(0.05, 0.05, 0.02)
          //                   : widgetSize.getResponsiveWidth(0.03, 0.05, 0.02),
          //             ),
          //             child: Center(
          //               child: Container(
          //                 width: boxWidth,
          //                 // height: boxHeight / 0.7,
          //                 decoration: BoxDecoration(
          //                   boxShadow: enableShadow == true
          //                       ? [
          //                           BoxShadow(
          //                               blurRadius: 3,
          //                               color: Colors.grey,
          //                               spreadRadius: 0.5)
          //                         ]
          //                       : null,
          //                   color: contentBGcolor,
          //                   borderRadius: roundedContent == true
          //                       ? new BorderRadius.only(
          //                           bottomLeft: const Radius.circular(10.0),
          //                           bottomRight: const Radius.circular(10.0),
          //                         )
          //                       : null,
          //                 ),
          //                 child: InkWell(
          //                   onTap: () {
          //                     Navigator.pushNamed(
          //                       context,
          //                       ProductDetailsPage.routeName,
          //                       arguments: productDataList[index],
          //                     );
          //                   },
          //                   child: Column(
          //                     mainAxisAlignment: MainAxisAlignment.center,
          //                     children: [
          //                       /// Image
          //                       DesignTypeImage(
          //                         boxWidth: boxWidth,
          //                         flexSize: 6,
          //                         isCircle: false,
          //                         targetImageUrl:
          //                             productDataList[index].urlList[0],
          //                       ),
          //
          //                       // Spacing
          //                       SizedBox(height: 10),
          //
          //                       /// Title
          //                       Align(
          //                         alignment:
          //                             productDataList[index].productName != ''
          //                                 ? Alignment.bottomLeft
          //                                 : Alignment.centerLeft,
          //                         child: AutoSizeText(
          //                           productDataList[index].productName,
          //                           overflow: TextOverflow.ellipsis,
          //                           maxLines: getDeviceType(mediaQuery) ==
          //                                   DeviceScreenType.Mobile
          //                               ? 1
          //                               : 2,
          //                           minFontSize:
          //                               deviceDetails.getNormalFontSize() - 2,
          //                           style: TextStyle(
          //                             fontSize:
          //                                 deviceDetails.getNormalFontSize(),
          //                             fontWeight: FontWeight.w600,
          //                             color: contentColor,
          //                           ),
          //                         ),
          //                       ),
          //
          //                       /// Content
          //                       Padding(
          //                         padding: const EdgeInsets.only(top: 8.0),
          //                         child: Align(
          //                           alignment: Alignment.center,
          //                           child: AutoSizeText(
          //                             contentIsPrice == true
          //                                 ?
          //                                 // Price
          //                                 'RM ' +
          //                                     formatCurrency.format(
          //                                       double.parse(
          //                                         productDataList[index]
          //                                             .priceString,
          //                                       ),
          //                                     )
          //                                 :
          //                                 // Description
          //                                 productDataList[index]
          //                                             .productDescription !=
          //                                         ''
          //                                     ? productDataList[index]
          //                                         .productDescription
          //                                     : '',
          //                             maxLines: 1,
          //                             minFontSize:
          //                                 deviceDetails.getNormalFontSize(),
          //                             overflow: TextOverflow.ellipsis,
          //                             style: TextStyle(
          //                               fontSize: deviceDetails
          //                                       .getNormalFontSize() -
          //                                   3,
          //                               fontWeight: FontWeight.w700,
          //                               color: subContentColor,
          //                             ),
          //                           ),
          //                         ),
          //                       ),
          //
          //                       // Spacing
          //                       Container(
          //                         color: Colors.green,
          //                         child: SizedBox(height: 10, width: 10),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               ),
          //             ),
          //           );
          //         },
          //       ),
          //     ),
          //   )
          :

          /// Loading
          Padding(
              padding: EdgeInsets.only(
                  left: widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),
              child: Container(
                width: widgetSize.getResponsiveWidth(0.9, 0.9, 0.9),
                child: ListView.builder(
                  shrinkWrap: true,
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                          right:
                              widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),
                      child: FittedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: CustomLoading(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
      bgColor: bgColor,
      widgetSize: widgetSize,
      deviceDetails: deviceDetails,
      sectionTitle: sectionTitle,
      sectionTitleColor: sectionTitleColor,
    );
  }
}
// endregion

// region Desktop Design Type With Content
class DesktopDesignTypeWithContent extends StatelessWidget {
  final bool hasUnderline;
  final bool contentIsPrice;

  final ScrollController scrollController;
  final WidgetSizeCalculation widgetSize;
  final DeviceDetails deviceDetails;

  final double boxWidth;
  final double boxHeight;

  final NumberFormat formatCurrency;
  final Position? userPosition;
  final String sectionTitle;
  final String defaultImagePath;
  final String sectionDataString;
  final int documentLimit;
  final int branchSize;

  final List<ProductDetailsArgument> productDataList;
  final bool enableShadow;
  final Color bgColor;
  final Color sectionTitleColor;
  final Color contentColor;
  final Color subContentColor;
  final bool roundedContent;
  final Color contentBGcolor;
  final dynamic mediaQuery;
  final int sectionIndex;

  DesktopDesignTypeWithContent({
    required this.hasUnderline,
    required this.contentIsPrice,
    required this.scrollController,
    required this.widgetSize,
    required this.deviceDetails,
    required this.boxWidth,
    required this.boxHeight,
    required this.formatCurrency,
    this.userPosition,
    required this.sectionTitle,
    required this.defaultImagePath,
    required this.sectionDataString,
    required this.documentLimit,
    required this.branchSize,
    required this.productDataList,
    required this.enableShadow,
    required this.bgColor,
    required this.sectionTitleColor,
    required this.contentColor,
    required this.subContentColor,
    required this.roundedContent,
    required this.contentBGcolor,
    required this.mediaQuery,
    required this.sectionIndex,
  });

  List<Widget> getContentUI(BuildContext context) {
    List<Widget> contentList = [];
    /*contentList.add(
      Container(
        child: Column(
          children: [
            Text("test")
          ]
        )
      )
    );*/
    for (int i = 0; i < productDataList.length; ++i) {
      contentList.add(
        Padding(
          padding: EdgeInsets.only(
            left: i == 0
                ? widgetSize.getResponsiveWidth(0.05, 0.05, 0.02)
                : widgetSize.getResponsiveWidth(0.03, 0.05, 0.02),
          ),
          child: Center(
            child: Container(
              width: boxWidth,
              decoration: BoxDecoration(
                boxShadow: enableShadow == true
                    ? [
                        BoxShadow(
                            blurRadius: 3,
                            color: Colors.grey,
                            spreadRadius: 0.5)
                      ]
                    : null,
                color: contentBGcolor,
                borderRadius: roundedContent == true
                    ? new BorderRadius.only(
                        bottomLeft: const Radius.circular(10.0),
                        bottomRight: const Radius.circular(10.0),
                      )
                    : null,
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    ProductDetailsPage.routeName,
                    arguments: productDataList[i],
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// Image
                    DesignTypeImage(
                      boxWidth: boxWidth,
                      flexSize: 6,
                      isCircle: false,
                      targetImageUrl: productDataList[i].urlList[0],
                    ),

                    // Spacing
                    SizedBox(height: 10),

                    /// Title
                    Align(
                      alignment: productDataList[i].productName != ''
                          ? Alignment.bottomLeft
                          : Alignment.centerLeft,
                      child: AutoSizeText(
                        productDataList[i].productName,
                        overflow: TextOverflow.ellipsis,
                        maxLines:
                            getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                                ? 1
                                : 2,
                        //minFontSize: deviceDetails.getNormalFontSize() - 2,
                        style: TextStyle(
                          fontSize: 15, //deviceDetails.getNormalFontSize(),
                          fontWeight: FontWeight.w600,
                          color: contentColor,
                        ),
                      ),
                    ),

                    /// Content
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AutoSizeText(
                          contentIsPrice == true
                              ?
                              // Price
                              'RM ' +
                                  formatCurrency.format(
                                    double.parse(
                                      productDataList[i].priceString,
                                    ),
                                  )
                              :
                              // Description
                              productDataList[i].productDescription != ''
                                  ? productDataList[i].productDescription
                                  : '',
                          maxLines: 1,
                          minFontSize: deviceDetails.getNormalFontSize(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: deviceDetails.getNormalFontSize() - 3,
                            fontWeight: FontWeight.w700,
                            color: subContentColor,
                          ),
                        ),
                      ),
                    ),

                    // Spacing
                    SizedBox(height: 10, width: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return contentList;
  }

  @override
  Widget build(BuildContext context) {
    return SectionDesign(
      hasUnderline: hasUnderline,
      content: productDataList.length > 0
          ?
          // Content (New Ver)
          Container(
              width: widgetSize.getResponsiveWidth(1, 1, 1),
              // height: boxHeight,
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  // padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  child: Row(
                    children: getContentUI(context),
                  ),
                ),
              ),
            )

          /// Content (Old Ver)
          // Container(
          //     width: widgetSize.getResponsiveWidth(1, 1, 1),
          //     height: boxHeight,
          //     child: Center(
          //       child: ListView.builder(
          //         shrinkWrap: true,
          //         controller: scrollController,
          //         scrollDirection: Axis.horizontal,
          //         itemCount: productDataList.length,
          //         itemBuilder: (context, index) {
          //           return Padding(
          //             padding: EdgeInsets.only(
          //               left: index == 0
          //                   ? widgetSize.getResponsiveWidth(0.05, 0.05, 0.02)
          //                   : widgetSize.getResponsiveWidth(0.03, 0.05, 0.02),
          //             ),
          //             child: Center(
          //               child: Container(
          //                 width: boxWidth,
          //                 // height: boxHeight / 0.7,
          //                 decoration: BoxDecoration(
          //                   boxShadow: enableShadow == true
          //                       ? [
          //                           BoxShadow(
          //                               blurRadius: 3,
          //                               color: Colors.grey,
          //                               spreadRadius: 0.5)
          //                         ]
          //                       : null,
          //                   color: contentBGcolor,
          //                   borderRadius: roundedContent == true
          //                       ? new BorderRadius.only(
          //                           bottomLeft: const Radius.circular(10.0),
          //                           bottomRight: const Radius.circular(10.0),
          //                         )
          //                       : null,
          //                 ),
          //                 child: InkWell(
          //                   onTap: () {
          //                     Navigator.pushNamed(
          //                       context,
          //                       ProductDetailsPage.routeName,
          //                       arguments: productDataList[index],
          //                     );
          //                   },
          //                   child: Column(
          //                     mainAxisAlignment: MainAxisAlignment.center,
          //                     children: [
          //                       /// Image
          //                       DesignTypeImage(
          //                         boxWidth: boxWidth,
          //                         flexSize: 6,
          //                         isCircle: false,
          //                         targetImageUrl:
          //                             productDataList[index].urlList[0],
          //                       ),
          //
          //                       // Spacing
          //                       SizedBox(height: 10),
          //
          //                       /// Title
          //                       Align(
          //                         alignment:
          //                             productDataList[index].productName != ''
          //                                 ? Alignment.bottomLeft
          //                                 : Alignment.centerLeft,
          //                         child: AutoSizeText(
          //                           productDataList[index].productName,
          //                           overflow: TextOverflow.ellipsis,
          //                           maxLines: getDeviceType(mediaQuery) ==
          //                                   DeviceScreenType.Mobile
          //                               ? 1
          //                               : 2,
          //                           minFontSize:
          //                               deviceDetails.getNormalFontSize() - 2,
          //                           style: TextStyle(
          //                             fontSize:
          //                                 deviceDetails.getNormalFontSize(),
          //                             fontWeight: FontWeight.w600,
          //                             color: contentColor,
          //                           ),
          //                         ),
          //                       ),
          //
          //                       /// Content
          //                       Padding(
          //                         padding: const EdgeInsets.only(top: 8.0),
          //                         child: Align(
          //                           alignment: Alignment.center,
          //                           child: AutoSizeText(
          //                             contentIsPrice == true
          //                                 ?
          //                                 // Price
          //                                 'RM ' +
          //                                     formatCurrency.format(
          //                                       double.parse(
          //                                         productDataList[index]
          //                                             .priceString,
          //                                       ),
          //                                     )
          //                                 :
          //                                 // Description
          //                                 productDataList[index]
          //                                             .productDescription !=
          //                                         ''
          //                                     ? productDataList[index]
          //                                         .productDescription
          //                                     : '',
          //                             maxLines: 1,
          //                             minFontSize:
          //                                 deviceDetails.getNormalFontSize(),
          //                             overflow: TextOverflow.ellipsis,
          //                             style: TextStyle(
          //                               fontSize: deviceDetails
          //                                       .getNormalFontSize() -
          //                                   3,
          //                               fontWeight: FontWeight.w700,
          //                               color: subContentColor,
          //                             ),
          //                           ),
          //                         ),
          //                       ),
          //
          //                       // Spacing
          //                       Container(
          //                         color: Colors.green,
          //                         child: SizedBox(height: 10, width: 10),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               ),
          //             ),
          //           );
          //         },
          //       ),
          //     ),
          //   )
          :

          /// Loading
          Padding(
              padding: EdgeInsets.only(
                  left: widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),
              child: Container(
                width: widgetSize.getResponsiveWidth(0.9, 0.9, 0.9),
                child: ListView.builder(
                  shrinkWrap: true,
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                          right:
                              widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),
                      child: FittedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: CustomLoading(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
      bgColor: bgColor,
      widgetSize: widgetSize,
      deviceDetails: deviceDetails,
      sectionTitle: sectionTitle,
      sectionTitleColor: sectionTitleColor,
    );
  }
}
// endregion

class SectionDesign extends StatelessWidget {
  final String sectionTitle;
  final Color sectionTitleColor;
  final WidgetSizeCalculation widgetSize;
  final DeviceDetails deviceDetails;
  final Widget content;
  final Color bgColor;
  final bool hasUnderline;

  const SectionDesign({
    Key? key,
    required this.sectionTitle,
    required this.sectionTitleColor,
    required this.widgetSize,
    required this.deviceDetails,
    required this.content,
    required this.bgColor,
    required this.hasUnderline,
  }) : super(key: key);

  Widget designUI(
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
    BuildContext context,
  ) {
    var mediaQuery = MediaQuery.of(context);

    if (getDeviceType(mediaQuery) != DeviceScreenType.Desktop) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Container(
          width: _widgetSize.getResponsiveWidth(1, 1, 1),
          decoration: BoxDecoration(
            color: bgColor,
            // border: hasUnderline == true
            //     ? Border(
            //         bottom: BorderSide(
            //           width: 0.5,
            //           color: Theme.of(context).dividerColor,
            //         ),
            //       )
            //     : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title
              Padding(
                padding: EdgeInsets.fromLTRB(
                  _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                  _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
                  0,
                  _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
                ),
                child: Text(
                  sectionTitle,
                  style: TextStyle(
                    letterSpacing: 1.2,
                    color: sectionTitleColor,
                    fontWeight: FontWeight.w800,
                    fontSize: _deviceDetails.getTitleFontSize(),
                  ),
                ),
              ),

              /// Content
              content,
            ],
          ),
        ),
      );
    } else {
      return Container(
        width: _widgetSize.getResponsiveWidth(1, 1, 1),
        decoration: BoxDecoration(
          color: bgColor,
          // border: hasUnderline == true
          //     ? Border(
          //         bottom: BorderSide(
          //           width: 0.5,
          //           color: Theme.of(context).dividerColor,
          //         ),
          //       )
          //     : null,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title
              Center(
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: 5, // Space between underline and text
                  ),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                    color: Colors.orange,
                    width: 2.0, // Underline thickness
                  ))),
                  child: Text(
                    sectionTitle,
                    style: TextStyle(
                      letterSpacing: 1.2,
                      color: sectionTitleColor,
                      fontWeight: FontWeight.w800,
                      fontSize: _deviceDetails.getTitleFontSize(),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              /// Content
              content,
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return designUI(widgetSize, deviceDetails, context);
  }
}

class ProductSection {
  final String designType;
  final String title;
  final List<ProductDetailsArgument> productDataList;

  ProductSection({
    required this.designType,
    required this.title,
    required this.productDataList,
  });
}

class CommentUI extends StatelessWidget {
  final List<CommentClass> dataList;
  final ScrollController scrollController;
  final WidgetSizeCalculation widgetSize;
  final DeviceDetails deviceDetails;
  final Color bgColor;
  final bool enableShadow;
  final Color sectionTitleColor;
  final Color contentColor;
  final Color subContentColor;
  final bool roundedContent;
  final Color contentBGcolor;
  final String sectionTitle;
  final double boxWidth;
  final double boxHeight;
  final String defaultImagePath;

  const CommentUI({
    Key? key,
    required this.dataList,
    required this.scrollController,
    required this.widgetSize,
    required this.deviceDetails,
    required this.bgColor,
    required this.enableShadow,
    required this.sectionTitleColor,
    required this.contentColor,
    required this.subContentColor,
    required this.roundedContent,
    required this.contentBGcolor,
    required this.sectionTitle,
    required this.boxWidth,
    required this.boxHeight,
    required this.defaultImagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SectionDesign(
      hasUnderline: false,
      content:

          /// Content
          dataList.length > 0
              ? Container(
                  // color: Colors.red,
                  width: widgetSize.getResponsiveWidth(1, 1, 1),
                  height: boxHeight,
                  child: Center(
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: dataList.length,
                      itemBuilder: (context, index) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              widgetSize.getResponsiveWidth(0.05, 0.02, 0.02),
                              10,
                              0,
                              10,
                            ),
                            child: Container(
                              width: boxWidth,
                              height: boxHeight / 0.7,
                              padding: EdgeInsets.fromLTRB(
                                widgetSize.getResponsiveWidth(0.01, 0.01, 0.01),
                                0,
                                widgetSize.getResponsiveWidth(0.01, 0.01, 0.01),
                                0,
                              ),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 10,
                                      color: Colors.grey,
                                      spreadRadius: 2)
                                ],
                                color: contentBGcolor,
                                borderRadius: roundedContent == true
                                    ? new BorderRadius.only(
                                        bottomLeft: const Radius.circular(10.0),
                                        bottomRight:
                                            const Radius.circular(10.0),
                                      )
                                    : null,
                              ),
                              child: Column(
                                children: [
                                  SizedBox(height: 20),

                                  /// Image
                                  DesignTypeImage(
                                    boxWidth: boxWidth,
                                    flexSize: 1,
                                    isCircle: true,
                                    targetImageUrl: dataList[index].image_url,
                                  ),

                                  SizedBox(height: 20),

                                  /// Title
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 10.0),
                                    child: AutoSizeText(
                                      dataList[index].name.toString(),
                                      style: TextStyle(
                                        fontSize:
                                            deviceDetails.getNormalFontSize() -
                                                5,
                                        fontWeight: FontWeight.w500,
                                        color: contentColor,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),

                                  /// Comment
                                  Expanded(
                                    child: AutoSizeText(
                                      dataList[index].value.toString(),
                                      maxFontSize:
                                          deviceDetails.getNormalFontSize() - 5,
                                      minFontSize:
                                          deviceDetails.getNormalFontSize() - 5,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize:
                                            deviceDetails.getNormalFontSize() -
                                                5,
                                        fontWeight: FontWeight.w400,
                                        color: contentColor,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.only(
                      left: widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),
                  child: Container(
                    width: widgetSize.getResponsiveWidth(0.9, 0.9, 0.9),
                    height: boxWidth, // <-- Base Size + Text height
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            right: widgetSize.getResponsiveWidth(
                              0.05,
                              0.05,
                              0.05,
                            ),
                          ),
                          child: FittedBox(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: CustomLoading(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
      bgColor: bgColor,
      widgetSize: widgetSize,
      deviceDetails: deviceDetails,
      sectionTitle: sectionTitle,
      sectionTitleColor: sectionTitleColor,
    );
  }
}

class UnderlineWidget extends StatelessWidget {
  const UnderlineWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      width: 100,
      color: Theme.of(context).highlightColor,
    );
  }
}

class DesignTypeImage extends StatelessWidget {
  final String? targetImageUrl;
  final double boxWidth;
  final int flexSize;
  final bool isCircle;
  final String defaultImageURL =
      'https://st3.depositphotos.com/23594922/31822/v/600/depositphotos_318221368-stock-illustration-missing-picture-page-for-website.jpg';

  const DesignTypeImage({
    Key? key,
    this.targetImageUrl,
    required this.boxWidth,
    required this.flexSize,
    required this.isCircle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: boxWidth,
      width: boxWidth,
      decoration: isCircle == true
          ? BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(blurRadius: 10, color: Colors.grey, spreadRadius: 2)
              ],
            )
          : null,
      child: CachedNetworkImage(
        width: boxWidth,
        height: boxWidth,
        imageBuilder: (context, imageProvider) => isCircle == true
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 3,
                      color: Colors.grey,
                      spreadRadius: 0.5,
                    )
                  ],
                ),
                child: CircleAvatar(
                  radius: 30.0,
                  backgroundImage: imageProvider,
                  backgroundColor: Colors.transparent,
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: imageProvider,
                  ),
                ),
              ),
        imageUrl: targetImageUrl != null
            ? targetImageUrl != ''
                ? targetImageUrl.toString()
                : defaultImageURL
            : defaultImageURL,
        fit: BoxFit.contain,
        errorWidget: (context, url, error) => Container(
          decoration: isCircle == true
              ? BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 3,
                      color: Colors.grey,
                      spreadRadius: 0.5,
                    )
                  ],
                )
              : null,
          child: isCircle == true
              ? CircleAvatar(
                  radius: 30.0,
                  backgroundImage: NetworkImage(
                      'https://st3.depositphotos.com/23594922/31822/v/600/depositphotos_318221368-stock-illustration-missing-picture-page-for-website.jpg'),
                  backgroundColor: Colors.transparent,
                )
              : Icon(
                  Icons.error,
                  color: Theme.of(context).primaryColor,
                  size: boxWidth / 2,
                ),
        ),
      ),
    );
  }
}

/// Footer
Widget getFooterUI(
  WidgetSizeCalculation _widgetSize,
  DeviceDetails _deviceDetails,
) {
  double boxHeight = _widgetSize.getResponsiveHeight(0.27, 0.4, 0.6);
  return SliverToBoxAdapter(
    child: Container(
        color: Color(0xFF3b322b),
        width: _widgetSize.getResponsiveWidth(1, 1, 1),
        padding: EdgeInsets.fromLTRB(
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          30,
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          10,
        ),
        //alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                RichText(
                    text: TextSpan(
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  children: <TextSpan>[
                    //'TIMOTI(M)Sdn.Bhd. (1299024-U) \n\nNo. 20B, Jalan Psj 1/31, 46000 Selangor, Petaling Jaya, Malaysia',
                    TextSpan(
                        text: 'TIMOTI STORY',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: '\n\nSimple & Finest',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: '\nWe commit to provide the finest skin cares. '
                            '\nWe ensure the nourishment for all skin types. \nNature, No alcohol, Non acid formula.'),
                    TextSpan(
                        text: '\n\nEffortless & Impressive',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text:
                            '\nWe analyse and response to everyone needs with our unique products.'
                            '\nIts an effortless, effective yet affordable types of privilege.'),
                  ],
                )),
              ],
            ),
            Column(
              children: [
                RichText(
                    text: TextSpan(
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  children: <TextSpan>[
                    //'TIMOTI(M)Sdn.Bhd. (1299024-U) \n\nNo. 20B, Jalan Psj 1/31, 46000 Selangor, Petaling Jaya, Malaysia',
                    TextSpan(
                        text: 'OUR PRODUCTS',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    TextSpan(text: '\n\nMAKE UP'),
                    TextSpan(text: '\n\nSKIN CARE'),
                    TextSpan(text: '\n\nTOOLS & BRUSHES'),
                    TextSpan(text: '\n\nMASK AND TREATMENT'),
                    TextSpan(text: '\n\nCLEANSING'),
                    TextSpan(text: '\n\nGIFT'),
                  ],
                )),
              ],
            ),
            Column(
              children: [
                RichText(
                    text: TextSpan(
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  children: <TextSpan>[
                    //'TIMOTI(M)Sdn.Bhd. (1299024-U) \n\nNo. 20B, Jalan Psj 1/31, 46000 Selangor, Petaling Jaya, Malaysia',
                    TextSpan(
                        text: 'NEED HELP?',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    TextSpan(
                        text:
                            '\n\nEMAIL: timoti@timoti.asia \nWe will reply to your inquiry within 48 working hours.'),
                    TextSpan(
                        text:
                            '\n\nTEL: 1-700-81-9644 \nMon-Fri (except public holiday) \n9AN - 5PM (UTC+08:00) Malaysia Time'),
                    TextSpan(text: '\n\nADDRESS'),
                    TextSpan(text: '\nTIMOTI (M) Sdn. Bhd.'),
                    TextSpan(
                        text:
                            '\nNo. 20B, Jalan Psj 1/31, 46000 Selangor, Petaling Jaya, Malaysia'),
                  ],
                )),
              ],
            )
          ],
        )),
  );
}
