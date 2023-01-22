import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '/Cart/Cart-Checkout.dart';
import '/Cart/Voucher/Get-Voucher-SelectPage.dart';
import '/Cart/Voucher/Select-VoucherPage.dart';
import '/Core/auth.dart';
import '/Custom-UI/Custom-ListTilePrice.dart';
import '/Custom-UI/Custom-LoadingUI.dart';
import '/Data-Class/CartCheckoutArgument.dart';
import '/Data-Class/CartMinClass.dart';
import '/Data-Class/ProductVariant.dart';
import '/Data-Class/ShippingDataClass.dart';
import '/Data-Class/ToggleableItemClass.dart';
import '/Data-Class/VoucherDataClass.dart';
import '/Functions/Messager.dart';
import '/Nav.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';
import '/Screen-Size/ui-utils.dart';
import '/enums/device-screen-type.dart';
import 'package:page_transition/page_transition.dart';
import '/main.dart';

/* Important Note
First Index for ProductMap is to identify the whole branch status
Such as:
boolValue = item checkbox
totalPrice = total price of branch
shippingData = shipping details of branch
voucherData = voucher details of branch
priceAfterDiscount = total price after discount of branch
hasItemChecked = has item or not in the branch
 */

class CartPage extends StatefulWidget {
  static const routeName = '/CartPage';
  final BottomAppBarState bottomAppBarState;

  CartPage({Key? key, required this.bottomAppBarState}) : super(key: key);

  @override
  CartPageState createState() => CartPageState();
}

class CartPageState extends State<CartPage> {
  bool selectAll = false;
  var totalPrice = 0.00;
  var firestoreRef;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Map<String, List<ToggleableItemClass>> productsMap =
      new Map<String, List<ToggleableItemClass>>();

  bool shouldUpdate = true;
  User firebaseUser = FirebaseAuth.instance.currentUser as User;
  bool loaded = false;
  bool isEmptyCart = true;
  int totalItem = 0;
  bool firstLoad = false;

  bool editMode = false;
  List<DocumentSnapshot> cartData = [];
  final formatCurrency = new NumberFormat.currency(
    locale: "ms-MY",
    symbol: "",
    decimalDigits: 2,
  );

  @override
  void initState() {
    firestoreRef = FirebaseFirestore.instance
        .collection('Cart')
        .where("User_ID", isEqualTo: firebaseUser.uid)
        .snapshots();

    if (this.mounted) {
      setState(() {});
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // region UI
  /// Custom App bar
  PreferredSize _getCustomAppBar(
    String title,
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
  ) {
    var mediaQuery = MediaQuery.of(context);

    return PreferredSize(
      preferredSize: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
          ? Size.fromHeight(55.0)
          : Size.fromHeight(80.0),
      child: Material(
        elevation: 8,
        shadowColor: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  decoration:
                      BoxDecoration(color: Theme.of(context).backgroundColor),
                ),
                SafeArea(
                  minimum: getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                      ? EdgeInsets.fromLTRB(
                          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                          0,
                          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                          0,
                        )
                      : EdgeInsets.fromLTRB(
                          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                          0,
                          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                          0,
                        ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Empty Box
                      SizedBox(
                        width: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                      ),

                      /// Title
                      SizedBox(
                        width:
                            getDeviceType(mediaQuery) == DeviceScreenType.Mobile
                                ? _widgetSize.getResponsiveWidth(0.6, 0.6, 0.6)
                                : _widgetSize.getResponsiveWidth(0.5, 0.5, 0.5),
                        child: Center(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: _deviceDetails.getTitleFontSize(),
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      /// Edit
                      if (isEmptyCart == false)
                        InkWell(
                          onTap: () {
                            if (editMode == true) {
                              editMode = false;

                              /// Unchecked all checked box
                              setAllItemBool(false);
                              selectAll = false;
                              totalPrice = 0;
                              setState(() {});
                            } else if (editMode == false) {
                              editMode = true;

                              /// Unchecked all checked box
                              setAllItemBool(false);
                              selectAll = false;
                              totalPrice = 0;
                              setState(() {});
                            }
                          },
                          child: Text(
                            editMode == false ? "Edit" : "Done",
                            style: TextStyle(
                              fontSize: _deviceDetails.getTitleFontSize(),
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                      /// Empty Box
                      if (isEmptyCart == true)
                        SizedBox(
                          width:
                              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                        ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// Quantity Buttons
  Widget quantityButtons(
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
    String branchName,
    int index,
  ) {
    return Container(
      width: _widgetSize.getResponsiveWidth(0.25, 0.25, 0.25),
      child: Row(
        children: [
          /// "-"
          SizedBox(
            width: _widgetSize.getResponsiveWidth(0.06, 0.06, 0.06),
            height: _widgetSize.getResponsiveWidth(0.06, 0.06, 0.06),
            child: InkWell(
              onTap: () {
                hasInternet().then((value) {
                  if (value == true) {
                    decreaseQuantity(branchName, index);
                  } else {
                    showSnackBar('No Internet Connection', context);
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).shadowColor,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                child: Icon(
                  Icons.remove,
                  color: Theme.of(context).primaryColor,
                  size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                ),
              ),
            ),
          ),

          /// Quantity Text
          Expanded(
            child: Center(
              child: Text(
                productsMap[branchName]![index].quantity.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: _deviceDetails.getTitleFontSize(),
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),

          /// "+"
          SizedBox(
            width: _widgetSize.getResponsiveWidth(0.06, 0.06, 0.06),
            height: _widgetSize.getResponsiveWidth(0.06, 0.06, 0.06),
            child: InkWell(
              onTap: () {
                hasInternet().then((value) {
                  if (value == true) {
                    addQuantity(branchName, index);
                  } else {
                    showSnackBar('No Internet Connection', context);
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).shadowColor,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).primaryColor,
                  size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Each Branch Voucher UI
  Widget getEachBranchVoucherUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    String branchName,
  ) {
    return Container(
      width: _widgetSize.getResponsiveWidth(1, 1, 1),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(
            width: 1.5,
            color: Colors.black,
          ),
          bottom: BorderSide(
            width: 1.5,
            color: Colors.black,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
        _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
      ),
      child: InkWell(
        onTap: () {
          if (FirebaseAuth.instance.currentUser?.isAnonymous == false) {
            goToSelectVoucherPage(branchName);
          } else {
            showLoginMessage(0, 15, context);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Voucher Applied Title
            if (productsMap[branchName]?[0].voucherData != null)
              Text(
                'Voucher [${productsMap[branchName]?[0].voucherData!.voucherCode}] Applied',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).primaryColorLight,
                ),
              ),

            /// Select A Voucher Title
            if (productsMap[branchName]?[0].voucherData == null)
              Text(
                'Select A Voucher',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: _deviceDetails.getNormalFontSize(),
                  color: Theme.of(context).primaryColorLight,
                ),
              ),

            /// Voucher Code + Arrow
            if (productsMap[branchName]?[0].voucherData != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  /// Voucher Code
                  Text(
                    productsMap[branchName]![0].voucherData!.voucherCode + " ",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: _deviceDetails.getNormalFontSize(),
                      color: Colors.black,
                    ),
                  ),

                  /// Arrow
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).primaryColorLight,
                    size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                  )
                ],
              ),

            /// Arrow
            if (productsMap[branchName]?[0].voucherData == null)
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColorLight,
                size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
              ),
          ],
        ),
      ),
    );
  }
  // endregion

  // region Function
  Future<void> getCartData(User firebaseUser) async {
    QuerySnapshot data = await FirebaseFirestore.instance
        .collection('Cart')
        .where("User_ID", isEqualTo: firebaseUser.uid)
        .get();

    if (data.docs.length == 0) {
      if (this.mounted) {
        setState(() {
          isEmptyCart = true;
        });
      }
      return;
    }
    cartData.addAll(data.docs);

    print("User Cart Has: " + cartData.length.toString());
    if (this.mounted) {
      setState(() {
        isEmptyCart = false;
      });
    }
  }

  /// Delete Cart From Edit Mode
  void deleteCartFromEdit() {
    /// Delete Selected Items
    productsMap.forEach((branchName, list) {
      /// If the first index is checked (whole branch selected)
      if (list[0].boolValue == true) {
        /// Remove the whole branch cart and Products
        removeBranchCartFromDB(
          list[0].branchCartID as String,
          firebaseUser.uid,
        ).then((value) {
          for (int i = 0; i < list.length; ++i) {
            if (i > 0) {
              /// Reach last index
              if (i == list.length - 1) {
                /// Remove Item from DB
                removeItemFromDB(
                    list[i].branchCartID as String, list[i].productId);
                list[i].isDisable = true;

                /// Remove From Map
                productsMap.remove(
                  branchName,
                );
                showSnackBar("Product removed from Cart", context);
                setState(() {});
              } else {
                removeItemFromDB(
                    list[i].branchCartID as String, list[i].productId);
                list[i].isDisable = true;
              }
            } else {
              list[0].isDisable = true;
            }
          }
        });
      }

      /// Remove Each Individual Product if its check
      else {
        for (int i = 0; i < list.length; ++i) {
          if (i > 0) {
            if (list[i].boolValue == true) {
              if (i == list.length - 1) {
                removeItemFromMap(
                  branchName,
                  i,
                );
                list[i].isDisable = true;

                showSnackBar("Product removed from Cart", context);
                setState(() {});
              } else {
                removeItemFromMap(
                  branchName,
                  i,
                );
                list[i].isDisable = true;
              }
            }
          }
        }
      }
    });

    widget.bottomAppBarState.updateCartQuantity();
  }

  Map<String, List<ToggleableItemClass>> addAllSelectedItemToMap() {
    totalItem = 0;
    Map<String, List<ToggleableItemClass>> tempMap =
        Map<String, List<ToggleableItemClass>>();

    productsMap.forEach((branchName, value) {
      for (int i = 0; i < productsMap[branchName]!.length; ++i) {
        if (i > 0) {
          if ((productsMap[branchName]![i].boolValue) == true) {
            /// Check if the Products contain in the Map
            if (tempMap.containsKey(branchName) == true) {
              /// Check the existing branch have existing products or not
              if (tempMap[branchName]?.contains(productsMap[branchName]?[i]) ==
                  false) {
                /// Add it to the existing map
                tempMap[branchName]!.add(productsMap[branchName]![i]);
                ++totalItem;
              }
            }

            /// Products doesnt contain in the map
            else {
              /// Add First One (Branch Name)
              Map<String, List<ToggleableItemClass>> temp = {
                branchName: [productsMap[branchName]![0]],
              };
              tempMap.addAll(temp);

              /// Then add First product
              tempMap[branchName]!.add(productsMap[branchName]![i]);
              ++totalItem;
            }
          }
        }
      }
    });

    return tempMap;
  }

  /// Get Product Variants List
  Future<ProductVariantType?> getAllProductVariantList(
      Map<String, dynamic> cartDetailsMapData) async {
    print("Getting Product Variant...");
    List<ProductVariant> productVariantsList = [];
    ProductVariantResult productVariantFinal = ProductVariantResult(
      Product_Variant_Types_id: '',
      Product_Variant_Types_name: '',
      productVariantOptionsList: productVariantsList,
    );

    // Check Product Variant Type Id
    if (cartDetailsMapData["Product_Variant_Types_id"] != null) {
      print('Product_Variant_Types_id not null');

      productVariantFinal.Product_Variant_Types_id =
          cartDetailsMapData["Product_Variant_Types_id"];
    } else {
      print("** Product_Variant_Types_id is null!");
      return null;
    }

    // Check Product Variant Type Name
    if (cartDetailsMapData["Product_Variant_Types_name"] != null) {
      print('Product_Variant_Types_name not null');

      productVariantFinal.Product_Variant_Types_name =
          cartDetailsMapData["Product_Variant_Types_name"];
    } else {
      print("** Product_Variant_Types_name is null!");
      return null;
    }

    // Check Product Variant List is null
    if (cartDetailsMapData["Product_Variant_List"] != null) {
      int variantLength = cartDetailsMapData["Product_Variant_List"].length;
      if (variantLength == 0) {
        print("** Product_Variant_List is empty!");
        return null;
      }
      // Assign Product Variant
      for (int i = 0; i < variantLength; ++i) {
        ProductVariant tmp = ProductVariant(
          Product_Variant_Options_id: cartDetailsMapData["Product_Variant_List"]
                  [i]['Product_Variant_Options_id'] ??
              '',
          Product_Variant_Options_name:
              cartDetailsMapData["Product_Variant_List"][i]
                      ['Product_Variant_Options_name'] ??
                  '',
          Product_Variant_Price: cartDetailsMapData["Product_Variant_List"][i]
                  ['Product_Variant_Price'] ??
              '',
          options: [],
        );

        /// Add to List
        productVariantsList.add(tmp);

        /// Reach Last Index
        if (i == variantLength - 1) {
          productVariantFinal.productVariantOptionsList = productVariantsList;
        }
      }
    } else {
      print("** Product_Variant_List is null!");
      return null;
    }

    if (productVariantFinal.productVariantOptionsList.length == 0) {
      print("** productVariantsList is empty!");
      return null;
    } else {
      print('productVariantsList Has Result!');
      // return productVariantsList;
    }
  }

  /// Get Selected Product Variants
  Future<ProductVariant?> getSelectedProductVariantData(
    Map<String, dynamic> cartDetailsMapData,
  ) async {
    print("Getting Selected Product Variant...");
    String Product_Variant_Options_id;
    String Product_Variant_Options_name;
    String Product_Variant_Price;

    // Check Product_Variant_Options_id
    if (cartDetailsMapData["Product_Variant_Options_id"] != null) {
      print('Product_Variant_Options_id not null');

      Product_Variant_Options_id =
          cartDetailsMapData["Product_Variant_Options_id"];
    } else {
      print("** Product_Variant_Options_id is null!");
      return null;
    }

    // Check Product_Variant_Options_name
    if (cartDetailsMapData["Product_Variant_Options_name"] != null) {
      print('Product_Variant_Options_name not null');

      Product_Variant_Options_name =
          cartDetailsMapData["Product_Variant_Options_name"];
    } else {
      print("** Product_Variant_Options_name is null!");
      return null;
    }

    // Check Product_Variant_Price
    if (cartDetailsMapData["Product_Variant_Price"] != null) {
      print('Product_Variant_Price not null');

      Product_Variant_Price = cartDetailsMapData["Product_Variant_Price"];
    } else {
      print("** Product_Variant_Price is null!");
      return null;
    }

    ProductVariant productVariant = ProductVariant(
      Product_Variant_Options_id: Product_Variant_Options_id,
      Product_Variant_Options_name: Product_Variant_Options_name,
      Product_Variant_Price: Product_Variant_Price,
      options: [],
    );

    return productVariant;
  }

  Future<void> assignData(
    List<DocumentSnapshot> branchCartData,
    WidgetSizeCalculation _widgetSize,
    DeviceDetails _deviceDetails,
  ) async {
    firstLoad = true;
    if (shouldUpdate == false) {
      firstLoad = false;
      return;
    }
    print('======= Branch Cart ID ============');
    String branchCartID;
    String branchProviderID;
    // print("branchCartData Length: " + branchCartData.length.toString());

    /// Define Branch Map Data
    Map<String, dynamic> branchData = Map<String, dynamic>();

    /// Define Cart Details Map Data
    Map<String, dynamic> cartDetailsMapData = Map<String, dynamic>();

    for (int i = 0; i < branchCartData.length; ++i) {
      /// Assign Data
      branchData = branchCartData[i].data() as Map<String, dynamic>;

      branchCartID = branchData['Cart_ID'];
      branchProviderID = branchData['Provider_ID'];
      print("[Branch provider ID $branchProviderID] " + branchCartID);

      QuerySnapshot cartDetailsData;
      cartDetailsData = await firestore
          .collection('CartDetails')
          .where("Cart_ID", isEqualTo: branchCartID)
          .where("Provider_ID", isEqualTo: branchData['Provider_ID'])
          .get();

      /// Has Cart Details Data
      if (cartDetailsData.docs.length > 0) {
        // print("cartDetailsData Length: " + cartDetailsData.docs.length.toString());

        String productID;
        String providerID;
        String productName;
        double productPrice;
        int productQuantity;
        String productImage;

        for (int j = 0; j < cartDetailsData.docs.length; ++j) {
          /// Assign Data
          cartDetailsMapData =
              cartDetailsData.docs[j].data() as Map<String, dynamic>;

          // region Assign Data
          productName = cartDetailsMapData["Product_Name"];
          providerID = cartDetailsMapData["Provider_ID"];
          // variantID = cartDetailsMapData["Variant_ID"];
          productID = cartDetailsMapData["Product_ID"];
          productQuantity = int.parse(cartDetailsMapData["Quantity"]);
          productImage = cartDetailsMapData["Image"];

          // Use Variant Price if exist
          productPrice = double.parse(
              cartDetailsMapData["Product_Variant_Price"] ??
                  cartDetailsMapData["Price"]);

          ProductVariantType? productVariantFinal =
              await getAllProductVariantList(cartDetailsMapData);
          ProductVariant? selectedProductVariant =
              await getSelectedProductVariantData(cartDetailsMapData);
          // endregion

          /// Get Branch Name
          DocumentSnapshot branchSnapshot;
          branchSnapshot =
              await firestore.collection('Branches').doc(providerID).get();

          /// Define Map Data
          Map<String, dynamic> branchSnapData = Map<String, dynamic>();

          /// Assign Data
          branchSnapData = branchSnapshot.data() as Map<String, dynamic>;

          String branchName = branchSnapData["Area"];

          /// Define Cart Details data
          ToggleableItemClass temp = ToggleableItemClass(
            branchCartID: branchCartID,
            productName: productName,
            productId: productID,
            // variantId: variantID,
            providerId: providerID,
            price: productPrice,
            boolValue: false,
            quantity: productQuantity,
            image: productImage,
            isDisable: false,
            totalPrice: 0,
            shippingData: ShippingData(isNULL: true),
            productVariantFinal: productVariantFinal,
            selectedProductVariant: selectedProductVariant,
          );

          /// Add Empty (For Toggle Branch Name)
          if (j == 0) {
            ToggleableItemClass empty = ToggleableItemClass(
              productId: "",
              variantId: "",
              providerId: providerID,
              price: 0.00,
              boolValue: false,
              branchCartID: branchCartID,
              isDisable: false,
              quantity: 0,
              shippingData: ShippingData(isNULL: true),
              voucherData: null,
              totalPrice: 0,
              productVariantFinal: productVariantFinal,
              selectedProductVariant: selectedProductVariant,
            );
            addToMap(branchName, empty);
          }

          /// Add to map
          addToMap(branchName, temp);

          /// Reached Last Product Index
          if (i == (branchCartData.length - 1) &&
              j == (cartDetailsData.docs.length - 1)) {
            /// Print Product Map
            productsMap.forEach((key, List<ToggleableItemClass> value) {
              for (int index = 0; index < value.length; ++index) {
                if (index > 0) {
                  print("Product[${value[index].productId}] is Inside: " +
                      "Branch [$key]");
                }
              }
            });
            firstLoad = false;
            shouldUpdate = false;
            setState(() {});
          }
        }
      } else {
        print("Branch Cart Not Added: " + branchCartID);
      }
    }
  }

  void addToMap(
    String targetBranch,
    ToggleableItemClass data,
  ) {
    /// Check if the Products contain in the Map
    if (productsMap.containsKey(targetBranch) == true) {
      // print("Contained");

      /// Check the existing branch have existing products or not
      if (productsMap[targetBranch]?.contains(data) == false) {
        /// Add it to the existing map
        productsMap[targetBranch]!.add(data);
      }
    }

    /// Products doesnt contain in the map
    else {
      Map<String, List<ToggleableItemClass>> temp = {
        targetBranch: [data],
      };
      productsMap.addAll(temp);
    }
  }

  /// Select / deselect all product items
  void setAllItemBool(bool value) {
    productsMap.forEach((key, list) {
      for (int i = 0; i < productsMap[key]!.length; ++i) {
        productsMap[key]![i].boolValue = value;
      }
    });
  }

  /// Select / deselect single branch items
  void setBranchBool(String branchName, bool value) {
    for (int i = 0; i < productsMap[branchName]!.length; ++i) {
      toggleProductSelection(branchName, i, value);
    }
  }

  /// Calculate All Total Price
  Future<void> checkBranchCheckBox(String branchName) async {
    bool allActive = true;
    for (int i = 0; i < productsMap[branchName]!.length; ++i) {
      if (i > 0) {
        if (productsMap[branchName]![i].boolValue == false) {
          allActive = false;
          // print(productsMap[branchName][i].productId);
        }
      }
    }
    if (allActive == true) {
      productsMap[branchName]![0].boolValue = true;
    } else {
      productsMap[branchName]![0].boolValue = false;
    }
  }

  /// Toggle Product
  void toggleProductSelection(
    String branchName,
    index,
    bool value,
  ) {
    productsMap[branchName]![index].boolValue = value;

    /// Check if the target branch all product active
    checkBranchCheckBox(branchName).then((value) {
      for (int i = 0; i < productsMap[branchName]!.length; ++i) {
        if (i > 0) {
          /// If one of the item in branch is checked
          if (productsMap[branchName]![i].boolValue == true) {
            /// Set branch first index for hasItemChecked = true
            productsMap[branchName]![0].hasItemChecked = true;
            print("Branch [$branchName] has item!");
            break;
          }
          if (i == productsMap[branchName]!.length - 1) {
            productsMap[branchName]![0].hasItemChecked = false;
            print("Branch [$branchName] no item!");
          }
        }
      }

      /// Calculate Total Price
      checkAndCalculateTotalPrice();
    });
  }

  // region Change Quantity
  /// Add Product Quantity
  void addQuantity(String branchName, int i) {
    ++productsMap[branchName]![i].quantity;

    /// Update Quantity From DB
    updateQuantityFromDB(
      productsMap[branchName]![i].branchCartID as String,
      productsMap[branchName]![i].productId,
      productsMap[branchName]![i].quantity,
    ).then((value) {
      /// Calculate Total Price
      checkAndCalculateTotalPrice();
      setState(() {});
    });
  }

  /// Decrease Product Quantity
  void decreaseQuantity(String branchName, int i) {
    if (productsMap[branchName]![i].quantity > 1) {
      --productsMap[branchName]![i].quantity;

      /// Update Quantity From DB
      updateQuantityFromDB(
        productsMap[branchName]![i].branchCartID as String,
        productsMap[branchName]![i].productId,
        productsMap[branchName]![i].quantity,
      ).then((value) {
        /// Calculate Total Price
        checkAndCalculateTotalPrice();
        setState(() {});
      });
    } else {
      /// Remove Product
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).backgroundColor,
            content: Text(
              'Remove this item ?',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w400,
              ),
            ),
            actions: [
              TextButton(
                child: Text("Cancel",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w400,
                    )),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("Remove",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w400,
                    )),
                onPressed: () {
                  setState(() {
                    removeItemFromMap(branchName, i);
                    Navigator.of(context).pop();
                  });
                },
              ),
            ],
          );
        },
      );
    }
    setState(() {});
  }
  // endregion

  /// Remove Product
  void removeItemFromMap(
    String branchName,
    int i,
  ) {
    hasInternet().then((value) {
      if (value == true) {
        /// Remove Product From DB
        removeItemFromDB(
          productsMap[branchName]![i].branchCartID as String,
          productsMap[branchName]![i].productId,
        ).then((value) {
          productsMap[branchName]![i].isDisable = true;
          productsMap[branchName]?.remove(productsMap[branchName]![i]);

          /// Calculate Total Price
          checkAndCalculateTotalPrice();

          /// If No more item
          if (productsMap[branchName]!.length == 1) {
            productsMap[branchName]![0].isDisable = true;

            /// Remove Branch Cart From DB
            removeBranchCartFromDB(
              productsMap[branchName]![0].branchCartID as String,
              firebaseUser.uid,
            ).then((value) {
              /// Remove branch from map
              productsMap.remove(branchName);
            });
          }
        });
      } else {
        showSnackBar('No Internet Connection', context);
      }
    });

    widget.bottomAppBarState.updateCartQuantity();
  }

  /// Get Current Branch Total Price
  double getBranchTotalPrice(String branchName) {
    double bTotalPrice = 0;
    for (int i = 0; i < productsMap[branchName]!.length; ++i) {
      if (i > 0) {
        bTotalPrice += (productsMap[branchName]![i].price! *
            productsMap[branchName]![i].quantity);
      }
    }
    return bTotalPrice;
  }

  /// Reset and Calculate Total Price
  void checkAndCalculateTotalPrice() {
    totalPrice = 0;
    double subBranchTotalPrice = 0;
    productsMap.forEach((key, value) {
      subBranchTotalPrice = 0;
      for (int i = 0; i < productsMap[key]!.length; ++i) {
        if (i > 0) {
          if (productsMap[key]![i].boolValue == true) {
            totalPrice +=
                (productsMap[key]![i].price! * productsMap[key]![i].quantity);
            subBranchTotalPrice +=
                (productsMap[key]![i].price! * productsMap[key]![i].quantity);
          }
        }

        if (i == productsMap[key]!.length - 1) {
          productsMap[key]![0].totalPrice = subBranchTotalPrice;
        }
      }
    });
  }

  // region DB Functions
  /// Remove Branch Cart From DB
  Future<void> removeBranchCartFromDB(String cartID, String userID) async {
    print("===== Removing Branch Cart From DB ======");
    print("Cart ID: " + cartID);
    print("User ID: " + userID);

    QuerySnapshot cartData;
    cartData = await firestore
        .collection('Cart')
        .where("Cart_ID", isEqualTo: cartID)
        .where("User_ID", isEqualTo: userID)
        .get();

    /// Existing Data
    if (cartData.docs.length > 0) {
      /// Remove Cart Details Document
      // region Remove Cart Details Data
      FirebaseFirestore.instance
          .collection("Cart")
          .doc(cartData.docs[0].id)
          .delete()
          .then((value) async {
        // widget.bottomAppBarState.updateCartQuantity();
        print("Removed Branch Cart from [$userID]");
        widget.bottomAppBarState.updateCartQuantity();
      });
      // endregion
    } else {
      showSnackBar("Branch Cart Not Exist", context);
    }
  }

  /// Remove Item from DB
  Future<void> removeItemFromDB(String cartID, String productID) async {
    print("===== Removing Product From DB ======");
    print("Cart ID: " + cartID);
    print("Product ID: " + productID);

    QuerySnapshot cartDetails;
    cartDetails = await firestore
        .collection('CartDetails')
        .where("Cart_ID", isEqualTo: cartID)
        .where("Product_ID", isEqualTo: productID)
        .get();

    /// Existing Data
    if (cartDetails.docs.length > 0) {
      /// Remove Cart Details Document
      // region Remove Cart Details Data
      FirebaseFirestore.instance
          .collection("CartDetails")
          .doc(cartDetails.docs[0].id)
          .delete()
          .then((value) async {
        print("Product Removed From Cart Details and Cart");
        widget.bottomAppBarState.updateCartQuantity();

        /// Update branch cart price
        // region Update Branch Cart Price & Quantity
        QuerySnapshot allCartDetailsSnapshot;
        allCartDetailsSnapshot = await firestore
            .collection('CartDetails')
            .where("Cart_ID", isEqualTo: cartID)
            .get();
        double totalPrice = 0;
        double eachPrice;
        int eachQuantity;
        double eachFinalPrice;

        /// Define Map Data
        Map<String, dynamic> allCartDetailsMapData = Map<String, dynamic>();

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
              widget.bottomAppBarState.updateCartQuantity();
            });
          }
        }
        // endregion
      });
      // endregion
    } else {
      showSnackBar("Item Not Exist", context);
    }
  }

  /// Update Quantity from DB
  Future<void> updateQuantityFromDB(
    String cartID,
    String productID,
    int quantity,
  ) async {
    print("===== Updating DB Product Quantity ======");
    print("Cart ID: " + cartID);
    print("Product ID: " + productID);
    print("Quantity: " + quantity.toString());

    QuerySnapshot cartDetails;
    cartDetails = await firestore
        .collection('CartDetails')
        .where("Cart_ID", isEqualTo: cartID)
        .where("Product_ID", isEqualTo: productID)
        .get();

    /// Existing Data
    if (cartDetails.docs.length > 0) {
      /// Then directly Update cart details (quantity)
      // region Update Cart Details Quantity
      int targetQuantity = quantity;
      FirebaseFirestore.instance
          .collection("CartDetails")
          .doc(cartDetails.docs[0].id)
          .update({
        "Quantity": targetQuantity.toString(),
      }).then((value) async {
        print("Updated Cart Details [${cartDetails.docs[0].id}] Quantity: " +
            targetQuantity.toString());

        /// Update branch cart price
        // region Update Branch Cart Price
        QuerySnapshot allCartDetailsSnapshot;
        allCartDetailsSnapshot = await firestore
            .collection('CartDetails')
            .where("Cart_ID", isEqualTo: cartID)
            .get();
        double totalPrice = 0;
        double eachPrice;
        int eachQuantity;
        double eachFinalPrice;

        /// Define Map Data
        Map<String, dynamic> allCartDetailsMapData = Map<String, dynamic>();

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
            });
          }
        }
        // endregion
      });
      // endregion
    } else {
      showSnackBar("Item Not Exist", context);
    }
  }
  // endregion

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

  /// Go to voucher page
  void goToSelectVoucherPage(String targetBranchName) async {
    if (productsMap[targetBranchName]?[0].voucherData != null) {
      print(
          "Select Voucher: ${productsMap[targetBranchName]?[0].voucherData?.voucherCode}");
    }

    VoucherData? result = await Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: SelectCollectedVoucherPage(
          branchName: targetBranchName,
          productsMap: productsMap,
          branchTotalPrice: getBranchTotalPrice(targetBranchName),
        ),
      ),
    );

    /// Has result
    if (result != null) {
      if (result.shouldRemove == true) {
        productsMap[targetBranchName]?[0].voucherData = null;
        if (this.mounted) {
          setState(() {});
        }
        showSnackBar('Removed Voucher from $targetBranchName', context);
      } else {
        productsMap[targetBranchName]?[0].voucherData = result;
        if (this.mounted) {
          setState(() {});
        }
        showSnackBar('Added Voucher in $targetBranchName', context);
      }
    }

    // /// No result == remove voucher
    // else {
    //   productsMap[targetBranchName][0].voucherData = null;
    //   if (this.mounted) {
    //     setState(() {});
    //   }
    //   // showSnackBar('Removed Voucher from $targetBranchName');
    // }
  }

  /// Check all branch price
  CartMinOrder checkEachBranchMinimumOrder() {
    CartMinOrder data = CartMinOrder(hasError: false);
    int j = 0;
    int length = productsMap.length;
    productsMap.forEach((branchName, list) {
      for (int i = 0; i < productsMap[branchName]!.length; ++i) {
        if (i == 0) {
          /// Check if the branch has item check
          if (productsMap[branchName]![0].hasItemChecked == true) {
            /// Check if the branch has voucher data
            if (productsMap[branchName]?[0].voucherData != null) {
              print("Branch $branchName: " +
                  productsMap[branchName]![0].totalPrice.toString());

              /// If current branch total price < minimum order
              if (productsMap[branchName]![0].totalPrice! <
                  productsMap[branchName]![0].voucherData!.minOrder) {
                print("Branch $branchName min order not reach");
                data = CartMinOrder(
                  branchName: branchName,
                  voucherCode:
                      productsMap[branchName]![0].voucherData!.voucherCode,
                  minOrder: productsMap[branchName]![0].voucherData!.minOrder,
                  hasError: true,
                );
              }
            }
          }

          /// if reach last branch
          if (j == length - 1) {
            print("All Branch reached Minimum Order");
          }
          // break;
        }
        ++j;
      }
    });

    return data;
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Scaffold(
      appBar: _getCustomAppBar(
        "My Cart",
        _widgetSize,
        _deviceDetails,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: StreamBuilder(
          stream: firestoreRef,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.data != null) {
              if (snapshot.data!.docs.length > 0) {
                isEmptyCart = false;
                // print("Run has data");
                // print("isEmptyCart: " + isEmptyCart.toString());

                /// Get all document
                List<DocumentSnapshot> targetData = snapshot.data!.docs;
                var bottomBarHeight =
                    _widgetSize.getResponsiveHeight(0.09, 0.09, 0.09);

                return ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                    minWidth: MediaQuery.of(context).size.width,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Main Part
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: getPageContent(
                              context,
                              _deviceDetails,
                              _widgetSize,
                              targetData,
                            ),
                          ),
                        ),
                      ),

                      /// Bottom Bar
                      if (isEmptyCart == false)
                        Container(
                          height: bottomBarHeight,
                          width: _widgetSize.getResponsiveWidth(1, 1, 1),
                          color: Colors.black,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                              _widgetSize.getResponsiveHeight(0.02, 0.02, 0.02),
                              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                              _widgetSize.getResponsiveHeight(0.02, 0.02, 0.02),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                /// All Button
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (selectAll == true) {
                                        selectAll = false;
                                        setAllItemBool(false);
                                        checkAndCalculateTotalPrice();
                                      } else {
                                        selectAll = true;
                                        setAllItemBool(true);
                                        checkAndCalculateTotalPrice();
                                      }
                                    });
                                  },
                                  child: Container(
                                    width: _widgetSize.getResponsiveWidth(
                                        0.15, 0.15, 0.15),
                                    height: bottomBarHeight,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        /// All Button
                                        Icon(
                                          selectAll == false
                                              ? Icons.check_box_outline_blank
                                              : Icons.check_box,
                                          color: Theme.of(context).canvasColor,
                                          size: _widgetSize.getResponsiveWidth(
                                              0.07, 0.07, 0.07),
                                        ),

                                        SizedBox(
                                          width: _widgetSize.getResponsiveWidth(
                                              0.02, 0.02, 0.02),
                                        ),

                                        /// All Text
                                        Text(
                                          "All",
                                          style: TextStyle(
                                            fontSize: _deviceDetails
                                                .getNormalFontSize(),
                                            color:
                                                Theme.of(context).canvasColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                /// Total Price and Check Out
                                Row(
                                  children: [
                                    /// Total Price
                                    if (editMode == false)
                                      Row(
                                        children: [
                                          /// Shipping text
                                          if (totalPrice > 0)
                                            Text(
                                              "Total: ",
                                              style: TextStyle(
                                                fontSize: _deviceDetails
                                                    .getTitleFontSize(),
                                                color: Theme.of(context)
                                                    .canvasColor,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),

                                          /// Shipping price
                                          if (totalPrice > 0)
                                            Text(
                                              "RM " +
                                                  formatCurrency.format(
                                                    totalPrice,
                                                  ),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: _deviceDetails
                                                    .getTitleFontSize(),
                                                color: Colors.white,
                                              ),
                                            ),
                                        ],
                                      ),

                                    /// Spacing
                                    SizedBox(
                                      width: _widgetSize.getResponsiveWidth(
                                        0.03,
                                        0.03,
                                        0.03,
                                      ),
                                    ),

                                    /// Check Out
                                    if (editMode == false)
                                      InkWell(
                                        onTap: () async {
                                          if (FirebaseAuth.instance.currentUser
                                                  ?.isAnonymous ==
                                              false) {
                                            CartMinOrder cartMinOrder =
                                                checkEachBranchMinimumOrder();

                                            /// Check for min order
                                            if (cartMinOrder.hasError ==
                                                false) {
                                              print(
                                                  "All Min Order Reached for Voucher!");
                                              if (totalPrice > 0) {
                                                Map<
                                                        String,
                                                        List<
                                                            ToggleableItemClass>>
                                                    tempMap = Map<
                                                        String,
                                                        List<
                                                            ToggleableItemClass>>();

                                                tempMap =
                                                    addAllSelectedItemToMap();
                                                tempMap.forEach((key,
                                                    List<ToggleableItemClass>
                                                        value) {
                                                  for (int index = 0;
                                                      index < value.length;
                                                      ++index) {
                                                    if (index > 0) {
                                                      print(
                                                          "Final Added[${value[index].productId}] In: " +
                                                              "Branch [$key]");
                                                    }
                                                  }
                                                });

                                                /// Checkout argument
                                                CartCheckoutArgument
                                                    cartCheckoutArgument =
                                                    new CartCheckoutArgument(
                                                  totalPrice: totalPrice,
                                                  totalItem: totalItem,
                                                  productsMap: tempMap,
                                                );

                                                Navigator.pushNamed(
                                                  context,
                                                  CartCheckoutPage.routeName,
                                                  arguments:
                                                      cartCheckoutArgument,
                                                );
                                              }
                                            } else {
                                              showMessage(
                                                '',
                                                "Minimum order for ${cartMinOrder.voucherCode} "
                                                    "voucher in ${cartMinOrder.branchName} is "
                                                    "RM ${formatCurrency.format(cartMinOrder.minOrder).toString()}",
                                                _deviceDetails,
                                                context,
                                              );
                                            }
                                          } else {
                                            showLoginMessage(0, 15, context);
                                          }
                                        },
                                        child: Container(
                                          width: _widgetSize.getResponsiveWidth(
                                              0.25, 0.25, 0.25),
                                          height: bottomBarHeight,
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .highlightColor,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Center(
                                            child: Text(
                                              "Check Out",
                                              style: TextStyle(
                                                fontSize: _deviceDetails
                                                    .getNormalFontSize(),
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                    /// Delete
                                    if (editMode == true)
                                      InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .backgroundColor,
                                                content: Text(
                                                  'Remove item(s) from Cart?',
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    child: Text("Cancel",
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        )),
                                                    onPressed: () {
                                                      setState(() {
                                                        Navigator.of(context)
                                                            .pop();
                                                      });
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text("Remove",
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        )),
                                                    onPressed: () {
                                                      deleteCartFromEdit();
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          width: _widgetSize.getResponsiveWidth(
                                              0.25, 0.25, 0.25),
                                          height: bottomBarHeight,
                                          decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Center(
                                            child: Text(
                                              "Delete",
                                              style: TextStyle(
                                                fontSize: _deviceDetails
                                                    .getNormalFontSize(),
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              } else {
                isEmptyCart = true;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: _widgetSize.getResponsiveHeight(0.15, 0.15, 0.15),
                    ),
                    Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.grey,
                      size: _widgetSize.getResponsiveWidth(0.25, 0.25, 0.25),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                          _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                          _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                          0),
                      child: Center(
                        child: Text(
                          "Oops, Your Shopping Cart is Empty",
                          style: TextStyle(
                            fontSize: _deviceDetails.getTitleFontSize(),
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                          _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
                          _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                          0),
                      child: Center(
                        child: Text(
                          "Check out more our ${App.appName} deals !",
                          style: TextStyle(
                            fontSize: _deviceDetails.getNormalFontSize(),
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                );
              }
            }
            return Container();
          },
        ),
      ),
    );
  }

  List<Widget> getPageContent(
    BuildContext context,
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    List<DocumentSnapshot> branchCartData,
  ) {
    List<Widget> pageContent = [];

    SizedBox _spacing2 = SizedBox(
      height: _widgetSize.getResponsiveHeight(0.15, 0.15, 0.15),
    );

    /// Assign Data
    assignData(branchCartData, _widgetSize, _deviceDetails);

    /// First Loading
    if (firstLoad == true) {
      /// First Loading
      pageContent.add(SizedBox(
        height: _widgetSize.getResponsiveHeight(0.15, 0.15, 0.15),
      ));
      pageContent.add(Padding(
        padding: EdgeInsets.fromLTRB(
            _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
            _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
            0),
        child: CustomLoading(),
      ));
    }

    /// Start Here
    else {
      /// Build UI
      if (productsMap.length > 0) {
        isEmptyCart = false;
        productsMap.forEach((branchName, value) {
          /// Branch Name
          if (productsMap[branchName]?[0].isDisable == false) {
            pageContent.add(
              Padding(
                padding: EdgeInsets.only(
                    top: _widgetSize.getResponsiveWidth(0.02, 0.02, 0.02)),
                child: Container(
                  color: Theme.of(context).shadowColor,
                  width: _widgetSize.getResponsiveWidth(1, 1, 1),
                  height: _widgetSize.getResponsiveWidth(0.12, 0.12, 0.12),
                  child: Row(
                    children: [
                      /// Spacing
                      SizedBox(
                          width:
                              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),

                      /// Radio button
                      InkWell(
                        onTap: () {
                          if (value[0].boolValue == false) {
                            print("Checked Branch: " + branchName);
                            setBranchBool(branchName, true);
                          } else if (value[0].boolValue == true) {
                            print("Unchecked Branch: " + branchName);
                            setBranchBool(branchName, false);
                          }
                          setState(() {});
                        },
                        child: Icon(
                          value[0].boolValue == false
                              ? Icons.check_box_outline_blank
                              : Icons.check_box,
                          color: Theme.of(context).highlightColor,
                          size:
                              _widgetSize.getResponsiveWidth(0.07, 0.07, 0.07),
                        ),
                      ),

                      /// Spacing
                      SizedBox(
                          width:
                              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05)),

                      /// Branch Name + Get Voucher
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /// Branch Name
                            Text(
                              branchName,
                              style: TextStyle(
                                fontSize: _deviceDetails.getTitleFontSize(),
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            // if (App.testing == false)
                            //   SizedBox(
                            //       width: _widgetSize.getResponsiveWidth(
                            //           0.05, 0.05, 0.05)),

                            // if (App.testing == true)

                            /// Get Voucher Button
                            Padding(
                              padding: EdgeInsets.only(
                                  right: _widgetSize.getResponsiveWidth(
                                      0.05, 0.05, 0.05)),
                              child: InkWell(
                                onTap: () async {
                                  if (FirebaseAuth
                                          .instance.currentUser?.isAnonymous ==
                                      false) {
                                    VoucherData? result = await Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.rightToLeft,
                                        child: GetVoucherSelectPage(
                                          branchName: branchName,
                                          branchTotalPrice:
                                              getBranchTotalPrice(branchName),
                                        ),
                                      ),
                                    );

                                    if (result != null) {
                                      productsMap[branchName]![0].voucherData =
                                          result;

                                      print("**********************");
                                      print(
                                          "Current Branch [$branchName] Voucher TEMP Quantity: " +
                                              productsMap[branchName]![0]
                                                  .voucherData!
                                                  .tempRedeemQty
                                                  .toString());

                                      if (this.mounted) {
                                        setState(() {});
                                      }
                                    }
                                  } else {
                                    showLoginMessage(0, 15, context);
                                  }
                                  // showMessage(
                                  //   "",
                                  //   "Coming Soon",
                                  //   _deviceDetails,
                                  //   context,
                                  // );
                                },
                                child: Text(
                                  'Get Voucher',
                                  style: TextStyle(
                                    fontSize:
                                        _deviceDetails.getNormalFontSize(),
                                    color: Theme.of(context).highlightColor,
                                    fontWeight: FontWeight.w600,
                                    // decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          /// List of Product Details
          for (int index = 0; index < value.length; ++index) {
            /// Because first index is empty
            if (index > 0) {
              /// Add Slideable UI
              // if (productsMap[branchName]?[index].isDisable == false) {
              //   pageContent.add(
              //     Slidable(
              //       // actionPane: SlidableDrawerActionPane(),
              //       // actionExtentRatio: 0.25,
              //       secondaryActions: <Widget>[
              //         IconSlideAction(
              //           caption: 'Delete',
              //           color: Colors.red,
              //           icon: Icons.delete,
              //           onTap: () {
              //             showDialog(
              //               context: context,
              //               barrierDismissible: false,
              //               builder: (BuildContext context) {
              //                 return AlertDialog(
              //                   backgroundColor:
              //                       Theme.of(context).backgroundColor,
              //                   content: Text(
              //                     'Remove this item ?',
              //                     style: TextStyle(
              //                       color: Theme.of(context).primaryColor,
              //                       fontWeight: FontWeight.w400,
              //                     ),
              //                   ),
              //                   actions: [
              //                     TextButton(
              //                       child: Text("Cancel",
              //                           style: TextStyle(
              //                             color: Theme.of(context).primaryColor,
              //                             fontWeight: FontWeight.w400,
              //                           )),
              //                       onPressed: () {
              //                         Navigator.of(context).pop();
              //                       },
              //                     ),
              //                     TextButton(
              //                       child: Text("Remove",
              //                           style: TextStyle(
              //                             color: Theme.of(context).primaryColor,
              //                             fontWeight: FontWeight.w400,
              //                           )),
              //                       onPressed: () {
              //                         setState(() {
              //                           removeItemFromMap(branchName, index);
              //                           Navigator.of(context).pop();
              //                         });
              //                       },
              //                     ),
              //                   ],
              //                 );
              //               },
              //             );
              //             setState(() {});
              //           },
              //         ),
              //       ],
              //       key: ValueKey(productsMap[branchName]![index]),
              //       // dismissal: SlidableDismissal(
              //       //   child: SlidableDrawerDismissal(),
              //       //   onDismissed: (actionType) {
              //       //     if (actionType == SlideActionType.secondary) {
              //       //       removeItemFromMap(branchName, index);
              //       //       setState(() {});
              //       //     }
              //       //   },
              //       // ),
              //       child: Container(
              //         height: _widgetSize.getResponsiveHeight(0.15, 0.15, 0.15),
              //         decoration: BoxDecoration(
              //           color: Theme.of(context).shadowColor,
              //           border: Border(
              //             bottom: BorderSide(
              //               width: 0.9,
              //               color: Theme.of(context).dividerColor,
              //             ),
              //           ),
              //         ),
              //         padding: EdgeInsets.fromLTRB(
              //           _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
              //           0,
              //           _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
              //           0,
              //         ),
              //         child: Row(
              //           children: [
              //             /// Radio button
              //             InkWell(
              //               onTap: () {
              //                 setState(() {
              //                   if (productsMap[branchName]![index].boolValue ==
              //                       false) {
              //                     toggleProductSelection(
              //                         branchName, index, true);
              //                   } else {
              //                     value[0].boolValue = false;
              //                     toggleProductSelection(
              //                         branchName, index, false);
              //                   }
              //                 });
              //               },
              //               child: Icon(
              //                 productsMap[branchName]?[index].boolValue == false
              //                     ? Icons.check_box_outline_blank
              //                     : Icons.check_box,
              //                 color: Theme.of(context).highlightColor,
              //                 size: _widgetSize.getResponsiveWidth(
              //                     0.07, 0.07, 0.07),
              //               ),
              //             ),

              //             SizedBox(
              //                 width: _widgetSize.getResponsiveWidth(
              //                     0.03, 0.03, 0.03)),

              //             /// Product Data
              //             Expanded(
              //               child: CustomListTilePrice(
              //                 title: productsMap[branchName]?[index]
              //                             .productName !=
              //                         null
              //                     ? productsMap[branchName]![index].productName
              //                     : "",
              //                 titleColor: Theme.of(context).primaryColor,
              //                 finalPrice: formatCurrency.format(
              //                     productsMap[branchName]![index].price),
              //                 fontColor: Colors.black,
              //                 // originalPrice: getFormattedCurrency(productPrice),
              //                 networkImagePath:
              //                     productsMap[branchName]![index].image,
              //                 spacing: true,
              //                 bgColor: Theme.of(context).shadowColor,
              //                 maxLine: 2,
              //                 shadowValue: 0,
              //                 customButton: quantityButtons(
              //                   _widgetSize,
              //                   _deviceDetails,
              //                   branchName,
              //                   index,
              //                 ),
              //                 contentPaddingTop: _widgetSize
              //                     .getResponsiveHeight(0.01, 0.01, 0.01),
              //                 contentPaddingBottom: _widgetSize
              //                     .getResponsiveHeight(0.01, 0.01, 0.01),
              //                 contentPaddingLeft: _widgetSize
              //                     .getResponsiveWidth(0.01, 0.01, 0.01),
              //                 contentPaddingRight: _widgetSize
              //                     .getResponsiveWidth(0.05, 0.05, 0.05),
              //                 productVariantFinal:
              //                     productsMap[branchName]![index]
              //                         .productVariantFinal,
              //                 selectedProductVariant:
              //                     productsMap[branchName]![index]
              //                         .selectedProductVariant,
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   );
              // }
            }
          }

          /// Voucher UI
          pageContent.add(
            getEachBranchVoucherUI(
              _deviceDetails,
              _widgetSize,
              branchName,
            ),
          );

          pageContent.add(SizedBox(
            height: _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
          ));
        });
      }

      /// No Item in Cart
      else {
        isEmptyCart = true;
        pageContent.add(
          SizedBox(
            height: _widgetSize.getResponsiveHeight(0.15, 0.15, 0.15),
          ),
        );
        pageContent.add(Icon(
          Icons.shopping_cart_outlined,
          color: Colors.grey,
          size: _widgetSize.getResponsiveWidth(0.25, 0.25, 0.25),
        ));

        pageContent.add(
          Padding(
            padding: EdgeInsets.fromLTRB(
                _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                0),
            child: Text(
              "Oops, Your Shopping Cart is Empty",
              style: TextStyle(
                fontSize: _deviceDetails.getTitleFontSize(),
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
        pageContent.add(
          Padding(
            padding: EdgeInsets.fromLTRB(
                _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03),
                _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1),
                0),
            child: Text(
              "Check out more our ${App.appName} deals !",
              style: TextStyle(
                fontSize: _deviceDetails.getNormalFontSize(),
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    }

    /// Spacing
    pageContent.add(_spacing2);

    return pageContent;
  }
}
