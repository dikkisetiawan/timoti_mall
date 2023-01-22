import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:timoti_project/Address-Page/Address-Add.dart';
import 'package:timoti_project/Address-Page/Address-Edit.dart';
import 'package:timoti_project/Address-Page/AddressClass.dart';
import 'package:timoti_project/Address-Page/AddressEditArgument.dart';
import 'package:timoti_project/Custom-UI/Custom-LoadingUI.dart';
import 'package:timoti_project/Google-Map/Map-Page.dart';
import 'package:timoti_project/Home/SelectAddress/Select-Map-Page.dart';
import 'package:timoti_project/Home/SelectAddress/SelectMapResult.dart';
import 'package:timoti_project/Functions/Messager.dart';
import 'package:timoti_project/Screen-Size/Get-Device-Details.dart';
import 'package:timoti_project/Screen-Size/WidgetSizeCalculation.dart';
import 'package:timoti_project/Screen-Size/ui-utils.dart';
import 'package:timoti_project/enums/device-screen-type.dart';
import 'package:page_transition/page_transition.dart';

class SelectAddressMainPage extends StatefulWidget {
  @override
  _SelectAddressMainPageState createState() => _SelectAddressMainPageState();
}

class _SelectAddressMainPageState extends State<SelectAddressMainPage> {
  /// Firebase
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  User firebaseUser = FirebaseAuth.instance.currentUser as User;

  List<AddressClass> addressDataList = <AddressClass>[];

  bool loading = false;
  Position? userPosition;
  String addressString = '';

  @override
  void initState() {
    /// Todo Get User Position
    // getUserPosition();

    print(firebaseUser.displayName);

    /// Get User Address
    getUserAddress();

    super.initState();
  }

  // region UI
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
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back_ios_sharp,
                          color: Theme.of(context).primaryColor,
                          size:
                              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                        ),
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

                      SizedBox(
                        width: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                      ),

                      /// Google Map
                      // FittedBox(
                      //   child: InkWell(
                      //     onTap: () async {
                      //       SelectMapResult result = await Navigator.push(
                      //         context,
                      //         PageTransition(
                      //           type: PageTransitionType.bottomToTop,
                      //           child: SelectGoogleMapPage(
                      //             initLatLong: userPosition != null
                      //                 ? LatLng(userPosition!.latitude,
                      //                     userPosition!.longitude)
                      //                 : null,
                      //           ),
                      //         ),
                      //       );
                      //
                      //       if (result != null) {
                      //         Navigator.pop(context, result);
                      //       }
                      //     },
                      //     child: SizedBox(
                      //       height: _widgetSize.getResponsiveWidth(
                      //           0.07, 0.07, 0.07),
                      //       width: _widgetSize.getResponsiveWidth(
                      //           0.07, 0.07, 0.07),
                      //       child: Image(
                      //         image: AssetImage('assets/icon/location1.png'),
                      //         fit: BoxFit.contain,
                      //         // color: otherIconColor,
                      //       ),
                      //     ),
                      //   ),
                      // ),
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

  /// Data Address UI
  Widget getDataAddressUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
    AddressClass data,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.6,
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: ListTile(
        tileColor: Theme.of(context).shadowColor,
        onTap: () {
          SelectMapResult result = SelectMapResult(
            address: data.addressDetails as String,
            latLng: data.latitude != null
                ? LatLng(data.latitude as double, data.longitude as double)
                : null,
          );
          Navigator.pop(
            context,
            result,
          );
        },
        leading: Icon(
          data.label == "Home" ? Icons.home : Icons.label,
          color: Colors.grey,
          size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        ),
        title: Text(
          data.label as String,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: _deviceDetails.getTitleFontSize(),
          ),
        ),

        /// Edit & Delete
        trailing: Container(
          width: _widgetSize.getResponsiveWidth(0.25, 0.25, 0.25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Edit
              InkWell(
                splashColor: Colors.transparent,
                onTap: () {
                  AddressEditArgument arg =
                      new AddressEditArgument(addressClass: data);

                  Navigator.pushNamed(context, AddressEditPage.routeName,
                          arguments: arg)
                      .then((value) {
                    addressDataList.clear();
                    getUserAddress();
                    setState(() {});
                  });
                },
                child: Text(
                  "Edit",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: _deviceDetails.getNormalFontSize(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              /// Line
              Text("|",
                  style: TextStyle(color: Theme.of(context).primaryColor)),

              /// Delete
              InkWell(
                splashColor: Colors.transparent,
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Theme.of(context).backgroundColor,
                        content: Text(
                          'Remove ${data.label} ?',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        actions: [
                          /// Cancel
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
                            child: Text("Delete",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w400,
                                )),
                            onPressed: () {
                              hasInternet().then((value) {
                                if (value == true) {
                                  removeAddress(data.index as int)
                                      .then((value) {
                                    addressDataList.clear();
                                    getUserAddress();
                                    setState(() {});
                                  });
                                } else {
                                  showSnackBar("No Internet Connection");
                                }
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  "Delete",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: _deviceDetails.getNormalFontSize(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Current Location UI
  Widget getCurrentLocationUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 2.5,
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: ListTile(
        tileColor: Theme.of(context).shadowColor,
        onTap: () {
          SelectMapResult result = SelectMapResult(
            address: addressString,
            latLng: userPosition != null
                ? LatLng(userPosition?.latitude as double,
                    userPosition?.longitude as double)
                : null,
          );
          Navigator.pop(
            context,
            result,
          );
        },
        leading: Icon(
          Icons.my_location,
          color: Colors.grey,
          size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        ),
        title: Text(
          addressString != ''
              ? addressString
              : 'Please enable Location permission',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: _deviceDetails.getTitleFontSize(),
          ),
        ),
      ),
    );
  }

  /// Add new address UI
  Widget getAddNewAddressUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.6,
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: ListTile(
        tileColor: Theme.of(context).shadowColor,
        onTap: () {
          Navigator.pushNamed(context, AddressAddPage.routeName).then((value) {
            addressDataList.clear();
            getUserAddress();
            setState(() {});
          });
        },
        leading: Icon(
          Icons.add,
          color: Colors.grey,
          size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
        ),
        title: Text(
          "Add New",
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: _deviceDetails.getTitleFontSize(),
          ),
        ),
      ),
    );
  }
  // endregion

  // region Functions
  // Todo Get User Position without Geocoder
  /// Get Current User Position
  // Future<void> getUserPosition() async {
  //   if (!mounted) {
  //     return;
  //   }
  //
  //   userPosition = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.best);
  //
  //   print("==== Address Main ==============");
  //   print("User Current Latitude: " + userPosition!.latitude.toString());
  //   print("USer Current Longitude: " + userPosition!.longitude.toString());
  //
  //   final coordinates = Coordinates(
  //     userPosition!.latitude,
  //     userPosition!.longitude,
  //   );
  //   var addresses =
  //       await Geocoder.local.findAddressesFromCoordinates(coordinates);
  //   Address targetAddress;
  //   targetAddress = addresses.first;
  //
  //   addressString = targetAddress.addressLine;
  //
  //   if (this.mounted) {
  //     if (addressString != '') {
  //       setState(() {});
  //     }
  //   }
  // }

  void getUserAddress() async {
    if (firebaseUser == null) {
      print("Didnt get User Data");
      return;
    }

    DocumentSnapshot userDocument;
    userDocument =
        await firestore.collection('Customers').doc(firebaseUser.uid).get();

    /// Define Map Data
    Map<String, dynamic> userDocMapData = Map<String, dynamic>();

    /// Assign Data
    userDocMapData = userDocument.data() as Map<String, dynamic>;

    /// - If data found
    if (userDocMapData["Address"] != null) {
      print("Has Address Data");
      if (userDocMapData["Address"].length > 0) {
        AddressClass temp = AddressClass();
        for (int i = 0; i < userDocMapData["Address"].length; ++i) {
          temp = AddressClass(
            addressDetails: userDocMapData["Address"][i]["Address_Details"],
            city: userDocMapData["Address"][i]["City"],
            state: userDocMapData["Address"][i]["State"],
            postcode: userDocMapData["Address"][i]["Postcode"],
            country: userDocMapData["Address"][i]["Country"],
            phone: userDocMapData["Address"][i]["Phone"],
            fullName: userDocMapData["Address"][i]["Full_Name"],
            label: userDocMapData["Address"][i]["Label"] != null
                ? userDocMapData["Address"][i]["Label"]
                : "Address ${i + 1}",
            index: i,
            latitude: userDocMapData["Address"][i]["Latitude"],
            longitude: userDocMapData["Address"][i]["Longitude"],
          );
          addressDataList.add(temp);

          if (i == userDocMapData["Address"].length - 1) {
            setState(() {});
          }
        }
      }
    } else {
      print("No Address Found");
    }
  }

  /// Remove Address
  Future<void> removeAddress(int targetIndex) async {
    if (firebaseUser == null) {
      print("Didnt get User Data");
      return;
    }

    loading = true;
    setState(() {});

    DocumentSnapshot userDocument;
    userDocument =
        await firestore.collection('Customers').doc(firebaseUser.uid).get();

    /// Define Map Data
    Map<String, dynamic> userDocMapData = Map<String, dynamic>();

    /// Assign Data
    userDocMapData = userDocument.data() as Map<String, dynamic>;

    /// Has Address Field
    if (userDocMapData["Address"] != null) {
      print("Has Address Field");
      if (userDocMapData["Address"].length > 0) {
        print("This has other address");
        List<dynamic> finalList = [];

        for (int i = 0; i < userDocMapData["Address"].length; ++i) {
          /// Dont add current Index
          if (i != targetIndex) {
            /// Assign Data
            AddressClass tempAddress = new AddressClass(
              addressDetails: userDocMapData["Address"][i]["Address_Details"],
              state: userDocMapData["Address"][i]["State"],
              city: userDocMapData["Address"][i]["City"],
              country: userDocMapData["Address"][i]["Country"],
              fullName: userDocMapData["Address"][i]["Full_Name"],
              label: userDocMapData["Address"][i]["Label"],
              phone: userDocMapData["Address"][i]["Phone"],
              postcode: userDocMapData["Address"][i]["Postcode"],
              latitude: userDocMapData["Address"][i]["Latitude"],
              longitude: userDocMapData["Address"][i]["Longitude"],
            );

            /// Add to List
            finalList.add(tempAddress.toMap());
          }

          /// Reach Last Index (Update Data)
          if (i == userDocMapData["Address"].length - 1) {
            await FirebaseFirestore.instance
                .collection("Customers")
                .doc(firebaseUser.uid)
                .update({
              'Address': finalList,
            }).then((value) async {
              print("Added Address on user: " + firebaseUser.uid);
              print("Index: " + targetIndex.toString());
              loading = false;
              setState(() {});

              /// Message
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Theme.of(context).highlightColor,
                    content: Text(
                      'Address Updated',
                      style: TextStyle(
                          color: Theme.of(context).backgroundColor,
                          fontWeight: FontWeight.bold),
                    ),
                    actions: [
                      TextButton(
                        child: Text("Ok",
                            style: TextStyle(
                              color: Theme.of(context).backgroundColor,
                            )),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            });
          }
        }
      }
    }

    /// No Address field
    else {
      print("No Address Field");
      loading = false;
      setState(() {});
    }
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

  /// Show Snackbar below
  void showSnackBar(String textData) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(textData),
      duration: const Duration(seconds: 1),
      // action: SnackBarAction(
      //   label: 'ACTION',
      //   onPressed: () { },
      // ),
    ));
  }

  void goToGoogleMap() {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: GoogleMapPage(
          initLatLong: null,
          // initLatLong: userPosition != null ? LatLng(
          //   userPosition.latitude,
          //   userPosition.longitude,
          // ) : null,
        ),
      ),
    );
  }
  // endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Scaffold(
      appBar: _getCustomAppBar("Select Address", _widgetSize, _deviceDetails),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: getPageContent(
                context,
                _deviceDetails,
                _widgetSize,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getPageContent(
    BuildContext context,
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    List<Widget> pageContent = [];
    // allAddress.clear();

    /// Spacing
    SizedBox _spacing = SizedBox(
      height: _widgetSize.getResponsiveHeight(0.03, 0.03, 0.03),
    );

    if (loading == false) {
      // region Use my Current location
      // Spacing
      // pageContent.add(_spacing);

      // /// Use my current location Title
      // pageContent.add(
      //   Padding(
      //     padding: EdgeInsets.fromLTRB(
      //         _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
      //         0,
      //         0,
      //         _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03)),
      //     child: Text(
      //       "Use my current location",
      //       style: TextStyle(
      //         color: Theme.of(context).primaryColor,
      //         fontWeight: FontWeight.w600,
      //         fontSize: _deviceDetails.getTitleFontSize(),
      //       ),
      //     ),
      //   ),
      // );
      //
      // /// Show "Use my Current Location"
      // pageContent.add(getCurrentLocationUI(_deviceDetails, _widgetSize));
      // endregion

      /// Save Places Title
      pageContent.add(
        Padding(
          padding: EdgeInsets.fromLTRB(
              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
              _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
              0,
              _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03)),
          child: Row(
            children: [
              /// Title
              Text(
                "Saved Places",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: _deviceDetails.getTitleFontSize(),
                ),
              ),

              SizedBox(width: 10),

              /// Info
              InkWell(
                onTap: () {
                  showMessage(
                    "",
                    'These are the address you saved',
                    _deviceDetails,
                    context,
                  );
                },
                child: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).highlightColor,
                  size: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
                ),
              )
            ],
          ),
        ),
      );

      if (addressDataList.length > 0) {
        /// List all address
        for (int i = 0; i < addressDataList.length; ++i) {
          pageContent.add(
            getDataAddressUI(
              _deviceDetails,
              _widgetSize,
              addressDataList[i],
            ),
          );
        }
      }

      /// Add new address
      pageContent.add(getAddNewAddressUI(_deviceDetails, _widgetSize));
    }

    /// Loading is true
    else {
      pageContent.add(Center(child: CustomLoading()));
    }

    /// Spacing
    pageContent.add(_spacing);

    pageContent.add(SizedBox(
      height: _widgetSize.getResponsiveHeight(0.1, 0.1, 0.1),
    ));
    return pageContent;
  }
}
