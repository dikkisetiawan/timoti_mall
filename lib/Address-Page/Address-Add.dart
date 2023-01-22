import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
// import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:geocoder/geocoder.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '/Address-Page/AddressClass.dart';
import '/Custom-UI/Custom-LoadingUI.dart';
import '/Custom-UI/Custom-RoundedInputField.dart';
import '/Functions/Messager.dart';
import '/Screen-Size/Get-Device-Details.dart';
import '/Screen-Size/WidgetSizeCalculation.dart';
import '/Screen-Size/ui-utils.dart';
import '/enums/device-screen-type.dart';

class AddressAddPage extends StatefulWidget {
  static const routeName = '/_AddressAddPage';
  @override
  _AddressAddPageState createState() => _AddressAddPageState();
}

class _AddressAddPageState extends State<AddressAddPage> {
  /// Form and Errors Detections
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressDetailController = TextEditingController();
  TextEditingController _postcodeController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _addressLabelController = TextEditingController();
  double addressLatitude = 0.00;
  double addressLongitude = 0.00;

  bool _fullNameError = false;
  bool _phoneError = false;
  bool _addressDetailsError = false;
  bool _postcodeError = false;
  bool _cityError = false;
  bool _addressLabelError = false;

  bool loading = false;

  /// Firebase
  User firebaseUser = FirebaseAuth.instance.currentUser as User;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Address
  String addressString = '';
  Position? userPosition;
  // Address targetAddress = new Address();
  List<AddressClass> addressDataList = <AddressClass>[];

  /// State
  List<String> state = [
    'Please Select a State',
    'Johor',
    'Kedah',
    'Kelantan',
    'Malacca',
    'Negeri Sembilan',
    'Pahang',
    'Penang',
    'Perak',
    'Perlis',
    'Sabah',
    'Sarawak',
    'Selangor',
    'Terengganu',
    'Kuala Lumpur',
    'Labuan',
    'Putrajaya',
  ];

  String currentState = "Please Select a State";
  String defaultState = 'Please Select a State';
  bool isDefault = false;

  @override
  void initState() {
    /// Get User Data
    print(firebaseUser.displayName);

    super.initState();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressDetailController.dispose();
    _postcodeController.dispose();
    _cityController.dispose();
    _addressLabelController.dispose();
    super.dispose();
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

                      /// Google Map
                      /// Todo Link Back Google Map
                      SizedBox(
                        width: 10,
                      ),
                      // FittedBox(
                      //   child: InkWell(
                      //     onTap: () async {
                      //       SelectMapResult result = await Navigator.push(
                      //         context,
                      //         PageTransition(
                      //           type: PageTransitionType.bottomToTop,
                      //           child: SelectGoogleMapPage(
                      //             initLatLong: LatLng(
                      //                     addressLatitude, addressLongitude)
                      //           ),
                      //         ),
                      //       );
                      //
                      //       if (result != null) {
                      //         _addressDetailController.text = result.address;
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
                      // )
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

  // Widget customBorder(
  //   TextEditingController controller,
  //   String labelText,
  //   bool verification,
  //   String errorText,
  //   bool hiddenInput,
  //   DeviceDetails _deviceDetails,
  //   bool pinpoint,
  //   String hintText,
  //   bool isNumeric,
  // ) {
  //   return TextField(
  //     controller: controller,
  //     keyboardType: isNumeric == true ? TextInputType.number : null,
  //     inputFormatters: isNumeric == true
  //         ? <TextInputFormatter>[
  //             FilteringTextInputFormatter.digitsOnly,
  //             LengthLimitingTextInputFormatter(18),
  //           ]
  //         : null,
  //     style: TextStyle(
  //         fontSize: _deviceDetails.getNormalFontSize(),
  //         height: 2.0,
  //         color: Colors.white),
  //     cursorColor: Theme.of(context).primaryColor,
  //     textAlignVertical: TextAlignVertical.center,
  //     decoration: InputDecoration(
  //       suffixIcon: pinpoint == true
  //           ? InkWell(
  //               onTap: () {
  //                 // Todo Get User Position
  //                 // getUserPosition();
  //               },
  //               child: Icon(
  //                 Icons.gps_fixed_rounded,
  //                 color: Theme.of(context).primaryColor,
  //               ),
  //             )
  //           : null,
  //       labelText: verification ? null : labelText,
  //       hintText: hintText,
  //       hintStyle: TextStyle(
  //         color: Colors.grey,
  //         fontSize: _deviceDetails.getNormalFontSize(),
  //       ),
  //       labelStyle: TextStyle(
  //         color: Colors.white,
  //         fontSize: _deviceDetails.getNormalFontSize(),
  //       ),
  //       errorBorder: UnderlineInputBorder(
  //         borderSide: new BorderSide(color: Colors.white),
  //       ),
  //       enabledBorder: UnderlineInputBorder(
  //         borderSide: new BorderSide(color: Colors.white),
  //       ),
  //       focusedBorder: UnderlineInputBorder(
  //         borderSide: new BorderSide(color: Colors.white),
  //       ),
  //       errorText: verification ? errorText : null,
  //       errorStyle: TextStyle(
  //           color: Colors.red,
  //           fontSize: _deviceDetails.getNormalFontSize(),
  //           fontWeight: FontWeight.w800),
  //     ),
  //     obscureText: hiddenInput,
  //   );
  // }

  /// First Name, Last name, Email, Password, Confirm Password
  Widget getRegisterUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    SizedBox spacing =
        SizedBox(height: _widgetSize.getResponsiveWidth(0.07, 0.07, 0.07));

    return SizedBox(
      width: _widgetSize.getResponsiveWidth(0.8, 0.8, 0.8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          /// Full Name
          customRoundedBorder(
            _fullNameController,
            "Full Name",
            _fullNameError,
            "Please fill in your Full Name",
            false,
            _deviceDetails,
            _widgetSize,
            'Full Name',
            null,
          ),
          spacing,

          /// Phone Number
          customRoundedBorder(
            _phoneController,
            "Phone Number",
            _phoneError,
            "Please fill in your Phone Number",
            false,
            _deviceDetails,
            _widgetSize,
            "Phone Number",
            null,
          ),
          spacing,

          /// Address Details
          customRoundedBorder(
            _addressDetailController,
            "Address Details",
            _addressDetailsError,
            "Please fill in your Address Details",
            false,
            _deviceDetails,
            _widgetSize,
            "Address Details",
            null,
          ),
          spacing,

          /// City
          customRoundedBorder(
            _cityController,
            "City",
            _cityError,
            "Please fill in your City",
            false,
            _deviceDetails,
            _widgetSize,
            "City",
            null,
          ),
          spacing,

          /// Postcode
          customRoundedBorder(
            _postcodeController,
            "Postcode",
            _postcodeError,
            "Please fill in your Postcode",
            false,
            _deviceDetails,
            _widgetSize,
            "Postcode",
            null,
          ),

          SizedBox(height: _widgetSize.getResponsiveWidth(0.03, 0.03, 0.03)),

          /// State
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).primaryColor,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1,
                  color: Theme.of(context).highlightColor,
                ),
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            focusColor: Theme.of(context).highlightColor,
            value: currentState,
            //elevation: 5,
            style: TextStyle(color: Theme.of(context).highlightColor),
            iconEnabledColor: Theme.of(context).highlightColor,
            dropdownColor: Theme.of(context).primaryColor,
            autofocus: false,
            items: state.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Theme.of(context).primaryColorLight,
                    ),
                  ),
                ),
              );
            }).toList(),
            hint: Text(
              "Please Choose a State",
              style: TextStyle(
                  color: Theme.of(context).primaryColorLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
            onChanged: (String? value) {
              setState(() {
                currentState = value as String;
              });
            },
          ),

          spacing,

          /// Address Label
          customRoundedBorder(
            _addressLabelController,
            "Address Label",
            _addressLabelError,
            "Please fill in your Address Label",
            false,
            _deviceDetails,
            _widgetSize,
            "Address Label",
            null,
          ),
        ],
      ),
    );
  }

  /// Sign up button
  Widget getSaveButtonUI(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    return SizedBox(
      width: _widgetSize.getResponsiveWidth(0.8, 0.8, 0.8),
      height: _widgetSize.getResponsiveWidth(0.12, 0.12, 0.12),
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
        onPressed: loading == true
            ? null
            : () {
                setState(() {
                  FocusScope.of(context).unfocus();
                  if (successValidate() == true) {
                    hasInternet().then((value) {
                      if (value == true) {
                        loading = true;
                        setState(() {});
                        translateAddressToLatLng().then((value) {
                          loading = false;
                          setState(() {});
                          if (isDefault == false) {
                            saveAddress(_deviceDetails);
                          } else {
                            updateToDefaultAddress(_deviceDetails);
                          }
                        }).catchError((error) {
                          /// In case have error still
                          loading = false;
                          setState(() {});
                          if (isDefault == false) {
                            saveAddress(_deviceDetails);
                          } else {
                            updateToDefaultAddress(_deviceDetails);
                          }
                        });
                      } else {
                        showSnackBar("No Internet Connection");
                      }
                    });
                  }
                });
              },
        child: loading == true
            ? CustomLoading()
            : Text(
                "Save".toUpperCase(),
                style: TextStyle(
                    fontSize: _deviceDetails.getTitleFontSize(),
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
      ),
    );
  }
  // endregion

  // region Function
  Future<void> translateAddressToLatLng() async {
    List<Location> locations =
        await locationFromAddress(_addressDetailController.text);
    print("Final Converted Latitude: " + locations[0].latitude.toString());
    print("Final Converted Longitude: " + locations[0].longitude.toString());
    addressLatitude = locations[0].latitude;
    addressLongitude = locations[0].longitude;
  }

  /// Get User current position
  /// Todo Get User Position without Geocoder
  // Future<void> getUserPosition() async {
  //   if (!mounted) {
  //     return;
  //   }
  //
  //   userPosition = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.best);
  //
  //   print("Latitude: " + userPosition!.latitude.toString());
  //   print("Longitude: " + userPosition!.longitude.toString());
  //
  //   final coordinates =
  //       Coordinates(userPosition!.latitude, userPosition!.longitude);
  //   var addresses =
  //       await Geocoder.local.findAddressesFromCoordinates(coordinates);
  //   targetAddress = addresses.first;
  //
  //   String temp = targetAddress.addressLine;
  //   // addressString = temp.split(",").first;
  //   addressString = targetAddress.addressLine;
  //   print(addressString);
  //
  //   print("==== Address ===================");
  //   print(
  //     'addressLine: ' +
  //         '${targetAddress.addressLine},'
  //             '\nlocality: ' +
  //         '${targetAddress.locality},'
  //             '\nadminArea: ' +
  //         '${targetAddress.adminArea},'
  //             '\nsubLocality: ' +
  //         '${targetAddress.subLocality},'
  //             '\nsubAdminArea: ' +
  //         '${targetAddress.subAdminArea},'
  //             '\nfeatureName: ' +
  //         '${targetAddress.featureName},'
  //             '\nthoroughfare: ' +
  //         '${targetAddress.thoroughfare}, '
  //             '\nsubThoroughfare: ' +
  //         '${targetAddress.subThoroughfare}',
  //   );
  //
  //   _addressDetailController.text = addressString;
  //   setState(() {});
  // }

  /// Save Address
  void saveAddress(DeviceDetails _deviceDetails) async {
    loading = true;
    if (this.mounted) {
      setState(() {});
    }

    DocumentSnapshot userDocument;
    userDocument =
        await firestore.collection('Customers').doc(firebaseUser.uid).get();

    /// Define Map Data
    Map<String, dynamic> data = Map<String, dynamic>();

    /// Assign Data
    data = userDocument.data() as Map<String, dynamic>;

    /// Has Address Field
    if (data["Address"] != null) {
      print("Has Address Field");
      if (data["Address"].length > 0) {
        print("This has other address");
        List<dynamic> finalList = [];

        for (int i = 0; i < data["Address"].length; ++i) {
          int targetIndex = data["Address"].length;

          /// Assign Data
          AddressClass tempAddress = new AddressClass(
            addressDetails: data["Address"][i]["Address_Details"],
            state: data["Address"][i]["State"],
            city: data["Address"][i]["City"],
            country: data["Address"][i]["Country"],
            fullName: data["Address"][i]["Full_Name"],
            label: data["Address"][i]["Label"],
            phone: data["Address"][i]["Phone"],
            postcode: data["Address"][i]["Postcode"],
            latitude: data["Address"][i]["Latitude"],
            longitude: data["Address"][i]["Longitude"],
          );

          /// Add to List
          finalList.add(tempAddress.toMap());

          /// Reach Last Index
          if (i == data["Address"].length - 1) {
            /// Assign Data
            AddressClass tempAddress = new AddressClass(
              addressDetails: _addressDetailController.text,
              state: currentState,
              city: _cityController.text,
              country: 'Malaysia',
              fullName: _fullNameController.text,
              label: _addressLabelController.text,
              phone: _phoneController.text,
              postcode: _postcodeController.text,
              latitude: addressLatitude,
              longitude: addressLongitude,
            );

            /// Add to List
            finalList.add(tempAddress.toMap());

            await FirebaseFirestore.instance
                .collection("Customers")
                .doc(firebaseUser.uid)
                .update({
              'Address': finalList,
            }).then((value) async {
              print("Added Address on user: " + firebaseUser.uid);
              print("Index: " + targetIndex.toString());
              loading = false;
              if (this.mounted) {
                setState(() {});
              }

              /// Message
              showMessage(
                "",
                'Address Saved',
                _deviceDetails,
                context,
              );
            });
          }
        }
      }

      /// Has Address Field but array Length is 0
      else {
        print("No Length");
        // region Assign & Add
        /// Assign Data
        AddressClass tempAddress = new AddressClass(
          addressDetails: _addressDetailController.text,
          state: currentState,
          city: _cityController.text,
          country: 'Malaysia',
          fullName: _fullNameController.text,
          label: _addressLabelController.text,
          phone: _phoneController.text,
          postcode: _postcodeController.text,
          latitude: addressLatitude,
          longitude: addressLongitude,
        );

        List<dynamic> finalList = <dynamic>[];

        finalList.add(tempAddress.toMap());
        await FirebaseFirestore.instance
            .collection("Customers")
            .doc(firebaseUser.uid)
            .update({
          'Address': finalList,
        }).then((value) async {
          print("Added Address on user: " + firebaseUser.uid);
          print("Index: " + 0.toString());
          loading = false;
          if (this.mounted) {
            setState(() {});
          }

          /// Message
          showMessage(
            "",
            'Address Saved',
            _deviceDetails,
            context,
          );
        });
        // endregion
      }
    }

    /// No Address field
    else {
      print("No Address Field");
      // region Assign & Add
      /// Assign Data
      AddressClass tempAddress = new AddressClass(
        addressDetails: _addressDetailController.text,
        state: currentState,
        city: _cityController.text,
        country: 'Malaysia',
        fullName: _fullNameController.text,
        label: _addressLabelController.text,
        phone: _phoneController.text,
        postcode: _postcodeController.text,
        latitude: addressLatitude,
        longitude: addressLongitude,
      );

      List<dynamic> finalList = <dynamic>[];

      finalList.add(tempAddress.toMap());
      await FirebaseFirestore.instance
          .collection("Customers")
          .doc(firebaseUser.uid)
          .update({
        'Address': finalList,
      }).then((value) async {
        print("Added Address on user: " + firebaseUser.uid);
        print("Index: " + 0.toString());
        loading = false;
        setState(() {});

        /// Message
        showMessage(
          "",
          'Address Saved',
          _deviceDetails,
          context,
        );
      });
      // endregion
    }
  }

  /// Update Address
  void updateToDefaultAddress(DeviceDetails _deviceDetails) async {
    loading = true;
    setState(() {});

    DocumentSnapshot userDocument;
    userDocument =
        await firestore.collection('Customers').doc(firebaseUser.uid).get();

    /// Define Map Data
    Map<String, dynamic> data = Map<String, dynamic>();

    /// Assign Data
    data = userDocument.data() as Map<String, dynamic>;

    /// Has Address Field
    if (data["Address"] != null) {
      print("Has Address Field");
      if (data["Address"].length > 0) {
        print("This has other address");
        List<dynamic> finalList = [];

        for (int i = 0; i < data["Address"].length; ++i) {
          /// Add to first index
          if (i == 0) {
            /// Assign the current field to class
            AddressClass tempAddress = new AddressClass(
              addressDetails: _addressDetailController.text,
              state: currentState,
              city: _cityController.text,
              country: 'Malaysia',
              fullName: _fullNameController.text,
              label: _addressLabelController.text,
              phone: _phoneController.text,
              postcode: _postcodeController.text,
              latitude: addressLatitude,
              longitude: addressLongitude,
            );

            /// Assign Data
            AddressClass dataAddress = new AddressClass(
              addressDetails: data["Address"][i]["Address_Details"],
              state: data["Address"][i]["State"],
              city: data["Address"][i]["City"],
              country: data["Address"][i]["Country"],
              fullName: data["Address"][i]["Full_Name"],
              label: data["Address"][i]["Label"],
              phone: data["Address"][i]["Phone"],
              postcode: data["Address"][i]["Postcode"],
              latitude: data["Address"][i]["Latitude"],
              longitude: data["Address"][i]["Longitude"],
            );

            /// Add the default address first
            finalList.add(tempAddress.toMap());

            finalList.add(dataAddress.toMap());
          }

          /// Dont add current
          else {
            /// Assign Data
            AddressClass tempAddress = new AddressClass(
              addressDetails: data["Address"][i]["Address_Details"],
              state: data["Address"][i]["State"],
              city: data["Address"][i]["City"],
              country: data["Address"][i]["Country"],
              fullName: data["Address"][i]["Full_Name"],
              label: data["Address"][i]["Label"],
              phone: data["Address"][i]["Phone"],
              postcode: data["Address"][i]["Postcode"],
              latitude: data["Address"][i]["Latitude"],
              longitude: data["Address"][i]["Longitude"],
            );

            /// Add to List
            finalList.add(tempAddress.toMap());
          }

          /// Reach Last Index (Update Data)
          if (i == data["Address"].length - 1) {
            await FirebaseFirestore.instance
                .collection("Customers")
                .doc(firebaseUser.uid)
                .update({
              'Address': finalList,
            }).then((value) async {
              print("Added Address on user: " + firebaseUser.uid);
              print("Index: " + 0.toString());
              loading = false;
              setState(() {});

              /// Message
              showMessage(
                "",
                'Address Updated',
                _deviceDetails,
                context,
              );
            });
          }
        }
      }

      /// Has Address Field but array Length is 0
      else {
        print("No Length");
        // region Assign & Add
        /// Assign Data
        AddressClass tempAddress = new AddressClass(
          addressDetails: _addressDetailController.text,
          state: currentState,
          city: _cityController.text,
          country: 'Malaysia',
          fullName: _fullNameController.text,
          label: _addressLabelController.text,
          phone: _phoneController.text,
          postcode: _postcodeController.text,
          latitude: addressLatitude,
          longitude: addressLongitude,
        );

        List<dynamic> finalList = <dynamic>[];

        finalList.add(tempAddress.toMap());
        await FirebaseFirestore.instance
            .collection("Customers")
            .doc(firebaseUser.uid)
            .update({
          'Address': finalList,
        }).then((value) async {
          print("Added Address on user: " + firebaseUser.uid);
          print("Index: " + 0.toString());
          loading = false;
          setState(() {});

          /// Message
          showMessage(
            "",
            'Address Saved',
            _deviceDetails,
            context,
          );
        });
        // endregion
      }
    }

    /// No Address field
    else {
      print("No Address Field");
      // region Assign & Add
      /// Assign Data
      AddressClass tempAddress = new AddressClass(
        addressDetails: _addressDetailController.text,
        state: currentState,
        city: _cityController.text,
        country: 'Malaysia',
        fullName: _fullNameController.text,
        label: _addressLabelController.text,
        phone: _phoneController.text,
        postcode: _postcodeController.text,
        latitude: addressLatitude,
        longitude: addressLongitude,
      );

      List<dynamic> finalList = <dynamic>[];

      finalList.add(tempAddress.toMap());
      await FirebaseFirestore.instance
          .collection("Customers")
          .doc(firebaseUser.uid)
          .update({
        'Address': finalList,
      }).then((value) async {
        print("Added Address on user: " + firebaseUser.uid);
        print("Index: " + 0.toString());
        loading = false;
        setState(() {});

        /// Message
        showMessage(
          "",
          'Address Saved',
          _deviceDetails,
          context,
        );
      });
      // endregion
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
  // endregion

  @override
  Widget build(BuildContext context) {
    WidgetSizeCalculation _widgetSize = WidgetSizeCalculation(context);
    DeviceDetails _deviceDetails = DeviceDetails(context);

    return Scaffold(
      appBar: _getCustomAppBar("Add Address", _widgetSize, _deviceDetails),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: getPageContent(_deviceDetails, _widgetSize),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getPageContent(
    DeviceDetails _deviceDetails,
    WidgetSizeCalculation _widgetSize,
  ) {
    List<Widget> pageContent = [];
    var paddingLeftRight = _widgetSize.getResponsiveWidth(0.1, 0.1, 0.1);

    /// Register UI
    pageContent.add(
      Padding(
        padding: EdgeInsets.fromLTRB(
            paddingLeftRight,
            _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
            paddingLeftRight,
            0),
        child: getRegisterUI(_deviceDetails, _widgetSize),
      ),
    );

    /// Spacing
    pageContent.add(SizedBox(
      height: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
    ));

    /// Default Radio
    pageContent.add(Container(
      padding: EdgeInsets.fromLTRB(
        paddingLeftRight,
        0,
        paddingLeftRight,
        0,
      ),
      child: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          setState(() {
            if (isDefault == false) {
              isDefault = true;
              print("Default address is true");
            } else if (isDefault == true) {
              isDefault = false;
              print("Default address is false");
            }
          });
        },
        child: Row(
          children: [
            if (isDefault == false)
              Icon(Icons.radio_button_unchecked,
                  color: Theme.of(context).primaryColor),
            if (isDefault == true)
              Icon(Icons.radio_button_checked,
                  color: Theme.of(context).highlightColor),
            SizedBox(width: 15),
            Text(
              "Set this as Default Address",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ));

    /// Spacing
    pageContent.add(SizedBox(
      height: _widgetSize.getResponsiveWidth(0.05, 0.05, 0.05),
    ));

    /// Sign up
    pageContent.add(
      getSaveButtonUI(_deviceDetails, _widgetSize),
    );

    /// Spacing
    pageContent.add(SizedBox(
      height: _widgetSize.getResponsiveHeight(0.2, 0.2, 0.2),
    ));

    return pageContent;
  }

  bool successValidate() {
    bool temp = false;

    if (_fullNameController.text.isEmpty) {
      _fullNameError = true;
    } else if (_phoneController.text.isEmpty) {
      _phoneError = true;
    } else if (_addressDetailController.text.isEmpty) {
      _addressDetailsError = true;
    } else if (_postcodeController.text.isEmpty) {
      _postcodeError = true;
    } else if (currentState == defaultState) {
      showSnackBar("Please Select a State");
    } else if (_cityController.text.isEmpty) {
      _cityError = true;
    } else if (_addressLabelController.text.isEmpty) {
      _addressLabelError = true;
    }
    // endregion

    else {
      _fullNameError = false;
      _phoneError = false;
      _addressDetailsError = false;
      _postcodeError = false;
      _cityError = false;
      _addressLabelError = false;
      temp = true;
    }

    return temp;
  }
}
