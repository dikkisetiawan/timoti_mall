
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:intl/intl.dart';
import '/Custom-UI/Custom-LoadingUI.dart';
import '/Data-Class/ProductDetailsArgument.dart';
import '/Data-Class/ProductVariant.dart';
import '/Data-Class/ShippingDataClass.dart';
import '/Functions/Messager.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';
import '/Screen-Size/ui-utils.dart';
import '/StaticData.dart';
import '/WebWidget/WebAppbar.dart';
import '/WebWidget/WebCategories.dart';
import '/WebWidget/WebDrawer.dart';
import '/WebWidget/WebLayout.dart';
import '/enums/ProductStatus.dart';
import '/enums/Shipping-Method-Type.dart';
import '/enums/device-screen-type.dart';
import 'package:photo_view/photo_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class ProductDetailsPage extends StatefulWidget {
  static const routeName = '/Product-Details-Page';

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  ScrollController _scrollController = ScrollController();
  final formatCurrency = new NumberFormat.currency(
    locale: "ms-MY",
    symbol: "",
    decimalDigits: 2,
  );
  bool isLoading = false;
  bool hasMore = true;
  DocumentSnapshot? lastDocument;

  List<DocumentSnapshot> products = [];
  ProductDetailsArgument? data;

  bool loaded = false;
  int quantity = 1;
  int minQuantity = 1;
  int maxQuantity = 99;
  int branchValue = 0;
  List<ShippingData> shippingList = [];
  int choiceIndex = 0;

  List<BranchData> branchDataList = <BranchData>[];
  BranchData? selectedBranchData;

  /// Scroll Direction
  bool isScrolling = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? firebaseUser = FirebaseAuth.instance.currentUser;
  String cartID = '';

  // Product Variant (Add On)
  ProductVariant? selectedProductVariant;
  List<ProductVariantOption> allSelectedProductVariantType = [];
  ProductStatus productStatus = ProductStatus.OutOfStock;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (ModalRoute.of(context)?.settings.arguments != null) {
      if (loaded == false) {
        data = ModalRoute.of(context)?.settings.arguments
            as ProductDetailsArgument;

        /// Get All Target Product
        getTargetProduct().then((value) {
          /// Get Target Branch
          getBranchDetails();
        });
        loaded = true;
      }
    } else {
      print("No Param Data");
    }
  }

  // region UI
  Widget addToCartTextUI(DeviceDetails _deviceDetails) {
    /// Available
    if (productStatus == ProductStatus.Available) {
      return Text(
        "Add To Cart",
        style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).primaryColor,
            fontSize: _deviceDetails.getNormalFontSize()),
      );
    }

    /// Unavailable
    else if (productStatus == ProductStatus.Unavailable) {
      return Text(
        "Unavailable",
        style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).primaryColor,
            fontSize: _deviceDetails.getNormalFontSize()),
      );
    }

    /// Out of Stock
    else {
      return Text(
        "Out of Stock",
        style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).primaryColor,
            fontSize: _deviceDetails.getNormalFontSize()),
      );
    }
  }

  /// Product Image
  Widget getProductImage(
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
  ) {
    double boxHeight = _widgetSize.getResponsiveHeight(0.27, 0.4, 0.4);
    return SizedBox(
      width: _widgetSize.getResponsiveWidth(1, 1, 1),
      height: boxHeight,
      child: Swiper(
        pagination: SwiperPagination(),
        itemCount: data!.urlList.length,
        autoplay: false,
        controller: SwiperController(),
        loop: false,
        viewportFraction: 1,
        itemBuilder: (BuildContext context, int i) {
          return SizedBox(
            width: _widgetSize.getResponsiveWidth(1, 1, 1),
            height: boxHeight,
            child: FittedBox(
              fit: BoxFit.contain,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DetailScreen(
                                tag: "data$i",
                                imgString: data!.urlList[i],
                              )));
                },
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
                  imageUrl: data!.urlList[i],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget getProductDescriptionUI(
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
  ) {
    return Container(
      color: Theme.of(context).shadowColor,
      padding: EdgeInsets.fromLTRB(
        _widgetSize.getResponsiveWidth(0.05, 0.05, 0.01),
        _widgetSize.getResponsiveWidth(0.03, 0.03, 0.01),
        _widgetSize.getResponsiveWidth(0.05, 0.05, 0.01),
        _widgetSize.getResponsiveWidth(0.03, 0.03, 0.01),
      ),
      width: _widgetSize.getResponsiveWidth(1, 1, 0.4),
      child: ExpandablePanel(
        header: Text(
          'Product Description',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).primaryColor,
            fontSize: _deviceDetails.getTitleFontSize(),
          ),
        ),
        collapsed: getProductDescriptionText(
          data!.productDescription,
          1,
          _deviceDetails,
        ),
        expanded: data?.productDescriptionHTML != null
            ?
            // HTML
            getHTMLProductDescriptionText(
                data!.productDescriptionHTML as String,
                _deviceDetails,
              )
            :
            // Normal String
            getProductDescriptionText(
                data!.productDescription,
                null,
                _deviceDetails,
              ),
      ),
    );
  }

  Widget getProductDescriptionText(
    String dataString,
    int? maxLine,
    DeviceDetails _deviceDetails,
  ) {
    return Text(
      dataString,
      maxLines: maxLine,
      style: TextStyle(
        fontWeight: FontWeight.w400,
        color: Theme.of(context).primaryColor,
        fontSize: _deviceDetails.getNormalFontSize(),
        overflow: maxLine != null ? TextOverflow.ellipsis : null,
      ),
    );
  }

  /// For HTML
  Widget getHTMLProductDescriptionText(
    String dataString,
    DeviceDetails _deviceDetails,
  ) {
    return Html(data: dataString, style: {
      "p": Style(
        color: Theme.of(context).primaryColor,
        fontSize: FontSize.large,
        fontWeight: FontWeight.w400,
      ),
    });
  }

  /// Product Name + Price + Description
  Widget getTitlePrice(
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Title + Price
        Container(
          color: Theme.of(context).shadowColor,
          width: _widgetSize.getResponsiveWidth(1, 1, 1),
          padding: EdgeInsets.fromLTRB(
            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
            _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
            _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Product Name
              Container(
                width: _widgetSize.getResponsiveWidth(0.6, 0.6, 0.6),
                child: Text(
                  data!.productName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                    fontSize: _deviceDetails.getTitleFontSize() + 2,
                  ),
                ),
              ),

              /// Price
              Container(
                width: _widgetSize.getResponsiveWidth(0.25, 0.25, 0.25),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    formatCurrency.format(
                      double.parse(
                        selectedProductVariant != null
                            ? selectedProductVariant!.Product_Variant_Price
                            : data!.priceString,
                      ),
                    ),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontSize: _deviceDetails.getTitleFontSize() + 7,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),

        /// Spacing
        SizedBox(height: _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03)),

        /// Product Description
        getProductDescriptionUI(_widgetSize, _deviceDetails),
      ],
    );
  }

  /// Quantity
  Widget getQuantity(
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        0,
        _widgetSize.getResponsiveWidth(0.03, 0, 0),
        0,
        _widgetSize.getResponsiveWidth(0.03, 0, 0),
      ),
      child: Container(
        color: Theme.of(context).shadowColor,
        width: _widgetSize.getResponsiveWidth(1, 1, 0.3),
        padding: EdgeInsets.fromLTRB(
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
          _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// "-"
            Container(
              width: _widgetSize.getResponsiveWidth(0.08, 0.04, 0.02),
              height: _widgetSize.getResponsiveWidth(0.08, 0.04, 0.02),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: IconButton(
                splashColor: Colors.transparent,
                padding: EdgeInsets.all(3),
                onPressed: () {
                  if (quantity > minQuantity) {
                    --quantity;
                    setState(() {});
                  }
                },
                icon: FittedBox(
                  child: Icon(
                    Icons.remove,
                    color: Theme.of(context).highlightColor,
                  ),
                ),
              ),
            ),

            /// Spacing
            SizedBox(width: _widgetSize.getResponsiveWidth(0.1, 0.1, 0.05)),

            /// Quantity
            Text(
              quantity.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                fontSize: _deviceDetails.getTitleFontSize(),
              ),
            ),

            /// Spacing
            SizedBox(width: _widgetSize.getResponsiveWidth(0.1, 0.1, 0.05)),

            /// "+"
            Container(
              width: _widgetSize.getResponsiveWidth(0.08, 0.04, 0.02),
              height: _widgetSize.getResponsiveWidth(0.08, 0.04, 0.02),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: IconButton(
                splashColor: Colors.transparent,
                padding: EdgeInsets.all(3),
                onPressed: () {
                  if (quantity < maxQuantity) {
                    ++quantity;
                    setState(() {});
                  }
                },
                icon: FittedBox(
                  child: Icon(
                    Icons.add,
                    color: Theme.of(context).highlightColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shipping Method
  Widget getShipMethod(
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        0,
        _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        0,
      ),
      child: Container(
        width: _widgetSize.getResponsiveWidth(0.9, 0.9, 0.9),
        height: _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
        child: ListView.builder(
            itemCount: shippingList.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(
                      shippingList[index].shippingName,
                      style: TextStyle(
                        color: choiceIndex == index
                            ? Theme.of(context).backgroundColor
                            : Theme.of(context).primaryColor,
                        fontSize: _deviceDetails.getNormalFontSize() - 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: choiceIndex == index,
                    selectedColor: Theme.of(context).highlightColor,
                    onSelected: (bool selected) {
                      setState(() {
                        choiceIndex = selected ? index : 0;
                        print('Selected Shipping Method: ' +
                            shippingList[choiceIndex].shippingName);
                      });
                    },
                    backgroundColor: Theme.of(context).shadowColor,
                  ),
                );
              } else if (index == shippingList.length - 1) {
                return Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: ChoiceChip(
                    label: Text(
                      shippingList[index].shippingName,
                      style: TextStyle(
                        color: choiceIndex == index
                            ? Theme.of(context).backgroundColor
                            : Theme.of(context).primaryColor,
                        fontSize: _deviceDetails.getNormalFontSize() - 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: choiceIndex == index,
                    selectedColor: Theme.of(context).highlightColor,
                    onSelected: (bool selected) {
                      setState(() {
                        choiceIndex = selected ? index : 0;
                        print('Selected Shipping Method: ' +
                            shippingList[choiceIndex].shippingName);
                      });
                    },
                    backgroundColor: Theme.of(context).shadowColor,
                  ),
                );
              }
              return ChoiceChip(
                label: Text(
                  shippingList[index].shippingName,
                  style: TextStyle(
                    color: choiceIndex == index
                        ? Theme.of(context).backgroundColor
                        : Theme.of(context).primaryColor,
                    fontSize: _deviceDetails.getNormalFontSize() - 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                selected: choiceIndex == index,
                selectedColor: Theme.of(context).highlightColor,
                onSelected: (bool selected) {
                  setState(() {
                    choiceIndex = selected ? index : 0;
                    print('Selected Shipping Method: ' +
                        shippingList[choiceIndex].shippingName);
                  });
                },
                backgroundColor: Theme.of(context).shadowColor,
              );
            }),
      ),
    );
  }
  // endregion

  // region Functions
  void cartChecker(DeviceDetails _deviceDetails) {
    /// Available
    if (productStatus == ProductStatus.Available) {
      /// Ensure User choose a branch
      if (selectedBranchData != null) {
        hasInternet().then((value) {
          if (value == true) {
            addToCart(_deviceDetails);
          } else {
            showSnackBar('No internet connection', context);
          }
        });
      }

      /// User haven't choose branch
      else if (selectedBranchData == null) {
        showMessage(
          'Please Select A Branch',
          null,
          _deviceDetails,
          context,
        );
      }
    }

    /// Unavailable
    else if (productStatus == ProductStatus.Unavailable) {
      showMessage(
        'Product is Temporary Unavailable',
        null,
        _deviceDetails,
        context,
      );
    }

    /// Out of Stock
    else {
      showMessage(
        'Product is Out of Stock',
        null,
        _deviceDetails,
        context,
      );
    }
  }

  /// Add to Cart
  addToCart(DeviceDetails _deviceDetails) async {
    // print("Price Debug: " + data!.priceString);
    // return;
    if (firebaseUser == null) {
      print("Didnt get User Data");
      return;
    }
    if (data == null) {
      print("Didnt get Product Data");
      return;
    }
    // Store all variant
    List<dynamic> productVariantDYNAMICList = [];

    if (selectedBranchData != null) {
      // If product HAVE variant
      if (selectedBranchData!.productVariantFinal != null) {
        // Display Error if variant not selected
        if (selectedProductVariant == null) {
          showMessage("Please Select 1 Option", null, _deviceDetails, context);
          return;
        }

        // Add All Product Variant to productVariantDYNAMICList
        else {
          for (int i = 0;
              i <
                  selectedBranchData!
                      .productVariantResult!.productVariantOptionsList.length;
              ++i) {
            productVariantDYNAMICList.add(
              selectedBranchData!
                  .productVariantResult!.productVariantOptionsList[i]
                  .toMap(),
            );
          }
        }
      }
    } else {
      showMessage("Please Select 1 Branch", null, _deviceDetails, context);
      return;
    }

    /// For Alert User when user trying to add different outlet cart
    bool needAlertMessage = false;

    /// -> Check if the current user cart has item or not
    if (data!.bottomAppBarState.getCartQuantity() > 0) {
      needAlertMessage = true;
    }

    /// -> Check if the current user cart has this branch cart or not
    QuerySnapshot cartSnapshot;
    cartSnapshot = await firestore
        .collection('Cart')
        .where("User_ID", isEqualTo: firebaseUser?.uid)
        .where("Provider_ID", isEqualTo: selectedBranchData!.branchID)
        .get();

    /// Define Cart Map Data
    Map<String, dynamic> cartMapData = Map<String, dynamic>();

    /// Define Cart Details Map Data
    Map<String, dynamic> cartDetailsMapData = Map<String, dynamic>();

    /// - If Branch Cart data not found
    if (cartSnapshot.docs.length == 0) {
      print("====================================");
      print("Cart Data not exist");

      if (needAlertMessage == true) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).backgroundColor,
              elevation: 10,
              scrollable: true,
              title: Text(
                'Alert',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: _deviceDetails.getNormalFontSize(),
                ),
              ),
              content: Text(
                'We found that your cart has other outlet items.\nIf you add this to ${selectedBranchData!.branchName} might include additional shipping fees. \n\n*Please be sure to check your shipping fees during checkout.',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: _deviceDetails.getNormalFontSize(),
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: _deviceDetails.getNormalFontSize(),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text(
                    "Add Item",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: _deviceDetails.getNormalFontSize(),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);

                    setLoadingStatus(true);

                    if (this.mounted) {
                      setState(() {});
                    }

                    /// add a branch cart
                    FirebaseFirestore.instance.collection("Cart").add({
                      "Last_Updated": DateFormat('yyyy-MM-dd hh:mm:ss')
                          .format(DateTime.now()),
                      "Price": selectedProductVariant != null
                          ? selectedProductVariant!.Product_Variant_Price
                          : data!.priceString,
                      "Provider_ID": selectedBranchData!.branchID,
                      "Qty": quantity,
                      "Quantity": quantity,
                      "User_ID": firebaseUser?.uid,
                    }).then((value) {
                      print("Cart Created");
                      print("Cart ID :" + value.id.toString());

                      /// Store Cart ID
                      cartID = value.id.toString();

                      /// Update Cart ID to Cart Document
                      FirebaseFirestore.instance
                          .collection("Cart")
                          .doc(value.id.toString())
                          .update({
                        "Cart_ID": value.id.toString(),
                      });

                      String documentNameCD;
                      if (selectedProductVariant != null) {
                        documentNameCD = cartID +
                            selectedBranchData!.productID +
                            selectedProductVariant!.Product_Variant_Options_id;
                      } else {
                        documentNameCD = cartID +
                            selectedBranchData!.productID +
                            selectedBranchData!.productID;
                      }

                      /// then add a cart details point to cart
                      FirebaseFirestore.instance
                          .collection("CartDetails")
                          .doc(documentNameCD)
                          .set({
                        "Cart_ID": value.id.toString(),
                        "Compare_At_Price": null,
                        "Created_At": DateFormat('yyyy-MM-dd hh:mm:ss')
                            .format(DateTime.now()),
                        "Discount_Applies_Once": null,
                        "Grams": null,
                        "Height": null,
                        "Image":
                            data?.urlList != null ? data!.urlList[0] : null,
                        "Is_Deleted": null,
                        "Price": selectedProductVariant != null
                            ? selectedProductVariant!.Product_Variant_Price
                            : data!.priceString,
                        "Price_After_Discount": selectedProductVariant != null
                            ? selectedProductVariant!.Product_Variant_Price
                            : data!.priceString,
                        "Product_Handle": null,
                        "Product_ID": selectedBranchData!.productID,
                        'Product_Name': data!.productName,
                        "Provider_ID": selectedBranchData!.branchID,
                        "Quantity": quantity.toString(),
                        "Shipping_Required": null,
                        "Subtotal": selectedProductVariant != null
                            ? selectedProductVariant!.Product_Variant_Price
                            : data!.priceString,
                        "Subtotal_After_Discount":
                            selectedProductVariant != null
                                ? selectedProductVariant!.Product_Variant_Price
                                : data!.priceString,
                        "Taxable": null,
                        "Total_Discount": "0",
                        "Total_Tax": null,
                        // "Variant_ID": selectedBranchData!.variantID,
                        "Width": null,
                        "User_ID": firebaseUser?.uid,
                        'Product_Variant_Types_id':
                            selectedProductVariant != null
                                ? selectedBranchData!.productVariantResult!
                                    .Product_Variant_Types_id
                                : null,
                        'Product_Variant_Types_name':
                            selectedProductVariant != null
                                ? selectedBranchData!.productVariantResult!
                                    .Product_Variant_Types_name
                                : null,
                        'Product_Variant_Options_id': selectedProductVariant !=
                                null
                            ? selectedProductVariant!.Product_Variant_Options_id
                            : null,
                        'Product_Variant_Options_name':
                            selectedProductVariant != null
                                ? selectedProductVariant!
                                    .Product_Variant_Options_name
                                : null,
                        'Product_Variant_Price': selectedProductVariant != null
                            ? selectedProductVariant!.Product_Variant_Price
                            : null,
                      }).then((value) {
                        print("Cart Details Created [" + documentNameCD + "]");

                        /// Update Cart QTY
                        data?.bottomAppBarState.updateCartQuantity();

                        /// Show Message
                        showSnackBar(
                          "Added to ${selectedBranchData!.branchName}",
                          context,
                        );

                        setLoadingStatus(false);

                        if (this.mounted) {
                          setState(() {});
                        }
                      });
                    });
                  },
                ),
              ],
            );
          },
        );
      } else {
        /// Normal add cart
        print("Normal Add Cart");
        setLoadingStatus(true);

        /// add a branch cart
        FirebaseFirestore.instance.collection("Cart").add({
          "Last_Updated":
              DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()),
          "Price": selectedProductVariant != null
              ? selectedProductVariant!.Product_Variant_Price
              : data!.priceString,
          "Provider_ID": selectedBranchData!.branchID,
          "Qty": quantity,
          "Quantity": quantity,
          "User_ID": firebaseUser?.uid,
        }).then((value) {
          print("Cart Created");
          print("Cart ID :" + value.id.toString());

          /// Store Cart ID
          cartID = value.id.toString();

          /// Update Cart ID to Cart Document
          FirebaseFirestore.instance
              .collection("Cart")
              .doc(value.id.toString())
              .update({
            "Cart_ID": value.id.toString(),
          });

          String documentNameCD;
          if (selectedProductVariant != null) {
            documentNameCD = cartID +
                selectedBranchData!.productID +
                selectedProductVariant!.Product_Variant_Options_id;
          } else {
            documentNameCD = cartID +
                selectedBranchData!.productID +
                selectedBranchData!.productID;
          }

          /// then add a cart details point to cart
          FirebaseFirestore.instance
              .collection("CartDetails")
              .doc(documentNameCD)
              .set({
            "Cart_ID": value.id.toString(),
            "Compare_At_Price": null,
            "Created_At":
                DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()),
            "Discount_Applies_Once": null,
            "Grams": null,
            "Height": null,
            "Image": data?.urlList != null ? data!.urlList[0] : null,
            "Is_Deleted": null,
            "Price": selectedProductVariant != null
                ? selectedProductVariant!.Product_Variant_Price
                : data!.priceString,
            "Price_After_Discount": selectedProductVariant != null
                ? selectedProductVariant!.Product_Variant_Price
                : data!.priceString,
            "Product_Handle": null,
            "Product_ID": selectedBranchData!.productID,
            'Product_Name': data!.productName,
            "Provider_ID": selectedBranchData!.branchID,
            "Quantity": quantity.toString(),
            "Shipping_Required": null,
            "Subtotal": selectedProductVariant != null
                ? selectedProductVariant!.Product_Variant_Price
                : data!.priceString,
            "Subtotal_After_Discount": selectedProductVariant != null
                ? selectedProductVariant!.Product_Variant_Price
                : data!.priceString,
            "Taxable": null,
            "Total_Discount": "0",
            "Total_Tax": null,
            // "Variant_ID": selectedBranchData!.variantID,
            "Width": null,
            "User_ID": firebaseUser?.uid,
            'Product_Variant_Types_id': selectedProductVariant != null
                ? selectedBranchData!
                    .productVariantResult!.Product_Variant_Types_id
                : null,
            'Product_Variant_Types_name': selectedProductVariant != null
                ? selectedBranchData!
                    .productVariantResult!.Product_Variant_Types_name
                : null,
            'Product_Variant_Options_id': selectedProductVariant != null
                ? selectedProductVariant!.Product_Variant_Options_id
                : null,
            'Product_Variant_Options_name': selectedProductVariant != null
                ? selectedProductVariant!.Product_Variant_Options_name
                : null,
            'Product_Variant_Price': selectedProductVariant != null
                ? selectedProductVariant!.Product_Variant_Price
                : null,
            'Product_Variant_List': productVariantDYNAMICList,
          }).then((value) {
            print("Cart Details Created [" + documentNameCD + "]");

            /// Update Cart QTY
            // data?.bottomAppBarState.updateCartQuantity();
            StaticData().updateCartQuantity(firebaseUser, firestore);

            /// Show Message
            showSnackBar("Added to ${selectedBranchData!.branchName}", context);
            setLoadingStatus(false);
          });
        });
      }
    }

    /// - If Branch Cart data existed
    else {
      print("====================================");
      print("Branch Cart Data existed");

      /// Store Cart ID
      cartID = cartSnapshot.docs[0].id;
      if (cartID == null) {
        print('Cart ID is null');
        return;
      }

      setLoadingStatus(true);

      /// Check if cart details existed
      QuerySnapshot cartDetailsSnapshot;
      // If product HAVE variants
      if (selectedBranchData!.productVariantFinal != null) {
        cartDetailsSnapshot = await firestore
            .collection('CartDetails')
            .where("Cart_ID", isEqualTo: cartID)
            .where("Product_ID", isEqualTo: selectedBranchData!.productID)
            .where(
              "Product_Variant_Options_id",
              isEqualTo: selectedProductVariant!.Product_Variant_Options_id,
            ) // Check Product Variant Option id exist or not
            .get();
      }
      // If product DONT HAVE variants
      else {
        cartDetailsSnapshot = await firestore
            .collection('CartDetails')
            .where("Cart_ID", isEqualTo: cartID)
            .where("Product_ID", isEqualTo: selectedBranchData!.productID)
            .get();
      }

      ///  - If cart details existed
      if (cartDetailsSnapshot.docs.length > 0) {
        print("====================================");
        print("This is Existing Cart Details");

        /// Assign Data
        cartDetailsMapData =
            cartDetailsSnapshot.docs[0].data() as Map<String, dynamic>;

        /// Then directly Update cart details (quantity)
        // region Update Cart Details Quantity
        int targetQuantity =
            int.parse(cartDetailsMapData["Quantity"]) + quantity;
        FirebaseFirestore.instance
            .collection("CartDetails")
            .doc(cartDetailsSnapshot.docs[0].id)
            .update({
          "Quantity": targetQuantity.toString(),
        }).then((value) async {
          print(
              "Updated Cart Details [${cartDetailsSnapshot.docs[0].id}] Quantity: " +
                  targetQuantity.toString());

          /// Update branch cart price
          // region Update Branch Cart Price
          QuerySnapshot allCartDetailsSnapshot;
          allCartDetailsSnapshot = await firestore
              .collection('CartDetails')
              .where("Cart_ID", isEqualTo: cartID)
              .get();

          /// Define All Cart Details Map Data
          Map<String, dynamic> allCartDetailsMapData = Map<String, dynamic>();

          double totalPrice = 0;
          double eachPrice;
          int eachQuantity;
          double eachFinalPrice;

          for (int i = 0; i < allCartDetailsSnapshot.docs.length; ++i) {
            /// Assign Data
            allCartDetailsMapData =
                allCartDetailsSnapshot.docs[i].data() as Map<String, dynamic>;

            /// Get Each Quantity + Price
            eachPrice = double.parse(allCartDetailsMapData["Price"]);
            eachQuantity = int.parse(allCartDetailsMapData["Quantity"]);

            /// Each Final Price = Each Quantity * Each Price
            eachFinalPrice = eachPrice * eachQuantity;

            /// Add to total price
            totalPrice += eachFinalPrice;

            /// Reach Final index
            if (i == allCartDetailsSnapshot.docs.length - 1) {
              /// Update Branch Cart Price
              FirebaseFirestore.instance.collection("Cart").doc(cartID).update({
                "Price": totalPrice.toStringAsFixed(2),
                "Quantity": allCartDetailsSnapshot.docs.length,
                "Qty": allCartDetailsSnapshot.docs.length,
              }).then((value) {
                print("Updated Cart Price: " + totalPrice.toString());

                /// Update Cart QTY
                // data?.bottomAppBarState.updateCartQuantity();
                StaticData().updateCartQuantity(firebaseUser, firestore);

                /// Show Message
                showMessage(
                  'Updated Cart',
                  "Total ${targetQuantity.toString()} Qty for this item in ${selectedBranchData!.branchName}",
                  _deviceDetails,
                  context,
                );

                setLoadingStatus(false);
              });
            }
          }
          // endregion
        });
        // endregion
      }

      /// - If cart details data not found
      else {
        print("====================================");
        print("This is a new Cart Details");

        /// Create a new Cart Details
        String documentNameCD;
        if (selectedProductVariant != null) {
          documentNameCD = cartID +
              selectedBranchData!.productID +
              selectedProductVariant!.Product_Variant_Options_id;
        } else {
          documentNameCD = cartID +
              selectedBranchData!.productID +
              selectedBranchData!.productID;
        }

        // region Create new Cart Details
        FirebaseFirestore.instance
            .collection("CartDetails")
            .doc(documentNameCD)
            .set({
          "Cart_ID": cartID,
          "Compare_At_Price": null,
          "Created_At":
              DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()),
          "Discount_Applies_Once": null,
          "Grams": null,
          "Height": null,
          "Image": data?.urlList != null ? data!.urlList[0] : null,
          "Is_Deleted": null,
          "Price": selectedProductVariant != null
              ? selectedProductVariant!.Product_Variant_Price
              : data!.priceString,
          "Price_After_Discount": selectedProductVariant != null
              ? selectedProductVariant!.Product_Variant_Price
              : data!.priceString,
          "Product_Handle": null,
          "Product_ID": selectedBranchData!.productID,
          'Product_Name': data!.productName,
          "Provider_ID": selectedBranchData!.branchID,
          "Quantity": quantity.toString(),
          "Shipping_Required": null,
          "Subtotal": selectedProductVariant != null
              ? selectedProductVariant!.Product_Variant_Price
              : data!.priceString,
          "Subtotal_After_Discount": selectedProductVariant != null
              ? selectedProductVariant!.Product_Variant_Price
              : data!.priceString,
          "Taxable": null,
          "Total_Discount": "0",
          "Total_Tax": null,
          // "Variant_ID": selectedBranchData!.variantID,
          "Width": null,
          "User_ID": firebaseUser?.uid,
          'Product_Variant_Types_id': selectedProductVariant != null
              ? selectedBranchData!
                  .productVariantResult!.Product_Variant_Types_id
              : null,
          'Product_Variant_Types_name': selectedProductVariant != null
              ? selectedBranchData!
                  .productVariantResult!.Product_Variant_Types_name
              : null,
          'Product_Variant_Options_id': selectedProductVariant != null
              ? selectedProductVariant!.Product_Variant_Options_id
              : null,
          'Product_Variant_Options_name': selectedProductVariant != null
              ? selectedProductVariant!.Product_Variant_Options_name
              : null,
          'Product_Variant_Price': selectedProductVariant != null
              ? selectedProductVariant!.Product_Variant_Price
              : null,
          'Product_Variant_List': productVariantDYNAMICList,
        }).then((value) async {
          print(
              "[Branch Cart Existed] Cart Details Created: " + documentNameCD);

          /// Update branch cart price
          // region Update Branch Cart Price
          QuerySnapshot allCartDetailsSnapshot;
          allCartDetailsSnapshot = await firestore
              .collection('CartDetails')
              .where("Cart_ID", isEqualTo: cartID)
              .get();

          /// Define All Cart Details Map Data
          Map<String, dynamic> allCartDetailsMapData = Map<String, dynamic>();

          double totalPrice = 0;
          double eachPrice;
          int eachQuantity;
          double eachFinalPrice;

          for (int i = 0; i < allCartDetailsSnapshot.docs.length; ++i) {
            /// Assign Data
            allCartDetailsMapData =
                allCartDetailsSnapshot.docs[i].data() as Map<String, dynamic>;

            /// Get Each Quantity + Price
            eachPrice = double.parse(allCartDetailsMapData["Price"]);
            eachQuantity = int.parse(allCartDetailsMapData["Quantity"]);

            /// Each Final Price = Each Quantity * Each Price
            eachFinalPrice = eachPrice * eachQuantity;

            /// Add to total price
            totalPrice += eachFinalPrice;

            /// Reach Final index
            if (i == allCartDetailsSnapshot.docs.length - 1) {
              /// Update Branch Cart Price
              FirebaseFirestore.instance.collection("Cart").doc(cartID).update({
                "Price": totalPrice.toStringAsFixed(2),
                "Quantity": allCartDetailsSnapshot.docs.length,
                "Qty": allCartDetailsSnapshot.docs.length,
              }).then((value) {
                print("Updated Cart Price: " + totalPrice.toString());

                /// Update Cart QTY
                // data?.bottomAppBarState.updateCartQuantity();
                StaticData().updateCartQuantity(firebaseUser, firestore);

                /// Show Message
                showMessage(
                  "",
                  'Added to Cart',
                  _deviceDetails,
                  context,
                );

                setLoadingStatus(false);
              });
            }
          }
          // endregion
        });
        // endregion
      }
    }
  }

  /// Get Target products
  getTargetProduct() async {
    if (data == null) {
      print("Didnt get Product Data");
      return;
    }
    // print("UserLat: " + data.userPosition.latitude.toString());
    // print("UserLong: " + data.userPosition.longitude.toString());
    print("Product Base ID: " + data!.productBaseID);

    QuerySnapshot querySnapshot;
    querySnapshot = await firestore
        .collection('Products')
        .where("Product_ID_Base", isEqualTo: data!.productBaseID)
        .where("Product_Is_Published", isEqualTo: "1")
        // .where("Product_Quantity", isGreaterThanOrEqualTo: 1)
        .get();

    setLoadingStatus(true);

    /// Add to List
    for (int i = 0; i < querySnapshot.docs.length; ++i) {
      /// Assign Data
      Map<String, dynamic> productMapData =
          querySnapshot.docs[i].data() as Map<String, dynamic>;

      if (productMapData["Product_Is_Published"] != null) {
        if (productMapData["Product_Is_Published"] == "1") {
          if (productMapData['Product_Quantity'] > 1) {
            print("Some how reach here");
            print(productMapData['Product_ID']);
            setLoadingStatus(false);
          }
          products.add(querySnapshot.docs[i]);
        }
      }
    }
  }

  /// Get Branch Details
  getBranchDetails() async {
    if (products.length < 1) {
      print("This Product Is Out of stock");

      productStatus = ProductStatus.OutOfStock;
      return;
    } else {
      productStatus = ProductStatus.Available;
    }

    DocumentSnapshot branchSnapshot;
    for (int i = 0; i < products.length; ++i) {
      /// Assign Product Data
      Map<String, dynamic> productMapData =
          products[i].data() as Map<String, dynamic>;

      // Product Variant Type for each branch
      List<ProductVariantType>? allVariantTypes =
          await getProductVariantTypes(productMapData);

      // All Product Variant Options for each branch
      List<ProductVariant>? allVariantRef =
          await getProductVariantRef(productMapData);

      // TEMPORARY DISABLE FOR VARIANT
      if (allVariantTypes != null) {
        productStatus = ProductStatus.Unavailable;
      }

      /// Find target branch
      branchSnapshot = await firestore
          .collection('Branches')
          .doc(productMapData["Branch_ID"])
          .get();

      /// Assign Branch Data
      Map<String, dynamic> branchMapData =
          branchSnapshot.data() as Map<String, dynamic>;

      /// With User Position
      if (data?.userPosition != null) {
        // region Calculate Distance
        calculateDistance(
          data?.userPosition?.latitude,
          data?.userPosition?.longitude,
          double.parse(branchMapData["Branch_lat"]),
          double.parse(branchMapData["Branch_long"]),
        ).then((disV) {
          setLoadingStatus(false);

          /// Assign data
          BranchData tempData = new BranchData(
            productID: productMapData["Product_ID"],
            branchID: branchMapData["Branch_id"],
            branchName: branchMapData["Area"],
            branchLatitude: branchMapData["Branch_lat"],
            branchLongitude: branchMapData["Branch_long"],
            distance: disV,
            disableNearest: false,
            outOfStock: productMapData["Product_Quantity"] > 1 ? false : true,
            productVariantFinal: null,
            // All Product Variant Types List
            productVariantTypesList: allVariantTypes,
            // All Product Variant Ref List
            allVariantRef: allVariantRef,
          );

          print("====== BRANCH DATA ================");
          print("Added Branch- Product ID: " + tempData.productID);
          print("Added Branch- Branch ID: " + tempData.branchID);
          print("Added Branch- Branch Name: " + tempData.branchName);
          print("Added Branch- Branch Lat: " + tempData.branchLatitude);
          print("Added Branch- Branch Long: " + tempData.branchLongitude);
          print("Added Branch- Distance: " + tempData.distance.toString());
          print("Branch Status: " + branchMapData["Status"].toString());

          /// Branch Status must be true
          if (branchMapData["Status"] == true) {
            /// Add to Branch Data List
            branchDataList.add(tempData);
          }

          /// Reach Last Index
          if (products.length == branchDataList.length) {
            /// Sort by distance (Shortest)
            branchDataList
                .sort((a, b) => a.distance!.compareTo(b.distance as double));

            /// Printing Sorted Branch
            for (int j = 0; j < branchDataList.length; ++j) {
              print("[$j]Sorted Branch name: " + branchDataList[j].branchName);
              print("[$j]Sorted Branch Distance: " +
                  branchDataList[j].distance.toString());
            }
          }
        });
        // endregion
      }

      /// No User position
      else {
        setLoadingStatus(false);

        /// Assign data
        BranchData tempData = new BranchData(
          productID: productMapData["Product_ID"],
          branchID: branchMapData["Branch_id"],
          branchName: branchMapData["Area"],
          branchLatitude: branchMapData["Branch_lat"],
          branchLongitude: branchMapData["Branch_long"],
          disableNearest: true,
          outOfStock: productMapData["Product_Quantity"] > 1 ? false : true,
          productVariantFinal: null,
          // All Product Variant Types List
          productVariantTypesList: allVariantTypes,
          // All Product Variant Options List
          allVariantRef: allVariantRef,
        );

        print("====== BRANCH DATA ================");
        print("Added Branch- Product ID: " + tempData.productID);
        print("Added Branch- Branch ID: " + tempData.branchID);
        print("Added Branch- Branch Name: " + tempData.branchName);
        print("Added Branch- Branch Lat: " + tempData.branchLatitude);
        print("Added Branch- Branch Long: " + tempData.branchLongitude);

        /// Branch Status must be true
        if (branchMapData["Status"] == true) {
          /// Add to Branch Data List
          branchDataList.add(tempData);
        }
      }

      /// Reach last index
      if (i == products.length - 1) {
        if (products.length == 1) {
          selectedBranchData = branchDataList[0];
        }
        if (this.mounted) {
          setState(() {});
        }
      }
    }
  }

  /// Get Product Variants Types
  Future<List<ProductVariantType>?> getProductVariantTypes(
    Map<String, dynamic> productMapData,
  ) async {
    print("Getting Product Variant Types...");
    // List that store all product variant types
    List<ProductVariantType> allTypeList = [];

    // Check Product Variant Type
    if (productMapData["Product_Variant_Types"] != null) {
      print('Product Variant Type not null');
      int typeLength = productMapData["Product_Variant_Types"].length;
      print("All Type Length: " + typeLength.toString());

      if (typeLength > 0) {
        for (int i = 0; i < typeLength; ++i) {
          if (productMapData["Product_Variant_Options"] != null) {
            int optionLength = productMapData["Product_Variant_Options"].length;
            print("All Options Length: " + optionLength.toString());

            // Define Variant options
            List<ProductVariantOption> optionList = [];

            for (int j = 0; j < optionLength; ++j) {
              // Only Allow same variant type id to be added inside
              if (productMapData["Product_Variant_Options"][j]
                      ["variant_type_id"] ==
                  productMapData["Product_Variant_Types"][i]["id"]) {
                // Define Current Option Details
                ProductVariantOption tmpOption = ProductVariantOption(
                  Option_id: productMapData["Product_Variant_Options"][j]["id"],
                  Option_name: productMapData["Product_Variant_Options"][j]
                      ["name"],
                );

                /// Add Current Option to all option list
                optionList.add(tmpOption);
              }
            }

            print(
                "Variant [${productMapData["Product_Variant_Types"][i]["name"]}] has ${optionList.length.toString()} options!");

            // Each Product Variant Type Details
            ProductVariantType tmp = ProductVariantType(
              Product_Variant_Types_id: productMapData["Product_Variant_Types"]
                  [i]["id"],
              Product_Variant_Types_name:
                  productMapData["Product_Variant_Types"][i]["name"],
              productVariantOptions: optionList,
            );

            /// Add Current Type to all type list (result)
            allTypeList.add(tmp);

            /// Reach Last Index
            if (i == typeLength - 1) {
              if (allTypeList.length == 0) {
                print("** Product Variant Type  is empty!");
                return null;
              } else {
                print('Product Variant Type Has Result!');
                return allTypeList;
              }
            }
          }
        }
      } else {
        print("** Product_Variant_Types Length is Empty !");
        return null;
      }
    } else {
      print("** Product_Variant_Types is null!");
      return null;
    }
  }

  /// Get All Product Variants Ref
  Future<List<ProductVariant>?> getProductVariantRef(
    Map<String, dynamic> productMapData,
  ) async {
    List<ProductVariant> allVariants = [];

    if (productMapData["Product_Variants"] != null) {
      print('Product Variant Options not null');

      int variantLength = productMapData["Product_Variants"].length;
      print("variantLength: " + variantLength.toString());

      for (int i = 0; i < variantLength; ++i) {
        if (productMapData["Product_Variants"][i]['is_enabled'] == 'true') {
          ProductVariant tmp = ProductVariant(
            Product_Variant_Options_id:
                productMapData["Product_Variants"][i]['id'] ?? '',
            Product_Variant_Options_name:
                productMapData["Product_Variants"][i]['name'] ?? '',
            Product_Variant_Price:
                productMapData["Product_Variants"][i]['price'] ?? '',
            Product_Variant_Quantity: int.parse(
                productMapData["Product_Variants"][i]['inventory_quantity']),
            options:
                List.from(productMapData["Product_Variants"][i]['options']),
          );
          print("Name:" + tmp.Product_Variant_Options_name);
          print("Option 0:" + tmp.options[0]);

          /// Add to List
          allVariants.add(tmp);
        }

        /// Reach Last Index
        if (i == variantLength - 1) {
          if (allVariants.length == 0) {
            print("** Product Variant Options is empty!");
            return null;
          } else {
            print('Product Variant Options Has Result!');
            return allVariants;
          }
        }
      }
    } else {
      print("** Product_Variants is null!");
      return null;
    }

    if (allVariants.length == 0) {
      print("** Product Variant Ref is empty!");
      return null;
    } else {
      print('Product Variant Ref Has Result!');
      return allVariants;
    }
  }

  /// Calculate Distance
  Future<double> calculateDistance(
    userLat,
    userLong,
    storeLat,
    storeLong,
  ) async {
    double distanceInMeters = Geolocator.distanceBetween(
      userLat,
      userLong,
      storeLat,
      storeLong,
    );

    return distanceInMeters;
  }

  /// Check Internet Status
  Future<bool> hasInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      // Neither mobile data or WIFI detected, not internet connection found.
      return false;
    }
  }

  void setLoadingStatus(bool value) {
    if (this.mounted) {
      isLoading = value;
      setState(() {});
    }
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    data =
        ModalRoute.of(context)?.settings.arguments as ProductDetailsArgument?;

    var mediaQuery = MediaQuery.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: kIsWeb == true
          ? WebDrawer(
              bottomAppBarState: data!.bottomAppBarState,
            )
          : null,
      appBar: getDeviceType(mediaQuery) != DeviceScreenType.Desktop
          ? AppBar(
              backgroundColor: isScrolling == true
                  ? Theme.of(context).shadowColor
                  : Colors.transparent,
              elevation: 0.0,
              title: isScrolling == true
                  ? Text(data!.productName,
                      style: TextStyle(color: Colors.black))
                  : null,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: isLoading == false
                    ? IconButton(
                        // splashColor: Colors.transparent,
                        // highlightColor: Colors.transparent,
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    : CustomLoading(),
              ),
            )
          : null,
      body: getDeviceType(mediaQuery) == DeviceScreenType.Desktop
          ? WebDesktopLayout(
              noCategories: false,
              content: SingleChildScrollView(
                controller: _scrollController,
                child: Container(
                  color: Theme.of(context).shadowColor,
                  padding: EdgeInsets.only(
                    top: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: getPageContentWEB(
                      _deviceDetails,
                      _widgetSize,
                      context,
                    ),
                  ),
                ),
              ),
              bottomAppBarState: data!.bottomAppBarState,
              widgetSize: _widgetSize,
              deviceDetails: _deviceDetails,
            )
          : ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
                minWidth: MediaQuery.of(context).size.width,
              ),
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.minScrollExtent) {
                    if (isScrolling == true) {
                      // print("Scroll Up");

                      isScrolling = false;
                      setState(() {});
                    }
                  } else if (_scrollController.position.userScrollDirection ==
                      ScrollDirection.reverse) {
                    if (isScrolling == false) {
                      // print("Scroll Down");

                      isScrolling = true;
                      setState(() {});
                    }
                  } else if (_scrollController.position.userScrollDirection ==
                      ScrollDirection.forward) {
                    if (isScrolling == false) {
                      isScrolling = true;
                      setState(() {});
                    }
                  }
                  return false;
                },
                child: Stack(
                  children: [
                    /// Main Content
                    CustomScrollView(
                      controller: _scrollController,
                      slivers:
                          getPageContentS(_deviceDetails, _widgetSize, context),
                    ),

                    /// Add to Cart
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: SizedBox(
                        width: _widgetSize.getResponsiveWidth(0.9, 0.45, 0.45),
                        height:
                            _widgetSize.getResponsiveHeight(0.07, 0.07, 0.07),
                        child: Center(
                          child: Builder(
                            builder: (BuildContext context) {
                              return TextButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                  backgroundColor: MaterialStateProperty.all(
                                      Theme.of(context).highlightColor),
                                  elevation: MaterialStateProperty.all(5),
                                  shadowColor:
                                      MaterialStateProperty.all(Colors.red),
                                ),
                                onPressed: isLoading == true
                                    ? null
                                    : () => cartChecker(_deviceDetails),
                                child: Center(
                                  // child: FirebaseAuth.instance.currentUser?.isAnonymous == false
                                  child: isLoading == true
                                      ? CustomLoading()
                                      : addToCartTextUI(_deviceDetails),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  // region Web Design
  List<Widget> getPageContentWEB(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    BuildContext context,
  ) {
    List<Widget> pageContent = <Widget>[];

    /// Product Images
    pageContent.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Image
          Expanded(
            flex: 3,
            child: Column(
              children: [
                getProductImage(
                  _widgetSize,
                  _deviceDetails,
                ),
                getProductDescriptionUI(
                  _widgetSize,
                  _deviceDetails,
                ),
              ],
            ),
          ),

          SizedBox(width: 30),

          /// Title + Price + Quantity + Add to Cart
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: webRow(
                _deviceDetails,
                _widgetSize,
                context,
              ),
            ),
          ),
        ],
      ),
    );

    /// Spacing
    pageContent.add(
      SizedBox(
        height: _widgetSize.getResponsiveWidth(0.5, 0.05, 0.05),
      ),
    );

    return pageContent;
  }

  List<Widget> webRow(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    BuildContext context,
  ) {
    List<Widget> pageContent = <Widget>[];

    /// Product Name
    pageContent.add(
      Container(
        padding: EdgeInsets.fromLTRB(
          _widgetSize.getResponsiveWidth(0.05, 0, 0),
          _widgetSize.getResponsiveWidth(0.03, 0, 0),
          _widgetSize.getResponsiveWidth(0.05, 0, 0),
          _widgetSize.getResponsiveWidth(0.03, 0, 0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Product Name
            Text(
              data!.productName,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
                fontSize: _deviceDetails.getTitleFontSize() + 5,
              ),
            ),

            SizedBox(
              height: 20,
            ),

            /// Price
            Text(
              "RM " + data!.priceString,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                fontSize: _deviceDetails.getTitleFontSize() + 5,
              ),
            ),
          ],
        ),
      ),
    );

    /// Show Product
    if (isLoading == false) {
      /// Quantity
      pageContent.add(getQuantity(_widgetSize, _deviceDetails));

      /// Green Line
      pageContent.add(
        Container(height: 3, color: Theme.of(context).highlightColor),
      );

      /// Available Branch Title
      pageContent.add(
        Padding(
          padding: EdgeInsets.fromLTRB(
            _widgetSize.getResponsiveWidth(0.05, 0, 0),
            _widgetSize.getResponsiveWidth(0.03, 0.01, 0.01),
            0,
            _widgetSize.getResponsiveWidth(0.02, 0.01, 0.01),
          ),
          child: Text(
            "Available Branch",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: _deviceDetails.getTitleFontSize(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

      /// Get Branch
      for (int i = 0; i < branchDataList.length; ++i) {
        pageContent.add(
          Padding(
            padding: EdgeInsets.only(
                bottom: _widgetSize.getResponsiveWidth(0.01, 0.01, 0.01)),
            child: Container(
              color: Theme.of(context).shadowColor,
              // height: _widgetSize.getResponsiveHeight(0.1),
              width: _widgetSize.getResponsiveWidth(1, 0.3, 0.3),
              padding: EdgeInsets.fromLTRB(
                0,
                _widgetSize.getResponsiveWidth(0.01, 0.01, 0.01),
                0,
                _widgetSize.getResponsiveWidth(0.01, 0.01, 0.01),
              ),
              child: RadioListTile(
                activeColor: Theme.of(context).highlightColor,
                value: branchDataList[i],
                groupValue: selectedBranchData,
                selected: false,
                onChanged: branchDataList[i].outOfStock == true
                    ? null
                    : (value) {
                        setState(() {
                          selectedBranchData = value as BranchData;
                          // branchValue = value;
                          print('===== Selected Branch ======');
                          print("Selected Branch ID: " +
                              selectedBranchData!.branchID);
                          print("Selected Branch Name: " +
                              selectedBranchData!.branchName);
                          print("Selected Branch Product ID: " +
                              selectedBranchData!.productID);
                          // print("Selected Branch Variant ID: " +
                          //     selectedBranchData!.variantID);
                          print("Selected Branch Distance: " +
                              selectedBranchData!.distance.toString());
                        });
                      },
                title: i == 0
                    ?

                    /// Nearest Branch
                    Row(
                        children: [
                          Text(
                            branchDataList[i].outOfStock == true
                                ? branchDataList[i].branchName +
                                    " (Out of Stock)"
                                : branchDataList[i].branchName,
                            style: TextStyle(
                              color: branchDataList[i].outOfStock == true
                                  ? Colors.grey
                                  : Theme.of(context).primaryColor,
                              fontSize: _deviceDetails.getNormalFontSize(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(" "),
                          if (branchDataList[i].disableNearest == false &&
                              branchDataList[i].outOfStock == false)
                            Expanded(
                              child: Text(
                                "(Nearest Branch)",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize:
                                      _deviceDetails.getNormalFontSize() - 2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                        ],
                      )
                    :

                    /// Others
                    Text(
                        branchDataList[i].outOfStock == true
                            ? branchDataList[i].branchName + " (Out of Stock)"
                            : branchDataList[i].branchName,
                        style: TextStyle(
                          color: branchDataList[i].outOfStock == true
                              ? Colors.grey
                              : Theme.of(context).primaryColor,
                          fontSize: _deviceDetails.getNormalFontSize(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        );
      }

      pageContent.add(
        SizedBox(
          width: _widgetSize.getResponsiveWidth(0.3, 0.15, 0.15),
          child: TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              backgroundColor:
                  MaterialStateProperty.all(Theme.of(context).highlightColor),
              elevation: MaterialStateProperty.all(5),
              shadowColor:
                  MaterialStateProperty.all(Theme.of(context).highlightColor),
            ),
            onPressed: isLoading == true
                ? null
                : () => cartChecker(
                      _deviceDetails,
                    ),
            child: Center(
              child: isLoading == true
                  ? CustomLoading()
                  : addToCartTextUI(_deviceDetails),
            ),
          ),
        ),
      );
    }

    /// Product is Loading
    else {
      /// Spacing
      pageContent.add(SizedBox(
        height: _widgetSize.getResponsiveWidth(0.1, 0.03, 0.03),
      ));

      /// Loading Text
      pageContent.add(
        Container(
          color: Theme.of(context).shadowColor,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
              _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
              0,
              _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
            ),
            child: Text(
              "Loading",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: _deviceDetails.getTitleFontSize(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return pageContent;
  }
  // endregion

  List<Widget> getPageContentS(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    BuildContext context,
  ) {
    List<Widget> pageContent = <Widget>[];

    /// Product Images
    pageContent.add(
      SliverToBoxAdapter(
        child: getProductImage(_widgetSize, _deviceDetails),
      ),
    );

    /// Product Name + Price + Description
    pageContent.add(
      SliverToBoxAdapter(child: getTitlePrice(_widgetSize, _deviceDetails)),
    );

    /// Show Product
    if (isLoading == false) {
      /// Quantity
      pageContent.add(
        SliverToBoxAdapter(
          child: getQuantity(_widgetSize, _deviceDetails),
        ),
      );

      /// Green Line
      pageContent.add(
        SliverToBoxAdapter(
            child:
                Container(height: 3, color: Theme.of(context).highlightColor)),
      );

      /// Available Branch Title
      pageContent.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
              _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
              0,
              _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
            ),
            child: Text(
              "Available Branch",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: _deviceDetails.getTitleFontSize(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );

      /// Get Branch
      for (int i = 0; i < branchDataList.length; ++i) {
        pageContent.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: _widgetSize.getResponsiveWidth(0.01, 0.01, 0.01)),
              child: Container(
                color: Theme.of(context).shadowColor,
                // height: _widgetSize.getResponsiveHeight(0.1),
                width: _widgetSize.getResponsiveWidth(1, 1, 1),
                padding: EdgeInsets.fromLTRB(
                  0,
                  _widgetSize.getResponsiveWidth(0.01, 0.01, 0.01),
                  0,
                  _widgetSize.getResponsiveWidth(0.01, 0.01, 0.01),
                ),
                child: RadioListTile(
                  activeColor: Theme.of(context).highlightColor,
                  value: branchDataList[i],
                  groupValue: selectedBranchData,
                  selected: false,
                  onChanged: branchDataList[i].outOfStock == true
                      ? null
                      : (value) {
                          setState(() {
                            selectedBranchData = value as BranchData;
                            // branchValue = value;
                            print('===== Selected Branch ======');
                            print("Selected Branch ID: " +
                                selectedBranchData!.branchID);
                            print("Selected Branch Name: " +
                                selectedBranchData!.branchName);
                            print("Selected Branch Product ID: " +
                                selectedBranchData!.productID);
                            // print("Selected Branch Variant ID: " +
                            //     selectedBranchData!.variantID);
                            print("Selected Branch Distance: " +
                                selectedBranchData!.distance.toString());
                          });
                        },
                  title: i == 0
                      ?

                      /// Nearest Branch
                      Row(
                          children: [
                            Text(
                              branchDataList[i].outOfStock == true
                                  ? branchDataList[i].branchName +
                                      " (Out of Stock)"
                                  : branchDataList[i].branchName,
                              style: TextStyle(
                                color: branchDataList[i].outOfStock == true
                                    ? Colors.grey
                                    : Theme.of(context).primaryColor,
                                fontSize: _deviceDetails.getNormalFontSize(),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(" "),
                            if (branchDataList[i].disableNearest == false &&
                                branchDataList[i].outOfStock == false)
                              Expanded(
                                child: Text(
                                  "(Nearest Branch)",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize:
                                        _deviceDetails.getNormalFontSize() - 2,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                          ],
                        )
                      :

                      /// Others
                      Text(
                          branchDataList[i].outOfStock == true
                              ? branchDataList[i].branchName + " (Out of Stock)"
                              : branchDataList[i].branchName,
                          style: TextStyle(
                            color: branchDataList[i].outOfStock == true
                                ? Colors.grey
                                : Theme.of(context).primaryColor,
                            fontSize: _deviceDetails.getNormalFontSize(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      }

      /// Variant Type
      if (selectedBranchData?.productVariantTypesList != null) {
        /// Display Variant Types
        for (int i = 0;
            i < selectedBranchData!.productVariantTypesList!.length;
            ++i) {
          /// Available Branch Title
          pageContent.add(
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                  _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
                  0,
                  _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
                ),
                child: Text(
                  "Available " +
                      selectedBranchData!.productVariantTypesList![i]
                          .Product_Variant_Types_name,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: _deviceDetails.getTitleFontSize(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );

          /// Display Variant Option
          for (int j = 0;
              j <
                  selectedBranchData!
                      .productVariantTypesList![i].productVariantOptions.length;
              ++j) {
            pageContent.add(
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: _widgetSize.getResponsiveWidth(0.01, 0.01, 0.01)),
                  child: Container(
                    color: Theme.of(context).shadowColor,
                    // height: _widgetSize.getResponsiveHeight(0.1),
                    width: _widgetSize.getResponsiveWidth(1, 1, 1),
                    padding: EdgeInsets.fromLTRB(
                      0,
                      _widgetSize.getResponsiveWidth(0.01, 0.01, 0.01),
                      0,
                      _widgetSize.getResponsiveWidth(0.01, 0.01, 0.01),
                    ),
                    child: RadioListTile(
                      activeColor: Theme.of(context).highlightColor,
                      value: selectedBranchData!
                          .productVariantTypesList![i].productVariantOptions[j],
                      groupValue: selectedBranchData!
                          .productVariantTypesList![i].selectedVariantOptions,
                      selected: false,
                      onChanged: (value) {
                        setState(() {
                          print('Selected Option: ' +
                              selectedBranchData!.productVariantTypesList![i]
                                  .productVariantOptions[j].Option_name);
                          selectedBranchData!.productVariantTypesList![i]
                                  .selectedVariantOptions =
                              selectedBranchData!.productVariantTypesList![i]
                                  .productVariantOptions[j];

                          if (selectedBranchData!.productVariantTypesList![i]
                                  .selectedVariantOptions !=
                              null) {
                            print('Final Selected Option: ' +
                                selectedBranchData!.productVariantTypesList![i]
                                    .selectedVariantOptions!.Option_name);
                          } else {
                            print('selected variant is null!');
                          }
                        });
                        // setState(() {
                        //   selectedProductVariant = value as ProductVariant;
                        //   print('===== Selected Product Variant ======');
                        //   // Product Variant
                        //   if (selectedProductVariant != null) {
                        //     print(
                        //         "Selected Variant *Product_Variant_Options_id: " +
                        //             selectedProductVariant!
                        //                 .Product_Variant_Options_id);
                        //     print(
                        //         "Selected Variant *Product_Variant_Options_name: " +
                        //             selectedProductVariant!
                        //                 .Product_Variant_Options_name);
                        //     print("Selected Variant *Product_Variant_Price: " +
                        //         selectedProductVariant!.Product_Variant_Price);
                        //   }
                        // });
                      },
                      title: Text(
                        selectedBranchData!.productVariantTypesList![i]
                            .productVariantOptions[j].Option_name,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: _deviceDetails.getNormalFontSize(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        }
      }
    }

    /// Product Loading
    else {
      /// Spacing
      pageContent.add(SliverToBoxAdapter(
        child: SizedBox(
          height: _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
        ),
      ));

      /// Loading Text
      pageContent.add(
        SliverToBoxAdapter(
          child: Container(
            color: Theme.of(context).shadowColor,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
                0,
                _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02),
              ),
              child: Text(
                "Loading",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: _deviceDetails.getTitleFontSize(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }

    /// Spacing
    pageContent.add(SliverToBoxAdapter(
      child: SizedBox(
        height: _widgetSize.getResponsiveWidth(0.5, 0.5, 0.5),
      ),
    ));

    return pageContent;
  }
}

class BranchData {
  String productID;
  String branchID;
  String branchName;
  String branchLatitude;
  String branchLongitude;
  double? distance;
  bool disableNearest;
  bool outOfStock;

  List<ProductVariantType>? productVariantTypesList;
  List<ProductVariant>? allVariantRef; // All Variant Ref

  // Not Used
  ProductVariantType? productVariantFinal;
  ProductVariantResult? productVariantResult;

  BranchData({
    required this.productID,
    required this.branchID,
    required this.branchName,
    required this.branchLatitude,
    required this.branchLongitude,
    this.distance,
    required this.disableNearest,
    this.outOfStock = true,
    required this.productVariantTypesList,
    required this.allVariantRef,
    // Not Used
    required this.productVariantFinal,
  });
}

class DetailScreen extends StatefulWidget {
  final String tag;
  final String imgString;

  DetailScreen({
    Key? key,
    required this.tag,
    required this.imgString,
  }) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
  void dispose() {
    //SystemChrome.restoreSystemUIOverlays();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).shadowColor,
              // borderRadius: BorderRadius.circular(40.0),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              splashColor: Colors.transparent,
              icon: Icon(
                Icons.clear,
                color: Theme.of(context).highlightColor,
                size: 30,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
        leading: Container(),
      ),
      body: Center(
        child: Hero(
          tag: widget.tag,
          child: PhotoView(
            imageProvider: CachedNetworkImageProvider(widget.imgString),
          ),
        ),
      ),
    );
  }
}
